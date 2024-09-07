import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/showup_animation.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/functions/functions.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';
import 'package:luvpark_get/location_auth/location_auth.dart';
import 'package:luvpark_get/mapa/utils/legend/legend_dialog.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'utils/suggestions/suggestions.dart';

// ignore: deprecated_member_use
class DashboardMapController extends GetxController
    with GetTickerProviderStateMixin {
  RxBool isOpenDial = false.obs;
  // Dependencies
  final GlobalKey<ScaffoldState> dashboardScaffoldKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey headerKey = GlobalKey();
  final TextEditingController searchCon = TextEditingController();
  final PanelController panelController = PanelController();
  late AnimationController animationController;
  late AnimationController animationDialController;
  late Animation<Offset> slideAnimation;
  RxBool isSidebarVisible = false.obs;
  GoogleMapController? gMapController;
  CameraPosition? initialCameraPosition;
  RxList<Marker> markers = <Marker>[].obs;
  RxList<dynamic> userBal = <dynamic>[].obs;
  RxList<dynamic> dataNearest = [].obs;
  RxList<dynamic> dialogData = [].obs;
  //drawerdata
  var userProfile;
  Circle circle = const Circle(circleId: CircleId('dottedCircle'));
  RxList suggestions = [].obs;
  RxString myProfPic = "".obs;
  Polyline polyline = const Polyline(
    polylineId: PolylineId('dottedPolyLine'),
  );

  LatLng searchCoordinates = const LatLng(0, 0);

//PIn icon
  List<String> searchImage = ['assets/dashboard_icon/location_pin.png'];

  // Configuration Variables
  String? ddRadius = "10";
  String pTypeCode = "";
  String amenities = "";
  String vtypeId = "";
  RxString addressText = "".obs;
  String isAllowOverNight = "";
  RxString myName = "".obs;
  // State Variables
  RxBool netConnected = true.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingMap = true.obs;
  RxBool isGetNearData = false.obs;
  RxBool isMarkerTapped = false.obs;
  //Panel variables
  RxDouble headerHeight = 0.0.obs;
  RxDouble minHeight = 0.0.obs;
  RxBool isClearSearch = true.obs;
  //Last Booking variables
  RxBool hasLastBooking = false.obs;
  RxBool isSearch = false.obs;
  RxString plateNo = "".obs;
  RxString brandName = "".obs;

  @override
  void onInit() {
    super.onInit();

    ddRadius = "10";
    pTypeCode = "";
    amenities = "";
    vtypeId = "";
    addressText = "".obs;
    isAllowOverNight = "";
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animationDialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0), // Start off-screen to the left
      end: Offset.zero, // End at the screen edge
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    getLastBooking();
    getUserData(false);
  }

  @override
  void dispose() {
    super.dispose();
    gMapController!.dispose();
    animationDialController.dispose();
    animationController.dispose();
  }

  void toggleSpeedDial() {
    isOpenDial.value = !isOpenDial.value;
    if (isOpenDial.value) {
      animationDialController.forward();
    } else {
      animationDialController.reverse();
    }
  }

  //Get last available booking
  Future<void> getLastBooking() async {
    dynamic data = await Authentication().getLastBooking();
    if (data.isEmpty || data == null) {
      hasLastBooking.value = false;
    } else {
      hasLastBooking.value = true;
      plateNo.value = data["plate_no"];
      brandName.value = data["brand_name"];
    }
  }

  //Book now last booking
  Future<void> bookNow() async {
    CustomDialog().loadingDialog(Get.context!);
    final data = await Authentication().getLastBooking();

    List lastBooking = dataNearest;
    lastBooking = lastBooking.where((e) {
      return int.parse(e["park_area_id"].toString()) ==
          int.parse(data["park_area_id"].toString());
    }).toList();

    LatLng destLoc =
        LatLng(lastBooking[0]["pa_latitude"], lastBooking[0]["pa_longitude"]);
    if (lastBooking[0]["is_allow_reserve"] == "N") {
      Get.back();
      CustomDialog().errorDialog(
        Get.context!,
        "LuvPark",
        "This area is not available at the moment.",
        () {
          Get.back();
        },
      );
      return;
    }

    Functions.getUserBalance(Get.context!, (dataBalance) async {
      final userdata = dataBalance[0];
      final items = userdata["items"];

      if (userdata["success"]) {
        if (double.parse(items[0]["amount_bal"].toString()) <
            double.parse(items[0]["min_wallet_bal"].toString())) {
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
          Functions.computeDistanceResorChckIN(Get.context!, destLoc,
              (success) {
            Get.back();
            if (success["success"]) {
              Get.toNamed(Routes.booking, arguments: {
                "currentLocation": success["location"],
                "areaData": lastBooking[0],
                "canCheckIn": success["can_checkIn"],
                "userData": items,
              });
            }
          });
        }
      } else {
        Get.back();
      }
    });
  }

  //Book marker dialog
  Future<void> bookMarkerNow(data) async {
    CustomDialog().loadingDialog(Get.context!);

    LatLng destLoc = LatLng(data[0]["pa_latitude"], data[0]["pa_longitude"]);
    if (data[0]["is_allow_reserve"] == "N") {
      Get.back();
      CustomDialog().errorDialog(
        Get.context!,
        "LuvPark",
        "This area is not available at the moment.",
        () {
          Get.back();
        },
      );
      return;
    }

    Functions.getUserBalance(Get.context!, (dataBalance) async {
      final userdata = dataBalance[0];
      final items = userdata["items"];

      if (userdata["success"]) {
        if (double.parse(items[0]["amount_bal"].toString()) <
            double.parse(items[0]["min_wallet_bal"].toString())) {
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
          Functions.computeDistanceResorChckIN(Get.context!, destLoc,
              (success) {
            Get.back();
            if (success["success"]) {
              Get.toNamed(Routes.booking, arguments: {
                "currentLocation": success["location"],
                "areaData": data[0],
                "canCheckIn": success["can_checkIn"],
                "userData": items,
              });
            }
          });
        }
      } else {
        Get.back();
      }
    });
  }

  //get curr location
  Future<void> getCurrentLoc() async {
    ddRadius = "10";
    pTypeCode = "";
    amenities = "";
    vtypeId = "";
    addressText = "".obs;
    isAllowOverNight = "";
    isOpenDial.value = false;
    animationDialController.value = 0.0;

    getUserData(false);
  }

  //get curr location
  Future<void> getFilterNearest(data) async {
    ddRadius = data[0]["radius"];
    pTypeCode = data[0]["park_type"];
    amenities = data[0]["amen"];
    vtypeId = data[0]["vh_type"];
    isAllowOverNight = data[0]["ovp"];

    getUserData(false);
  }

  //toggle
  void toggleSidebar() {
    if (isSidebarVisible.value) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
    isSidebarVisible.value = !isSidebarVisible.value;
  }

//MAP SETUP
  void onMapCreated(GoogleMapController controller) {
    DefaultAssetBundle.of(Get.context!)
        .loadString('assets/custom_map_style/map_style.json')
        .then((String style) {
      controller.setMapStyle(style);
    });
    gMapController = controller;
    animateCamera();
  }

  void onCameraMoveStarted() {
    if (isMarkerTapped.value) return;

    isGetNearData.value = false;
  }

  void onCameraIdle() async {
    String? address = await Functions.getAddress(
      initialCameraPosition!.target.latitude,
      initialCameraPosition!.target.longitude,
    );

    addressText.value = address!;

    initialCameraPosition = CameraPosition(
      target: LatLng(initialCameraPosition!.target.latitude,
          initialCameraPosition!.target.longitude),
      zoom: 16,
      tilt: 0,
      bearing: 0,
    );
    polyline = Polyline(
      polylineId: const PolylineId('dottedCircle'),
      color: AppColor.mainColor,
      width: 4,
      patterns: [
        PatternItem.dash(20),
        PatternItem.gap(20),
      ],
      points: List<LatLng>.generate(
        360,
        (index) => calculateNewCoordinates(
          initialCameraPosition!.target.latitude,
          initialCameraPosition!.target.longitude,
          200,
          double.parse(
            index.toString(),
          ),
        ),
      ),
    );
    if (isMarkerTapped.value) return;
    isGetNearData.value = true;
  }

  void animateCamera() {
    if (gMapController != null) {
      gMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(initialCameraPosition!.target.latitude,
                  initialCameraPosition!.target.longitude),
              zoom: dataNearest.isEmpty ? 15 : 17),
        ),
      );
    }
  }

  void onDrawerOpen() async {
    String? userData = await Authentication().getUserData();
    final item = await Authentication().getUserData2();
    final profPic = await Authentication().getUserProfilePic();

    userProfile = item;
    myProfPic.value = profPic;

    userProfile = item;
    if (jsonDecode(userData!)["first_name"] == null) {
      myName.value = "";
    } else {
      myName.value = jsonDecode(userData)["first_name"];
    }
    update();
  }

//END OF MAP SETUP
  void getUserData(isSearch) async {
    isLoading.value = true;
    isLoadingMap.value = true;

    String? userData = await Authentication().getUserData();
    final item = await Authentication().getUserData2();
    final profPic = await Authentication().getUserProfilePic();

    userProfile = item;
    myProfPic.value = profPic;

    userProfile = item;
    if (jsonDecode(userData!)["first_name"] == null) {
      myName.value = "";
    } else {
      myName.value = jsonDecode(userData)["first_name"];
    }

    LocationService.grantPermission(Get.context!, (isGranted) {
      if (isGranted) {
        Functions.getUserBalance(Get.context!, (dataBalance) async {
          userBal.value = dataBalance[0]["items"];
          if (!dataBalance[0]["has_net"]) {
            netConnected.value = false;
            isLoading.value = false;
            isLoadingMap.value = false;
          } else {
            isLoading.value = false;
            if (isSearch) {
              getNearest(dataBalance[0]["items"], searchCoordinates);
            } else {
              List ltlng = await Functions.getCurrentPosition();
              LatLng coordinates = LatLng(ltlng[0]["lat"], ltlng[0]["long"]);
              searchCoordinates = coordinates;
              getNearest(dataBalance[0]["items"], coordinates);
            }
          }
        });
      } else {
        isLoading.value = true;
        Get.toNamed(Routes.permission);
      }
    });
  }

  void getNearest(List<dynamic> uData, LatLng coordinates) async {
    String params =
        "${ApiKeys.gApiSubFolderGetNearestSpace}?is_allow_overnight=$isAllowOverNight&parking_type_code=$pTypeCode&latitude=${coordinates.latitude}&longitude=${coordinates.longitude}&radius=$ddRadius&parking_amenity_code=$amenities&vehicle_type_id=$vtypeId";

    try {
      var returnData = await HttpRequest(api: params).get();
      if (returnData == "No Internet") {
        handleNoInternet();
        return;
      }
      if (returnData == null) {
        handleServerError();
        return;
      }
      if (returnData["items"].isEmpty) {
        handleNoParkingFound();
        return;
      }

      handleData(returnData, uData, coordinates);
    } catch (e) {
      handleServerError();
    }
  }

  void handleNoInternet() {
    netConnected.value = false;
    isLoadingMap.value = true;
    CustomDialog().internetErrorDialog(Get.context!, () {
      Get.back();
    });
  }

  void handleServerError() {
    netConnected.value = true;
    isLoadingMap.value = false;
    CustomDialog().errorDialog(Get.context!, "Internet Error",
        "Error while connecting to server, Please contact support.", () {
      Get.back();
    });
  }

  void handleNoParkingFound() {
    netConnected.value = true;
    isLoadingMap.value = false;
    initialCameraPosition = CameraPosition(
      target: searchCoordinates,
      zoom: 16,
      tilt: 0,
      bearing: 0,
    );
    markers.clear();
    bool isDouble = ddRadius!.contains(".");
    CustomDialog().errorDialog(Get.context!, "Luvpark",
        "No parking area found within \n${(isDouble ? double.parse(ddRadius!) : int.parse(ddRadius!)) >= 1 ? '${ddRadius!} Km' : '${double.parse(ddRadius!) * 1000} meters'}, please change location.",
        () {
      Get.back();
    });
  }

  void handleData(
      dynamic returnData, List<dynamic> uData, LatLng coordinates) async {
    final Uint8List availabeMarkIcons =
        await Functions.getSearchMarker(searchImage[0], 100);
    markers.clear();

    if (double.parse(uData[0]["amount_bal"].toString()) >=
        double.parse(uData[0]["min_wallet_bal"].toString())) {
      initialCameraPosition = CameraPosition(
        target: coordinates,
        zoom: uData.isEmpty ? 14 : 17,
        tilt: 0,
        bearing: 0,
      );
      circle = Circle(
        circleId: const CircleId('dottedCircle'),
        center: LatLng(initialCameraPosition!.target.latitude,
            initialCameraPosition!.target.longitude),
        radius: 200,
        strokeWidth: 0,
        fillColor: AppColor.primaryColor.withOpacity(.03),
      );
      polyline = Polyline(
        polylineId: const PolylineId('dottedCircle'),
        color: AppColor.primaryColor,
        width: 2,
        patterns: [
          PatternItem.dash(20),
          PatternItem.gap(20),
        ],
        points: List<LatLng>.generate(
            360,
            (index) => calculateNewCoordinates(
                initialCameraPosition!.target.latitude,
                initialCameraPosition!.target.longitude,
                200,
                double.parse(index.toString()))),
      );
      markers.add(
        Marker(
          // ignore: deprecated_member_use
          consumeTapEvents: true,
          infoWindow: InfoWindow(title: "Current"),
          // ignore: deprecated_member_use
          icon: BitmapDescriptor.fromBytes(availabeMarkIcons),
          markerId: MarkerId(0.toString()),
          position: coordinates,
        ),
      );

      buildMarkers(returnData["items"]);
      netConnected.value = true;
      isLoadingMap.value = false;
      bool isShowPopUp = await Authentication().getPopUpNearest();
      if (dataNearest.isNotEmpty && !isShowPopUp) {
        Future.delayed(const Duration(seconds: 1), () {
          Authentication().setShowPopUpNearest(true);

          showLegend(() {
            showNearestSuggestDialog();
          });
        });
      }
    }

    update();
  }

  String getIconAssetForPwd(String parkingTypeCode, String vehicleTypes) {
    switch (parkingTypeCode) {
      case "S":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/dashboard_icon/street/cmp_street.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/street/motor_pwd_street.png';
        } else {
          return 'assets/dashboard_icon/street/car_pwd_street.png';
        }
      case "P":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/dashboard_icon/private/cmp_private.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/private/motor_pwd_private.png';
        } else {
          return 'assets/dashboard_icon/private/car_pwd_private.png';
        }
      case "C":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
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
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/dashboard_icon/street/car_motor_street.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/street/motor_street.png';
        } else {
          return 'assets/dashboard_icon/street/car_street.png';
        }
      case "P":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/dashboard_icon/private/car_motor_private.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/private/motor_private.png';
        } else {
          return 'assets/dashboard_icon/private/car_private.png';
        }
      case "C":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
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

  Future<void> buildMarkers(data) async {
    dataNearest.value = data;
    int ctr = 0;

    if (dataNearest.isNotEmpty) {
      for (int i = 0; i < dataNearest.length; i++) {
        ctr++;
        var items = dataNearest[i];

        final String isPwd = items["is_pwd"] ?? "N";
        final String vehicleTypes = items["vehicle_types_list"];

        String iconAsset;
        // Determine the iconAsset based on parking type and PWD status
        if (isPwd == "Y") {
          iconAsset =
              getIconAssetForPwd(items["parking_type_code"], vehicleTypes);
        } else {
          iconAsset =
              getIconAssetForNonPwd(items["parking_type_code"], vehicleTypes);
        }

        final Uint8List markerIcon =
            await Variables.getBytesFromAsset(iconAsset, 0.5);

        markers.add(
          Marker(
            // ignore: deprecated_member_use

            infoWindow: InfoWindow(title: items["park_area_name"]),
            // ignore: deprecated_member_use
            icon: BitmapDescriptor.fromBytes(markerIcon),
            markerId: MarkerId(ctr.toString()),
            position: LatLng(double.parse(items["pa_latitude"].toString()),
                double.parse(items["pa_longitude"].toString())),
            onTap: () {
              dialogData.clear();

              onMarkerTapped(items);
            },
          ),
        );
      }
    }
  }

  //SEARCH PLACE
  Future<void> fetchSuggestions() async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${searchCon.text}&location=${initialCameraPosition!.target.latitude},${initialCameraPosition!.target.longitude}&radius=${double.parse(ddRadius.toString())}&key=${Variables.mapApiKey}';

    var links = http.get(Uri.parse(url));

    try {
      final response = await HttpRequest.fetchDataWithTimeout(links);
      suggestions.value = [];
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final predictions = data['predictions'];

        if (predictions != null) {
          for (var prediction in predictions) {
            suggestions.add(
                "${prediction['description']}=Rechie=${prediction['place_id']}=structured=${prediction["structured_formatting"]["main_text"]}");
          }
          update();
        } else {
          suggestions.value = [];
          update();
        }
      } else {
        suggestions.value = [];
        update();
      }
    } catch (e) {
      suggestions.value = [];
      update();
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
    }
  }

  void showLegend(VoidCallback cb) {
    Get.dialog(LegendDialogScreen(
      callback: cb,
    ));
  }

  void showNearestSuggestDialog() {
    Get.dialog(SuggestionsScreen(
      data: dataNearest,
    ));
  }

  //calculate coordinates
  LatLng calculateNewCoordinates(
      double lat, double lon, double radiusInMeters, double angleInDegrees) {
    // ignore: non_constant_identifier_names
    double PI = 3.141592653589793238;

    double angleInRadians = angleInDegrees * PI / 180;

    // Constants for Earth's radius and degrees per meter
    const earthRadiusInMeters = 6371000; // Approximate Earth radius in meters
    const degreesPerMeterLatitude = 1 / earthRadiusInMeters * 180 / pi;
    final degreesPerMeterLongitude =
        1 / (earthRadiusInMeters * cos(lat * PI / 180)) * 180 / pi;

    // Calculate the change in latitude and longitude in degrees
    double degreesOfLatitude = radiusInMeters * degreesPerMeterLatitude;
    double degreesOfLongitude = radiusInMeters * degreesPerMeterLongitude;

    // Calculate the new latitude and longitude
    double newLat = lat + degreesOfLatitude * sin(angleInRadians);
    double newLon = lon + degreesOfLongitude * cos(angleInRadians);
    return LatLng(newLat, newLon);
  }

  //onMarker tapped
  void onMarkerTapped(data) {
    dialogData.add(data);

    isMarkerTapped.value = true;
    isGetNearData.value = false;
  }

  void closeMarkerDialog() {
    isMarkerTapped.value = false;
    isGetNearData.value = true;
  }
}
