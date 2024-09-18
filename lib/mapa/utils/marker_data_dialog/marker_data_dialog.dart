import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/mapa/index.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../custom_widgets/alert_dialog.dart';
import '../../../custom_widgets/custom_text.dart';
import '../../../functions/functions.dart';
import '../../../routes/routes.dart';

class DialogMarker extends StatefulWidget {
  final Function cb;
  final List markerData;
  const DialogMarker({super.key, required this.cb, required this.markerData});

  @override
  State<DialogMarker> createState() => _DialogMarkerState();
}

class _DialogMarkerState extends State<DialogMarker> {
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

  static String getIconAssetForNonPwdDetails(
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardMapController());
    return Wrap(
      children: [
        Container(
            width: MediaQuery.of(Get.context!).size.width,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFFDFE7EF)),
                borderRadius: BorderRadius.circular(15),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 15,
                  offset: Offset(2, 5),
                  spreadRadius: 5,
                )
              ],
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              String formatTimeSched(String time) {
                // Ensure the time string is in 4 characters (HHmm format)
                if (time.length != 4) {
                  return 'Invalid time';
                }

                // Extract hours and minutes
                int hours = int.parse(time.substring(0, 2));
                String minutes = time.substring(2);

                // Determine AM or PM
                String period = hours >= 12 ? 'PM' : 'AM';

                // Convert hours to 12-hour format
                hours = hours % 12;
                hours = hours == 0 ? 12 : hours; // Handle midnight and noon

                // Return formatted time
                return '$hours:$minutes $period';
              }

              String getFormattedSchedule(String startTime, String endTime) {
                String formattedStartTime = formatTimeSched(startTime);
                String formattedEndTime = formatTimeSched(endTime);

                return '$formattedStartTime - $formattedEndTime';
              }

              String startTime = widget.markerData[0]["opened_time"]
                  .toString()
                  .replaceAll(":", "")
                  .trim();
              String endTime = widget.markerData[0]["closed_time"]
                  .toString()
                  .replaceAll(":", "")
                  .trim();

              String formattedSchedule =
                  getFormattedSchedule(startTime, endTime);

              String formatTime(String time) {
                return "${time.substring(0, 2)}:${time.substring(2)}";
              }

              String finalSttime =
                  formatTime(widget.markerData[0]["start_time"]);
              String finalEndtime =
                  formatTime(widget.markerData[0]["end_time"]);
              bool isOpen =
                  Functions.checkAvailability(finalSttime, finalEndtime);

              final String isPwd = widget.markerData[0]["is_pwd"] ?? "N";
              final String vehicleTypes =
                  widget.markerData[0]["vehicle_types_list"];
              String iconAsset;

              if (isPwd == "Y") {
                iconAsset = getIconAssetForPwdDetails(
                    widget.markerData[0]["parking_type_code"], vehicleTypes);
              } else {
                iconAsset = getIconAssetForNonPwdDetails(
                    widget.markerData[0]["parking_type_code"], vehicleTypes);
              }

              print("widget.markerData[0] ${widget.markerData[0]}");
              return Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 22, 15, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          LayoutBuilder(
                            builder: ((context, constraints) {
                              return iconAsset.contains("png")
                                  ? Image(
                                      image: AssetImage(iconAsset),
                                      height: 50,
                                      width: 50,
                                    )
                                  : SvgPicture.asset(
                                      height: 50, width: 50, iconAsset);
                            }),
                          ),
                          Container(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTitle(
                                  text: widget.markerData[0]["park_area_name"],
                                  fontSize: 20,
                                ),
                                CustomParagraph(
                                  text: widget.markerData[0]["address"],
                                  maxlines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 12,
                                )
                              ],
                            ),
                          ),
                          Container(width: 10),
                          Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              onTap: () {
                                Get.back();
                                widget.cb();
                              },
                              child: Container(
                                decoration: ShapeDecoration(
                                  color: Color(0xFFF3F4F6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(37.39),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.close,
                                    color: Color(0xFF747579),
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 15),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side:
                                BorderSide(width: 1, color: Color(0xFFC5E0FF)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                                "assets/dashboard_icon/marker_panel/panel_marker.svg"),
                            Container(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTitle(
                                    text: widget.markerData[0]["time_arrival"]
                                        .toString(),
                                  ),
                                  CustomParagraph(
                                    text: widget.markerData[0]
                                            ["distance_display"]
                                        .toString(),
                                    fontSize: 14,
                                  )
                                ],
                              ),
                            ),
                            Container(width: 10),
                            InkWell(
                              onTap: () {
                                CustomDialog().loadingDialog(context);
                                String mapUrl = "";

                                String dest =
                                    "${widget.markerData[0]["pa_latitude"]},${widget.markerData[0]["pa_longitude"]}";
                                if (Platform.isIOS) {
                                  mapUrl =
                                      'https://maps.apple.com/?daddr=$dest';
                                } else {
                                  mapUrl =
                                      'https://www.google.com/maps/search/?api=1&query=$dest';
                                }
                                Future.delayed(const Duration(seconds: 2),
                                    () async {
                                  Get.back();
                                  if (await canLaunchUrl(Uri.parse(mapUrl))) {
                                    await launchUrl(Uri.parse(mapUrl),
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    throw 'Something went wrong while opening map. Pleaase report problem';
                                  }
                                });
                              },
                              child: Container(
                                  width: 92,
                                  height: 32,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: ShapeDecoration(
                                    color: Color(0xFF0078FF),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: CustomParagraph(
                                    text: 'Direction',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    textAlign: TextAlign.center,
                                  )),
                            )
                          ],
                        ),
                      ),
                      Container(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 15),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side:
                                BorderSide(width: 1, color: Color(0xFFC5E0FF)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/dashboard_icon/marker_panel/panel_parking.svg",
                            ),
                            Container(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTitle(
                                    text:
                                        '${widget.markerData[0]["ps_vacant_count"]} ${widget.markerData[0]["ps_vacant_count"] > 1 ? "slots" : "slot"} available',
                                  ),
                                  CustomParagraph(
                                    text: "Parking Availability",
                                    fontSize: 14,
                                  )
                                ],
                              ),
                            ),
                            Container(width: 10),
                          ],
                        ),
                      ),
                      Container(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 15),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side:
                                BorderSide(width: 1, color: Color(0xFFC5E0FF)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                                "assets/dashboard_icon/marker_panel/panel_time.svg"),
                            Container(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTitle(text: formattedSchedule),
                                  CustomParagraph(
                                    text: "Working Time",
                                    fontSize: 14,
                                  )
                                ],
                              ),
                            ),
                            Container(width: 10),
                            Container(
                              width: 65,
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: ShapeDecoration(
                                color: isOpen
                                    ? Color(0x144CAF50)
                                    : Color.fromARGB(19, 175, 86, 76),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    isOpen ? 'Open' : 'Close',
                                    style: TextStyle(
                                      color: isOpen
                                          ? Color(0xFF4CAF50)
                                          : Colors.red,
                                      fontSize: 14,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 35),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Get.toNamed(Routes.parkingDetails,
                                    arguments: widget.markerData[0]);
                              },
                              child: Container(
                                height: 48,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: ShapeDecoration(
                                  color: Color(0xFFF9FBFC),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(74),
                                  ),
                                ),
                                child: Center(
                                  child: CustomParagraph(
                                    text: 'Details',
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                controller.bookMarkerNow(widget.markerData,
                                    (data) {
                                  Get.back();
                                });
                              },
                              child: Container(
                                  height: 48,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: ShapeDecoration(
                                    color: Color(0xFF0078FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(74),
                                    ),
                                  ),
                                  child: Center(
                                    child: CustomParagraph(
                                      text: 'Book now',
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      )
                    ],
                  ));
            })),
      ],
    );
  }
}
