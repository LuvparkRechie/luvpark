import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/no_data_found.dart';
import 'package:luvpark_get/parking_areas/controller.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/showup_animation.dart';
import '../custom_widgets/variables.dart';
import '../functions/functions.dart';

class ParkingAreas extends GetView<ParkingAreasController> {
  const ParkingAreas({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.primaryColor, // Set status bar color
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));
    Get.put(ParkingAreasController());
    final ParkingAreasController ct = Get.put(ParkingAreasController());

    return Scaffold(
      appBar: const CustomAppbar(
        title: "Parking Areas",
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 20),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color(0xFFFBFBFB),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0x232563EB)),
                  borderRadius: BorderRadius.circular(54),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/dashboard_icon/search.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: "Search parking zone/address",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(left: 10),
                          hintStyle:
                              paragraphStyle(fontWeight: FontWeight.w600),
                        ),
                        style: paragraphStyle(),
                        onChanged: (String value) async {
                          ct.onSearch(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 20),
            const CustomParagraph(
              text: "Nearest Parking",
              fontWeight: FontWeight.w700,
            ),
            Container(height: 10),
            Obx(
              () => Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    //   color: AppColor.bodyColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(7),
                    ),
                  ),
                  child: controller.isLoadDisplay.value
                      ? Center(
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : ct.searchedZone.isEmpty
                          ? NoDataFound(
                              text: "There are no parking areas to display.",
                            )
                          : ScrollConfiguration(
                              behavior:
                                  ScrollBehavior().copyWith(overscroll: false),
                              child: StretchingOverscrollIndicator(
                                axisDirection: AxisDirection.down,
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(height: 2);
                                  },
                                  itemCount: ct.searchedZone.length,
                                  itemBuilder: (context, index) {
                                    return ShowUpAnimation(
                                      delay: 5 * index,
                                      child: InkWell(
                                        onTap: () async {
                                          CustomDialog()
                                              .loadingDialog(Get.context!);

                                          controller.markerData =
                                              ct.searchedZone;

                                          List ltlng = await Functions
                                              .getCurrentPosition();
                                          LatLng coordinates = LatLng(
                                              ltlng[0]["lat"],
                                              ltlng[0]["long"]);
                                          LatLng dest = LatLng(
                                              double.parse(ct
                                                  .searchedZone[index]
                                                      ["pa_latitude"]
                                                  .toString()),
                                              double.parse(ct
                                                  .searchedZone[index]
                                                      ["pa_longitude"]
                                                  .toString()));
                                          final estimatedData =
                                              await Functions.fetchETA(
                                                  coordinates, dest);

                                          controller.markerData.value =
                                              controller.markerData.map((e) {
                                            e["distance_display"] =
                                                "${Variables.parseDistance(double.parse(e["current_distance"].toString()))} away";
                                            e["time_arrival"] =
                                                estimatedData[0]["time"];
                                            return e;
                                          }).toList();
                                          Get.back();
                                          if (estimatedData[0]["error"] ==
                                              "No Internet") {
                                            CustomDialog().internetErrorDialog(
                                                Get.context!, () {
                                              Get.back();
                                            });

                                            return;
                                          } else {
                                            Get.back();
                                            controller.callback(
                                                [controller.markerData[index]]);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 15, 10, 15),
                                          decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                              color: Colors.grey.shade200,
                                            )),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        CustomTitle(
                                                          text: ct.searchedZone[
                                                                  index][
                                                              "park_area_name"],
                                                          fontSize: 16,
                                                          maxlines: 1,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                        CustomParagraph(
                                                          text: ct.searchedZone[
                                                              index]["address"],
                                                          maxlines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color(0xFF1E1E1E),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(width: 10),
                                                  LayoutBuilder(
                                                    builder: ((context,
                                                        constraints) {
                                                      final String isPwd =
                                                          ct.searchedZone[index]
                                                                  ["is_pwd"] ??
                                                              "N";
                                                      final String
                                                          vehicleTypes =
                                                          ct.searchedZone[index]
                                                              [
                                                              "vehicle_types_list"];
                                                      String iconAsset;

                                                      if (isPwd == "Y") {
                                                        iconAsset = controller
                                                            .getIconAssetForPwdDetails(
                                                                ct.searchedZone[
                                                                        index][
                                                                    "parking_type_code"],
                                                                vehicleTypes);
                                                      } else {
                                                        iconAsset = controller
                                                            .getIconAssetForNonPwdDetails(
                                                                ct.searchedZone[
                                                                        index][
                                                                    "parking_type_code"],
                                                                vehicleTypes);
                                                      }
                                                      return iconAsset
                                                              .contains("png")
                                                          ? Image(
                                                              image: AssetImage(
                                                                  iconAsset),
                                                              height: 45,
                                                              width: 45,
                                                            )
                                                          : SvgPicture.asset(
                                                              height: 45,
                                                              width: 45,
                                                              iconAsset);
                                                    }),
                                                  ),
                                                ],
                                              ),
                                              Container(height: 10),
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Visibility(
                                                        visible: ct
                                                                .searchedZone[
                                                            index]["is_open"],
                                                        child: Container(
                                                          child: Icon(
                                                            LucideIcons
                                                                .checkCircle2,
                                                            color: Colors.green,
                                                            weight: 1500,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(width: 10),
                                                      CustomParagraph(
                                                        text: ct.searchedZone[
                                                                    index]
                                                                ["is_open"]
                                                            ? "Open"
                                                            : "Close",
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        maxlines: 1,
                                                        fontSize: 12,
                                                        minFontSize: 10,
                                                        color: ct.searchedZone[
                                                                    index]
                                                                ["is_open"]
                                                            ? null
                                                            : Colors.red,
                                                      ),
                                                    ],
                                                  ),
                                                  Container(width: 10),
                                                  Expanded(
                                                    child: _openTime(
                                                      Container(
                                                        child: Icon(
                                                          LucideIcons.clock2,
                                                          color: Colors.blue,
                                                          weight: 1500,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      " ${Variables.timeFormatter2(ct.searchedZone[index]["opened_time"].toString())} - ${Variables.timeFormatter2(ct.searchedZone[index]["closed_time"]).toString()}",
                                                    ),
                                                  ),
                                                  Container(width: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        child: Icon(
                                                          LucideIcons
                                                              .parkingCircle,
                                                          color: Colors.blue,
                                                          weight: 1500,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      Container(width: 10),
                                                      CustomParagraph(
                                                        text:
                                                            '${int.parse(ct.searchedZone[index]["ps_vacant_count"].toString())} ${int.parse(ct.searchedZone[index]["ps_vacant_count"].toString()) > 1 ? "slots" : "slot"} left',
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        maxlines: 1,
                                                        fontSize: 12,
                                                        minFontSize: 10,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _openTime(dynamic icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        Container(width: 10),
        Flexible(
          child: CustomParagraph(
            text: text,
            fontWeight: FontWeight.w700,
            maxlines: 1,
            fontSize: 12,
            minFontSize: 10,
          ),
        )
      ],
    );
  }
}
