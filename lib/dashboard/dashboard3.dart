import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/bottom_tab/bottom_tab.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart' as func;
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/dashboard/filter_map_v2.dart';
import 'package:luvpark/dashboard/search_place.dart';
import 'package:luvpark/dashboard/view_area_details.dart';
import 'package:luvpark/dashboard/view_list.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:luvpark/permission/permission_handler.dart';
import 'package:luvpark/verify_user/verify_user_account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Dashboard3 extends StatefulWidget {
  const Dashboard3({super.key});

  @override
  State<Dashboard3> createState() => _Dashboard3State();
}

class _Dashboard3State extends State<Dashboard3> {
  TextEditingController searchController = TextEditingController();
  PanelController panelController = PanelController();

  List pTypeData = [];
  List radiusData = [];
  late GoogleMapController mapController;
  LatLng? startLocation;
  String pTypeCode = "";
  String amenities = "";
  String vtypeId = "";
  String isAllowOverNight = "N";
  List filteredArea = [];
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

  @override
  void initState() {
    super.initState();
    ddRadius = "10000";
    searchController.addListener(() {});
    getUsersData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showFilter() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      barrierLabel: MaterialLocalizations.of(context).dialogLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, _, __) {
        return FilterMap(
            radius: ddRadius!,
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

  Future<void> getUsersData() async {
    final prefs = await SharedPreferences.getInstance();
    myData = prefs.getString(
      'userData',
    );
    bool servicestatus = await Geolocator.isLocationServiceEnabled();
    final statusReq = await Geolocator.checkPermission();
    if (!servicestatus) {
      // ignore: use_build_context_synchronously
      showAlertDialog(context, "Attention",
          "To continue, turn on device location, which uses Google's location service.",
          () {
        Navigator.of(context).pop();
      });
      return;
    } else if (statusReq == LocationPermission.denied) {
      // ignore: use_build_context_synchronously
      Variables.pageTrans(
          PermissionHandlerScreen(
            isLogin: true,
            index: 1,
            widget: MainLandingScreen(),
          ),
          context);
    } else {
      DashboardComponent.getPositionLatLong().then((position) {
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
              startLocation = LatLng(position.latitude, position.longitude);
            });
          }

          DashboardComponent.getNearest(
              ctxt,
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
            displayMapData(nearestData, position.latitude, position.longitude);
          });
        });
      });
    }
  }

  displayMapData(nearestData, lat, lng) async {
    final Uint8List availabeMarkIcons =
        await DashboardComponent().getSearchMarker(searchImage[0], 120);
    int ctr = 0;

    if (mounted) {
      setState(() {
        markers = [];
        subDataNearest = nearestData;
        startLocation =
            LatLng(double.parse(lat.toString()), double.parse(lng.toString()));
        initialCameraPosition = CameraPosition(
          target: startLocation!,
          zoom: subDataNearest.isEmpty ? 16 : 16,
          tilt: 0,
          bearing: 0,
        );
        markers.add(Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
              double.parse(lat.toString()), double.parse(lng.toString())),
          icon: BitmapDescriptor.fromBytes(availabeMarkIcons),
        ));
        if (onSearchAdd) {
          if (userBal >= double.parse(logData["min_wallet_bal"].toString())) {
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(double.parse(lat.toString()),
                        double.parse(lng.toString())),
                    zoom: nearestData.isEmpty ? 16 : 16),
              ),
            );
          }
        }

        isLoadingPage = false;
        isLoadingMap = false;
      });
    }
    if (nearestData.isNotEmpty &&
        userBal >= double.parse(logData["min_wallet_bal"].toString())) {
      for (var i = 0; i < nearestData.length; i++) {
        ctr++;
        var items = nearestData[i];
        items["index"] = i.toString();
        final Uint8List markerIcon = await Variables.capturePng(
            context,
            printScreen(AppColor.bodyColor, "$i",
                "${items["min_base_rate"].toString()}-${items["max_base_rate"].toString()}"),
            80,
            true);
        print("markerIcon $markerIcon");
        if (userBal >= double.parse(logData["min_wallet_bal"].toString())) {
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
                    func.Functions.getAmenities(context, "", (cb) {
                      print("cb $cb");
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
        }

        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  markerDisplay(canBook, items) {
    if (items.length > 0) {
      DashboardComponent.getAddress(
              double.parse(items["pa_latitude"].toString()),
              double.parse(items["pa_longitude"].toString()))
          .then((address) {});
    }
  }

  void getFilteredData(data) {
    print("data filter $data");
    if (mounted) {
      setState(() {
        isLoadingPage = true;
        isLoadingMap = true;
      });
    }
    DashboardComponent.getNearest(
        ctxt,
        data["p_type"],
        data["radius"],
        startLocation!.latitude,
        startLocation!.longitude,
        data["vh_type"],
        data["amen"],
        data["is_allow_overnight"], (nearestData) {
      print("nearestData $nearestData");
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
      displayMapData(
        nearestData,
        startLocation!.latitude,
        startLocation!.longitude,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ctxt = context;

    return !hasInternetBal
        ? NoInternetConnected(onTap: () {
            if (isClicked) return;
            setState(() {
              isClicked = true;
              hasInternetBal = true;
            });
            getUsersData();
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
                        child: CustomDisplayText(
                          label: 'Getting nearest parking area for you.',
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : userBal < double.parse(logData["min_wallet_bal"].toString())
                ? noMapDisplay()
                : mapDisplay();
  }

  Widget noMapDisplay() {
    return SafeArea(
      child: Column(
        children: [
          searchBar(false),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  subDataNearest.isEmpty
                      ? Container()
                      : Text(
                          'Parking Nearby',
                          style: GoogleFonts.lato(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 0.06,
                          ),
                        ),
                  Container(
                    height: 8,
                  ),
                  subDataNearest.isEmpty
                      ? Container()
                      : CustomDisplayText(
                          label: 'The best parking space near you',
                          color: const Color.fromARGB(255, 82, 82, 82),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 0,
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

  Widget mapDisplay() {
    return SlidingUpPanel(
      maxHeight: Variables.screenSize.height * 0.50,
      minHeight: 50,
      parallaxEnabled: true,
      parallaxOffset: .3,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24.0),
        topRight: Radius.circular(24.0),
      ),
      controller: panelController,
      body: Column(
        children: [
          Expanded(
            child: _body(),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
            height: 110,
          )
        ],
      ),
      panel: _panel(),
    );
  }

  Widget _body() {
    return Stack(
      fit: StackFit.loose,
      children: [
        GoogleMap(
          mapType: MapType.normal,
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

            // mapController.animateCamera(
            //   CameraUpdate.newCameraPosition(
            //     CameraPosition(target: startLocation!, zoom: 13),
            //   ),
            // );
          },
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
        ),
        SafeArea(child: searchBar(false)),
        Positioned(
          bottom: 20,
          right: 20,
          child: Row(
            children: [
              InkWell(
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
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    "assets/images/vh_list.png",
                    width: 20.013092041015625,
                    height: 19.998329162597656,
                  ),
                ),
              ),
              Container(width: 10),
              InkWell(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String? geoShareId = prefs.getString('geo_share_id');
                  if (geoShareId == null) {
                    showModalConfirmation(
                        context,
                        "luvpark Notice",
                        "This functionality involves utilizing a background process to continuously obtain and update the current location. "
                            "The background process will automatically deactivate once the location sharing has ended.",
                        "Cancel",
                        "Continue", () {
                      Navigator.of(context).pop();
                    }, () async {
                      Navigator.of(context).pop();
                      Variables.customBottomSheet(
                          context,
                          VerifyUserAcct(
                            isInvite: true,
                          ));
                    });
                  } else {
                    showAlertDialog(
                        context, "LuvPark", "You still have active sharing.",
                        () {
                      Navigator.of(context).pop();
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    "assets/images/navigation.png",
                    width: 20.013092041015625,
                    height: 19.998329162597656,
                  ),
                ),
              ),
              Container(width: 10),
              InkWell(
                onTap: () {
                  if (isClicked) return;
                  setState(() {
                    isClicked = true;
                    hasInternetBal = true;
                    isLoadingMap = true;
                    searchController.clear();
                    onSearchAdd = false;
                  });
                  getUsersData();
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    "assets/images/nearest.png",
                    width: 20.013092041015625,
                    height: 19.998329162597656,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _panel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 80,
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
                CustomDisplayText(
                  label:
                      "${jsonDecode(myData!)['first_name'] == null ? "Welcome to luvpark" : "Hi, " + jsonDecode(myData!)['first_name']}",
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  maxFontsize: 1,
                  maxLines: 1,
                ),
                CustomDisplayText(
                  label:
                      "Parking ${subDataNearest.length >= 5 ? "areas" : "area"} near you",
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  maxFontsize: 1,
                  maxLines: 1,
                  color: Colors.grey,
                ),
                Container(height: 10),
              ],
            ),
          ),
          Expanded(
              child: HorizontalListView(
                  nearestData: subDataNearest, startLocation: startLocation!)),
        ],
      ),
    );
  }

  //Search Child
  Widget searchBar(isReadOnly) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16.0),
        ),
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  showFilter();
                },
                child: Icon(
                  Iconsax.filter,
                  color: AppColor.primaryColor,
                ),
              ),
              Expanded(
                child: TextField(
                  readOnly: true,
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search parking area",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 10),
                    hintStyle: Platform.isAndroid
                        ? GoogleFonts.dmSans(
                            color: Color(0x993C3C43),
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            height: 0.08,
                            letterSpacing: -0.41,
                          )
                        : TextStyle(
                            color: Color(0x993C3C43),
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            height: 0.08,
                            letterSpacing: -0.41,
                          ),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return SearchPlaces(
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
                                        .toString()));
                              });
                        });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10),
                child: InkWell(
                  onTap: () {},
                  child: Icon(
                    Icons.search,
                    color: AppColor.primaryColor,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget reserveShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: const Color(0xFFe6faff),
        child: Container(
          height: 100.0,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: const Color(0xFFffffff),
            border: Border.all(
                style: BorderStyle.solid, color: Colors.grey.shade100),
            borderRadius: const BorderRadius.all(
              Radius.circular(15),
            ),
          ),
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
  final List nearestData;
  final LatLng startLocation;
  const HorizontalListView({
    super.key,
    required this.startLocation,
    required this.nearestData,
  });

  @override
  State<HorizontalListView> createState() => _HorizontalListViewState();
}

class _HorizontalListViewState extends State<HorizontalListView> {
  List dataFiltered = [];
  @override
  void initState() {
    dataFiltered = widget.nearestData.take(5).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.nearestData.isEmpty
        ? const NoDataFound(
            size: 70,
            textText:
                "No parking area found nearby. Please search another place.",
          )
        : ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: dataFiltered.length, // Set your desired item count
            itemBuilder: (context, index) {
              print("dataFiltered ${dataFiltered[index]}");
              double distance = Geolocator.distanceBetween(
                widget.startLocation.latitude,
                widget.startLocation.longitude,
                dataFiltered[index]["pa_latitude"],
                dataFiltered[index]["pa_longitude"],
              );
              String getDistanceString(sss) {
                if (sss >= 1000) {
                  // If the distance is greater than or equal to 1000 meters, display in kilometers
                  double distanceInKilometers = sss / 1000;
                  return '${distanceInKilometers.toStringAsFixed(2)} km';
                } else {
                  // Otherwise, display in meters
                  return '${sss.toStringAsFixed(2)} m';
                }
              }

              String finalSttime =
                  "${dataFiltered[index]["start_time"].toString().substring(0, 2)}:${dataFiltered[index]["start_time"].toString().substring(2)}";
              String finalEndtime =
                  "${dataFiltered[index]["end_time"].toString().substring(0, 2)}:${dataFiltered[index]["end_time"].toString().substring(2)}";
              bool isOpen = DashboardComponent.checkAvailability(
                  finalSttime, finalEndtime);

              return NearestList(
                  nearestData: dataFiltered[index],
                  isOpen: isOpen,
                  distance: getDistanceString(distance));
            },
          );
  }

  Widget bottomListDetails(String icon, String label) {
    return Expanded(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image(
          width: 15,
          height: 15,
          fit: BoxFit.fill,
          image: AssetImage("assets/images/$icon.png"),
        ),
        Container(
          width: 5,
        ),
        Expanded(
          child: CustomDisplayText(
            label: label,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            maxLines: 1,
          ),
        )
      ],
    ));
  }

  Widget bottomListDetails2(String icon, String label) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            width: 15,
            height: 15,
            fit: BoxFit.fill,
            image: AssetImage("assets/images/$icon.png"),
          ),
          Container(
            width: 5,
          ),
          Expanded(
            child: CustomDisplayText(
              label: label,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              maxLines: 1,
            ),
          ),
        ],
      ),
    ));
  }

  Widget bottomListDetails3(String icon, String label) {
    return Expanded(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Image(
          width: 15,
          height: 15,
          fit: BoxFit.fill,
          image: AssetImage("assets/images/$icon.png"),
        ),
        Container(
          width: 5,
        ),
        Expanded(
          child: CustomDisplayText(
            label: label,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            maxLines: 1,
          ),
        )
      ],
    ));
  }
}

class NearestList extends StatelessWidget {
  final dynamic nearestData;
  final bool isOpen;
  final String distance;
  const NearestList(
      {super.key,
      required this.nearestData,
      required this.isOpen,
      required this.distance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: InkWell(
        onTap: () {
          CustomModal(context: context).loader();
          func.Functions.getAmenities(context, "", (cb) {
            print("cb $cb");
            if (cb["msg"] == "Success") {
              Navigator.of(context).pop();
              if (cb["data"].isNotEmpty) {
                Variables.pageTrans(
                    ViewDetails(
                        areaData: [nearestData], amenitiesData: cb["data"]),
                    context);
              }
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          width: Variables.screenSize.width * .88,
          height: 74,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomDisplayText(
                      label: nearestData["park_area_name"],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomDisplayText(
                      label:
                          "$distance  ●  ${nearestData["parking_schedule"]}  ●  ${isOpen ? "open" : "close"}",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_right_outlined,
                color: AppColor.primaryColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}
