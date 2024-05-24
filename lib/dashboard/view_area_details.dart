import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/dashboard/view_rates.dart';
import 'package:luvpark/http_request/http_request_model.dart';
import 'package:luvpark/reserve/reserve_form2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewDetails extends StatefulWidget {
  final List areaData;
  const ViewDetails({required this.areaData, super.key});

  @override
  State<ViewDetails> createState() => _ViewDetailsState();
}

class _ViewDetailsState extends State<ViewDetails> {
  late GoogleMapController mapController;

  LatLng? currentLocation;
  LatLng? destLocation;
  List<String> digitPairs = [];
  List etaData = [];
  bool hasNet = true;
  bool isLoadingBtn = false;
  String finalSttime = "";
  String finalEndtime = "";
  String currAdd = "";
  bool isOpen = false;
  Timer? timer;

  List<Marker> markers = <Marker>[];
  List<String> vehicles = [];

  @override
  void initState() {
    super.initState();
    digitPairs =
        Variables.splitNumberIntoPairs(widget.areaData[0]["end_time"], 2);
    destLocation = LatLng(
        double.parse(widget.areaData[0]["pa_latitude"].toString()),
        double.parse(widget.areaData[0]["pa_longitude"].toString()));
    finalSttime =
        "${widget.areaData[0]["start_time"].toString().substring(0, 2)}:${widget.areaData[0]["start_time"].toString().substring(2)}";
    finalEndtime =
        "${widget.areaData[0]["end_time"].toString().substring(0, 2)}:${widget.areaData[0]["end_time"].toString().substring(2)}";
    isOpen = DashboardComponent.checkAvailability(finalSttime, finalEndtime);
    vehicles = widget.areaData[0]["vehicle_types_list"].toString().split("|");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  void getCustomMarker(List dataMarker) async {
    List<Marker> newMarkers = []; // Create a new list to hold the markers
    int ctr = 0;
    for (var data in dataMarker) {
      ctr++;
      Uint8List bytessss = await Variables.capturePng(
          context,
          printScreen(data, ctr == 1 ? Colors.white : AppColor.primaryColor),
          30,
          false);

      newMarkers.add(
        Marker(
          markerId: MarkerId(ctr == 1
              ? "MyLocation"
              : widget.areaData[0]["park_area_name"]
                  .toString()), // Use unique marker ids
          infoWindow: InfoWindow(
              title: ctr == 1
                  ? "My Location"
                  : widget.areaData[0]["park_area_name"].toString()),
          position: ctr == 1 ? currentLocation! : destLocation!,
          icon: BitmapDescriptor.fromBytes(bytessss),
        ),
      );
    }

    setState(() {
      markers.addAll(newMarkers);
    });
  }

  Future<void> fetchData() async {
    timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      DashboardComponent.getPositionLatLong().then((position) async {
        if (mounted) {
          setState(() {
            currentLocation = LatLng(position.latitude, position.longitude);
          });
          DashboardComponent.getAddress(position.latitude, position.longitude)
              .then((address) {
            setState(() {
              currAdd = address!;
            });
          });
          getCustomMarker(["my_marker", "dest_marker"]);
        }
        DashboardComponent.fetchETA(currentLocation!, destLocation!,
            (estimatedData) async {
          if (estimatedData == "No Internet") {
            if (mounted) {
              setState(() {
                hasNet = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                hasNet = true;
              });
            }
          }

          try {
            if (mounted) {
              setState(() {
                etaData = estimatedData;
              });
            }
          } catch (e) {}
        });
      });
    });
  }

  void getAmenities(rateData) async {
    HttpRequest(
      api:
          '${ApiKeys.gApiSubFolderGetAmenities}?park_area_id=${widget.areaData[0]["park_area_id"]}',
    ).get().then((amenitiesData) async {
      if (amenitiesData == "No Internet") {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (amenitiesData == null) {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (amenitiesData["items"].isNotEmpty) {
        Navigator.of(context).pop();
        Variables.pageTrans(
            ViewRates(
              data: rateData,
              amenData: amenitiesData["items"],
            ),
            context);
      } else {
        Navigator.of(context).pop();
        showAlertDialog(context, "LuvPark", amenitiesData["msg"], () {
          Navigator.of(context).pop();
        });
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: CustomParentWidget(
          appbarColor: Colors.transparent,
          extendedBody: true,
          child: currentLocation == null
              ? const Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                )
              : etaData.isEmpty
                  ? Container()
                  : bodyWidget(etaData)),
    );
  }

  Widget bodyWidget(etaData) {
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        currentLocation!.latitude < destLocation!.latitude
            ? currentLocation!.latitude
            : destLocation!.latitude,
        currentLocation!.longitude < destLocation!.longitude
            ? currentLocation!.longitude
            : destLocation!.longitude,
      ),
      northeast: LatLng(
        currentLocation!.latitude > destLocation!.latitude
            ? currentLocation!.latitude
            : destLocation!.latitude,
        currentLocation!.longitude > destLocation!.longitude
            ? currentLocation!.longitude
            : destLocation!.longitude,
      ),
    );

    LatLng center = LatLng(
      (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
      (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
    );

    return Column(
      children: [
        //  Container(height: 20),
        Expanded(
            child: Stack(
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

                  mapController.animateCamera(CameraUpdate.newLatLngBounds(
                    bounds,
                    50, // Adjust padding as needed
                  ));
                }
              },
              initialCameraPosition: CameraPosition(
                target: center,
                zoom: 12.0,
              ),
              zoomGesturesEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              buildingsEnabled: false,
              tiltGesturesEnabled: true,
              markers: Set<Marker>.of(markers),
              polylines: <Polyline>{
                Polyline(
                  polylineId: const PolylineId('polylineId'),
                  color: Colors.blue,
                  width: 5,
                  points: etaData[0]['poly_line'],
                ),
              },
            ),
            Positioned(
                top: 30,
                left: 20,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 6.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )),
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: Container(
                  clipBehavior: Clip.antiAlias,
                  padding: EdgeInsets.all(10),
                  decoration: ShapeDecoration(
                    color: Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  width: Variables.screenSize.width,
                  child: Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Icon(
                            Icons.radio_button_checked,
                            color: Colors.orange,
                          ),
                          Dash(
                              direction: Axis.vertical,
                              length: 40,
                              dashLength: 5,
                              dashThickness: 3.0,
                              dashColor: Colors.grey.shade400),
                          Image(
                            image: AssetImage("assets/images/my_marker.png"),
                            height: 20,
                            width: 20,
                          ),
                        ],
                      ),
                      Container(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CustomDisplayText(
                              label: "Current Location",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                            CustomDisplayText(
                              label: currAdd,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.grey,
                            ),
                            Divider(),
                            CustomDisplayText(
                              label: widget.areaData[0]["park_area_name"],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                            CustomDisplayText(
                              label: widget.areaData[0]["address"],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
            Positioned(
                bottom: 20,
                right: 10,
                child: InkWell(
                  onTap: () async {
                    String mapUrl = "";
                    String dest =
                        "${widget.areaData[0]["pa_latitude"]},${widget.areaData[0]["pa_longitude"]}";
                    if (Platform.isIOS) {
                      mapUrl = 'https://maps.apple.com/?daddr=$dest';
                    } else {
                      mapUrl =
                          'https://www.google.com/maps/search/?api=1&query=${widget.areaData[0]["pa_latitude"]},${widget.areaData[0]["pa_longitude"]}';
                    }
                    if (await canLaunchUrl(Uri.parse(mapUrl))) {
                      await launchUrl(Uri.parse(mapUrl),
                          mode: LaunchMode.externalApplication);
                    } else {
                      throw 'Something went wrong while opening map. Pleaase report problem';
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: ShapeDecoration(
                      color: AppColor.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.directions,
                      size: 20,
                      color: AppColor.bodyColor,
                    ),
                  ),
                )),
          ],
        )),

        Container(
          width: Variables.screenSize.width,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                child: SizedBox(
                  height: 30,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vehicles.length,
                      itemBuilder: ((context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 5, left: 8, right: 7, bottom: 5),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: AppColor.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(41),
                              ),
                            ),
                            child: Center(
                              child: CustomDisplayText(
                                label: "${vehicles[index]}",
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      })),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomDisplayText(
                                label: "Parking Slot",
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                maxLines: 1,
                              ),
                              if (widget.areaData[0]["park_size"] == null)
                                CustomDisplayText(
                                  label: "No data yet",
                                  color: const Color(0xFF8D8D8D),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  maxLines: 2,
                                ),
                              if (widget.areaData[0]["park_size"] != null)
                                CustomDisplayText(
                                  label: widget.areaData[0]["park_size"] == null
                                      ? "Unknown"
                                      : "${widget.areaData[0]["park_size"]}",
                                  color: const Color(0xFF8D8D8D),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  maxLines: 2,
                                ),
                              if (widget.areaData[0]["park_size"] != null)
                                CustomDisplayText(
                                  label: widget.areaData[0]["park_size"] == null
                                      ? "Unknown"
                                      : "${widget.areaData[0]["park_orientation"]}",
                                  color: const Color(0xFF8D8D8D),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  maxLines: 2,
                                ),
                            ],
                          ),
                        ),
                        Container(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDisplayText(
                              label: etaData[0]["distance"],
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            CustomDisplayText(
                              label: "${etaData[0]["time"].toString()}",
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.clock_fill,
                            color: Colors.blue,
                            size: 20,
                          ),
                          Container(width: 10),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: isOpen ? "Open now" : "Closed",
                                  style: GoogleFonts.dmSans(
                                    color: isOpen ? Colors.green : Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 0.11,
                                    letterSpacing: -0.41,
                                  ),
                                ),
                                TextSpan(
                                  text: " ● ",
                                  style: GoogleFonts.dmSans(
                                    color: isOpen ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      " Close at ${Variables.convert24HourTo12HourFormat("${digitPairs[0]}:${digitPairs[1]}")}",
                                  style: GoogleFonts.dmSans(
                                    color: Color(0xFF131313),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 0.11,
                                    letterSpacing: -0.41,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        CustomModal(context: context).loader();
                        HttpRequest(
                                api:
                                    '${ApiKeys.gApiSubFolderGetRates}?park_area_id=${widget.areaData[0]["park_area_id"]}')
                            .get()
                            .then((returnData) async {
                          if (returnData == "No Internet") {
                            Navigator.pop(context);
                            showAlertDialog(context, "Error",
                                "Please check your internet connection and try again.",
                                () {
                              Navigator.of(context).pop();
                            });

                            return;
                          }
                          if (returnData == null) {
                            Navigator.of(context).pop();
                            showAlertDialog(context, "Error",
                                "Error while connecting to server, Please try again.",
                                () {
                              Navigator.of(context).pop();
                            });

                            return;
                          }

                          if (returnData["items"].length > 0) {
                            getAmenities(returnData["items"]);
                          } else {
                            Navigator.of(context).pop();
                            showAlertDialog(
                                context, "LuvPark", returnData["msg"], () {
                              Navigator.of(context).pop();
                            });
                          }
                        });
                      },
                      child: CustomDisplayText(
                        label: "View details",
                        fontSize: 14,
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                child: isLoadingBtn
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: const Color(0xFFe6faff),
                        child: CustomButton(
                          label: "",
                          onTap: () {},
                        ),
                      )
                    : widget.areaData[0]["is_allow_reserve"] == "N"
                        ? CustomButton(
                            color: AppColor.primaryColor.withOpacity(.6),
                            textColor: Colors.white,
                            label: "Book",
                            onTap: () {
                              showAlertDialog(context, "LuvPark",
                                  "This area is not available at the moment.",
                                  () {
                                Navigator.of(context).pop();
                              });
                            })
                        : CustomButton(
                            label: "Book",
                            onTap: () async {
                              if (isLoadingBtn) return;
                              CustomModal(context: context).loader();
                              SharedPreferences pref =
                                  await SharedPreferences.getInstance();

                              if (widget.areaData[0]["vehicle_types_list"]
                                  .toString()
                                  .contains("|")) {
                                pref.setString(
                                    'availableVehicle',
                                    jsonEncode(widget.areaData[0]
                                            ["vehicle_types_list"]
                                        .toString()
                                        .toLowerCase()));
                              } else {
                                pref.setString(
                                    'availableVehicle',
                                    jsonEncode(widget.areaData[0]
                                            ["vehicle_types_list"]
                                        .toString()
                                        .toLowerCase()));
                              }
                              if (mounted) {
                                setState(() {
                                  isLoadingBtn = true;
                                });
                              }
                              Functions.getUserBalance((dataBalance) async {
                                if (dataBalance != "null" ||
                                    dataBalance != "No Internet") {
                                  Functions.computeDistanceResorChckIN(
                                      context,
                                      LatLng(widget.areaData[0]["pa_latitude"],
                                          widget.areaData[0]["pa_longitude"]),
                                      (success) {
                                    if (success["success"]) {
                                      var dataItemParam = [];
                                      dataItemParam.add(widget.areaData[0]);
                                      print("uss ${success["can_checkIn"]}");
                                      setState(() {
                                        isLoadingBtn = false;
                                      });

                                      Navigator.pop(context);
                                      Variables.pageTrans(
                                          ReserveForm2(
                                            queueChkIn: [
                                              {
                                                "is_chkIn":
                                                    success["can_checkIn"],
                                                "is_queue": widget.areaData[0]
                                                        ["is_allow_reserve"] ==
                                                    "N"
                                              }
                                            ],
                                            areaData: dataItemParam,
                                            isCheckIn: success["can_checkIn"],
                                            pId: widget.areaData[0]
                                                ["park_area_id"],
                                            userBal: dataBalance.toString(),
                                          ),
                                          context);
                                    } else {
                                      setState(() {
                                        isLoadingBtn = false;
                                      });
                                      Navigator.pop(context);
                                    }
                                  });
                                } else {
                                  setState(() {
                                    isLoadingBtn = false;
                                  });
                                  Navigator.pop(context);
                                }
                              });
                            },
                          ),
              ),
              Container(height: 20)
            ],
          ),
        ),
      ],
    );
  }

  Widget printScreen(String imgName, Color color) {
    return Container(
      width: 120, // Set the width to adjust the size of the marker image
      height: 120,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Image(
          fit: BoxFit.contain,
          image: AssetImage(
            "assets/images/$imgName.png",
          ),
        ),
      ),
    );
  }
}
