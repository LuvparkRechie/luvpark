import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:location/location.dart' as loc;
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/biometric_login.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart' as func;
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/location_controller.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/dashboard/filter_map_v2.dart';
import 'package:luvpark/dashboard/nearest_list.dart';
import 'package:luvpark/dashboard/search_place.dart';
import 'package:luvpark/dashboard/view_area_details.dart';
import 'package:luvpark/dashboard/view_list.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:luvpark/parking_trans/park_detailsv2.dart';
import 'package:luvpark/sqlite/pa_message_table.dart';
import 'package:luvpark/sqlite/reserve_notification_table.dart';
import 'package:luvpark/sqlite/share_location_table.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../login/login.dart';
import '../notification_controller/notification_controller.dart';

class Dashboard3 extends StatefulWidget {
  const Dashboard3({super.key});

  @override
  State<Dashboard3> createState() => _Dashboard3State();
}

class _Dashboard3State extends State<Dashboard3> {
  TextEditingController searchController = TextEditingController();
  PanelController panelController = PanelController();

  late GoogleMapController mapController;
  LatLng? startLocation;
  String pTypeCode = "";
  String amenities = "";
  String vtypeId = "";
  String isAllowOverNight = "";
  CameraPosition? initialCameraPosition;
  bool isLoadingPage = true;
  bool isLoadingMap = true;
  bool hasInternetBal = true;
  List<String> images = [
    'assets/images/geo_tag.png',
  ];
  List<String> searchImage = ['assets/images/my_marker2.png'];
  List subDataNearest = [];
  List<Marker> markers = <Marker>[];
  var myData;
  var logData;
  String? ddRadius;
  bool onSearchAdd = false;
  double userBal = 0.0, avgRate = 0.0, maxPanelHeight = 0.0;
  bool isClicked = false;
  //added
  loc.Location locationSer = loc.Location();
  double actualPanelHeight = 60;

  Circle _circle = const Circle(circleId: CircleId('dottedCircle'));
  Polyline _polyline = const Polyline(
    polylineId: PolylineId('dottedPolyLine'),
  );

  @override
  void initState() {
    super.initState();
    ddRadius = "10";
    searchController.addListener(() {});
    getUsersData("Current Location");
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showFilter() {
    print("isAllowOverNight $isAllowOverNight");
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      barrierLabel: MaterialLocalizations.of(context).dialogLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, _, __) {
        return FilterMap(
            radius: ddRadius!,
            parkOvernight: isAllowOverNight,
            callBack: (dataCallBack) {
              getFilteredData(dataCallBack);
            });
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ).drive(Tween<Offset>(
            begin: const Offset(0, 1.0),
            end: Offset.zero,
          )),
          child: child,
        );
      },
    );
  }

  Future<void> getUsersData(locTitle) async {
    final prefs = await SharedPreferences.getInstance();
    myData = prefs.getString(
      'userData',
    );
    LocationService.grantPermission(context, (isGranted) {
      if (isGranted) {
        Functions.getLocation(context, (location) {
          String subApi =
              "${ApiKeys.gApiSubFolderGetBalance}?user_id=${jsonDecode(myData!)['user_id'].toString()}";

          HttpRequest(api: subApi).get().then((returnBalance) async {
            if (mounted) {
              setState(() {
                isClicked = false;
              });
            }
            if (returnBalance == "No Internet") {
              showAlertDialog(context, "Error",
                  "Please check your internet connection and try again.", () {
                Navigator.of(context).pop();
                if (mounted) {
                  setState(() {
                    hasInternetBal = false;
                  });
                }
              });

              return;
            }
            if (returnBalance == null) {
              showAlertDialog(context, "Error",
                  "Error while connecting to server, Please try again.", () {
                Navigator.of(context).pop();
                if (mounted) {
                  setState(() {
                    hasInternetBal = true;
                  });
                }
              });
            }
            if (returnBalance["items"].isEmpty) {
              showAlertDialog(context, "Error",
                  "There ase some changes made in your account. please contact support.",
                  () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                Navigator.pop(context);
                CustomModal(context: context).loader();
                await NotificationDatabase.instance
                    .readAllNotifications()
                    .then((notifData) async {
                  if (notifData.isNotEmpty) {
                    for (var nData in notifData) {
                      NotificationController.cancelNotificationsById(
                          nData["reserved_id"]);
                    }
                  }
                  var logData = pref.getString('loginData');
                  var mappedLogData = [jsonDecode(logData!)];
                  mappedLogData[0]["is_active"] = "N";
                  pref.setString("loginData", jsonEncode(mappedLogData[0]!));
                  pref.remove('myId');
                  NotificationDatabase.instance.deleteAll();
                  PaMessageDatabase.instance.deleteAll();
                  ShareLocationDatabase.instance.deleteAll();
                  NotificationController.cancelNotifications();
                  //  ForegroundNotif.onStop();
                  BiometricLogin().clearPassword();
                  Timer(const Duration(seconds: 1), () {
                    Navigator.of(context).pop(context);
                    Variables.pageTrans(const LoginScreen(index: 1), context);
                  });
                });
              });
            }
            if (mounted) {
              setState(() {
                userBal = double.parse(
                    returnBalance["items"][0]["amount_bal"].toString());
                hasInternetBal = true;
              });
            }

            if (mounted) {
              setState(() {
                logData = jsonDecode(myData);
                startLocation = LatLng(location.latitude, location.longitude);
              });
            }

            DashboardComponent.getNearest(
                context,
                pTypeCode,
                ddRadius,
                startLocation!.latitude,
                startLocation!.longitude,
                vtypeId,
                amenities,
                isAllowOverNight, (nearestData) {
              if (nearestData == "No Internet") {
                setState(() {
                  hasInternetBal = false;
                });
              }
              displayMapData(
                  nearestData, location.latitude, location.longitude, locTitle);
            });
          });
        });
      } else {
        getUsersData("Current Location");
      }
    });
  }

  displayMapData(nearestData, lat, lng, locTitle) async {
    final Uint8List availabeMarkIcons =
        await DashboardComponent().getSearchMarker(searchImage[0], 100);
    int ctr = 0;

    if (userBal >= double.parse(logData["min_wallet_bal"].toString())) {
      if (mounted) {
        setState(() {
          markers = [];
          subDataNearest = nearestData;
          startLocation = LatLng(
              double.parse(lat.toString()), double.parse(lng.toString()));
          initialCameraPosition = CameraPosition(
            target: startLocation!,
            zoom: subDataNearest.isEmpty ? 14 : 17,
            tilt: 0,
            bearing: 0,
          );
          markers.add(Marker(
            infoWindow: InfoWindow(title: "$locTitle"),
            markerId: const MarkerId('current_location'),
            position: LatLng(
                double.parse(lat.toString()), double.parse(lng.toString())),
            icon: BitmapDescriptor.fromBytes(availabeMarkIcons),
          ));
          if (onSearchAdd) {
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(double.parse(lat.toString()),
                        double.parse(lng.toString())),
                    zoom: nearestData.isEmpty ? 14 : 17),
              ),
            );
          }
          _circle = Circle(
            circleId: const CircleId('dottedCircle'),
            center: startLocation!,
            radius: 200,
            strokeWidth: 0,
            fillColor: AppColor.primaryColor.withOpacity(.03),
          );
          _polyline = Polyline(
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
                    startLocation!.latitude,
                    startLocation!.longitude,
                    200,
                    double.parse(index.toString()))),
          );
        });
      }
      setState(() {
        isLoadingPage = false;
        isLoadingMap = false;
      });
      if (nearestData.isNotEmpty) {
        for (var i = 0; i < nearestData.length; i++) {
          ctr++;
          var items = nearestData[i];
          items["index"] = i.toString();
          String rateDisplay = int.parse(items["min_base_rate"].toString()) ==
                  int.parse(items["max_base_rate"].toString())
              ? "${int.parse(items["max_base_rate"].toString())}"
              : "${items["min_base_rate"].toString()}-${items["max_base_rate"].toString()}";

          final Uint8List markerIcon = await Variables.capturePng(context,
              printScreen(AppColor.bodyColor, "$i", rateDisplay), 80, true);
          markers.add(
            Marker(
                icon: BitmapDescriptor.fromBytes(markerIcon),
                markerId: MarkerId(ctr.toString()),
                position: LatLng(double.parse(items["pa_latitude"].toString()),
                    double.parse(items["pa_longitude"].toString())),
                onTap: () {
                  setState(() {
                    isLoadingPage = true;
                  });
                  if (userBal <
                      double.parse(logData["min_wallet_bal"].toString())) {
                    setState(() {
                      isLoadingPage = false;
                    });
                    showAlertDialog(
                        context,
                        "Attention",
                        "Your balance is below the required minimum for this feature. "
                            "Please ensure a minimum balance of ${double.parse(logData["min_wallet_bal"].toString())} tokens to access the requested service.",
                        () {
                      Navigator.of(context).pop();
                    });
                    return;
                  } else {
                    CustomModal(context: context).loader();
                    func.Functions.getAmenities(context, items["park_area_id"],
                        (cb) {
                      if (cb["msg"] == "Success") {
                        Navigator.of(context).pop();
                        if (cb["data"].isNotEmpty) {
                          Variables.pageTrans(
                              ViewDetails(
                                  areaData: [items], amenitiesData: cb["data"]),
                              context);
                        }
                      }
                    });
                  }
                }),
          );

          if (mounted) {
            setState(() {});
          }
        }
      }
    } else {
      if (mounted) {
        setState(() {
          markers = [];
          subDataNearest = nearestData;
          startLocation = LatLng(
              double.parse(lat.toString()), double.parse(lng.toString()));
          isLoadingPage = false;
          isLoadingMap = false;
        });
      }
    }
  }

  LatLng calculateNewCoordinates(
      double lat, double lon, double radiusInMeters, double angleInDegrees) {
    // Convert angle from degrees to radians
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

  void getFilteredData(data) {
    if (mounted) {
      setState(() {
        isLoadingPage = true;
        isLoadingMap = true;
      });
    }
    DashboardComponent.getNearest(
        context,
        data["p_type"],
        data["radius"],
        startLocation!.latitude,
        startLocation!.longitude,
        data["vh_type"],
        data["amen"],
        data["is_allow_overnight"], (nearestData) {
      if (nearestData == "No Internet") {
        setState(() {
          hasInternetBal = false;
        });
      }
      setState(() {
        ddRadius = data["radius"].toString();
        pTypeCode = data["p_type"];
        amenities = data["amen"];
        vtypeId = data["vh_type"];
        isAllowOverNight = data["is_allow_overnight"];
      });
      displayMapData(nearestData, startLocation!.latitude,
          startLocation!.longitude, "Searched Location");
    });
  }

  @override
  Widget build(BuildContext context) {
    return !hasInternetBal
        ? NoInternetConnected(onTap: () {
            if (isClicked) return;
            setState(() {
              isClicked = true;
              hasInternetBal = true;
            });
            getUsersData("Current Location");
          })
        : isLoadingMap
            ? SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                        width: 100,
                        height: 100,
                        image: AssetImage(
                            "assets/images/luvpark_transparent.png")),
                    FadeIn(
                      delay: const Duration(milliseconds: 400),
                      child: Shimmer.fromColors(
                        baseColor: Colors.black,
                        highlightColor: Colors.grey[100]!,
                        child: CustomParagraph(
                            text: 'Getting nearest parking area for you.'),
                      ),
                    ),
                  ],
                ),
              )
            : userBal < double.parse(logData["min_wallet_bal"].toString())
                ? noMapDisplay()
                : mapDisplay(subDataNearest);
  }

  Widget noMapDisplay() {
    return SafeArea(
      child: Column(
        children: [
          searchBar(false),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  subDataNearest.isEmpty
                      ? Container()
                      : CustomTitle(text: "Parking Nearby"),
                  Container(
                    height: 8,
                  ),
                  subDataNearest.isEmpty
                      ? Container()
                      : CustomParagraph(
                          text: 'The best parking space near you',
                        ),
                  subDataNearest.isEmpty
                      ? Container()
                      : Container(
                          height: 8,
                        ),
                  Expanded(
                    child: isLoadingPage
                        ? ListView.builder(
                            itemCount: 10,
                            itemBuilder: ((context, index) {
                              return reserveShimmer();
                            }),
                          )
                        : subDataNearest.isEmpty
                            ? const NoDataFound()
                            : ListItems(
                                data: subDataNearest,
                                userbal: userBal,
                                minBalance: double.parse(
                                  logData["min_wallet_bal"].toString(),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget mapDisplay(nearestData) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Expanded(child: _body()),
          SlidingUpPanel(
            maxHeight: 280,
            minHeight: Variables.screenSize.height * 0.05,
            parallaxEnabled: true,
            parallaxOffset: .3,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(7.0),
              topRight: Radius.circular(7.0),
            ),
            controller: panelController,
            header: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: _panel(nearestData)),
            collapsed: GestureDetector(
              onTap: () {
                setState(() {
                  panelController.open();
                });
              },
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7.0),
                      topRight: Radius.circular(7.0),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: AppColor.secondaryColor,
                    ),
                  )),
            ),
            panel: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppColor.bodyColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(7.0),
                  topRight: Radius.circular(7.0),
                ),
              ),
            ),
            color: AppColor.bodyColor,
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          zoomGesturesEnabled: true,
          initialCameraPosition: initialCameraPosition!,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          buildingsEnabled: false,
          tiltGesturesEnabled: true,
          markers: Set<Marker>.of(markers),
          polylines: {_polyline},
          circles: {_circle},
          onMapCreated: (GoogleMapController controller) {
            if (mounted) {
              setState(() {
                mapController = controller;
                DefaultAssetBundle.of(context)
                    .loadString('assets/custom_map_style/map_style.json')
                    .then((String style) {
                  controller.setMapStyle(style);
                });
              });
            }
          },
        ),
        Positioned(
          top: 10,
          right: 15,
          child: SafeArea(
              child: Container(
            width: 178,
            padding: EdgeInsets.fromLTRB(12, 11, 10, 11),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFFDFE7EF)),
                borderRadius: BorderRadius.circular(7),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Row(
              children: [
                const Image(
                  image: AssetImage("assets/images/luvparklogo.png"),
                  width: 37,
                  height: 32,
                ),
                Container(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomParagraph(
                        text: "My balance",
                        maxlines: 1,
                        fontSize: 16,
                        letterSpacing: -0.41,
                        fontWeight: FontWeight.w600,
                      ),
                      CustomTitle(
                        text: toCurrencyString(userBal.toString()),
                        maxlines: 1,
                        fontSize: 18,
                        letterSpacing: -0.41,
                        fontWeight: FontWeight.w900,
                      )
                    ],
                  ),
                ),
                Container(width: 8),
                Icon(
                  Icons.chevron_right_outlined,
                  color: AppColor.secondaryColor,
                ),
              ],
            ),
          )),
        ),
        Positioned(
          right: 10,
          left: 10,
          bottom: 25,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFDFE7EF)),
                    borderRadius: BorderRadius.circular(57),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: Image(
                        image: AssetImage("assets/dashboard_icon/car.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(width: 5),
                    const CustomTitle(text: "Land Cruiser", fontSize: 14),
                    Container(width: 5),
                    CustomLinkLabel(
                      text: "YKB-7635",
                      fontSize: 14,
                      color: AppColor.primaryColor,
                    )
                  ],
                ),
              ),
              Expanded(child: Container()),
              GestureDetector(
                onTap: () {
                  Variables.pageTrans(
                      ViewList(
                        nearestData: subDataNearest,
                        balance: userBal,
                        minBalance:
                            double.parse(logData["min_wallet_bal"].toString()),
                        onTap: () {},
                      ),
                      context);
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(10),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFFDFE7EF)),
                        borderRadius: BorderRadius.circular(57),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: const Image(
                      image: AssetImage("assets/dashboard_icon/parking.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _panel(data) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 71,
                  height: 6,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(56),
                      color: Color(0xffd9d9d9))),
            ),
            Container(height: 20),
            CustomParagraph(
              text:
                  "${jsonDecode(myData!)['first_name'] == null ? "Welcome to luvpark" : "${Variables.greeting()}, " + jsonDecode(myData!)['first_name']}",
              // color: Color(0xFF666666),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.41,
            ),
            CustomTitle(
              text: "What do you want to do today?",
              color: Color(0xFF131313),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.41,
            ),
            Container(height: 20),
            inatay("Find Parking", "Reserve space in advance", "search_icon",
                () {
              Variables.pageTrans(
                  SearchPlaces(
                      latlng: LatLng(
                        startLocation!.latitude,
                        startLocation!.longitude,
                      ),
                      radius: ddRadius.toString(),
                      pTypeCode: pTypeCode,
                      vtypeId: vtypeId,
                      amenities: amenities,
                      isAllowOverNight: isAllowOverNight,
                      callback: (searchedObj) {
                        if (searchedObj["data"].isEmpty &&
                            searchedObj["searchedData"].isEmpty) {
                          setState(() {
                            isLoadingMap = true;
                          });
                          Future.delayed(Duration(seconds: 1));
                          getUsersData("Current Location");
                          return;
                        }
                        if (mounted) {
                          Navigator.of(context).pop();
                          setState(() {
                            onSearchAdd = true;
                            isLoadingPage = true;
                            searchController.text = searchedObj["searchedData"]
                                    [0]["place"]
                                .toString();
                            startLocation = LatLng(
                                double.parse(searchedObj["searchedData"][0]
                                        ["lat"]
                                    .toString()),
                                double.parse(searchedObj["searchedData"][0]
                                        ["long"]
                                    .toString()));
                            ddRadius = searchedObj["searchedData"][0]["radius"]
                                .toString();

                            if (searchedObj == "No Internet") {
                              hasInternetBal = false;
                            }
                          });
                        }

                        displayMapData(
                            searchedObj["data"],
                            double.parse(searchedObj["searchedData"][0]["lat"]
                                .toString()),
                            double.parse(searchedObj["searchedData"][0]["long"]
                                .toString()),
                            "Pin Location");
                      }),
                  context);
            }),
            Container(height: 10),
            inatay(
                "Park and pay now", "I'm in the parking zone", "car_dashboard",
                () {
              Variables.pageTrans(ParkDetailsV2(), context);
              // if (subDataNearest.isEmpty) {
              //   errorDialog(context, "LuvPark", "No nearest data found.", () {
              //     Navigator.of(context).pop();
              //   });
              //   return;
              // }
              // setState(() {
              //   isLoadingPage = true;
              // });
              // if (userBal <
              //     double.parse(logData["min_wallet_bal"].toString())) {
              //   setState(() {
              //     isLoadingPage = false;
              //   });
              //   showAlertDialog(
              //       context,
              //       "Attention",
              //       "Your balance is below the required minimum for this feature. "
              //           "Please ensure a minimum balance of ${double.parse(logData["min_wallet_bal"].toString())} tokens to access the requested service.",
              //       () {
              //     Navigator.of(context).pop();
              //   });
              //   return;
              // } else {
              //   CustomModal(context: context).loader();
              //   func.Functions.getAmenities(
              //       context, subDataNearest[0]["park_area_id"], (cb) {
              //     if (cb["msg"] == "Success") {
              //       Navigator.of(context).pop();
              //       if (cb["data"].isNotEmpty) {
              //         Variables.pageTrans(
              //             ViewDetails(
              //                 areaData: [subDataNearest[0]],
              //                 amenitiesData: cb["data"]),
              //             context);
              //       }
              //     }
              //   });
              // }
            }),
          ],
        ),
      ),
    );
  }

  Widget inatay(String title, String paragraph, String img, Function onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Color(0xFFDFE7EF)),
            borderRadius: BorderRadius.circular(4),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 15,
              offset: Offset(0, 5),
              spreadRadius: 0,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 11, 5, 11),
          child: Row(
            children: [
              Image(
                image: AssetImage("assets/dashboard_icon/$img.png"),
                width: 48,
                height: 48,
              ),
              Container(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTitle(
                    text: title,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: -0.41,
                  ),
                  CustomParagraph(
                    text: paragraph,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.41,
                    maxlines: 1,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  //Search Child
  Widget searchBar(isMap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: Variables.screenSize.width,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1), // changes position of shadow
              ),
            ]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  CupertinoIcons.search,
                  color: Colors.black87,
                ),
              ),
              Container(width: 10),
              Expanded(
                child: TextField(
                  controller: searchController,
                  readOnly: true,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search address, places or city',
                      hintStyle: GoogleFonts.manrope(
                        color: Color(0x993C3C43),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.41,
                      )),
                  onTap: () {
                    Variables.pageTrans(
                        SearchPlaces(
                            latlng: LatLng(
                              startLocation!.latitude,
                              startLocation!.longitude,
                            ),
                            radius: ddRadius.toString(),
                            pTypeCode: pTypeCode,
                            vtypeId: vtypeId,
                            amenities: amenities,
                            isAllowOverNight: isAllowOverNight,
                            callback: (searchedObj) {
                              Navigator.of(context).pop();
                              print("searchedObj $searchedObj");
                              if (searchedObj["data"].isEmpty &&
                                  searchedObj["searchedData"].isEmpty) {
                                setState(() {
                                  isLoadingMap = true;
                                });
                                Future.delayed(Duration(seconds: 1));
                                getUsersData("Current Location");
                                return;
                              }
                              if (mounted) {
                                setState(() {
                                  onSearchAdd = true;
                                  isLoadingPage = true;
                                  searchController.text =
                                      searchedObj["searchedData"][0]["place"]
                                          .toString();
                                  startLocation = LatLng(
                                      double.parse(searchedObj["searchedData"]
                                              [0]["lat"]
                                          .toString()),
                                      double.parse(searchedObj["searchedData"]
                                              [0]["long"]
                                          .toString()));
                                  ddRadius = searchedObj["searchedData"][0]
                                          ["radius"]
                                      .toString();

                                  if (searchedObj == "No Internet") {
                                    hasInternetBal = false;
                                  }
                                });
                              }

                              displayMapData(
                                  searchedObj["data"],
                                  double.parse(searchedObj["searchedData"][0]
                                          ["lat"]
                                      .toString()),
                                  double.parse(searchedObj["searchedData"][0]
                                          ["long"]
                                      .toString()),
                                  "Pin Location");
                            }),
                        context);
                  },
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.0,
                    color: AppColor.paragraphColor,
                    wordSpacing: 2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showFilter();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Iconsax.filter,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget reserveShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        title: Container(
          width: double.infinity,
          height: 20.0,
          color: Colors.white,
        ),
        subtitle: Container(
          width: double.infinity,
          height: 14.0,
          color: Colors.white,
        ),
      ),
    );
  }

//Display Text as marker
  Widget printScreen(Color color, String index, String rate) {
    return Container(
      height: 50,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    "P",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            Container(width: 5),
            Text(
              "₱$rate",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              maxLines: 1,
            )
          ],
        ),
      ),
    );
  }
}

class HorizontalListView extends StatefulWidget {
  final List abnormal;
  final LatLng startLocation;
  const HorizontalListView({
    super.key,
    required this.startLocation,
    required this.abnormal,
  });

  @override
  State<HorizontalListView> createState() => _HorizontalListViewState();
}

class _HorizontalListViewState extends State<HorizontalListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.abnormal.isEmpty
        ? const NoDataFound(
            size: 70,
            textText:
                "No parking area found nearby. Please search another place.",
          )
        : ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: widget.abnormal.length, // Set your desired item count
            itemBuilder: (context, index) {
              String getDistanceString() {
                if (widget.abnormal[index]["distance"] >= 1000) {
                  // If the distance is greater than or equal to 1000 meters, display in kilometers
                  double distanceInKilometers =
                      widget.abnormal[index]["distance"] / 1000;
                  return '${distanceInKilometers.toStringAsFixed(2)} km';
                } else {
                  // Otherwise, display in meters
                  return '${widget.abnormal[index]["distance"].toStringAsFixed(2)} m';
                }
              }

              String finalSttime =
                  "${widget.abnormal[index]["start_time"].toString().substring(0, 2)}:${widget.abnormal[index]["start_time"].toString().substring(2)}";
              String finalEndtime =
                  "${widget.abnormal[index]["end_time"].toString().substring(0, 2)}:${widget.abnormal[index]["end_time"].toString().substring(2)}";
              bool isOpen = DashboardComponent.checkAvailability(
                  finalSttime, finalEndtime);

              return NearestList(
                  nearestData: widget.abnormal[index],
                  isOpen: isOpen,
                  distance: getDistanceString());
            },
          );
  }
}
