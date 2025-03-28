import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/billers/tabContainer.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/parking_areas/controller.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/custom_button.dart';
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
                                                      CrossAxisAlignment.start,
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                                            color: Colors.green,
                                                            weight: 1500,
                                                            size: 20,
                                                          ),
                                                        ),
                                                        Container(width: 10),
                                                        CustomParagraph(
                                                          text:
                                                              controller.searchedZone[
                                                                          index]
                                                                      [
                                                                      "is_open"]
                                                                  ? "Open"
                                                                  : "Close",
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          maxlines: 1,
                                                          fontSize: 12,
                                                          minFontSize: 10,
                                                          color:
                                                              controller.searchedZone[
                                                                          index]
                                                                      [
                                                                      "is_open"]
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
                                                      LucideIcons.parkingCircle,
                                                      color: Colors.blue,
                                                      weight: 1500,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  Container(width: 10),
                                                  CustomParagraph(
                                                    text:
                                                        '${int.parse(controller.searchedZone[index]["ps_vacant_count"].toString())} ${int.parse(controller.searchedZone[index]["ps_vacant_count"].toString()) > 1 ? "slots" : "slot"}',
                                                    fontWeight: FontWeight.w500,
                                                    maxlines: 1,
                                                    fontSize: 12,
                                                    minFontSize: 10,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(height: 10),
                                          Divider(),
                                          Container(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: CustomButton(
                                                    btnColor: Colors.white,
                                                    textColor:
                                                        AppColor.primaryColor,
                                                    bordercolor:
                                                        AppColor.primaryColor,
                                                    text: "Parking Details",
                                                    onPressed: () async {
                                                      List parkData = [];
                                                      final items = controller
                                                          .searchedZone[index];
                                                      FocusManager.instance
                                                          .primaryFocus!
                                                          .unfocus();

                                                      CustomDialog()
                                                          .loadingDialog(
                                                              Get.context!);

                                                      List ltlng = await Functions
                                                          .getCurrentPosition();

                                                      LatLng coordinates =
                                                          LatLng(
                                                              ltlng[0]["lat"],
                                                              ltlng[0]["long"]);
                                                      LatLng dest = LatLng(
                                                          double.parse(items[
                                                                  "pa_latitude"]
                                                              .toString()),
                                                          double.parse(items[
                                                                  "pa_longitude"]
                                                              .toString()));
                                                      final estimatedData =
                                                          await Functions
                                                              .fetchETA(
                                                                  coordinates,
                                                                  dest);

                                                      if (estimatedData[0]
                                                              ["error"] ==
                                                          "No Internet") {
                                                        Get.back();
                                                        CustomDialog()
                                                            .internetErrorDialog(
                                                                Get.context!,
                                                                () {
                                                          Get.back();
                                                        });

                                                        return;
                                                      }
                                                      parkData = [];
                                                      controller.markerData
                                                          .clear();
                                                      parkData.add(items);
                                                      parkData =
                                                          parkData.map((e) {
                                                        e["distance_display"] =
                                                            "${Variables.parseDistance(double.parse(items["current_distance"].toString()))} away";
                                                        e["time_arrival"] =
                                                            estimatedData[0]
                                                                ["time"];
                                                        e["polyline"] =
                                                            estimatedData[0]
                                                                ['poly_line'];
                                                        return e;
                                                      }).toList();
                                                      controller.markerData.add(
                                                          controller
                                                                  .searchedZone[
                                                              index]);
                                                      controller.getAmenities(
                                                          parkData[0]);
                                                    }),
                                              ),
                                              Container(width: 10),
                                              Expanded(
                                                child: CustomButton(
                                                    text: "Book now",
                                                    onPressed: () async {
                                                      List parkData = [];
                                                      final items = controller
                                                          .searchedZone[index];
                                                      FocusManager.instance
                                                          .primaryFocus!
                                                          .unfocus();

                                                      CustomDialog()
                                                          .loadingDialog(
                                                              Get.context!);

                                                      List ltlng = await Functions
                                                          .getCurrentPosition();

                                                      LatLng coordinates =
                                                          LatLng(
                                                              ltlng[0]["lat"],
                                                              ltlng[0]["long"]);
                                                      LatLng dest = LatLng(
                                                          double.parse(items[
                                                                  "pa_latitude"]
                                                              .toString()),
                                                          double.parse(items[
                                                                  "pa_longitude"]
                                                              .toString()));
                                                      final estimatedData =
                                                          await Functions
                                                              .fetchETA(
                                                                  coordinates,
                                                                  dest);

                                                      if (estimatedData[0]
                                                              ["error"] ==
                                                          "No Internet") {
                                                        Get.back();
                                                        CustomDialog()
                                                            .internetErrorDialog(
                                                                Get.context!,
                                                                () {
                                                          Get.back();
                                                        });

                                                        return;
                                                      }
                                                      parkData = [];
                                                      controller.markerData
                                                          .clear();
                                                      parkData.add(items);
                                                      parkData =
                                                          parkData.map((e) {
                                                        e["distance_display"] =
                                                            "${Variables.parseDistance(double.parse(items["current_distance"].toString()))} away";
                                                        e["time_arrival"] =
                                                            estimatedData[0]
                                                                ["time"];
                                                        e["polyline"] =
                                                            estimatedData[0]
                                                                ['poly_line'];
                                                        return e;
                                                      }).toList();
                                                      Get.back();
                                                      controller.onClickBooking(
                                                          parkData[0]);
                                                    }),
                                              )
                                            ],
                                          )
                                        ],
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

class ParkingDetails extends StatefulWidget {
  final Map<String, dynamic> dataParam;
  const ParkingDetails({super.key, required this.dataParam});

  @override
  State<ParkingDetails> createState() => _ParkingDetailsState();
}

class _ParkingDetailsState extends State<ParkingDetails> {
  int denoInd = 0;
  List ratesWidget = <Widget>[];
  @override
  void initState() {
    super.initState();
    print("dataParam ${widget.dataParam}");
    getVhRatesData(widget.dataParam["vehicleTypes"][0]["vh_types"]);
  }

  String getIconAssetForPwdDetails(
      String parkingTypeCode, String vehicleTypes) {
    switch (parkingTypeCode) {
      case "S":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
          return 'assets/details_logo/blue/blue_cmp.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/blue/blue_mp.svg';
        } else {
          return 'assets/details_logo/blue/blue_cp.svg';
        }
      case "P":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
          return 'assets/details_logo/orange/orange_cmp.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/orange/orange_mp.svg';
        } else {
          return 'assets/details_logo/orange/orange_cp.svg';
        }
      case "C":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
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

  String getIconAssetForNonPwdDetails(
      String parkingTypeCode, String vehicleTypes) {
    switch (parkingTypeCode) {
      case "S":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
          return 'assets/details_logo/blue/blue_cm.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/blue/blue_motor.svg';
        } else {
          return 'assets/details_logo/blue/blue_car.svg';
        }
      case "P":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
          return 'assets/details_logo/orange/orange_cm.svg';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/details_logo/orange/orange_motor.svg';
        } else {
          return 'assets/details_logo/orange/orange_car.svg';
        }
      case "C":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Cars")) {
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

  void getVhRatesData(String vhType) async {
    ratesWidget = <Widget>[];
    List data = widget.dataParam["parkingRatesData"].where((obj) {
      return obj["vehicle_type"]
          .toString()
          .trim()
          .toLowerCase()
          .contains(vhType.toString().trim().toLowerCase());
    }).toList();

    ratesWidget.add(Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.3, color: Color(0xFFE8E8E8)),
                    borderRadius: BorderRadius.all(
                      Radius.circular(7),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: CustomParagraph(
                      text: "Base Rate",
                      maxlines: 1,
                      fontSize: 12,
                    )),
                    CustomParagraph(
                      text: "${data[0]["base_rate"]}",
                      color: Colors.black,
                      textAlign: TextAlign.right,
                      fontSize: 12,
                    )
                  ],
                ),
              ),
            ),
            Container(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.3, color: Color(0xFFE8E8E8)),
                    borderRadius: BorderRadius.all(
                      Radius.circular(7),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: CustomParagraph(
                      text: "Base Hours",
                      maxlines: 1,
                      fontSize: 12,
                    )),
                    CustomParagraph(
                      text: "${data[0]["base_hours"]}",
                      color: Colors.black,
                      textAlign: TextAlign.right,
                      fontSize: 12,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.3, color: Color(0xFFE8E8E8)),
                    borderRadius: BorderRadius.all(
                      Radius.circular(7),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: CustomParagraph(
                      text: "Succeeding Rate",
                      maxlines: 2,
                      fontSize: 12,
                    )),
                    Container(width: 5),
                    CustomParagraph(
                      text: "${data[0]["succeeding_rate"]}",
                      color: Colors.black,
                      textAlign: TextAlign.right,
                      fontSize: 12,
                    )
                  ],
                ),
              ),
            ),
            Container(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                        child: CustomParagraph(
                      text: " ",
                      maxlines: 1,
                    )),
                    CustomParagraph(
                      text: " ",
                      color: Colors.black,
                      textAlign: TextAlign.right,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 15, 15, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(7),
        ),
      ),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 10),
            Center(
              child: Container(
                width: 71,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(56),
                  color: const Color(0xffd9d9d9),
                ),
              ),
            ),
            Container(height: 10),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTitle(
                                text: widget.dataParam["markerData"][0]
                                        ["park_area_name"]
                                    .toString(),
                                fontSize: 18,
                              ),
                              Container(height: 5),
                              CustomParagraph(
                                text: widget.dataParam["markerData"][0]
                                        ["address"]
                                    .toString(),
                                maxlines: 2,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 12,
                              )
                            ],
                          ),
                        ),
                        Container(width: 10),
                        LayoutBuilder(
                          builder: ((context, constraints) {
                            final String isPwd = widget.dataParam["markerData"]
                                    [0]["is_pwd"] ??
                                "N";
                            final String vehicleTypes =
                                widget.dataParam["markerData"][0]
                                    ["vehicle_types_list"];
                            String iconAsset;

                            if (isPwd == "Y") {
                              iconAsset = getIconAssetForPwdDetails(
                                  widget.dataParam["markerData"][0]
                                      ["parking_type_code"],
                                  vehicleTypes);
                            } else {
                              iconAsset = getIconAssetForNonPwdDetails(
                                  widget.dataParam["markerData"][0]
                                      ["parking_type_code"],
                                  vehicleTypes);
                            }
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
                      ],
                    ),
                    Divider(
                      color: AppColor.subtitleColor,
                    ),
                    Row(
                      children: [
                        Icon(
                          Symbols.route_rounded,
                          color: Colors.blue,
                          size: 18,
                        ),
                        Container(width: 5),
                        CustomParagraph(
                          text: widget.dataParam["markerData"][0]
                              ["time_arrival"],
                          fontWeight: FontWeight.w500,
                          maxlines: 1,
                          fontSize: 10,
                          minFontSize: 10,
                        ),
                        CustomParagraph(
                          text:
                              " (${widget.dataParam["markerData"][0]["distance_display"]})",
                          fontWeight: FontWeight.w500,
                          maxlines: 1,
                          fontSize: 10,
                          minFontSize: 10,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.clock2,
                              color: Colors.blue,
                              size: 18,
                            ),
                            CustomParagraph(
                              text:
                                  " ${Variables.timeFormatter2(widget.dataParam["markerData"][0]["opened_time"].toString())} - ${Variables.timeFormatter2(widget.dataParam["markerData"][0]["closed_time"]).toString()}",
                              fontWeight: FontWeight.w500,
                              maxlines: 1,
                              fontSize: 10,
                              minFontSize: 10,
                            )
                          ],
                        ),
                        SizedBox(width: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Icon(
                                LucideIcons.parkingCircle,
                                color: Colors.blue,
                                weight: 1500,
                                size: 18,
                              ),
                            ),
                            Container(width: 5),
                            CustomParagraph(
                              text:
                                  '${int.parse(widget.dataParam["markerData"][0]["ps_vacant_count"].toString())} ${int.parse(widget.dataParam["markerData"][0]["ps_vacant_count"].toString()) > 1 ? "slots" : "slot"} left',
                              fontWeight: FontWeight.w500,
                              maxlines: 1,
                              fontSize: 10,
                              minFontSize: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    _vehicles(),
                    Container(height: 10),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300, width: .5),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomParagraph(
                            text: "Parking Amenities",
                            maxlines: 1,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                          Container(height: 10),
                          _amenities(),
                        ],
                      ),
                    ),
                    Container(height: 20),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300, width: .5),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomParagraph(
                            text: "Parking Rates",
                            maxlines: 1,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                          Container(height: 15),
                          _parkRates(),
                        ],
                      ),
                    ),
                    Container(height: 20),
                  ],
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
      children: [
        icon,
        Flexible(
          child: CustomParagraph(
            text: text,
            fontWeight: FontWeight.w500,
            maxlines: 1,
            fontSize: 10,
            minFontSize: 10,
          ),
        )
      ],
    );
  }

  Widget _vehicles() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: LayoutBuilder(builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int j = 0;
                j < widget.dataParam["vehicleTypes"].length;
                j++) ...[
              Padding(
                padding: const EdgeInsets.only(right: 10, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      weight: 10,
                      Iconsax.tick_circle1,
                      size: 10,
                      color: AppColor.primaryColor,
                    ),
                    SizedBox(width: 5),
                    CustomParagraph(
                      text: '${widget.dataParam["vehicleTypes"][j]['name']}',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    SizedBox(width: 5),
                    CustomParagraph(
                      text:
                          '(${widget.dataParam["vehicleTypes"][j]['count']} slots)',
                      fontStyle: FontStyle.italic,
                      color: AppColor.subtitleColor,
                      fontSize: 10,
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _amenities() {
    return SingleChildScrollView(
      child: widget.dataParam["amenitiesData"].isEmpty
          ? CustomParagraph(text: "No amenities")
          : Column(
              children: [
                for (int i = 0;
                    i < widget.dataParam["amenitiesData"].length;
                    i += 2)
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int j = i; j < i + 2; j++)
                        j < widget.dataParam["amenitiesData"].length
                            ? _buildColumn(
                                widget.dataParam["amenitiesData"][j]
                                    ["parking_amenity_desc"],
                                widget.dataParam["amenitiesData"][j]["icon"],
                              )
                            : _buildPlaceholder(),
                    ],
                  ),
              ],
            ),
    );
  }

  Widget _parkRates() {
    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: widget.dataParam["vehicleTypes"].length >= 3
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.start,
              children: [
                for (int i = 0;
                    i < widget.dataParam["vehicleTypes"].length;
                    i++)
                  Padding(
                    padding: widget.dataParam["vehicleTypes"].length >= 3
                        ? const EdgeInsets.all(0)
                        : EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          denoInd = i;
                          getVhRatesData(
                              widget.dataParam["vehicleTypes"][i]["vh_types"]);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: ShapeDecoration(
                            color: denoInd == i
                                ? const Color(0xFFEDF7FF)
                                : Color.fromARGB(255, 242, 245, 247),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: denoInd == i
                                    ? AppColor.primaryColor
                                    : Color.fromARGB(255, 242, 245, 247),
                              ),
                              borderRadius: BorderRadius.circular(100),
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
                          child: Row(
                            children: [
                              Image(
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                color: denoInd == i
                                    ? AppColor.primaryColor
                                    : Color(0xFFB6C1CC),
                                image: AssetImage(
                                    "assets/dashboard_icon/${widget.dataParam["vehicleTypes"][i]["icon"]}.png"),
                              ),
                              Container(width: 5),
                              CustomParagraph(
                                text: widget.dataParam["vehicleTypes"][i]
                                    ["name"],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: denoInd == i
                                    ? AppColor.primaryColor
                                    : AppColor.paragraphColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Container(height: 20),
            Column(
              children: [
                ...ratesWidget.toList(),
              ],
            ),
          ],
        ),
      ),
      crossFadeState: CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildColumn(String text, String icon) {
    return SizedBox(
      width: MediaQuery.of(Get.context!).size.width / 2.5,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            SvgPicture.asset(
              _getSvgForAmenities(text),
              width: 30.0,
              height: 30.0,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: CustomParagraph(
                text: text.toLowerCase().trim().contains("perpendicular")
                    ? text
                        .trim()
                        .replaceAll("PERPENDICULAR", "\nPERPENDICULAR")
                        .trim()
                    : text.trim().toUpperCase(),
                textAlign: TextAlign.left,
                maxlines: 2,
                fontSize: 10,
                minFontSize: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      width: MediaQuery.of(Get.context!).size.width / 2.2,
      child: Padding(
        padding: const EdgeInsets.all(5), // Padding to ensure spacing
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              child: const Padding(
                padding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: const CustomParagraph(
                text: "",
                textAlign: TextAlign.left,
                maxlines: 2,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSvgForAmenities(String amenText) {
    switch (amenText) {
      case 'ASPHALT FLOOR':
        return 'assets/map_filter/active/asphalt_active.svg';
      case 'CONCRETE FLOOR':
        return 'assets/map_filter/active/concrete_active.svg';
      case 'COVERED / SHADED':
        return 'assets/map_filter/active/covered_active.svg';
      case 'COMPACTED GRAVEL':
        return 'assets/map_filter/active/gravel_active.svg';
      case 'WITH CCTV':
        return 'assets/map_filter/active/cctv_active.svg';
      case 'WITH SECURITY':
        return 'assets/map_filter/active/security_active.svg';
      default:
        return 'assets/area_details/dimension.svg';
    }
  }
}
