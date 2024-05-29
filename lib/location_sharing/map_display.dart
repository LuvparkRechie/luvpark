import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/background_process/foreground_notification.dart';
import 'package:luvpark/bottom_tab/bottom_tab.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/verify_user/verify_user_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapSharingScreen extends StatefulWidget {
  const MapSharingScreen({
    super.key,
  });

  @override
  State<MapSharingScreen> createState() => MapSharingScreenState();
}

class MapSharingScreenState extends State<MapSharingScreen> {
  LatLng? iyahangLocation;

  Timer? timers;

  String userAddress = "";

  MapType _currentMapType = MapType.normal;
  List<Marker> markers = <Marker>[];
  List<String> images = ['assets/images/profIcon.png'];
  double _panelHeightClosed = 80.0;
  double _panelHeightOpen = 300.0;
  double _panelHeight = 90.0;
  bool hasInternet = true;
  var invitedWidget = <Widget>[];
  int ctr = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ambot();
      fetchDataPeriodically();
    });
  }

  @override
  void dispose() {
    if (timers != null) {
      timers!.cancel();
    }
    super.dispose();
  }

  Future<void> fetchData() async {
    String id = await Variables.getUserId();

    await Functions.getSharedData(id, (sharedData) async {
      if (sharedData["data"].isEmpty && sharedData["msg"] == "No Internet") {
        if (mounted) {
          setState(() {
            hasInternet = false;
            markers = <Marker>[];
          });
        }
        return;
      } else {
        if (mounted) {
          setState(() {
            hasInternet = true;
          });
        }
        if (sharedData["data"].isNotEmpty) {
          if (mounted) {
            markers = <Marker>[];
            for (var markerData in sharedData["data"]) {
              ctr++;
              iyahangLocation =
                  LatLng(markerData["latitude"], markerData["longitude"]);

              if (markerData['profile_pic'] == null) {
                final Uint8List availabeMarkIcons = await DashboardComponent()
                    .getImages(images[0],
                        (MediaQuery.of(context).devicePixelRatio * 50).round());
                markers.add(Marker(
                  markerId: MarkerId('${markerData["user_name"]}'),
                  infoWindow: InfoWindow(title: "${markerData["user_name"]}"),
                  position: LatLng(
                      double.parse(markerData["latitude"].toString()),
                      double.parse(markerData["longitude"].toString())),
                  icon: BitmapDescriptor.fromBytes(availabeMarkIcons),
                ));
              } else {
                Uint8List iconBytes = await Variables.getMarkerIcon(
                    context, markerData['profile_pic'], 50);
                BitmapDescriptor icon = BitmapDescriptor.fromBytes(iconBytes);
                markers.add(Marker(
                  markerId: MarkerId('${markerData["user_name"]}'),
                  infoWindow: InfoWindow(title: "${markerData["user_name"]}"),
                  position: LatLng(
                      double.parse(markerData["latitude"].toString()),
                      double.parse(markerData["longitude"].toString())),
                  icon: icon,
                ));
              }
            }
            if (mounted) {
              setState(() {});
            }
          }
        }
      }
    });
  }

  Future<void> getUserLocation() async {
    DashboardComponent.getPositionLatLong().then((position) async {
      final apiUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

      final response = await http.get(
        Uri.parse(
            '$apiUrl?latlng=${position.latitude},${position.longitude}&key=${Variables.mapApiKey}'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final results = decodedResponse['results'] as List<dynamic>;

        if (results.isNotEmpty) {
          final formattedAddress = results[0]['formatted_address'];
          if (mounted) {
            setState(() {
              userAddress = formattedAddress;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              userAddress = 'Address not found';
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            userAddress = 'Error retrieving address';
          });
        }
      }
    });
  }

  Future<void> fetchDataPeriodically() async {
    timers = Timer.periodic(Duration(seconds: 5), (timer) async {
      await fetchData();
      await getUserLocation();
      await fetchPendingInviteData();
    });
  }

  Future<void> ambot() async {
    ForegroundNotif.startLocator();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: iyahangLocation == null ? true : false,
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1)),
        child: CustomParentWidget(
          appbarColor: Colors.transparent,
          extendedBody: true,
          bodyColor: AppColor.bodyColor,
          child: Container(
            color: AppColor.bodyColor,
            width: Variables.screenSize.width,
            height: Variables.screenSize.height,
            child: mapDisplay(),
          ),
        ),
      ),
    );
  }

  Widget mapDisplay() {
    return iyahangLocation == null
        ? const Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
          )
        : Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      mapType: _currentMapType,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(iyahangLocation!.latitude,
                            iyahangLocation!.longitude),
                        zoom: 14.4746,
                      ),
                      markers: Set<Marker>.of(markers),
                      onMapCreated: (GoogleMapController controller) {
                        // DefaultAssetBundle.of(context)
                        //     .loadString(
                        //         'assets/custom_map_style/map_style.json')
                        //     .then((String style) {
                        //   controller.setMapStyle(style);
                        // });
                      },
                    ),
                    Positioned(
                      bottom: 10,
                      right: 20,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: FloatingActionButton(
                          backgroundColor: AppColor.primaryColor,
                          onPressed: () {
                            _showMapTypeSelector(context);
                          },
                          child: Icon(
                            Icons.layers,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 30,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: FloatingActionButton(
                          backgroundColor: AppColor.primaryColor,
                          onPressed: () {
                            showModalConfirmation(
                              context,
                              "Confirmation",
                              "Are you sure you want close this page?",
                              "",
                              "Yes",
                              () {
                                Navigator.of(context).pop();
                              },
                              () async {
                                setState(() {
                                  timers!.cancel();
                                });
                                Navigator.of(context).pop();
                                Variables.pageTrans(
                                    MainLandingScreen(), context);
                              },
                            );
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onVerticalDragUpdate: _onVerticalDragUpdate,
                child: AnimatedContainer(
                  duration: Duration(microseconds: 0),
                  height: _panelHeight,
                  width: Variables.screenSize.width,
                  color: Color(0xFFF8F8F8),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 80,
                            height: 10,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade200),
                          ),
                        ),
                        Container(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: CustomDisplayText(
                                label: "Sharing location with",
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                minFontsize: 1,
                                maxLines: 1,
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                Variables.customBottomSheet(
                                    context,
                                    VerifyUserAcct(
                                      isInvite: false,
                                    ));
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColor.primaryColor,
                                child: Icon(Icons.person_add,
                                    color: AppColor.bodyColor),
                              ),
                            )
                          ],
                        ),
                        Expanded(
                            child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(height: 10),
                              Container(
                                width: 110,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 243, 228, 206),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 3),
                                  child: Center(
                                    child: CustomDisplayText(
                                      label: "Pending Invitation",
                                      fontSize: 12,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                      minFontsize: 1,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                children: invitedWidget,
                              )
                            ],
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade50,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.location,
                            color: Colors.black54,
                          ),
                          Container(width: 10),
                          Expanded(
                            child: CustomDisplayText(
                              label: userAddress,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      Container(height: 20),
                      CustomButton(
                          label: "End Sharing",
                          onTap: () async {
                            showModalConfirmation(
                                context,
                                "Share Location",
                                "Are you sure you want to end sharing?",
                                "",
                                "Yes", () {
                              Navigator.of(context).pop();
                            }, () async {
                              Navigator.pop(context);
                              CustomModal(context: context).loader();

                              Functions.endSharing((cb) async {
                                Navigator.pop(context);
                                if (cb == "Success") {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();

                                  prefs.remove("geo_share_id");
                                  prefs.remove("geo_connect_id");
                                  if (mounted) {
                                    setState(() {
                                      timers!.cancel();
                                    });
                                  }
                                  showAlertDialog(context, "Success",
                                      "Live sharing successfully ended.",
                                      () async {
                                    Navigator.of(context).pop();
                                    ForegroundNotif.onStop();
                                    Navigator.of(context).pushNamed('/');
                                  });
                                }
                              });
                            });
                          }),
                    ],
                  ),
                ),
              )
            ],
          );
  }

  void _showMapTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.map,
                  color: AppColor.primaryColor,
                ),
                title: CustomDisplayText(
                    label: "Normal", fontSize: 14, fontWeight: FontWeight.bold),
                onTap: () {
                  _changeMapType(MapType.normal);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.satellite, color: AppColor.primaryColor),
                title: CustomDisplayText(
                    label: "Satellite",
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                onTap: () {
                  _changeMapType(MapType.satellite);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.terrain, color: AppColor.primaryColor),
                title: CustomDisplayText(
                    label: "Terrain",
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                onTap: () {
                  _changeMapType(MapType.terrain);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeMapType(MapType mapType) {
    if (mounted) {
      setState(() {
        _currentMapType = mapType;
      });
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _panelHeight -= details.primaryDelta!; // Adjusted to subtract delta
      if (_panelHeight > _panelHeightOpen) {
        _panelHeight = _panelHeightOpen;
      } else if (_panelHeight < _panelHeightClosed) {
        _panelHeight = _panelHeightClosed;
      }
    });
  }

  Future<void> fetchPendingInviteData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? geoShareId = prefs.getString("geo_share_id");

    HttpRequest(
      api: "${ApiKeys.gApiLuvParkPutShareLoc}?geo_share_id=${geoShareId!}",
    ).get().then((pendingInviteData) async {
      if (pendingInviteData.isNotEmpty) {
        invitedWidget = <Widget>[];
        for (dynamic dataRow in pendingInviteData["items"]) {
          invitedWidget.add(Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade100)),
            margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: ClipRRect(
                      borderRadius: BorderRadius.circular(80 / 2),
                      child: dataRow["profile_pic"] == null
                          ? const Image(
                              image: AssetImage("assets/images/profIcon.png"))
                          : Image.memory(
                              const Base64Decoder()
                                  .convert(dataRow["profile_pic"].toString()),
                              fit: BoxFit.cover,
                              height: 50,
                              width: 50,
                              gaplessPlayback: true,
                            ),
                    )),
                  ),
                  Container(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDisplayText(
                          label: dataRow["user_name"],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 30, 30, 30),
                        ),
                        CustomDisplayText(
                          label: dataRow["mobile_no"],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  Container(width: 10),
                  InkWell(
                      onTap: () {
                        CustomModal(context: context).loader();
                        Functions.inviteFriend(
                            context, dataRow["user_id"], true);
                      },
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColor.primaryColor.withOpacity(.1),
                        child: Icon(Icons.near_me_outlined,
                            color: AppColor.primaryColor),
                      )),
                ],
              ),
            ),
          ));
        }
      } else {
        setState(() {
          invitedWidget = <Widget>[];
        });
      }
    });
  }
}
