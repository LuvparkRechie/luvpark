import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/functions/functions.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';
import 'package:luvpark_get/routes/routes.dart';

class ParkingDetailsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final dataNearest = Get.arguments;
  Rx<GoogleMapController?> googleMapController = Rx<GoogleMapController?>(null);
  final DraggableScrollableController dragController =
      DraggableScrollableController();
  late TabController tabController;
  RxList<Widget> carsData = <Widget>[].obs;
  RxBool btnLoading = false.obs;
  RxBool isNetConnected = true.obs;
  RxBool isLoading = true.obs;
  RxBool isOpen = false.obs;
  RxBool isMoreDetails = false.obs;
  RxBool isHideAmen = true.obs;
  RxInt tabIndex = 0.obs;
  RxList<dynamic> amenData = <dynamic>[].obs;
  RxList<dynamic> carsInfo = <dynamic>[].obs;
  RxList<Marker> markers = <Marker>[].obs;
  RxList etaData = [].obs;
  Rx<Polyline> polyline = const Polyline(
    polylineId: PolylineId('dottedPolyLine'),
  ).obs;
  Rx<LatLng> destLoc = const LatLng(0, 0).obs;
  Rx<LatLng> currentLocation = const LatLng(0, 0).obs;
  Rx<CameraPosition> initialPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 12.0, // Default zoom
  ).obs;
  RxList<dynamic> vehicleTypes = <dynamic>[].obs;
  RxList<dynamic> vehicleRates = <dynamic>[].obs;

  List iconAmen = [
    {"code": "D", "icon": "dimension"},
    {"code": "V", "icon": "covered_area"},
    {"code": "C", "icon": "concrete"},
    {"code": "T", "icon": "cctv"},
    {"code": "G", "icon": "grass_area"},
    {"code": "A", "icon": "asphalt"},
    {"code": "S", "icon": "security"},
    {"code": "P", "icon": "pwd"},
    {"code": "XXX", "icon": "no_image"},
  ];

  String finalSttime = "";
  String finalEndtime = "";
  String parkSched = "";

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    goingBackToTheCornerWhenIFirstSawYou();
    refreshAmenData();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _parseVehicleTypes(String vhTpList) {
    final types = vhTpList.split(' | ');
    final parsedTypes = <Map<String, String>>[];
    Color color;

    for (var type in types) {
      final parts = type.split('(');
      if (parts.length < 2) continue;

      final name = parts[0].trim();
      final count = parts[1].split('/')[0].trim();

      final lowerCaseName = name.toLowerCase();
      String iconKey;
      if (lowerCaseName.contains("motorcycle")) {
        color = const Color(0xFFD65F5F);
        iconKey = "scooter";
      } else if (lowerCaseName.contains("trikes")) {
        color = const Color(0xFF21B979);
        iconKey = "car";
      } else {
        color = const Color(0x7F616161);
        iconKey = "delivery";
      }

      final colorString = '#${color.value.toRadixString(16).padLeft(8, '0')}';
      parsedTypes.add({
        'name': name,
        'count': count,
        'color': colorString,
        'icon': iconKey,
      });
    }

    return parsedTypes;
  }

  Future<void> goingBackToTheCornerWhenIFirstSawYou() async {
    final vehicleTypesList = dataNearest['vehicle_types_list'] as String;

    List inataya = _parseVehicleTypes(vehicleTypesList).map((e) {
      String eName;

      if (e["name"].toString().toLowerCase().contains("trikes")) {
        eName = e["count"].toString().length > 1 ? "Cars" : "Car";
      } else if (e["name"].toString().toLowerCase().contains("motor")) {
        eName = e["count"].toString().length > 1 ? "Motors" : "Motor";
      } else {
        eName = e["name"].toString();
      }
      e["name"] = eName;
      return e;
    }).toList();
    inataya = inataya.where((element) {
      return int.parse(element["count"].toString()) != 0;
    }).toList();
    vehicleTypes.value = Functions.sortJsonList(inataya, 'count');
    print("inatay $vehicleTypes");
    finalSttime = formatTime(dataNearest["start_time"]);
    finalEndtime = formatTime(dataNearest["end_time"]);
    isOpen.value = Functions.checkAvailability(finalSttime, finalEndtime);
    destLoc.value =
        LatLng(dataNearest["pa_latitude"], dataNearest["pa_longitude"]);
  }

  String formatTime(String time) {
    return "${time.substring(0, 2)}:${time.substring(2)}";
  }

  Future<void> refreshAmenData() async {
    isNetConnected.value = true;
    isLoading.value = true;
    await getAmenities();
  }

  Future<void> getAmenities() async {
    final response = await HttpRequest(
            api:
                "${ApiKeys.gApiSubFolderGetAmenities}?park_area_id=${dataNearest["park_area_id"]}")
        .get();

    if (response == "No Internet") {
      isNetConnected.value = false;
      CustomDialog().internetErrorDialog(Get.context!, () => Get.back());
      return;
    }

    if (response == null || response["items"] == null) {
      isNetConnected.value = true;
      isLoading.value = false;
      CustomDialog().errorDialog(
        Get.context!,
        "Error",
        "Error while connecting to server, Please contact support.",
        () => Get.back(),
      );
      return;
    }

    if (response["items"].isNotEmpty) {
      List<dynamic> item = response["items"];
      item = item.map((element) {
        List<dynamic> icon = iconAmen.where((e) {
          return e["code"] == element["parking_amenity_code"];
        }).toList();
        element["icon"] = icon.isNotEmpty ? icon[0]["icon"] : "no_image";

        return element;
      }).toList();
      if (dataNearest["park_orientation"] != null) {
        item.insert(0, {
          "zone_amenity_id": 0,
          "zone_id": 0,
          "parking_amenity_code": "D",
          "parking_amenity_desc":
              "${dataNearest["park_size"]} ${dataNearest["park_orientation"]}",
          "icon": "dimension"
        });
      }

      amenData.value = item;
      getParkingRates();
    } else {
      isNetConnected.value = true;
      isLoading.value = false;
      CustomDialog().errorDialog(
        Get.context!,
        "luvpark",
        "No amenities found in this area.",
        () => Get.back(),
      );
    }
  }

  Future<void> getParkingRates() async {
    HttpRequest(
            api:
                '${ApiKeys.gApiSubFolderGetRates}?park_area_id=${dataNearest["park_area_id"]}')
        .get()
        .then((returnData) async {
      if (returnData == "No Internet") {
        isNetConnected.value = false;
        isLoading.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData == null) {
        isNetConnected.value = true;
        isLoading.value = false;
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData["items"].length > 0) {
        List<dynamic> item = returnData["items"];
        vehicleRates.value = item;

        fetchRoute();
      } else {
        isNetConnected.value = true;
        isLoading.value = false;
        CustomDialog().errorDialog(Get.context!, "luvpark", returnData["msg"],
            () {
          Get.back();
        });
      }
    });
  }

  Future<void> fetchRoute() async {
    await Functions.getLocation(Get.context!, (location) async {
      currentLocation.value = location;

      await getCustomMarker([
        {"marker": "my_marker", "loc": currentLocation.value},
        {"marker": "dest_marker", "loc": destLoc.value}
      ]);

      final estimatedData =
          await Functions.fetchETA(currentLocation.value, destLoc.value);
      etaData.value = estimatedData;

      isLoading.value = false;
    });
  }

  Future<void> getCustomMarker(List<Map<String, dynamic>> dataMarker) async {
    final List<Marker> newMarkers = [];
    for (int i = 0; i < dataMarker.length; i++) {
      final data = dataMarker[i];
      final Uint8List bytes = await Variables.capturePng(
        Get.context!,
        printScreen(
            data["marker"], i == 0 ? Colors.white : AppColor.primaryColor),
        30,
        false,
      );

      newMarkers.add(
        Marker(
          markerId: MarkerId(i == 0
              ? "CurrentLocation"
              : dataNearest["park_area_name"].toString()),
          infoWindow: InfoWindow(
              title: i == 0
                  ? "Current Location"
                  : dataNearest["park_area_name"].toString()),
          position: data["loc"],
          // ignore: deprecated_member_use
          icon: BitmapDescriptor.fromBytes(bytes),
        ),
      );
    }

    markers.addAll(newMarkers);
  }

  Widget printScreen(String imgName, Color color) {
    return Container(
      width: 120,
      height: 120,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Image.asset("assets/images/$imgName.png", fit: BoxFit.contain),
      ),
    );
  }

  void onClickBooking() {
    btnLoading.value = true;
    CustomDialog().loadingDialog(Get.context!);
    if (dataNearest["is_allow_reserve"] == "N") {
      btnLoading.value = false;
      Get.back();
      CustomDialog().infoDialog("Booking Unavailable",
          "This area is currently unavailable. Please try again later.", () {
        Get.back();
      });

      return;
    }

    if (dataNearest["is_24_hrs"] == "N") {
      final now = DateTime.now();
      int getDiff(String time) {
        DateTime specifiedTime = DateFormat("HH:mm").parse(time);
        DateTime todaySpecifiedTime = DateTime(now.year, now.month, now.day,
            specifiedTime.hour, specifiedTime.minute);
        Duration difference = todaySpecifiedTime.difference(now);
        return difference.inMinutes;
      }

      int diffBook(time) {
        DateTime specifiedTime = DateFormat("HH:mm").parse(time);
        final DateTime openingTime = DateTime(now.year, now.month, now.day,
            specifiedTime.hour, specifiedTime.minute); // Opening at 2:30 PM

        int diff = openingTime.difference(now).inMinutes;

        return diff;
      }

      String ctime = dataNearest["closed_time"].toString().trim();
      String otime = dataNearest["opened_time"].toString().trim();

      if (diffBook(otime) > 30) {
        btnLoading.value = false;
        Get.back();

        DateTime st = DateFormat("HH:mm").parse(otime);
        final DateTime ot =
            DateTime(now.year, now.month, now.day, st.hour, st.minute)
                .subtract(Duration(minutes: 30));
        String formattedTime = DateFormat.jm().format(ot);

        CustomDialog().infoDialog("Booking Policy",
            "Booking will start at $formattedTime.\nPlease come back later.\nThank you",
            () {
          Get.back();
        });
        return;
      }
      // Convert the difference to minutes
      int minutesClose = getDiff(ctime);

      if (minutesClose <= 0) {
        btnLoading.value = false;
        Get.back();
        CustomDialog().infoDialog(
            "luvpark", "Apologies, but we are closed for bookings right now.",
            () {
          Get.back();
        });
        return;
      }

      if (minutesClose <= 29) {
        btnLoading.value = false;
        Get.back();
        CustomDialog().errorDialog(
          Get.context!,
          "luvpark",
          "You cannot make a booking within 30 minutes of our closing time.",
          () {
            Get.back();
          },
        );
        return;
      }
    }

    Functions.getUserBalance(Get.context!, (dataBalance) async {
      final userdata = dataBalance[0];
      final items = userdata["items"];

      if (userdata["success"]) {
        if (double.parse(items[0]["amount_bal"].toString()) <
            double.parse(items[0]["min_wallet_bal"].toString())) {
          btnLoading.value = false;
          Get.back();
          CustomDialog().errorDialog(
            Get.context!,
            "Attention",
            "Your balance is below the required minimum for this feature. "
                "Please ensure a minimum balance of ${items[0]["min_wallet_bal"]} tokens to access the requested service.",
            () {
              Get.back();
            },
          );
          return;
        } else {
          Functions.computeDistanceResorChckIN(Get.context!, destLoc.value,
              (success) {
            btnLoading.value = false;
            Get.back();
            if (success["success"]) {
              Get.toNamed(Routes.booking, arguments: {
                "currentLocation": success["location"],
                "areaData": dataNearest,
                "canCheckIn": success["can_checkIn"],
                "userData": items,
              });
            }
          });
        }
      } else {
        btnLoading.value = false;
        Get.back();
      }
    });
  }

  String getIconAssetForPwdDetails(
      String parkingTypeCode, String vehicleTypes) {
    switch (parkingTypeCode) {
      case "S":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/details_logo/blue/blue_cmp.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/blue/blue_mp.svg';
        } else {
          return 'assets/details_logo/blue/blue_cp.svg';
        }
      case "P":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/details_logo/orange/orange_cmp.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/orange/orange_mp.svg';
        } else {
          return 'assets/details_logo/orange/orange_cp.svg';
        }
      case "C":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/details_logo/green/green_cmp.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/green/green_mp.svg';
        } else {
          return 'assets/details_logo/green/green_cp.svg';
        }
      default:
        return 'assets/details_logo/violet/violet.svg'; // Valet
    }
  }

  String getIconAssetForNonPwdDetails(
      String parkingTypeCode, String vehicleTypes) {
    switch (parkingTypeCode) {
      case "S":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/details_logo/blue/blue_cm.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/blue/blue_motor.svg';
        } else {
          return 'assets/details_logo/blue/blue_car.svg';
        }
      case "P":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/details_logo/orange/orange_cm.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/orange/orange_motor.svg';
        } else {
          return 'assets/details_logo/orange/orange_car.svg';
        }
      case "C":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/details_logo/green/green_cm.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/green/green_motor.svg';
        } else {
          return 'assets/details_logo/green/green_car.svg';
        }
      case "V":
        return 'assets/details_logo/violet/violet.svg'; // Valet
      default:
        return 'assets/images/no_image.png'; // Fallback icon
    }
  }
}
