import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';

import '../../../custom_widgets/alert_dialog.dart';
import '../../../custom_widgets/showup_animation.dart';
import '../../../functions/functions.dart';
import '../../../routes/routes.dart';
import '../../controller.dart';

class SuggestionsScreen extends StatefulWidget {
  final List data;
  final VoidCallback cb;
  SuggestionsScreen({super.key, required this.data, required this.cb});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  List markerData = [];
  @override
  Widget build(BuildContext context) {
    DashboardMapController controller = Get.put(DashboardMapController());
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 34),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .60,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 34),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: StretchingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(overscroll: false),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTitle(
                          text: "Nearby parking found",
                          fontSize: 20,
                        ),
                        Container(height: 10),
                        const CustomParagraph(
                          text: 'Here are the list of parking zone.',
                          textAlign: TextAlign.center,
                        ),
                        Container(height: 10),
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 2);
                            },
                            itemCount: widget.data.length > 5
                                ? widget.data.take(5).toList().length
                                : widget.data.length,
                            itemBuilder: (context, index) {
                              String getDistanceString() {
                                double kmDist = double.parse(widget.data[index]
                                        ["current_distance"]
                                    .toString());

                                if (kmDist >= 1000) {
                                  double distanceInKilometers = kmDist / 1000;
                                  return '${distanceInKilometers.round()} km';
                                } else {
                                  return '${kmDist.round()} m';
                                }
                              }

                              final String isPwd =
                                  widget.data[index]["is_pwd"] ?? "N";
                              final String vehicleTypes =
                                  widget.data[index]["vehicle_types_list"];

                              String iconAsset;
                              // Determine the iconAsset based on parking type and PWD status
                              if (isPwd == "Y") {
                                iconAsset = controller.getIconAssetForPwd(
                                    widget.data[index]["parking_type_code"],
                                    vehicleTypes);
                              } else {
                                iconAsset = controller.getIconAssetForNonPwd(
                                    widget.data[index]["parking_type_code"],
                                    vehicleTypes);
                              }

                              return ShowUpAnimation(
                                delay: 5 * index,
                                child: InkWell(
                                  onTap: () async {
                                    markerData.clear();
                                    CustomDialog().loadingDialog(Get.context!);

                                    markerData.add(widget.data[index]);
                                    List ltlng =
                                        await Functions.getCurrentPosition();
                                    LatLng coordinates = LatLng(
                                        ltlng[0]["lat"], ltlng[0]["long"]);
                                    LatLng dest = LatLng(
                                        double.parse(widget.data[index]
                                                ["pa_latitude"]
                                            .toString()),
                                        double.parse(widget.data[index]
                                                ["pa_longitude"]
                                            .toString()));
                                    final estimatedData =
                                        await Functions.fetchETA(
                                            coordinates, dest);

                                    markerData = markerData.map((e) {
                                      e["distance_display"] =
                                          "${estimatedData[0]["distance"]} away";
                                      e["time_arrival"] =
                                          estimatedData[0]["time"];
                                      return e;
                                    }).toList();
                                    Get.back();
                                    Get.toNamed(Routes.parkingDetails,
                                        arguments: widget.data[index]);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 15, 15, 15),
                                    width:
                                        MediaQuery.of(context).size.width * .88,
                                    decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                      )),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 34,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: const BoxDecoration(),
                                          child: Image(
                                            image: AssetImage(iconAsset),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Container(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CustomTitle(
                                                text: widget.data[index]
                                                    ["park_area_name"],
                                                fontSize: 16,
                                                maxlines: 1,
                                              ),
                                              CustomParagraph(
                                                text: widget.data[index]
                                                    ["address"],
                                                fontSize: 14,
                                                maxlines: 2,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(width: 10),
                                        CustomLinkLabel(
                                            text: getDistanceString())
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(height: 10),
                        CustomButton(
                            text: "Okay",
                            onPressed: () {
                              Get.back();
                              widget.cb();
                            })
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
