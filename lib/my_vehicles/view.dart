import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:luvpark/custom_widgets/scanner.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/custom_text.dart';
import 'controller.dart';

class MyVehicles extends GetView<MyVehiclesController> {
  const MyVehicles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfaf7f7),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("My Vehicles"),
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
                        Container(height: 20),
                        CustomParagraph(
                          text:
                              "Manage your vehicles for a seamless parking experience.",
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
                                                  children: [
                                                    Hero(
                                                      tag: data[
                                                              "vehicle_plate_no"]
                                                          .toString()
                                                          .toUpperCase(),
                                                      createRectTween:
                                                          (begin, end) {
                                                        // Custom Tween for smoother animation
                                                        return MaterialRectCenterArcTween(
                                                            begin: begin,
                                                            end: end);
                                                      },
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: Container(
                                                          width: 60,
                                                          height: 60,
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          decoration:
                                                              BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              fit: BoxFit
                                                                  .contain,
                                                              image: data["image"] ==
                                                                          null ||
                                                                      data["image"]
                                                                          .isEmpty
                                                                  ? AssetImage(
                                                                          "assets/images/no_image.png")
                                                                      as ImageProvider
                                                                  : MemoryImage(
                                                                      base64Decode(
                                                                        removeInvalidCharacters(
                                                                          data[
                                                                              "image"],
                                                                        ),
                                                                      ),
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                        child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        CustomParagraph(
                                                          text: controller
                                                              .vehicleData[
                                                                  index][
                                                                  "vehicle_plate_no"]
                                                              .toString()
                                                              .toUpperCase(),
                                                          color: AppColor
                                                              .headerColor,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 14,
                                                        ),
                                                        Container(height: 5),
                                                        CustomParagraph(
                                                          maxlines: 1,
                                                          text: controller
                                                              .vehicleData[
                                                                  index][
                                                                  "vehicle_brand_name"]
                                                              .toString()
                                                              .toUpperCase(),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12,
                                                        ),
                                                      ],
                                                    )),
                                                    SizedBox(height: 10),
                                                    GestureDetector(
                                                      onTap: () {
                                                        controller
                                                            .onDeleteVehicle(
                                                          controller.vehicleData[
                                                                  index][
                                                              "vehicle_plate_no"],
                                                        );
                                                      },
                                                      child: CircleAvatar(
                                                        radius: 15,
                                                        backgroundColor: Colors
                                                            .red
                                                            .withOpacity(.1),
                                                        child: Icon(
                                                          LucideIcons.trash,
                                                          color: Colors.red,
                                                          size: 18,
                                                        ),
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
                        CustomElevatedButton(
                          onPressed: controller.getVehicleDropDown,
                          text: "Add Vehicle",
                          icon: LucideIcons.plus,
                          iconColor: Colors.white,
                          btnwidth: double.infinity,
                          btnColor: AppColor.primaryColor,
                          textColor: Colors.white,
                          disabled: false,
                        ),
                        Container(height: 20),
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
    String api = "${ApiKeys.getVhSubscription}$plateNo";
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
        elevation: 1,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("Subscription List"),
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 20),
            CustomParagraph(
              text: "Stay updated on your parking subscriptions and renewals.",
            ),
            Container(height: 20),
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
            CustomElevatedButton(
              onPressed: () {
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
              text: "Subscribe",
              icon: LucideIcons.scanLine,
              iconColor: Colors.white,
              btnwidth: double.infinity,
              btnColor: AppColor.primaryColor,
              textColor: Colors.white,
              disabled: false,
            ),
            Container(height: 20),
          ],
        ),
      ),
    );
  }
}
