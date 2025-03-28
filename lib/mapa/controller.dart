//mapa controller

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/location_auth/location_auth.dart';
import 'package:luvpark/mapa/utils/legend/legend_dialog.dart';
import 'package:luvpark/mapa/utils/target.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../custom_widgets/app_color.dart';
import '../sqlite/pa_message_table.dart';

// ignore: deprecated_member_use

class DashboardMapController extends GetxController
    with GetTickerProviderStateMixin, WidgetsBindingObserver {
  // Dependencies
  RxBool hasShownLastBookingModal = false.obs;

  final GlobalKey<ScaffoldState> dashboardScaffoldKey =
      GlobalKey<ScaffoldState>();

  final TextEditingController searchCon = TextEditingController();
  PanelController panelController = PanelController();

  late TabController tabController;
  late AnimationController animationController;

  bool isFilter = false;
  RegExp regExp = RegExp(r'[^a-zA-Z0-9]');
  GoogleMapController? gMapController;
  CameraPosition? initialCameraPosition;
  RxList<Marker> markers = <Marker>[].obs;
  RxList<Marker> filteredMarkers = <Marker>[].obs;
  RxString userBal = "".obs;
  RxList<dynamic> dataNearest = [].obs;
  List markerData = [];

  //drawerdata
  RxMap userProfile = {}.obs;
  Circle circle = const Circle(circleId: CircleId('dottedCircle'));
  RxList suggestions = [].obs;
  RxString myProfPic = "".obs;
  var profWidget = <Widget>[].obs;

  Polyline polyline = const Polyline(
    polylineId: PolylineId('dottedPolyLine'),
  );

  LatLng searchCoordinates = const LatLng(0, 0);
  LatLng currentCoord = LatLng(0, 0);

//PIn icon
  List<String> searchImage = ['assets/dashboard_icon/location_pin.png'];

  // Configuration Variables
  RxString ddRadius = "10000".obs;
  String pTypeCode = "";
  String amenities = "";
  String vtypeId = "";
  RxString addressText = "".obs;
  String isAllowOverNight = "";
  RxString myName = "".obs;
  // State Variables
  RxBool netConnected = true.obs;
  RxBool isLoading = true.obs;
  RxBool isGetNearData = false.obs;
  RxBool isSearched = false.obs;
  //Last Booking variables
  RxBool hasLastBooking = false.obs;
  RxList lastBookData = [].obs;
  RxString plateNo = "".obs;
  RxString brandName = "".obs;
//panel gg
  RxDouble panelHeightOpen = 180.0.obs;
  RxDouble initFabHeight = 80.0.obs;
  RxDouble fabHeight = 0.0.obs;
  RxDouble panelHeightClosed = 60.0.obs;
  RxBool isHidePanel = false.obs;
//Drawer
  RxInt unreadMsg = 0.obs;

  Timer? debounce;
  Timer? debouncePanel;

  late TutorialCoachMark tutorialCoachMark;
  RxBool isFromDrawer = false.obs;
  final GlobalKey menubarKey = GlobalKey();
  final GlobalKey walletKey = GlobalKey();
  final GlobalKey parkKey = GlobalKey();
  final GlobalKey locKey = GlobalKey();
  var denoInd = (-1).obs;

  //amenities
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
  List<Map<String, dynamic>> menuIcons = [
    {"icon": LucideIcons.car, "label": "My Parking", "index": 0},
    {"icon": LucideIcons.walletCards, "label": "Wallet", "index": 1},
    {"icon": Iconsax.car, "label": "My Vehicles", "index": 2},
  ];
  RxList<dynamic> amenData = <dynamic>[].obs;
  RxList<dynamic> carsInfo = <dynamic>[].obs;
  String finalSttime = "";
  String finalEndtime = "";
  String parkSched = "";
  RxList<dynamic> vehicleTypes = <dynamic>[].obs;
  RxList<dynamic> vehicleRates = <dynamic>[].obs;
  RxList<dynamic> balanceData = <dynamic>[].obs;
  RxBool isOpen = false.obs;
  RxInt tabIndex = 0.obs;
  LatLng lastLatlng = LatLng(0, 0);
  RxString lastRouteName = "".obs;
  RxList ratesWidget = <Widget>[].obs;
  final FocusNode focusNode = FocusNode();

  RxBool isClkBook = false.obs;
  RxString lastPlateNumber = "".obs;
  RxString lastVehicleType = "".obs;
  @override
  void onInit() {
    ddRadius.value = "10000";
    pTypeCode = "";
    amenities = "";
    vtypeId = "";
    addressText = "".obs;
    isAllowOverNight = "";
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    fabHeight.value = panelHeightOpen.value + 30;

    panelController = PanelController();

    tabController = TabController(length: 2, vsync: this);
    focusNode.addListener(() {
      if (!focusNode.hasFocus && searchCon.text.isEmpty) {
        suggestions.clear();
        panelController.close();

        Future.delayed(Duration(milliseconds: 200), () {
          panelController.open();
        });
      }
    });
    WidgetsBinding.instance.addObserver(this);
    onDrawerOpen();
    _checkLocationService();
    getBgTmrStatus();
    fetchData();
    super.onInit();
  }
  // void initializeMap() async {
  //   await _checkLocationService();
  //   await fetchData();
  //   await getLastBooking();
  // }

  @override
  void onClose() {
    super.onClose();
    gMapController!.dispose();
    animationController.dispose();
    debounce?.cancel();
    debouncePanel?.cancel();
    focusNode.dispose();
    tabController.dispose();

    WidgetsBinding.instance.removeObserver(this);
  }

  void getBgTmrStatus() async {
    await Authentication().enableTimer(true);
  }

  Future<void> _checkLocationService() async {
    getDefaultLocation();
  }

  Future<void> showModalLastBook() async {
    CustomDialog().confirmationDialog(
        Get.context!,
        "Last Booking",
        "Do you want to book again using\nPlate Number: ${lastPlateNumber.value}?",
        "Back",
        "Book Now", () {
      Get.back();
    }, () {
      Get.back();
      proceedLastBooking();
    });
  }

  Future<void> onSearchChanged() async {
    if (debounce?.isActive ?? false) debounce?.cancel();

    Duration duration = const Duration(seconds: 2);
    debounce = Timer(duration, () {
      FocusManager.instance.primaryFocus!.unfocus();
      fetchSuggestions((cbData) {
        panelController.open();
        Future.delayed(Duration(milliseconds: 200), () {
          if (suggestions.isNotEmpty) {
            fabHeight.value =
                MediaQuery.of(Get.context!).size.height * .70 + 30;
          } else {
            resetFilter();
            getCurrentLoc();
          }
        });
        update();
      });
    });
  }

  void onVoiceGiatay() {
    fetchSuggestions((cbData) {
      FocusManager.instance.primaryFocus!.unfocus();

      Future.delayed(Duration(milliseconds: 200), () {
        panelController.open();
      });
      update();
    });
  }

  double getPanelHeight() {
    double bottomInset = MediaQuery.of(Get.context!).viewInsets.bottom;
    double height = bottomInset == 0
        ? suggestions.isEmpty
            ? 180
            : MediaQuery.of(Get.context!).size.height * .70
        : 180;

    panelHeightOpen.value = height;
    update();
    return height;
  }

  void onPanelSlide(double pos) {
    fabHeight.value = pos * (panelHeightOpen.value - panelHeightClosed.value) +
        initFabHeight.value;
  }

  Future<void> fetchData() async {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      getBalance();
    });
  }

  Future<void> refresher() async {
    netConnected.value = true;
    isLoading.value = true;
    _checkLocationService();
  }

  void getBalance() async {
    final item = await Authentication().getUserId();
    List<dynamic> msgdata =
        await PaMessageDatabase.instance.getUnreadMessages();
    unreadMsg.value = msgdata.length;

    String subApi = "${ApiKeys.getUserBalance}$item";

    HttpRequest(api: subApi).get().then((returnBalance) async {
      if (returnBalance["items"].isNotEmpty) {
        userBal.value = returnBalance["items"][0]["amount_bal"];
        balanceData.value = returnBalance["items"];
      }
    });
  }

  //GEt nearest data based on
  getDefaultLocation() {
    isLoading.value = true;
    isFilter = false;
    isSearched.value = false;
    LocationService.grantPermission(Get.context!, (isGranted) async {
      if (isGranted) {
        List ltlng = await Functions.getCurrentPosition();
        LatLng coordinates = LatLng(ltlng[0]["lat"], ltlng[0]["long"]);
        searchCoordinates = coordinates;
        currentCoord = coordinates;
        bridgeLocation(coordinates);
      } else {
        isLoading.value = true;

        Get.toNamed(Routes.permission);
      }
    });
  }

  void bridgeLocation(coordinates) {
    CustomDialog().mapLoading(
        Variables.parseDistance(double.parse(ddRadius.value.toString()))
            .toString());
    isLoading.value = false;
    dataNearest.value = [];
    markerData = [];
    markers.clear();
    filteredMarkers.clear();

    getNearest(coordinates);
  }

  void getNearest(LatLng coordinates) async {
    final id = await Authentication().getUserId();
    String params =
        "${ApiKeys.getNearbyParkingLoc}$id/?is_allow_overnight=$isAllowOverNight&parking_type_code=$pTypeCode&current_latitude=${currentCoord.latitude}&current_longitude=${currentCoord.longitude}&search_latitude=${searchCoordinates.latitude}&search_longitude=${searchCoordinates.longitude}&radius=${ddRadius.toString()}&parking_amenity_code=$amenities&vehicle_type_id=$vtypeId";
    try {
      var returnData = await HttpRequest(api: params).get();

      if (returnData == "No Internet") {
        Get.back();
        handleNoInternet();
        return;
      }

      if (returnData == null) {
        Get.back();
        handleServerError();
        return;
      }
      if (returnData["items"].isEmpty) {
        Get.back();
        handleNoParkingFound(returnData["items"]);
        return;
      }
      getLastBooking();
      handleData(returnData["items"]);
    } catch (e) {
      handleServerError();
    }
  }

  void getLastBooking() async {
    hasLastBooking.value = false;
    final data = await Authentication().getLastBooking();
    hasLastBooking.value = data.isNotEmpty;
    lastPlateNumber.value = data["vehicle_plate_no"];
    lastVehicleType.value = data["vehicle_type_id"].toString();

    if (hasLastBooking.value && !hasShownLastBookingModal.value) {
      hasShownLastBookingModal.value = true;
      Future.delayed(Duration(seconds: 1));
      showModalLastBook();
    }
  }

  void handleNoInternet() {
    showDottedCircle([]);
    netConnected.value = false;
    isLoading.value = false;
    dataNearest.value = [];

    CustomDialog().internetErrorDialog(Get.context!, () {
      Get.back();
      Future.delayed(Duration(milliseconds: 200), () {
        panelController.open();
      });
    });

    return;
  }

  void handleServerError() {
    showDottedCircle([]);
    netConnected.value = true;
    isLoading.value = false;
    dataNearest.value = [];

    CustomDialog().serverErrorDialog(Get.context!, () {
      Get.back();
      Future.delayed(Duration(milliseconds: 200), () {
        panelController.open();
      });
    });
    return;
  }

  void handleNoParkingFound(dynamic nearData) {
    dataNearest.value = [];
    netConnected.value = true;
    isLoading.value = false;

    String message = isFilter
        ? "There are no parking areas available based on your filter."
        : "No parking area found within \n${Variables.parseDistance(double.parse(ddRadius.value.toString()))}, please change location.";
    showDottedCircle(nearData);
    CustomDialog().infoDialog("Map Filter", message, () {
      Get.back();
      if (suggestions.isEmpty) {
        Future.delayed(Duration(milliseconds: 200), () {
          panelController.show();
          panelController.open();
        });
      }
    });
  }

  void handleData(dynamic nearData) async {
    Get.back();
    showDottedCircle(nearData);
    buildMarkers(nearData);
    netConnected.value = true;
  }

  void showDottedCircle(nearData) {
    initialCameraPosition = CameraPosition(
      target: searchCoordinates,
      zoom: nearData.isEmpty
          ? 15
          : Variables.computeZoomLevel(
              searchCoordinates.latitude, double.parse(ddRadius.toString())),
      bearing: 0,
    );

    animateCamera();
  }

  //get curr location
  Future<void> getCurrentLoc() async {
    ddRadius.value = "10000";
    pTypeCode = "";
    amenities = "";
    vtypeId = "";
    addressText = "".obs;
    isAllowOverNight = "";
    suggestions.clear();
    searchCon.text = "";
    getDefaultLocation();
  }

  Future<void> resetFilter() async {
    ddRadius.value = "10000";
    pTypeCode = "";
    amenities = "";
    vtypeId = "";
    addressText = "".obs;
    isAllowOverNight = "";
  }

  //get curr location
  Future<void> getFilterNearest(data) async {
    ddRadius.value = data[0]["radius"];
    pTypeCode = data[0]["park_type"];
    amenities = data[0]["amen"];
    vtypeId = data[0]["vh_type"];
    isAllowOverNight = data[0]["ovp"];
    isFilter = true;
    focusNode.unfocus();
    bridgeLocation(searchCoordinates);
  }

//MAP SETUP
  void onMapCreated(GoogleMapController controller) {
    DefaultAssetBundle.of(Get.context!)
        .loadString('assets/custom_map_style/map_style.json')
        .then((String style) {
      controller.setMapStyle(style);
    });
    gMapController = controller;

    Future.delayed(Duration(milliseconds: 200), () {
      panelController.open();
    });
    animateCamera();
  }

  void onCameraMoveStarted() {
    isGetNearData.value = false;
    panelController.close();
    update();
  }

  void onCameraIdle() async {
    isGetNearData.value = true;
  }

  void animateCamera() async {
    polyline = Polyline(
      polylineId: const PolylineId('dottedCircle'),
      color: AppColor.mainColor,
      width: 4,
      points: List<LatLng>.generate(
        365,
        (index) => calculateNewCoordinates(
          searchCoordinates.latitude,
          searchCoordinates.longitude,
          double.parse(ddRadius.value.toString()),
          double.parse(
            index.toString(),
          ),
        ),
      ),
    );

    isLoading.value = false;
    if (isSearched.value) {
      final Uint8List availabeMarkIcons =
          await Functions.getSearchMarker(searchImage[0], 90);
      markers.add(Marker(
        infoWindow: InfoWindow(title: addressText.value),
        markerId: MarkerId(addressText.value),
        position: LatLng(initialCameraPosition!.target.latitude,
            initialCameraPosition!.target.longitude),
        icon: BitmapDescriptor.fromBytes(availabeMarkIcons),
      ));
    }

    if (gMapController != null) {
      gMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(initialCameraPosition!.target.latitude,
                initialCameraPosition!.target.longitude),
            zoom: dataNearest.isEmpty ? 16 : 17,
          ),
        ),
      );
    }
  }

  void onDrawerOpen() async {
    final item = await Authentication().getUserData2();
    final profPic = await Authentication().getUserProfilePic();

    profWidget.clear();
    userProfile.addAll(item);
    myProfPic.value = profPic;

    if (userProfile["first_name"] == null) {
      myName.value = userProfile["mobile_no"];
    } else {
      String midName = userProfile["middle_name"] == null
          ? ""
          : userProfile["middle_name"].toString();
      myName.value =
          "${userProfile["first_name"]} ${midName.isEmpty ? "" : "${midName[0]}."} ${userProfile["last_name"]}";
    }

    profWidget.add(
      Hero(
        tag: "profile_pic",
        createRectTween: (begin, end) {
          // Custom Tween for smoother animation
          return MaterialRectCenterArcTween(begin: begin, end: end);
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2.0,
              ),
            ),
            child: ClipRRect(
              clipBehavior: Clip.none,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: myProfPic.isNotEmpty
                    ? MemoryImage(
                        base64Decode(myProfPic.value),
                      )
                    : null,
                child: myProfPic.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 32,
                        color: AppColor.primaryColor,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
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

  Future<void> buildMarkers(data) async {
    dataNearest.value = data;

    if (dataNearest.isNotEmpty) {
      for (int i = 0; i < dataNearest.length; i++) {
        var items = dataNearest[i];

        final String isPwd = items["is_pwd"] ?? "N";
        final String vehicleTypes = items["vehicle_types_list"];
        String iconAsset;

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
            infoWindow: InfoWindow(title: items["park_area_name"]),
            // ignore: deprecated_member_use
            icon: BitmapDescriptor.fromBytes(markerIcon),
            markerId: MarkerId(items["park_area_id"].toString()),
            position: LatLng(double.parse(items["pa_latitude"].toString()),
                double.parse(items["pa_longitude"].toString())),
            onTap: () async {
              FocusManager.instance.primaryFocus!.unfocus();

              tabController = TabController(length: 2, vsync: this);

              CustomDialog().loadingDialog(Get.context!);

              List ltlng = await Functions.getCurrentPosition();

              LatLng coordinates = LatLng(ltlng[0]["lat"], ltlng[0]["long"]);
              LatLng dest = LatLng(
                  double.parse(items["pa_latitude"].toString()),
                  double.parse(items["pa_longitude"].toString()));
              final estimatedData = await Functions.fetchETA(coordinates, dest);

              if (estimatedData[0]["error"] == "No Internet") {
                Get.back();
                CustomDialog().internetErrorDialog(Get.context!, () {
                  Get.back();
                });

                return;
              }
              markerData.clear();
              markerData = [];
              filteredMarkers.clear();
              tabIndex.value = 0;
              markerData.add(items);
              markerData = markerData.map((e) {
                e["distance_display"] =
                    "${Variables.parseDistance(double.parse(markerData[0]["current_distance"].toString()))} away";
                e["time_arrival"] = estimatedData[0]["time"];
                e["polyline"] = estimatedData[0]['poly_line'];
                return e;
              }).toList();
              lastRouteName.value = "";
              filterMarkersData(markerData[0]["park_area_name"], "");
              // Get.toNamed(Routes.parkingDetails, arguments: markerData[0]);
            },
          ),
        );
        filteredMarkers.assignAll(markers);
      }
    }
  }

  //SEARCH PLACE
  Future<void> fetchSuggestions(Function? cb) async {
    CustomDialog().loadingDialog(Get.context!);
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${searchCon.text}&location=${initialCameraPosition!.target.latitude},${initialCameraPosition!.target.longitude}&radius=${double.parse(ddRadius.toString())}&key=${Variables.mapApiKey}';

    var response = await http.get(Uri.parse(url));
    try {
      suggestions.value = [];
      if (response.statusCode == 200) {
        Get.back();
        final data = json.decode(response.body);

        final predictions = data['predictions'];

        if (predictions != null) {
          for (var prediction in predictions) {
            suggestions.add(
                "${prediction['description']}=Rechie=${prediction['place_id']}=structured=${prediction["structured_formatting"]["main_text"]}");
          }
          cb!(suggestions.length);
        } else {
          suggestions.value = [];
          cb!(suggestions.length);
        }
      } else {
        Get.back();
        suggestions.value = [];
        cb!(suggestions.length);
      }
    } catch (e) {
      Get.back();
      suggestions.value = [];
      cb!(suggestions.length);
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

  LatLng calculateNewCoordinates(
      double lat, double lon, double radiusInMeters, double angleInDegrees) {
    const double PI = 3.141592653589793;

    double angleInRadians = angleInDegrees * PI / 180.0;
    double radiusInDegrees =
        radiusInMeters / 111320.0; // Approx. meters per degree latitude

    // Calculate the new latitude
    double newLat = lat + radiusInDegrees * cos(angleInRadians);

    // Calculate the new longitude
    double newLon =
        lon + (radiusInDegrees / cos(lat * PI / 180.0)) * sin(angleInRadians);

    // Normalize the longitude to be within -180 to 180 degrees
    if (newLon > 180.0) newLon -= 360.0;
    if (newLon < -180.0) newLon += 360.0;

    return LatLng(newLat, newLon);
  }

  void initTargetTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: addTargetsPage(
        menubar: menubarKey,
        wallet: walletKey,
        parkinginformation: parkKey,
        currentlocation: locKey,
      ),
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        wordSpacing: 4,
        fontSize: 14,
      ),
      colorShadow: Colors.black54,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        if (isFromDrawer.value) {
          dashboardScaffoldKey.currentState?.openDrawer();
        }
      },
      onSkip: () {
        if (isFromDrawer.value) {
          dashboardScaffoldKey.currentState?.openDrawer();
        }
        return true;
      },
    );
  }

  void routeToParkingAreas() async {
    Get.toNamed(
      Routes.parkingAreas,
      arguments: {
        "data": dataNearest,
        "balance": balanceData,
        "callback": (objData) async {
          lastRouteName.value = "park_areas";
          CustomDialog().loadingDialog(Get.context!);
          await Future.delayed(const Duration(seconds: 1));
          markerData = objData;
          filterMarkersData(markerData[0]["park_area_name"], "");
        }
      },
    );
  }

  void filterMarkersData(String query, String param) async {
    if (query.isEmpty) {
      panelController.show();
      filteredMarkers.assignAll(markers);
      if (lastRouteName.value == "park_areas") {
        routeToParkingAreas();
      }
      isHidePanel.value = false;

      await Future.delayed(const Duration(milliseconds: 200), () {
        gMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: lastLatlng,
              zoom: 15,
            ),
          ),
        );
      });
    } else {
      panelController.hide();
      filteredMarkers.assignAll(
        markers.where((marker) {
          return marker.infoWindow.title!.toLowerCase().trim() ==
              query.toLowerCase().trim();
        }),
      );
      Future.delayed(Duration(seconds: 1), () {
        lastLatlng = filteredMarkers[0].position;
        gMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: filteredMarkers[0].position,
              zoom: 16,
            ),
          ),
        );
        isHidePanel.value = true;

        getAmenities(filteredMarkers[0].markerId.value, () {}, markerData);
      });
    }
  }

  // void showTargetTutorial(BuildContext context, bool isDrawer) {
  //   Future.delayed(
  //     const Duration(seconds: 5),
  //     () {
  //       tutorialCoachMark.show(context: context);
  //     },
  //   );
  // }

  //Get amenities
  Future<void> getAmenities(parkId, Function cb, data) async {
    final response = await HttpRequest(
            api: "${ApiKeys.getParkingAmenities}?park_area_id=$parkId")
        .get();

    if (response == "No Internet") {
      Get.back();
      CustomDialog().internetErrorDialog(Get.context!, () {
        filterMarkersData("", "");
        Get.back();
      });
      return;
    }

    if (response == null || response["items"] == null) {
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

    if (data[0]["park_size"] != null &&
        data[0]["park_orientation"].toString().toLowerCase() != "unknown") {
      item.insert(0, {
        "zone_amenity_id": 0,
        "zone_id": 0,
        "parking_amenity_code": "D",
        "parking_amenity_desc":
            "${data[0]["park_size"]} ${data[0]["park_orientation"]}",
        "icon": "dimension"
      });
    }

    amenData.value = item;
    getParkingRates(parkId, (isSuccess) {
      cb(isSuccess);
    });
  }

  Future<void> getParkingRates(parkId, Function cb) async {
    HttpRequest(api: '${ApiKeys.getParkingRates}$parkId')
        .get()
        .then((returnData) async {
      Get.back();
      if (returnData == "No Internet") {
        cb(false);
        CustomDialog().internetErrorDialog(Get.context!, () {
          filterMarkersData("", "");
          Get.back();
        });
        return;
      }
      if (returnData == null) {
        cb(false);
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData["items"].length > 0) {
        List<dynamic> item = returnData["items"];
        vehicleRates.value = item;
        goingBackToTheCornerWhenIFirstSawYou();
        cb(true);
      } else {
        cb(false);
        CustomDialog().errorDialog(Get.context!, "luvpark", returnData["msg"],
            () {
          Get.back();
        });
        return;
      }
    });
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
    finalSttime = formatTime(markerData[0]["start_time"]);
    finalEndtime = formatTime(markerData[0]["end_time"]);
    bool isOpenPa = await isOpenArea(markerData);
    bool openBa = await Functions.checkAvailability(finalSttime, finalEndtime);
    if (!isOpenPa) {
      isOpen.value = isOpenPa;
    } else {
      isOpen.value = openBa;
    }
    getVhRatesData(vehicleTypes[0]["vh_types"]);
  }

  void getVhRatesData(String vhType) async {
    ratesWidget.value = <Widget>[];
    List data = vehicleRates.where((obj) {
      return obj["vehicle_type"]
          .toString()
          .trim()
          .toLowerCase()
          .contains(vhType.toString().trim().toLowerCase());
    }).toList();

    ratesWidget.add(Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.3, color: Color(0xFFE8E8E8)),
                    borderRadius: BorderRadius.all(
                      Radius.circular(7),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: CustomParagraph(
                      text: "Base Rate",
                      maxlines: 1,
                    )),
                    CustomParagraph(
                      text: "${data[0]["base_rate"]}",
                      color: Colors.black,
                      textAlign: TextAlign.right,
                    )
                  ],
                ),
              ),
            ),
            Container(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.3, color: Color(0xFFE8E8E8)),
                    borderRadius: BorderRadius.all(
                      Radius.circular(7),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: CustomParagraph(
                      text: "Base Hours",
                      maxlines: 1,
                    )),
                    CustomParagraph(
                      text: "${data[0]["base_hours"]}",
                      color: Colors.black,
                      textAlign: TextAlign.right,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.3, color: Color(0xFFE8E8E8)),
                    borderRadius: BorderRadius.all(
                      Radius.circular(7),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: CustomParagraph(
                      text: "Succeeding Rate",
                      maxlines: 2,
                    )),
                    Container(width: 5),
                    CustomParagraph(
                      text: "${data[0]["succeeding_rate"]}",
                      color: Colors.black,
                      textAlign: TextAlign.right,
                    )
                  ],
                ),
              ),
            ),
            Container(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                        child: CustomParagraph(
                      text: " ",
                      maxlines: 1,
                    )),
                    CustomParagraph(
                      text: " ",
                      color: Colors.black,
                      textAlign: TextAlign.right,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ));
    update();
  }

  String formatTime(String time) {
    return "${time.substring(0, 2)}:${time.substring(2)}";
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

  Future<bool> isOpenArea(data) async {
    DateTime timeNow = await Functions.getTimeNow();

    Map<String, dynamic> jsonData = data[0];
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

  void onClickBooking(areaData) async {
    CustomDialog().loadingDialog(Get.context!);
    bool isOpenPa = await isOpenArea(areaData);

    if (!isOpenPa) {
      Get.back();
      CustomDialog().infoDialog("Booking", "This area is currently close.", () {
        Get.back();
      });

      return;
    }

    DateTime now = await Functions.getTimeNow();

    if (areaData.isEmpty) {
      Get.back();
      CustomDialog()
          .infoDialog("Not Available", "No data found please refresh.", () {
        Get.back();
      });
      return;
    }
    if (areaData[0]["is_allow_reserve"] == "N") {
      Get.back();
      CustomDialog().infoDialog("Not Open to Public Yet",
          "This area is currently unavailable. Please try again later.", () {
        Get.back();
      });

      return;
    }

    if (areaData[0]["is_24_hrs"] == "N") {
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

      String ctime = areaData[0]["closed_time"].toString().trim();
      String otime = areaData[0]["opened_time"].toString().trim();

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

    if (int.parse(areaData[0]["res_vacant_count"].toString()) == 0) {
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
          "${ApiKeys.getSubscribedVehicle}$userId?park_area_id=${areaData[0]["park_area_id"]}";
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

      Functions.computeDistanceResorChckIN(Get.context!,
          LatLng(areaData[0]["pa_latitude"], areaData[0]["pa_longitude"]),
          (success) {
        Get.back();

        final args = {
          "currentLocation": success["location"],
          "areaData": areaData[0],
          "canCheckIn": success["can_checkIn"],
          "userData": balanceData,
        };
        if (success["success"]) {
          Get.toNamed(Routes.booking, arguments: args);
        }
      });
    }
  }

  void onMenuIconsTap(int index) {
    switch (index) {
      case 0:
        Get.toNamed(Routes.parking, arguments: "D");
        break;
      case 1:
        Get.toNamed(Routes.wallet);
        break;
      case 2:
        Get.toNamed(Routes.myVehicles);
        break;
    }
  }

  Future<void> proceedLastBooking() async {
    CustomDialog().loadingDialog(Get.context!);
    List lData = [];
    final data = await Authentication().getLastBooking();
    lData = dataNearest.where((e) {
      return e["park_area_id"] == data["park_area_id"];
    }).toList();
    List ltlng = await Functions.getCurrentPosition();

    LatLng coordinates = LatLng(ltlng[0]["lat"], ltlng[0]["long"]);
    LatLng dest = LatLng(double.parse(lData[0]["pa_latitude"].toString()),
        double.parse(lData[0]["pa_longitude"].toString()));
    final estimatedData = await Functions.fetchETA(coordinates, dest);

    if (estimatedData[0]["error"] == "No Internet") {
      Get.back();
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });

      return;
    }
    lData = lData.map((e) {
      e["distance_display"] =
          "${Variables.parseDistance(double.parse(lData[0]["current_distance"].toString()))} away";
      e["time_arrival"] = estimatedData[0]["time"];
      e["polyline"] = estimatedData[0]['poly_line'];
      return e;
    }).toList();

    getAmenities(filteredMarkers[0].markerId.value, (cbData) {
      if (cbData) {
        onClickBooking(lData);
      }
    }, lData);
  }
}
