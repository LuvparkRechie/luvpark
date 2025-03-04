import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/parking_areas/controller.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/showup_animation.dart';
import '../custom_widgets/variables.dart';
import '../functions/functions.dart';

class ParkingAreas extends GetView<ParkingAreasController> {
  const ParkingAreas({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("Parking Areas"),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Iconsax.arrow_left,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: AppColor.bodyColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 54,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: Offset(0, 0),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(
                          54), // Match TextField border radius
                    ),
                    child: TextField(
                      autofocus: false,
                      style: paragraphStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1, // Ensures single line input
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        hintText: "Search parking zone/address",
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(54),
                          borderSide: BorderSide(color: AppColor.primaryColor),
                        ),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(54),
                          borderSide:
                              BorderSide(width: 1, color: Color(0xFFCECECE)),
                        ),
                        prefixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 15),
                            Icon(LucideIcons.search),
                            Container(width: 10),
                          ],
                        ),
                        hintStyle: paragraphStyle(
                          color: Color(0xFF646263),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        labelStyle: paragraphStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColor.hintColor,
                        ),
                      ),
                      onChanged: (value) {
                        controller.onSearch(value);
                      },
                    ),
                  ),
                ),
                Container(height: 20),
                const CustomParagraph(
                  text: "Nearest Parking",
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
          Obx(
            () => Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: AppColor.bodyColor,
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
                    : controller.searchedZone.isEmpty
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
                                  return const SizedBox(height: 10);
                                },
                                itemCount: controller.searchedZone.length,
                                itemBuilder: (context, index) {
                                  return ShowUpAnimation(
                                    delay: 5 * index,
                                    child: InkWell(
                                      onTap: () async {
                                        CustomDialog()
                                            .loadingDialog(Get.context!);

                                        controller.markerData =
                                            controller.searchedZone;

                                        List ltlng = await Functions
                                            .getCurrentPosition();
                                        LatLng coordinates = LatLng(
                                            ltlng[0]["lat"], ltlng[0]["long"]);
                                        LatLng dest = LatLng(
                                            double.parse(controller
                                                .searchedZone[index]
                                                    ["pa_latitude"]
                                                .toString()),
                                            double.parse(controller
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
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
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
                                                        text: controller
                                                                    .searchedZone[
                                                                index]
                                                            ["park_area_name"],
                                                        fontSize: 16,
                                                        maxlines: 1,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                      Container(height: 5),
                                                      CustomParagraph(
                                                        text: controller
                                                                .searchedZone[
                                                            index]["address"],
                                                        maxlines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontSize: 12,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(width: 10),
                                                LayoutBuilder(
                                                  builder:
                                                      ((context, constraints) {
                                                    final String isPwd =
                                                        controller.searchedZone[
                                                                    index]
                                                                ["is_pwd"] ??
                                                            "N";
                                                    final String vehicleTypes =
                                                        controller.searchedZone[
                                                                index][
                                                            "vehicle_types_list"];
                                                    String iconAsset;

                                                    if (isPwd == "Y") {
                                                      iconAsset = controller
                                                          .getIconAssetForPwdDetails(
                                                              controller.searchedZone[
                                                                      index][
                                                                  "parking_type_code"],
                                                              vehicleTypes);
                                                    } else {
                                                      iconAsset = controller
                                                          .getIconAssetForNonPwdDetails(
                                                              controller.searchedZone[
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                !controller.searchedZone[index]
                                                        ["is_open"]
                                                    ? CustomParagraph(
                                                        text: controller
                                                                    .searchedZone[
                                                                index]["is_open"]
                                                            ? "Open"
                                                            : "Close",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        maxlines: 1,
                                                        fontSize: 12,
                                                        minFontSize: 10,
                                                        color: Colors.red,
                                                      )
                                                    : Row(
                                                        children: [
                                                          Container(
                                                            child: Icon(
                                                              LucideIcons
                                                                  .checkCircle2,
                                                              color:
                                                                  Colors.green,
                                                              weight: 1500,
                                                              size: 20,
                                                            ),
                                                          ),
                                                          Container(width: 10),
                                                          CustomParagraph(
                                                            text: controller.searchedZone[
                                                                        index]
                                                                    ["is_open"]
                                                                ? "Open"
                                                                : "Close",
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            maxlines: 1,
                                                            fontSize: 12,
                                                            minFontSize: 10,
                                                            color: controller
                                                                            .searchedZone[
                                                                        index]
                                                                    ["is_open"]
                                                                ? Colors.green
                                                                : Colors.red,
                                                          ),
                                                        ],
                                                      ),
                                                Container(width: 5),
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
                                                    " ${Variables.timeFormatter2(controller.searchedZone[index]["opened_time"].toString())} - ${Variables.timeFormatter2(controller.searchedZone[index]["closed_time"]).toString()}",
                                                  ),
                                                ),
                                                Container(width: 5),
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
                                                          '${int.parse(controller.searchedZone[index]["ps_vacant_count"].toString())} ${int.parse(controller.searchedZone[index]["ps_vacant_count"].toString()) > 1 ? "slots" : "slot"}',
                                                      fontWeight:
                                                          FontWeight.w500,
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
            maxlines: 1,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            minFontSize: 10,
          ),
        )
      ],
    );
  }
}
