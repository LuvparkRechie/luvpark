//mapa controller

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/functions/functions.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';
import 'package:luvpark_get/location_auth/location_auth.dart';
import 'package:luvpark_get/mapa/utils/legend/legend_dialog.dart';
import 'package:luvpark_get/mapa/utils/target.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../custom_widgets/app_color.dart';
import '../sqlite/pa_message_table.dart';
import 'utils/suggestions/suggestions.dart';

// ignore: deprecated_member_use
class DashboardMapController extends GetxController
    with GetTickerProviderStateMixin, WidgetsBindingObserver {
  // Dependencies
  final GlobalKey<ScaffoldState> dashboardScaffoldKey =
      GlobalKey<ScaffoldState>();

  final TextEditingController searchCon = TextEditingController();
  PanelController panelController = PanelController();
  DraggableScrollableController dragController =
      DraggableScrollableController();
  late TabController tabController;
  late AnimationController animationController;

  bool isFilter = false;

  GoogleMapController? gMapController;
  CameraPosition? initialCameraPosition;
  RxList<Marker> markers = <Marker>[].obs;
  RxList<Marker> filteredMarkers = <Marker>[].obs;
  RxString userBal = "".obs;
  RxList<dynamic> dataNearest = [].obs;
  List markerData = [];

  //drawerdata
  var userProfile;
  Circle circle = const Circle(circleId: CircleId('dottedCircle'));
  RxList suggestions = [].obs;
  RxString myProfPic = "".obs;
  Polyline polyline = const Polyline(
    polylineId: PolylineId('dottedPolyLine'),
  );

  LatLng searchCoordinates = const LatLng(0, 0);
  LatLng currentCoord = LatLng(0, 0);

//PIn icon
  List<String> searchImage = ['assets/dashboard_icon/location_pin.png'];

  // Configuration Variables
  RxString ddRadius = "10".obs;
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
  RxList<dynamic> amenData = <dynamic>[].obs;
  RxList<dynamic> carsInfo = <dynamic>[].obs;
  String finalSttime = "";
  String finalEndtime = "";
  String parkSched = "";
  RxList<dynamic> vehicleTypes = <dynamic>[].obs;
  RxList<dynamic> vehicleRates = <dynamic>[].obs;
  RxBool isOpen = false.obs;
  RxInt tabIndex = 0.obs;
  LatLng lastLatlng = LatLng(0, 0);
  RxString lastRouteName = "".obs;
  final FocusNode focusNode = FocusNode();
  @override
  void onInit() {
    super.onInit();

    ddRadius.value = "10";
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
    dragController = DraggableScrollableController();
    tabController = TabController(length: 2, vsync: this);
    focusNode.addListener(() {
      if (!focusNode.hasFocus && searchCon.text.isEmpty) {
        suggestions.clear();
        panelController.close();

        Future.delayed(Duration(milliseconds: 200), () {
          panelController.open();
        });
        update();
      }
    });
    getLastBooking();
    getUserData();
    getDefaultLocation();
    initTargetTutorial();
  }

  @override
  void onClose() {
    super.onClose();
    gMapController!.dispose();
    animationController.dispose();
    debounce?.cancel();
    debouncePanel?.cancel();
    focusNode.dispose(); //
  }

  Future<void> onSearchChanged() async {
    if (debounce?.isActive ?? false) debounce?.cancel();

    Duration duration = const Duration(seconds: 1);
    debounce = Timer(duration, () {
      FocusManager.instance.primaryFocus!.unfocus();
      fetchSuggestions((cbData) {
        panelController.open();
        Future.delayed(Duration(milliseconds: 200), () {
          if (suggestions.isNotEmpty) {
            fabHeight.value =
                MediaQuery.of(Get.context!).size.height * .70 + 30;
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
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      getBalance();
    });
  }

  Future<void> refresher() async {
    netConnected.value = true;
    isLoading.value = true;
    getLastBooking();
    getUserData();
    getDefaultLocation();
  }

  void getBalance() async {
    final item = await Authentication().getUserId();
    List<dynamic> msgdata =
        await PaMessageDatabase.instance.getUnreadMessages();
    unreadMsg.value = msgdata.length;

    String subApi = "${ApiKeys.gApiSubFolderGetBalance}?user_id=$item";

    HttpRequest(api: subApi).get().then((returnBalance) async {
      if (returnBalance["items"].isNotEmpty) {
        userBal.value = returnBalance["items"][0]["amount_bal"];
      }
    });
  }

  void getUserData() async {
    String? userData = await Authentication().getUserData();
    final item = await Authentication().getUserData2();
    final profPic = await Authentication().getUserProfilePic();
    userBal.value = item["amount_bal"];
    userProfile = item;
    myProfPic.value = profPic;

    userProfile = item;
    if (jsonDecode(userData!)["first_name"] == null) {
      myName.value = "";
    } else {
      myName.value = jsonDecode(userData)["first_name"];
    }
    fetchData();
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
        Variables.convertDistance(ddRadius.value.toString()).toString());
    isLoading.value = false;
    getNearest(coordinates);
  }

  void getNearest(LatLng coordinates) async {
    String params =
        "${ApiKeys.gApiSubGetNearybyParkings}?is_allow_overnight=$isAllowOverNight&parking_type_code=$pTypeCode&current_latitude=${currentCoord.latitude}&current_longitude=${currentCoord.longitude}&search_latitude=${searchCoordinates.latitude}&search_longitude=${searchCoordinates.longitude}&radius=${Variables.convertToMeters(ddRadius.value.toString())}&parking_amenity_code=$amenities&vehicle_type_id=$vtypeId";
    print(" params$params");
    try {
      var returnData = await HttpRequest(api: params).get();

      Get.back();

      if (returnData == "No Internet") {
        handleNoInternet();
        return;
      }
      if (returnData == null) {
        handleServerError();
        return;
      }
      if (returnData["items"].isEmpty) {
        handleNoParkingFound(returnData["items"]);
        return;
      }

      handleData(returnData["items"]);
    } catch (e) {
      handleServerError();
    }
  }

  void handleNoInternet() {
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
    netConnected.value = true;
    isLoading.value = false;
    dataNearest.value = [];
    markers.clear();
    bool isDouble = ddRadius.value.contains(".");
    String message = isFilter
        ? "There are no parking areas available based on your filter."
        : "No parking area found within \n${(isDouble ? double.parse(ddRadius.value) : int.parse(ddRadius.value)) >= 1 ? '${ddRadius.value} Km' : '${double.parse(ddRadius.value) * 1000} meters'}, please change location.";

    CustomDialog().infoDialog("Map Filter", message, () {
      Get.back();
      showDottedCircle(nearData);
    });
  }

  void handleData(dynamic nearData) async {
    markers.clear();
    dynamic lastBookData = await Authentication().getLastBooking();
    showDottedCircle(nearData);
    buildMarkers(nearData);
    netConnected.value = true;
    bool isShowPopUp = await Authentication().getPopUpNearest();
    if (dataNearest.isNotEmpty && !isShowPopUp) {
      Future.delayed(const Duration(seconds: 1), () {
        Authentication().setShowPopUpNearest(true);
        print("lastBookData $lastBookData");
        if (lastBookData.isEmpty || lastBookData == null) {
          showLegend(() {
            showNearestSuggestDialog();
          });
        } else {
          showNearestSuggestDialog();
        }
      });
    } else {
      Future.delayed(Duration(milliseconds: 200), () {
        panelController.open();
      });
    }

    update();
  }

//Based on radius
  void showDottedCircle(nearData) {
    initialCameraPosition = CameraPosition(
      target: searchCoordinates,
      zoom: nearData.isEmpty ? 14 : 16,
      tilt: 0,
      bearing: 0,
    );

    animateCamera();
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

  //get curr location
  Future<void> getCurrentLoc() async {
    ddRadius.value = "10";
    pTypeCode = "";
    amenities = "";
    vtypeId = "";
    addressText = "".obs;
    isAllowOverNight = "";
    suggestions.clear();
    getDefaultLocation();
  }

  //get curr location
  Future<void> getFilterNearest(data) async {
    ddRadius.value = data[0]["radius"];
    pTypeCode = data[0]["park_type"];
    amenities = data[0]["amen"];
    vtypeId = data[0]["vh_type"];
    isAllowOverNight = data[0]["ovp"];

    isFilter = true;
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

    animateCamera();
  }

  void onCameraMoveStarted() {
    isGetNearData.value = false;
    panelController.close();

    update();
  }

  void onCameraIdle() async {
    isGetNearData.value = true;
    if (debouncePanel?.isActive ?? false) debouncePanel?.cancel();

    Duration duration = const Duration(seconds: 3);

    debouncePanel = Timer(duration, () {
      // if (!isHidePanel.value) {

      // }

      update();
    });
  }

  void animateCamera() async {
    double filterRadius = Variables.convertToMeters(ddRadius.value);

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
          searchCoordinates.latitude,
          searchCoordinates.longitude,
          filterRadius,
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
              zoom: dataNearest.isEmpty ? 14 : 16),
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
              markerData.clear();

              CustomDialog().loadingDialog(Get.context!);

              markerData.add(items);

              List ltlng = await Functions.getCurrentPosition();
              LatLng coordinates = LatLng(ltlng[0]["lat"], ltlng[0]["long"]);
              LatLng dest = LatLng(
                  double.parse(items["pa_latitude"].toString()),
                  double.parse(items["pa_longitude"].toString()));
              final estimatedData = await Functions.fetchETA(coordinates, dest);

              markerData = markerData.map((e) {
                e["distance_display"] = "${estimatedData[0]["distance"]} away";
                e["time_arrival"] = estimatedData[0]["time"];
                e["polyline"] = estimatedData[0]['poly_line'];
                return e;
              }).toList();

              if (estimatedData[0]["error"] == "No Internet") {
                Get.back();
                CustomDialog().internetErrorDialog(Get.context!, () {
                  Get.back();
                });

                return;
              }
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

    var links = http.get(Uri.parse(url));

    try {
      final response = await HttpRequest.fetchDataWithTimeout(links);
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

  void showNearestSuggestDialog() {
    Get.dialog(SuggestionsScreen(
      data: dataNearest,
      cb: (data) {
        if (data == "yowo") {
          Future.delayed(Duration(milliseconds: 200), () {
            panelController.show();
            panelController.open();
          });

          if (!hasLastBooking.value) {
            showTargetTutorial(Variables.ctxt!, false);
          }
          return;
        } else {
          markerData = data;
          lastRouteName.value = "suggestions";
          CustomDialog().loadingDialog(Get.context!);
          filterMarkersData(markerData[0]["park_area_name"], "suggestion");
        }
      },
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

  void showTargetTutorial(BuildContext context, bool isDrawer) {
    isFromDrawer.value = isDrawer;

    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        tutorialCoachMark.show(context: context);
      },
    );
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
      if (lastRouteName.value == "suggestions") {
        showNearestSuggestDialog();
      } else if (lastRouteName.value == "park_areas") {
        routeToParkingAreas();
      }
      isHidePanel.value = false;

      await Future.delayed(const Duration(milliseconds: 200), () {
        gMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: lastLatlng, zoom: 14),
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
      lastLatlng = filteredMarkers[0].position;
      gMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: filteredMarkers[0].position, zoom: 17),
        ),
      );
      isHidePanel.value = true;

      getAmenities(filteredMarkers[0].markerId.value);
    }
  }

  //Get amenities
  Future<void> getAmenities(parkId) async {
    final response = await HttpRequest(
            api: "${ApiKeys.gApiSubFolderGetAmenities}?park_area_id=$parkId")
        .get();

    if (response == "No Internet") {
      Get.back();
      CustomDialog().internetErrorDialog(Get.context!, () => Get.back());
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

    if (response["items"].isNotEmpty) {
      List<dynamic> item = response["items"];
      item = item.map((element) {
        List<dynamic> icon = iconAmen.where((e) {
          return e["code"] == element["parking_amenity_code"];
        }).toList();
        element["icon"] = icon.isNotEmpty ? icon[0]["icon"] : "no_image";

        return element;
      }).toList();
      if (markerData[0]["park_orientation"] != null) {
        item.insert(0, {
          "zone_amenity_id": 0,
          "zone_id": 0,
          "parking_amenity_code": "D",
          "parking_amenity_desc":
              "${markerData[0]["park_size"]} ${markerData[0]["park_orientation"]}",
          "icon": "dimension"
        });
      }

      amenData.value = item;
      getParkingRates(parkId);
    } else {
      Get.back();
      CustomDialog().errorDialog(
        Get.context!,
        "luvpark",
        "No amenities found in this area.",
        () => Get.back(),
      );
    }
  }

  Future<void> getParkingRates(parkId) async {
    HttpRequest(api: '${ApiKeys.gApiSubFolderGetRates}?park_area_id=$parkId')
        .get()
        .then((returnData) async {
      if (returnData == "No Internet") {
        Get.back();
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData == null) {
        Get.back();
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData["items"].length > 0) {
        Get.back();
        List<dynamic> item = returnData["items"];
        vehicleRates.value = item;
      } else {
        Get.back();
        CustomDialog().errorDialog(Get.context!, "luvpark", returnData["msg"],
            () {
          Get.back();
        });
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

  Future<void> goingBackToTheCornerWhenIFirstSawYou() async {
    final vehicleTypesList = markerData[0]['vehicle_types_list'] as String;

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
    finalSttime = formatTime(markerData[0]["start_time"]);
    finalEndtime = formatTime(markerData[0]["end_time"]);
    isOpen.value = Functions.checkAvailability(finalSttime, finalEndtime);
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

  void onClickBooking() {
    CustomDialog().loadingDialog(Get.context!);
    if (markerData[0]["is_allow_reserve"] == "N") {
      Get.back();
      CustomDialog().infoDialog("Not Open to Public Yet",
          "This area is currently unavailable. Please try again later.", () {
        Get.back();
      });

      return;
    }

    if (markerData[0]["is_24_hrs"] == "N") {
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

      String ctime = markerData[0]["closed_time"].toString().trim();
      String otime = markerData[0]["opened_time"].toString().trim();

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

    Functions.getUserBalance(Get.context!, (dataBalance) async {
      print("data balance $dataBalance");
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
          Functions.computeDistanceResorChckIN(
              Get.context!,
              LatLng(
                  markerData[0]["pa_latitude"], markerData[0]["pa_longitude"]),
              (success) {
            Get.back();

            if (success["success"]) {
              Get.toNamed(Routes.booking, arguments: {
                "currentLocation": success["location"],
                "areaData": markerData[0],
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
}
