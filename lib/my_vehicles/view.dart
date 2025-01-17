import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/custom_text.dart';
import '../custom_widgets/scanner.dart';
import 'controller.dart';

class MyVehicles extends GetView<MyVehiclesController> {
  const MyVehicles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.getVehicleDropDown();
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: AppColor.bodyColor,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Obx(
        () => controller.isLoadingPage.value
            ? const PageLoader()
            : !controller.isNetConn.value
                ? NoInternetConnected(
                    onTap: controller.onRefresh,
                  )
                : Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 10),
                        Stack(
                          children: [
                            Row(
                              children: [
                                // Back Button (start)
                                InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: Color(0xFF0078FF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(43),
                                      ),
                                      shadows: [
                                        BoxShadow(
                                          color: Color(0x0C000000),
                                          blurRadius: 15,
                                          offset: Offset(0, 5),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      LucideIcons.arrowLeft,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Align(
                                alignment: Alignment.center,
                                child: CustomTitle(
                                  text: "My Vehicles",
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(height: 20),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: controller.onRefresh,
                            child: controller.vehicleData.isEmpty
                                ? const NoDataFound(
                                    text: "No registered vehicle",
                                  )
                                : StretchingOverscrollIndicator(
                                    axisDirection: AxisDirection.down,
                                    child: ScrollConfiguration(
                                      behavior: ScrollBehavior()
                                          .copyWith(overscroll: false),
                                      child: ListView.builder(
                                        itemCount:
                                            controller.vehicleData.length,
                                        itemBuilder: (context, index) {
                                          dynamic data =
                                              controller.vehicleData[index];

                                          String removeInvalidCharacters(
                                              String input) {
                                            final RegExp validChars =
                                                RegExp(r'[^A-Za-z0-9+/=]');

                                            return input.replaceAll(
                                                validChars, '');
                                          }

                                          return GestureDetector(
                                            onTap: () {
                                              Get.to(() => DetailPage(
                                                    data: data,
                                                    tag:
                                                        data["vehicle_plate_no"]
                                                            .toString()
                                                            .toUpperCase(),
                                                  ));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 15),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1.0,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      spreadRadius: 1,
                                                      blurRadius: 6,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    // Vehicle details
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Hero(
                                                                tag: data[
                                                                        "vehicle_plate_no"]
                                                                    .toString()
                                                                    .toUpperCase(),
                                                                createRectTween:
                                                                    (begin,
                                                                        end) {
                                                                  // Custom Tween for smoother animation
                                                                  return MaterialRectCenterArcTween(
                                                                      begin:
                                                                          begin,
                                                                      end: end);
                                                                },
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  child:
                                                                      Container(
                                                                    width: 60,
                                                                    height: 60,
                                                                    margin: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      image:
                                                                          DecorationImage(
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        image: data["image"] == null ||
                                                                                data["image"].isEmpty
                                                                            ? AssetImage("assets/images/no_image.png") as ImageProvider
                                                                            : MemoryImage(
                                                                                base64Decode(
                                                                                  removeInvalidCharacters(
                                                                                    data["image"],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 10),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  controller
                                                                      .onDeleteVehicle(
                                                                    controller.vehicleData[
                                                                            index]
                                                                        [
                                                                        "vehicle_plate_no"],
                                                                  );
                                                                },
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 15,
                                                                  backgroundColor:
                                                                      Colors.red
                                                                          .withOpacity(
                                                                              .1),
                                                                  child: Icon(
                                                                    LucideIcons
                                                                        .trash,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 18,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 10),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8.0),
                                                            child: Row(
                                                              children: [
                                                                CustomParagraph(
                                                                  text: controller
                                                                      .vehicleData[
                                                                          index]
                                                                          [
                                                                          "vehicle_plate_no"]
                                                                      .toString()
                                                                      .toUpperCase(),
                                                                  color: AppColor
                                                                      .headerColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 14,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(height: 5),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8.0),
                                                            child:
                                                                CustomParagraph(
                                                              maxlines: 1,
                                                              text: controller
                                                                  .vehicleData[
                                                                      index][
                                                                      "vehicle_brand_name"]
                                                                  .toString()
                                                                  .toUpperCase(),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                        ],
                                                      ),
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
                      ],
                    ),
                  ),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final String tag;
  final dynamic data;

  const DetailPage({
    Key? key,
    required this.tag,
    this.data,
  }) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List subsListData = [];
  bool hasNet = true;
  bool isLoading = true;
  final controller = Get.put(MyVehiclesController());

  String removeInvalidCharacters(String input) {
    final RegExp validChars = RegExp(r'[^A-Za-z0-9+/=]');

    return input.replaceAll(validChars, '');
  }

  @override
  void initState() {
    super.initState();
    getVhSubscriptionDetails();
  }

  Future<void> getVhSubscriptionDetails() async {
    String plateNo = widget.data["vehicle_plate_no"];
    String api =
        "${ApiKeys.gApiGetSubscriptionDetails}?vehicle_plate_no=$plateNo";
    final objData = await HttpRequest(
      api: api,
    ).get();

    setState(() {
      isLoading = false;
      if (objData == "No Internet") {
        hasNet = false;
        return;
      }
      hasNet = true;
      if (objData == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      } else {
        subsListData = objData['items'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Color(0xFF0078FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(43),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.arrowLeft,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Hero(
              tag: widget.tag,
              createRectTween: (begin, end) {
                // Custom Tween for smoother animation
                return MaterialRectCenterArcTween(begin: begin, end: end);
              },
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.width / 2.5,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: widget.data["image"] == null ||
                                widget.data["image"].isEmpty
                            ? AssetImage("assets/images/no_image.png")
                                as ImageProvider
                            : MemoryImage(
                                base64Decode(
                                  removeInvalidCharacters(
                                    widget.data["image"],
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
            child: GestureDetector(
              onTap: () {
                FocusNode().unfocus();
                Get.to(
                  ScannerScreen(
                    onchanged: (ScannedData args) async {
                      String result = args.scannedHash;

                      if (result.isEmpty) {
                        CustomDialog().errorDialog(
                          Get.context!,
                          "Invalid QR Code",
                          "The scanned QR code is invalid. Please try again.",
                          () {
                            Get.back();
                          },
                        );
                        return;
                      } else {
                        bool retSub = await controller.subscrbeVh(
                          result,
                          widget.data["vehicle_plate_no"].toString(),
                          widget.data["vehicle_brand_id"].toString(),
                        );

                        if (retSub) {
                          setState(() {
                            isLoading = true;
                          });
                          getVhSubscriptionDetails();
                        }
                      }
                    },
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.scanLine,
                      color: AppColor.primaryColor,
                    ),
                    Container(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTitle(
                            text: "Subscribe",
                            fontWeight: FontWeight.w700,
                          ),
                          Container(height: 5),
                          CustomParagraph(
                            text: "Scan QR code to subscribe.",
                            maxlines: 1,
                            fontSize: 13,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                CustomTitle(text: "Subscription List"),
                CustomParagraph(text: " (${subsListData.length})")
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColor.bodyColor,
              child: isLoading
                  ? const PageLoader()
                  : subsListData.isEmpty
                      ? NoDataFound(
                          text: "No subscription data",
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                          itemCount: subsListData.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.0,
                                ),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTitle(
                                      text:
                                          "Plate No: ${subsListData[index]["vehicle_plate_no"]}"),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomParagraph(
                                        text:
                                            "Brand: ${subsListData[index]["vehicle_brand_name"]}",
                                        color: Colors.grey[600],
                                      ),
                                      CustomParagraph(
                                        text:
                                            "Rate: ${subsListData[index]["subscription_rate"]}",
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  CustomParagraph(
                                      text:
                                          "Type: ${subsListData[index]["vehicle_type"]} (${subsListData[index]["subscription_type"]})"),
                                  SizedBox(height: 8),
                                  CustomParagraph(
                                    text:
                                        "Location: ${subsListData[index]["group_area_name"]} - ${subsListData[index]["park_area_name"]}",
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: 5,
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
