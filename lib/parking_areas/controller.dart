import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/parking_areas/view.dart';
import 'package:luvpark/routes/routes.dart';

import '../custom_widgets/alert_dialog.dart';
import '../functions/functions.dart';
import '../http/http_request.dart';

class ParkingAreasController extends GetxController {
  ParkingAreasController();
  bool isInternetConnected = true;
  final dataNearest = Get.arguments["data"];
  final balanceData = Get.arguments["balance"];
  final Function callback = Get.arguments["callback"];
  RxList searchedZone = [].obs;
  RxList markerData = [].obs;
  RxList amenitiesData = [].obs;
  RxList parkingRatesData = [].obs;
  RxList vehicleTypes = [].obs;
  RxList ratesWidget = <Widget>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadDisplay = true.obs;
  RxBool isOpenParking = false.obs;
  RxInt denoInd = 0.obs;
  Timer? debounce;
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

  @override
  void onInit() {
    initializeData();

    super.onInit();
  }

  initializeData() async {
    Future.delayed(Duration(seconds: 1), () {
      initData(dataNearest);
    });
  }

  void onSearch(String value) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    List subData = dataNearest;
    subData = dataNearest.where((e) {
      return e["park_area_name"]
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase()) ||
          e["address"].toString().toLowerCase().contains(value.toLowerCase());
    }).toList();

    Duration duration = const Duration(seconds: 2);
    debounce = Timer(duration, () {
      Future.delayed(Duration(milliseconds: 200), () {
        initData(subData);
      });
    });

    update();
  }

  void onListTap(bool load) {
    isLoading.value = load;
    update();
  }

  String getIconAssetForPwd(String parkingTypeCode, String vehicleTypes) {
    switch (parkingTypeCode) {
      case "S":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
          return 'assets/dashboard_icon/street/cmp_street.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/street/motor_pwd_street.png';
        } else {
          return 'assets/dashboard_icon/street/car_pwd_street.png';
        }
      case "P":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
          return 'assets/dashboard_icon/private/cmp_private.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/private/motor_pwd_private.png';
        } else {
          return 'assets/dashboard_icon/private/car_pwd_private.png';
        }
      case "C":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
          return 'assets/dashboard_icon/commercial/cmp_commercial.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/commercial/motor_pwd_commercial.png';
        } else {
          return 'assets/dashboard_icon/commercial/car_pwd_commercial.png';
        }
      default:
        return 'assets/dashboard_icon/valet/valet.png';
    }
  }

  String getIconAssetForNonPwd(String parkingTypeCode, String vehicleTypes) {
    switch (parkingTypeCode) {
      case "S":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
          return 'assets/dashboard_icon/street/car_motor_street.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/street/motor_street.png';
        } else {
          return 'assets/dashboard_icon/street/car_street.png';
        }
      case "P":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
          return 'assets/dashboard_icon/private/car_motor_private.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/private/motor_private.png';
        } else {
          return 'assets/dashboard_icon/private/car_private.png';
        }
      case "C":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
          return 'assets/dashboard_icon/commercial/car_motor_commercial.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/commercial/motor_commercial.png';
        } else {
          return 'assets/dashboard_icon/commercial/car_commercial.png';
        }
      case "V":
        return 'assets/dashboard_icon/valet/valet.png'; // Valet
      default:
        return 'assets/dashboard_icon/default.png'; // Fallback icon
    }
  }

  String formatTime(String time) {
    return "${time.substring(0, 2)}:${time.substring(2)}";
  }

  void initData(List data) async {
    FocusManager.instance.primaryFocus!.unfocus();
    isLoadDisplay.value = true;

    List<Future<Map<String, dynamic>>> futures =
        data.map<Future<Map<String, dynamic>>>((e) async {
      String finalSttime = formatTime(e["start_time"]);
      String finalEndtime = formatTime(e["end_time"]);
      bool isOpen =
          await Functions.checkAvailability(finalSttime, finalEndtime);
      e["is_open"] = isOpen; // Update the parking availability

      return e;
    }).toList();

    List<Map<String, dynamic>> results = await Future.wait(futures);

    searchedZone.value = results;
    isLoadDisplay.value = false;
  }

  void clearSearch() {
    initData(dataNearest);
  }

  String getIconAssetForPwdDetails(
      String parkingTypeCode, String vehicleTypes) {
    switch (parkingTypeCode) {
      case "S":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
          return 'assets/details_logo/blue/blue_cmp.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/blue/blue_mp.svg';
        } else {
          return 'assets/details_logo/blue/blue_cp.svg';
        }
      case "P":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
          return 'assets/details_logo/orange/orange_cmp.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/orange/orange_mp.svg';
        } else {
          return 'assets/details_logo/orange/orange_cp.svg';
        }
      case "C":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
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
            vehicleTypes.contains("Cars")) {
          return 'assets/details_logo/blue/blue_cm.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/blue/blue_motor.svg';
        } else {
          return 'assets/details_logo/blue/blue_car.svg';
        }
      case "P":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
          return 'assets/details_logo/orange/orange_cm.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/orange/orange_motor.svg';
        } else {
          return 'assets/details_logo/orange/orange_car.svg';
        }
      case "C":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
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

  Future<void> getAmenities(areaData) async {
    final response = await HttpRequest(
            api:
                "${ApiKeys.getParkingAmenities}?park_area_id=${areaData["park_area_id"]}")
        .get();

    if (response == "No Internet") {
      Get.back();
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }

    if (response == null || response["items"] == null) {
      amenitiesData.value = [];
      Get.back();
      CustomDialog().errorDialog(
        Get.context!,
        "Error",
        "Error while connecting to server, Please contact support.",
        () => Get.back(),
      );
      return;
    }
    List<dynamic> item = response["items"];
    item = item.map((element) {
      List<dynamic> icon = iconAmen.where((e) {
        return e["code"] == element["parking_amenity_code"];
      }).toList();
      element["icon"] = icon.isNotEmpty ? icon[0]["icon"] : "no_image";
      return element;
    }).toList();

    if (areaData["park_size"] != null &&
        areaData["park_orientation"].toString().toLowerCase() != "unknown") {
      item.insert(0, {
        "zone_amenity_id": 0,
        "zone_id": 0,
        "parking_amenity_code": "D",
        "parking_amenity_desc":
            "${areaData["park_size"]} ${areaData["park_orientation"]}",
        "icon": "dimension"
      });
    }
    amenitiesData.value = item;

    getParkingRates(areaData["park_area_id"]);
  }

  Future<void> getParkingRates(parkId) async {
    HttpRequest(api: '${ApiKeys.getParkingRates}$parkId')
        .get()
        .then((returnData) async {
      Get.back();
      if (returnData == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (returnData == null) {
        parkingRatesData.value = [];
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData["items"].length > 0) {
        List<dynamic> item = returnData["items"];
        parkingRatesData.value = item;

        goingBackToTheCornerWhenIFirstSawYou();
      } else {
        parkingRatesData.value = [];
        CustomDialog().errorDialog(Get.context!, "luvpark", returnData["msg"],
            () {
          Get.back();
        });
      }
    });
  }

  Future<void> goingBackToTheCornerWhenIFirstSawYou() async {
    final vehicleTypesList = markerData[0]['vehicle_types_list'] as String;

    List inataya = _parseVehicleTypes(vehicleTypesList).map((e) {
      String eName;

      if (e["name"].toString().toLowerCase().contains("cars")) {
        e["vh_types"] = e["name"];
        eName = e["count"].toString().length > 1 ? "Cars" : "Car";
      } else if (e["name"].toString().toLowerCase().contains("motor")) {
        e["vh_types"] = e["name"];
        eName = e["count"].toString().length > 1 ? "Motors" : "Motor";
      } else {
        e["vh_types"] = e["name"];
        eName = e["name"].toString();
      }
      e["vh_types"] = e["name"];
      e["name"] = eName;
      return e;
    }).toList();

    vehicleTypes.value = Functions.sortJsonList(inataya, 'count');

    denoInd.value = 0;

    Map<String, dynamic> paramArg = {
      "markerData": markerData,
      "vehicleTypes": vehicleTypes,
      "amenitiesData": amenitiesData,
      "parkingRatesData": parkingRatesData
    };

    Get.bottomSheet(
      ParkingDetails(dataParam: paramArg),
    );
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
        color = const Color(0xFF21B979);
        iconKey = "scooter";
      } else if (lowerCaseName.contains("cars")) {
        color = const Color(0xFF21B979);
        iconKey = "car";
      } else {
        color = const Color(0xFF21B979);
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

  void onClickBooking(Map<String, dynamic> mData) async {
    CustomDialog().loadingDialog(Get.context!);
    DateTime now = await Functions.getTimeNow();
    bool isOpenPa = await isOpenArea(mData);
    if (!isOpenPa) {
      Get.back();
      CustomDialog().infoDialog("Booking", "This area is currently close.", () {
        Get.back();
      });

      return;
    }

    if (mData["is_allow_reserve"] == "N") {
      Get.back();
      CustomDialog().infoDialog("Not Open to Public Yet",
          "This area is currently unavailable. Please try again later.", () {
        Get.back();
      });

      return;
    }

    if (mData["is_24_hrs"] == "N") {
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

      String ctime = mData["closed_time"].toString().trim();
      String otime = mData["opened_time"].toString().trim();

      if (diffBook(otime) > 30) {
        Get.back();

        DateTime st = DateFormat("HH:mm").parse(otime);
        final DateTime ot =
            DateTime(now.year, now.month, now.day, st.hour, st.minute)
                .subtract(const Duration(minutes: 30));
        String formattedTime = DateFormat.jm().format(ot);

        CustomDialog().infoDialog("Booking",
            "Booking will start at $formattedTime.\nPlease come back later.\nThank you",
            () {
          Get.back();
        });
        return;
      }
      // Convert the difference to minutes
      int minutesClose = getDiff(ctime);

      if (minutesClose <= 0) {
        Get.back();
        CustomDialog().infoDialog(
            "luvpark", "Apologies, but we are closed for bookings right now.",
            () {
          Get.back();
        });
        return;
      }

      if (minutesClose <= 29) {
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

    if (int.parse(mData["res_vacant_count"].toString()) == 0) {
      Get.back();
      CustomDialog().infoDialog("Booking not availabe",
          "There are no available parking spaces at the moment.", () {
        Get.back();
      });
      return;
    }

    if (double.parse(balanceData[0]["amount_bal"].toString()) <
        double.parse(balanceData[0]["min_wallet_bal"].toString())) {
      Get.back();
      CustomDialog().infoDialog(
        "Attention",
        "Your balance is below the required minimum for this feature. "
            "Please ensure a minimum balance of ${balanceData[0]["min_wallet_bal"]} tokens to access the requested service.",
        () {
          Get.back();
        },
      );
      return;
    } else {
      int? userId = await Authentication().getUserId();
      String api =
          "${ApiKeys.getSubscribedVehicle}$userId?park_area_id=${mData["park_area_id"]}";
      final response = await HttpRequest(api: api).get();

      if (response == "No Internet") {
        Get.back();
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (response == null) {
        Get.back();
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      Variables.subsVhList.value = [];
      List<dynamic> items = response["items"];
      if (response["items"].isNotEmpty) {
        for (dynamic dataItem in items) {
          Variables.subsVhList.add(dataItem);
        }
      } else {
        Variables.subsVhList.value = items;
      }

      Functions.computeDistanceResorChckIN(
          Get.context!, LatLng(mData["pa_latitude"], mData["pa_longitude"]),
          (success) {
        Get.back();

        if (success["success"]) {
          Get.toNamed(Routes.booking, arguments: {
            "currentLocation": success["location"],
            "areaData": mData,
            "canCheckIn": success["can_checkIn"],
            "userData": balanceData,
          });
        }
      });
    }
  }

  Future<bool> isOpenArea(mData) async {
    DateTime timeNow = await Functions.getTimeNow();
    Map<String, dynamic> jsonData = mData;
    Map<String, String> jsonDatas = {};
    Iterable<String> keys = jsonData.keys;
    String today = DateFormat('EEEE').format(timeNow).toLowerCase();

    for (var key in keys) {
      if (key.toLowerCase() == today.toLowerCase()) {
        jsonDatas[key] = jsonData[key];
      }
    }
    String value = jsonData[today].toString();
    return value.toLowerCase() == "y" ? true : false;
  }
}
