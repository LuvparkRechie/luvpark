import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:luvpark/no_internet/no_internet_connected.dart';
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
  bool isOpen = false;
  Timer? timers;
  final StreamController<List<Map<String, dynamic>>> _dataStreamController =
      StreamController<List<Map<String, dynamic>>>();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDataPeriodically();
    });
  }

  @override
  void dispose() {
    _dataStreamController.close();
    if (timers != null) {
      timers!.cancel();
    }
    super.dispose();
  }

  Future<void> fetchDataPeriodically() async {
    timers = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    DashboardComponent.getPositionLatLong().then((position) async {
      if (mounted) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
      DashboardComponent.fetchETA(currentLocation!, destLocation!,
          (estimatedData) async {
        print(estimatedData);
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
            _dataStreamController.add(estimatedData);
          }
        } catch (e) {
          print('Error fetching data: $e');
        }
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    if (mounted) {
      setState(() {
        mapController = controller;
        DefaultAssetBundle.of(context)
            .loadString('assets/custom_map_style/map_style.json')
            .then((String style) {
          controller.setMapStyle(style);
        });
      });
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              double.parse(widget.areaData[0]["pa_latitude"].toString()),
              double.parse(widget.areaData[0]["pa_longitude"].toString()),
            ),
            zoom: 12,
          ),
        ),
      );
    }
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
        Variables.pageTrans(ViewRates(
          data: rateData,
          amenData: amenitiesData["items"],
        ));
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
          appbarColor: AppColor.primaryColor,
          child: currentLocation == null
              ? const Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                )
              : StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _dataStreamController.stream,
                  builder: (context, snapshot) {
                    if (!hasNet) {
                      return NoInternetConnected();
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                      ); // Show loading indicator while waiting for data
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error: ${snapshot.error}'); // Show error message if there's an error
                    } else {
                      // Data has been received
                      final List<Map<String, dynamic>> data = snapshot.data!;
                      final firstItem = data.isNotEmpty
                          ? data[0]
                          : null; // Get the first item from the list
                      if (firstItem != null) {
                        return bodyWidget(firstItem);
                      } else {
                        return Text('No data available');
                      }
                    }
                  },
                )),
    );
  }

  Widget bodyWidget(firstItem) {
    return Column(
      children: [
        Expanded(
            child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: currentLocation!,
              ),
              zoomGesturesEnabled: true,
              markers: {
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: currentLocation!,
                  infoWindow: const InfoWindow(title: 'Current Location'),
                ),
                Marker(
                  markerId: const MarkerId('destinationLocation'),
                  position: destLocation!,
                  infoWindow: const InfoWindow(title: 'Destination Location'),
                ),
              },
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              buildingsEnabled: false,
              tiltGesturesEnabled: true,
              polylines: <Polyline>{
                Polyline(
                  polylineId: const PolylineId('polylineId'),
                  color: Colors.blue,
                  width: 5,
                  points: firstItem['poly_line'],
                ),
              },
            ),
            Positioned(
                top: 20,
                left: 8,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _dataStreamController.close();
                      _dataStreamController.done;
                      if (timers != null) {
                        timers!.cancel();
                      }
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )),
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
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 1, left: 8, right: 7, bottom: 1),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(41),
                    ),
                  ),
                  child: CustomDisplayText(
                    label: "${widget.areaData[0]["vehicle_types_list"]}",
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                                label: widget.areaData[0]["park_area_name"],
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                maxLines: 1,
                              ),
                              CustomDisplayText(
                                label: widget.areaData[0]["address"],
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
                              label: firstItem["distance"],
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            CustomDisplayText(
                              label: "${firstItem["time"].toString()}",
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        )
                      ],
                    ),
                    Container(height: 10),
                    Column(
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
                        label: "View rates",
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
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDisplayText(
                          label: "${widget.areaData[0]["ps_vacant_count"]}",
                          color: Color(0xFF131313),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 0.09,
                          letterSpacing: -0.41,
                        ),
                        Container(height: 20),
                        CustomDisplayText(
                          label: "Available parking",
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          height: 0.11,
                          letterSpacing: -0.41,
                        ),
                      ],
                    ),
                    Container(width: 30),
                    Expanded(
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
                                    Functions.getUserBalance(
                                        (dataBalance) async {
                                      if (dataBalance != "null" ||
                                          dataBalance != "No Internet") {
                                        Functions.computeDistanceResorChckIN(
                                            context,
                                            LatLng(
                                                widget.areaData[0]
                                                    ["pa_latitude"],
                                                widget.areaData[0]
                                                    ["pa_longitude"]),
                                            (success) {
                                          if (success["success"]) {
                                            var dataItemParam = [];
                                            dataItemParam
                                                .add(widget.areaData[0]);
                                            print(
                                                "uss ${success["can_checkIn"]}");
                                            setState(() {
                                              isLoadingBtn = false;
                                            });

                                            Navigator.pop(context);
                                            Variables.pageTrans(ReserveForm2(
                                              queueChkIn: [
                                                {
                                                  "is_chkIn":
                                                      success["can_checkIn"],
                                                  "is_queue": widget.areaData[0]
                                                          [
                                                          "is_allow_reserve"] ==
                                                      "N"
                                                }
                                              ],
                                              areaData: dataItemParam,
                                              isCheckIn: success["can_checkIn"],
                                              pId: widget.areaData[0]
                                                  ["park_area_id"],
                                              userBal: dataBalance.toString(),
                                            ));
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
                  ],
                ),
              ),
              Container(height: 20)
            ],
          ),
        ),
      ],
    );
  }
}
