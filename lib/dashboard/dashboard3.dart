import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luvpark/bottom_tab/bottom_tab.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/dashboard/filter_map_v2.dart';
import 'package:luvpark/dashboard/view_area_details.dart';
import 'package:luvpark/dashboard/view_list.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:luvpark/permission/permission_handler.dart';
import 'package:luvpark/reserve/reserve_form2.dart';
import 'package:luvpark/verify_user/verify_user_account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class Dashboard3 extends StatefulWidget {
  const Dashboard3({super.key});

  @override
  State<Dashboard3> createState() => _Dashboard3State();
}

class _Dashboard3State extends State<Dashboard3> {
  TextEditingController locationController = TextEditingController();
  TextEditingController hoursController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  List pTypeData = [];
  List radiusData = [];
  bool onViewPopup = false;
  late GoogleMapController mapController;
  bool isShowKeyboard = false;
  LatLng? startLocation;
  String locationAddress = "";
  String pTypeCode = "";
  String amenities = "";
  String vtypeId = "";
  String myAddress = "";
  List filteredArea = [];
  List subMapData = [];
  LatLng? directionPosition;
  Uint8List? marketimages;
  double? cameraZoom;
  CameraPosition? initialCameraPosition;
  bool isLoadingPage = true;
  bool isLoadingMap = true;
  bool isBooked = false;
  bool hasInternetBal = true;
  bool isClickedIcon = false;
  List<String> images = [
    'assets/images/geo_tag.png',
    'assets/images/red_marker.png'
  ];
  List<String> searchImage = ['assets/images/search_pin.png'];
  var parentWidget = <Widget>[];
  List dataNearrest = [];
  List subDataNearest = [];
  List<Marker> markers = <Marker>[];
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10000,
  );
  BuildContext? ctxt;
  // ignore: prefer_typing_uninitialized_variables
  var logData;
  bool isDrawerOpen = false;
  String? ddRadius;
  bool onSearchAdd = false;
  bool isClickedMarker = false;
  bool isAtMinHeight = false;
  bool isLoadingSearch = false;
  //Getting radius
  bool isLoadingRadius = true;
  String radiusValue = "0";
  String radiusName = "Radius";
  int ctrR = 0;
  double userBal = 0.0;
  bool isClicked = false;
  double minSheetHeight = 0.4;
  double filterPosition = 0.4;
  //Vehicle Type
  int vehicleId = 0;
  String vehicleName = "Vehicle";
  int ctrV = 0;
  bool isShow = true;
  bool isAllowBooking = true;
  //Hours Relate
  String etaDistance = "";
  String buttonText = "Book";
  late ScrollController _scrollController;
  List sortednearestSubData = [];
  var paddingW = <Widget>[];
  bool isVisible = true;
  List<String> suggestions = [];
  bool isLoading = true;
  int searchData = 0;
  bool isOntapSuggestion = false;

  @override
  void initState() {
    super.initState();
    ddRadius = "10000";
    _scrollController = ScrollController();

    searchController.addListener(() {});

    getUsersData();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    // locationSubscription!.cancel();
  }

  void showFilter() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      barrierLabel: MaterialLocalizations.of(context).dialogLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, _, __) {
        // return VerticalModal(callBack: cb);
        return FilterMap(callBack: (dataCallBack) {
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
    var myData = prefs.getString(
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
      Variables.pageTrans(PermissionHandlerScreen(
        isLogin: true,
        index: 1,
        widget: MainLandingScreen(),
      ));
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
              isAtMinHeight = false;
            });
          }

          DashboardComponent.getNearest(
              ctxt,
              pTypeCode,
              ddRadius,
              startLocation!.latitude,
              startLocation!.longitude,
              vtypeId,
              amenities, (nearestData) {
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
    final Uint8List availabeMarkIcons = await DashboardComponent().getImages(
        images[0], (MediaQuery.of(context).devicePixelRatio * 40).round());
    int ctr = 0;

    if (mounted) {
      setState(() {
        markers = [];
        parentWidget = <Widget>[];
        subDataNearest = nearestData;
        sortednearestSubData = [];

        isLoadingSearch = true;
      });
    }

    if (nearestData.isNotEmpty) {
      for (var i = 0; i < nearestData.length; i++) {
        ctr++;
        var items = nearestData[i];
        items["index"] = i.toString();

        if (userBal >= double.parse(logData["min_wallet_bal"].toString())) {
          markers.add(
            Marker(
                icon: BitmapDescriptor.fromBytes(availabeMarkIcons),
                markerId: MarkerId(ctr.toString()),
                position: LatLng(double.parse(items["pa_latitude"].toString()),
                    double.parse(items["pa_longitude"].toString())),
                onTap: () {
                  subMapData = [];
                  locationAddress = "";
                  if (isBooked) return;
                  setState(() {
                    paddingW = <Widget>[];
                    isLoadingPage = true;
                    isBooked = true;
                    onViewPopup = true;
                  });
                  if (userBal <
                      double.parse(logData["min_wallet_bal"].toString())) {
                    setState(() {
                      isLoadingPage = false;
                      isBooked = false;
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
                    setState(() {
                      onViewPopup = true;
                      isBooked = false;
                      paddingW.add(Row(
                        children: [
                          bottomListDetails(
                              "time_money", "${items["parking_schedule"]}"),
                          bottomListDetails2(
                              "road", "${items["parking_type_name"]} PARKING"),
                          bottomListDetails3("carpool",
                              "${items["ps_vacant_count"].toString()} AVAILABLE"),
                        ],
                      ));
                    });
                    Variables.pageTrans(ViewDetails(areaData: [items]));
                  }
                }),
          );
        }
        parentWidget.add(
          _listItem(items, const EdgeInsets.only(top: 10, bottom: 20), false),
        );

        if (mounted) {
          setState(() {});
        }
      }
    } else {
      setState(() {
        subDataNearest = [];
      });
    }
    if (userBal >= double.parse(logData["min_wallet_bal"].toString())) {
      if (mounted) {
        if (onSearchAdd) {
          final Uint8List availabeMarkIcons =
              await DashboardComponent().getSearchMarker(searchImage[0], 80);
          initialCameraPosition = CameraPosition(
            target: LatLng(
                double.parse(lat.toString()), double.parse(lng.toString())),
            zoom: subDataNearest.isEmpty ? 12 : 16,
          );

          if (nearestData.isNotEmpty && onSearchAdd) {
            markers.add(Marker(
              markerId: const MarkerId('Searched place'),
              position: LatLng(
                  double.parse(lat.toString()), double.parse(lng.toString())),
              icon: BitmapDescriptor.fromBytes(availabeMarkIcons),
            ));
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(double.parse(lat.toString()),
                        double.parse(lng.toString())),
                    zoom: nearestData.isEmpty ? 12 : 16),
              ),
            );
          }
        } else {
          if (mounted) {
            initialCameraPosition = CameraPosition(
              target: startLocation!,
              zoom: 10,
              tilt: 0,
              bearing: 0,
            );
          }
        }
        setState(() {
          startLocation = LatLng(
              double.parse(lat.toString()), double.parse(lng.toString()));

          isLoadingPage = false;
          isLoadingMap = false;
          isLoadingSearch = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoadingPage = false;
          isLoadingMap = false;
        });
      }
    }
  }

  markerDisplay(canBook, items) {
    setState(() {
      isClickedMarker = true;
      isAtMinHeight = false;
    });

    if (items.length > 0) {
      DashboardComponent.getAddress(
              double.parse(items["pa_latitude"].toString()),
              double.parse(items["pa_longitude"].toString()))
          .then((address) {
        locationAddress = address!;

        setState(() {
          minSheetHeight = 0.04;

          subMapData.add(items);
        });
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (mounted) {
      setState(() {
        mapController = controller;
        DefaultAssetBundle.of(context)
            .loadString('assets/custom_map_style/map_style.json')
            .then((String style) {
          controller.setMapStyle(style);
          // for (var marker in markers) {
          //   mapController.showMarkerInfoWindow(marker.markerId);
          // }
        });
      });
    }

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: startLocation!, zoom: 13),
      ),
    );
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
        data["amen"], (nearestData) {
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
      });
      displayMapData(
        nearestData,
        startLocation!.latitude,
        startLocation!.longitude,
      );
    });
  }

  void onChangeTrigger(textSuggest) async {
    await DashboardComponent()
        .fetchSuggestions(
            textSuggest,
            double.parse(startLocation!.latitude.toString()),
            double.parse(startLocation!.longitude.toString()),
            ddRadius.toString())
        .then((suggestions) {
      setState(() {
        this.suggestions = suggestions;
        searchData = suggestions.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ctxt = context;

    return CustomParentWidget(
        appbarColor: AppColor.primaryColor,
        child: Material(
            child: !hasInternetBal
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
                                  label:
                                      'Getting nearest parking area for you.',
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
                    : userBal <
                            double.parse(logData["min_wallet_bal"].toString())
                        ? noMapDisplay()
                        : mapDisplay()));
  }

  Widget noMapDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: Column(
        children: [
          Visibility(
            visible: isVisible,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                ),
                searchBar(false),
                Container(
                  height: 30,
                ),
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
              ],
            ),
          ),
          Visibility(
            visible: isVisible,
            child: Expanded(
              child: isLoadingPage
                  ? ListView.builder(
                      itemCount: 10,
                      itemBuilder: ((context, index) {
                        return reserveShimmer();
                      }),
                    )
                  : subDataNearest.isEmpty
                      ? const NoDataFound()
                      : SingleChildScrollView(
                          child: Column(
                            children: parentWidget,
                          ),
                        ),
            ),
          ),
          Visibility(
            visible: !isVisible,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        setState(() {
                          isVisible = !isVisible;
                        });
                      },
                      child: Icon(Icons.arrow_back)),
                  Container(width: 5),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius:
                            BorderRadius.circular(!isShow ? 10 : 16.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              readOnly: false,
                              enabled: true,
                              autofocus: true,
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: " Search parking area",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 5, right: 5, bottom: 5),
                                alignLabelWithHint: true,
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
                              onChanged: (query) async {
                                onChangeTrigger(query);
                              },
                            ),
                          ),
                          if (searchController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      searchController.clear();
                                    });
                                  },
                                  child: Icon(Icons.close, size: 20)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 10),
          Visibility(
            visible: !isVisible,
            child: Expanded(
              child: FadeInUp(
                child: suggestions.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomDisplayText(
                              label: "No data",
                              fontWeight: FontWeight.normal,
                              color: AppColor.textSubColor,
                              fontSize: 16),
                          Container(
                            height: 10,
                          ),
                        ],
                      )
                    : suggestions[0] == "No Internet"
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                height:
                                    MediaQuery.of(context).size.height * .20,
                                width: MediaQuery.of(context).size.width / 2,
                                image: const AssetImage(
                                    "assets/images/no_internet.png"),
                              ),
                              Container(
                                height: 20,
                              ),
                              CustomDisplayText(
                                  label:
                                      "Please check your internet connection.",
                                  fontWeight: FontWeight.normal,
                                  color: AppColor.textSubColor,
                                  fontSize: 12),
                              Container(
                                height: 10,
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                      onTap: () async {
                                        // if (isOntapSuggestion) return;
                                        CustomModal(context: context).loader();
                                        if (mounted) {
                                          setState(() {
                                            isOntapSuggestion = true;
                                          });
                                        }

                                        await DashboardComponent.searchPlaces(
                                            context,
                                            suggestions[index]
                                                .split("=Rechie=")[0],
                                            (searchedPlace) {
                                          if (searchedPlace == "No Internet") {
                                            Navigator.pop(context);
                                            return;
                                          }
                                          Navigator.of(context).pop();
                                          setState(() {
                                            isVisible = !isVisible;
                                          });

                                          List data = [
                                            {
                                              "lat":
                                                  searchedPlace[0].toString(),
                                              "long":
                                                  searchedPlace[1].toString(),
                                              "place": suggestions[index]
                                                  .toString()
                                                  .split("=Rechie=")[0],
                                              "radius": 10000,
                                              "hours":
                                                  hoursController.text.isEmpty
                                                      ? "1"
                                                      : hoursController.text,
                                            }
                                          ];

                                          for (var marker in markers) {
                                            mapController.hideMarkerInfoWindow(
                                                marker.markerId);
                                          }

                                          DashboardComponent.getNearest(
                                              ctxt,
                                              pTypeCode,
                                              ddRadius.toString(),
                                              data[0]["lat"].toString(),
                                              data[0]["long"].toString(),
                                              vtypeId,
                                              amenities, (nearestData) {
                                            if (mounted) {
                                              setState(() {
                                                onSearchAdd = true;
                                                isLoadingPage = true;
                                                searchController.text =
                                                    data[0]["place"].toString();
                                                startLocation = LatLng(
                                                    double.parse(data[0]["lat"]
                                                        .toString()),
                                                    double.parse(data[0]["long"]
                                                        .toString()));
                                                ddRadius = data[0]["radius"]
                                                    .toString();
                                                hoursController.text =
                                                    data[0]["hours"].toString();
                                                isClickedMarker = false;
                                                //  isAtMinHeight = true;
                                                minSheetHeight = 0.4;

                                                isOntapSuggestion = false;
                                                if (nearestData ==
                                                    "No Internet") {
                                                  hasInternetBal = false;
                                                }
                                              });
                                            }

                                            displayMapData(
                                                nearestData,
                                                data[0]["lat"].toString(),
                                                data[0]["long"].toString());
                                          });
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColor.primaryColor,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: Icon(
                                                  Icons.location_pin,
                                                  size: 20,
                                                  color: AppColor.bodyColor,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 10,
                                            ),
                                            Expanded(
                                                child: CustomDisplayText(
                                              label: suggestions[index]
                                                  .split("=Rechie=")[0],
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              maxLines: 2,
                                            ))
                                          ],
                                        ),
                                      )),
                                  const Divider()
                                ],
                              );
                            },
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget mapDisplay() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                onMapCreated: _onMapCreated,
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
              Positioned(
                bottom: 10,
                right: 10,
                child: SpeedDial(
                    overlayOpacity: 0,
                    animatedIcon: AnimatedIcons.menu_close,
                    children: [
                      SpeedDialChild(
                        child: Image.asset(
                          "assets/images/current_location.png",
                          width: 24,
                          height: 24,
                        ),
                        label: 'Current Location',
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
                      ),
                      SpeedDialChild(
                        child: Image.asset(
                          "assets/images/parking_areas.png",
                          width: 24,
                          height: 24,
                        ),
                        label: "Parking Areas",
                        onTap: () {
                          Variables.pageTrans(
                            ViewList(
                              nearestData: subDataNearest,
                              balance: userBal,
                              bottomW: paddingW,
                              minBalance: double.parse(
                                  logData["min_wallet_bal"].toString()),
                              onTap: () {
                                setState(() {
                                  onViewPopup = false;
                                });
                              },
                            ),
                          );
                        },
                      ),
                      SpeedDialChild(
                        label: 'Share Location',
                        child: Image.asset(
                          "assets/images/share-location.png",
                          width: 24,
                          height: 24,
                        ),
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
                            showAlertDialog(context, "LuvPark",
                                "You still have active sharing.", () {
                              Navigator.of(context).pop();
                            });
                          }
                        },
                      ),
                    ]),
              )
            ],
          ),
        ),
        Visibility(
          visible: !isVisible,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: Variables.screenSize.width,
            height: Variables.screenSize.height * 0.50,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                          child: Icon(Icons.arrow_back)),
                      Container(width: 5),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius:
                                BorderRadius.circular(!isShow ? 10 : 16.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  readOnly: false,
                                  enabled: true,
                                  autofocus: true,
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    hintText: " Search parking area",
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 10, top: 5, right: 5, bottom: 5),
                                    alignLabelWithHint: true,
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
                                  onChanged: (query) async {
                                    onChangeTrigger(query);
                                  },
                                ),
                              ),
                              if (searchController.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          searchController.clear();
                                        });
                                      },
                                      child: Icon(Icons.close, size: 20)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(height: 5),
                  Expanded(
                    child: FadeInUp(
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.white,
                          child: suggestions.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomDisplayText(
                                        label: "No data",
                                        fontWeight: FontWeight.normal,
                                        color: AppColor.textSubColor,
                                        fontSize: 16),
                                    Container(
                                      height: 10,
                                    ),
                                  ],
                                )
                              : suggestions[0] == "No Internet"
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .20,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          image: const AssetImage(
                                              "assets/images/no_internet.png"),
                                        ),
                                        Container(
                                          height: 20,
                                        ),
                                        CustomDisplayText(
                                            label:
                                                "Please check your internet connection.",
                                            fontWeight: FontWeight.normal,
                                            color: AppColor.textSubColor,
                                            fontSize: 12),
                                        Container(
                                          height: 10,
                                        ),
                                      ],
                                    )
                                  : ListView.builder(
                                      itemCount: suggestions.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                                onTap: () async {
                                                  if (isOntapSuggestion) return;
                                                  CustomModal(context: context)
                                                      .loader();
                                                  if (mounted) {
                                                    setState(() {
                                                      isOntapSuggestion = true;
                                                    });
                                                  }

                                                  await DashboardComponent
                                                      .searchPlaces(
                                                          context,
                                                          suggestions[index]
                                                              .split(
                                                                  "=Rechie=")[0],
                                                          (searchedPlace) {
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      isVisible = !isVisible;
                                                    });

                                                    List data = [
                                                      {
                                                        "lat": searchedPlace[0]
                                                            .toString(),
                                                        "long": searchedPlace[1]
                                                            .toString(),
                                                        "place": suggestions[
                                                                index]
                                                            .toString()
                                                            .split(
                                                                "=Rechie=")[0],
                                                        "radius": 10000,
                                                        "hours": hoursController
                                                                .text.isEmpty
                                                            ? "1"
                                                            : hoursController
                                                                .text,
                                                      }
                                                    ];

                                                    for (var marker
                                                        in markers) {
                                                      mapController
                                                          .hideMarkerInfoWindow(
                                                              marker.markerId);
                                                    }

                                                    DashboardComponent
                                                        .getNearest(
                                                            ctxt,
                                                            pTypeCode,
                                                            ddRadius.toString(),
                                                            data[0]["lat"]
                                                                .toString(),
                                                            data[0]["long"]
                                                                .toString(),
                                                            vtypeId,
                                                            amenities,
                                                            (nearestData) {
                                                      if (mounted) {
                                                        setState(() {
                                                          onSearchAdd = true;
                                                          isLoadingPage = true;
                                                          searchController
                                                              .text = data[0]
                                                                  ["place"]
                                                              .toString();
                                                          startLocation = LatLng(
                                                              double.parse(data[
                                                                      0]["lat"]
                                                                  .toString()),
                                                              double.parse(data[
                                                                      0]["long"]
                                                                  .toString()));
                                                          ddRadius = data[0]
                                                                  ["radius"]
                                                              .toString();
                                                          hoursController.text =
                                                              data[0]["hours"]
                                                                  .toString();
                                                          isClickedMarker =
                                                              false;
                                                          //  isAtMinHeight = true;
                                                          minSheetHeight = 0.4;

                                                          isOntapSuggestion =
                                                              false;
                                                          if (nearestData ==
                                                              "No Internet") {
                                                            hasInternetBal =
                                                                false;
                                                          }
                                                        });
                                                      }

                                                      displayMapData(
                                                          nearestData,
                                                          data[0]["lat"]
                                                              .toString(),
                                                          data[0]["long"]
                                                              .toString());
                                                    });
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: AppColor
                                                              .primaryColor,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(3.0),
                                                          child: Icon(
                                                            Icons.location_pin,
                                                            size: 20,
                                                            color: AppColor
                                                                .bodyColor,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                          child:
                                                              CustomDisplayText(
                                                        label: suggestions[
                                                                index]
                                                            .split(
                                                                "=Rechie=")[0],
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        maxLines: 2,
                                                      ))
                                                    ],
                                                  ),
                                                )),
                                            const Divider()
                                          ],
                                        );
                                      },
                                    )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: isVisible,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: Variables.screenSize.width,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchBar(false),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: false,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: Variables.screenSize.width,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
            ),
          ),
        ),
      ],
    );
  }

  //Search Child
  Widget searchBar(isReadOnly) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(!isShow ? 10 : 16.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              readOnly: true,
              enabled: true,
              autofocus: false,
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search parking area",
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9C9C9C),
                ),
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
                setState(() {
                  isVisible = !isVisible;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10),
            child: InkWell(
              onTap: () {
                showFilter();
              },
              child: const Icon(
                Icons.tune_outlined,
                color: Color(0xFF9C9C9C),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _listItem(data, EdgeInsets padding, isShowPopup) {
    String finalSttime =
        "${data["start_time"].toString().substring(0, 2)}:${data["start_time"].toString().substring(2)}";
    String finalEndtime =
        "${data["end_time"].toString().substring(0, 2)}:${data["end_time"].toString().substring(2)}";
    bool isOpen =
        DashboardComponent.checkAvailability(finalSttime, finalEndtime);

    return Container(
      decoration: const BoxDecoration(
          color: Color(0xFFffffff),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 73,
                  height: 90,
                  decoration: ShapeDecoration(
                      color: const Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      image: const DecorationImage(
                          image: AssetImage("assets/images/map_view.png"),
                          fit: BoxFit.cover)),
                ),
                Container(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            top: 1,
                                            left: 8,
                                            right: 7,
                                            bottom: 1),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          color: AppColor.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(41),
                                          ),
                                        ),
                                        child: CustomDisplayText(
                                          label:
                                              "${data["vehicle_types_list"]}",
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        if (userBal <
                                            double.parse(
                                                logData["min_wallet_bal"]
                                                    .toString())) {
                                          setState(() {
                                            isLoadingPage = false;
                                            isBooked = false;
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
                                        }
                                        CustomModal(context: context).loader();

                                        Position position =
                                            await Geolocator.getCurrentPosition(
                                          desiredAccuracy:
                                              LocationAccuracy.high,
                                        );
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);

                                        String mapUrl = "";
                                        String dest =
                                            "${data["pa_latitude"]},${data["pa_longitude"]}";
                                        String origin =
                                            "${position.latitude.toString()},${position.longitude.toString()}";

                                        if (Platform.isIOS) {
                                          mapUrl =
                                              'https://maps.apple.com/?daddr=$dest';
                                        } else {
                                          mapUrl =
                                              "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$dest&travelmode=driving&dir_action=navigate";
                                        }
                                        if (await canLaunchUrl(
                                            Uri.parse(mapUrl))) {
                                          await launchUrl(Uri.parse(mapUrl),
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } else {
                                          throw 'Something went wrong while opening map. Pleaase report problem';
                                        }
                                        // Variables.pageTrans(ParkingRoute(
                                        //   latLng: LatLng(data["pa_latitude"],
                                        //       data["pa_longitude"]),
                                        //   place: data["park_area_name"],
                                        // ));
                                      },
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: ShapeDecoration(
                                          color: const Color(0x160078FF),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.directions,
                                          size: 20,
                                          color: AppColor.primaryColor,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  height: 5,
                                ),
                                CustomDisplayText(
                                  label: "${data["park_area_name"]}",
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 1,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 5,
                      ),
                      data["address"] == null
                          ? Container()
                          : CustomDisplayText(
                              label: "${data["address"]}",
                              color: const Color(0xFF8D8D8D),
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              maxLines: 2,
                            )
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 73,
                  child: Center(
                    child: CustomDisplayText(
                      label: isOpen ? "Open Now" : "Closed",
                      color: isOpen ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 10,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      if (isBooked) return;

                      SharedPreferences pref =
                          await SharedPreferences.getInstance();

                      if (data["vehicle_types_list"].toString().contains("|")) {
                        pref.setString(
                            'availableVehicle',
                            jsonEncode(data["vehicle_types_list"]
                                .toString()
                                .toLowerCase()));
                      } else {
                        pref.setString(
                            'availableVehicle',
                            jsonEncode(data["vehicle_types_list"]
                                .toString()
                                .toLowerCase()));
                      }
                      setState(() {
                        isLoadingPage = true;
                        isBooked = true;
                      });
                      if (userBal <
                          double.parse(logData["min_wallet_bal"].toString())) {
                        setState(() {
                          isLoadingPage = false;
                          isBooked = false;
                        });
                        // ignore: use_build_context_synchronously
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
                        if (onViewPopup) {
                          setState(() {
                            onViewPopup = false;
                          });
                        }
                        // ignore: use_build_context_synchronously
                        CustomModal(
                                context: context,
                                title: "Analyzing distance.\nAlmost there!")
                            .loader();

                        CustomModal(context: context).loader();
                        Functions.getUserBalance((dataBalance) async {
                          if (dataBalance != "null" ||
                              dataBalance != "No Internet") {
                            Functions.computeDistanceResorChckIN(
                                context,
                                LatLng(
                                    data["pa_latitude"], data["pa_longitude"]),
                                (success) {
                              if (success["success"]) {
                                var dataItemParam = [];
                                dataItemParam.add(data);

                                setState(() {
                                  isBooked = false;
                                  isLoadingPage = false;
                                });

                                Navigator.pop(context);
                                Variables.pageTrans(ReserveForm2(
                                  queueChkIn: [
                                    {
                                      "is_chkIn": success["can_checkIn"],
                                      "is_queue":
                                          data["is_allow_reserve"] == "N"
                                    }
                                  ],
                                  areaData: dataItemParam,
                                  isCheckIn: success["can_checkIn"],
                                  pId: data["park_area_id"],
                                  userBal: dataBalance.toString(),
                                ));
                              } else {
                                setState(() {
                                  isBooked = false;
                                  isLoadingPage = false;
                                });
                                Navigator.pop(context);
                              }
                            });
                          } else {
                            setState(() {
                              isBooked = false;
                              isLoadingPage = false;
                            });
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    child: Container(
                      width: Variables.screenSize.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: AppColor.primaryColor),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Center(
                          child: CustomDisplayText(
                            label: "Book",
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Container(
            //   height: 10,
            // ),
            const Divider(
              color: Color.fromARGB(255, 223, 223, 223),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: Row(
                children: [
                  bottomListDetails(
                      "time_money", "${data["parking_schedule"]}"),
                  bottomListDetails2(
                      "road", "${data["parking_type_name"]} PARKING"),
                  bottomListDetails3("carpool",
                      "${data["ps_vacant_count"].toString()} AVAILABLE"),
                ],
              ),
            ),

            const Divider(
              color: Color.fromARGB(255, 223, 223, 223),
            ),
          ],
        ),
      ),
    );
  }

  // bottom List
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
          )
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
}
