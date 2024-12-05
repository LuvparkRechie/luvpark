import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';

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

                            // Positioned My Vehicles Title (centered)
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
                                          String removeInvalidCharacters(
                                              String input) {
                                            final RegExp validChars =
                                                RegExp(r'[^A-Za-z0-9+/=]');

                                            return input.replaceAll(
                                                validChars, '');
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
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
                                                        SizedBox(height: 5),
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
                                                    ),
                                                  ),
                                                  // Vehicle image
                                                  Container(
                                                    width: 60,
                                                    height: 40,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        fit: BoxFit.contain,
                                                        image: controller.vehicleData[
                                                                            index]
                                                                        [
                                                                        "image"] ==
                                                                    null ||
                                                                controller
                                                                    .vehicleData[
                                                                        index][
                                                                        "image"]
                                                                    .isEmpty
                                                            ? AssetImage(
                                                                    "assets/images/no_image.png")
                                                                as ImageProvider
                                                            : MemoryImage(
                                                                base64Decode(
                                                                  removeInvalidCharacters(
                                                                    controller.vehicleData[
                                                                            index]
                                                                        [
                                                                        "image"],
                                                                  ),
                                                                ),
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                  // More options button
                                                  GestureDetector(
                                                    onTap: () {
                                                      Get.bottomSheet(
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  16),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              SizedBox(
                                                                  height: 10),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  // Subscribe Button
                                                                  Flexible(
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        FocusNode()
                                                                            .unfocus();
                                                                        Get.to(
                                                                          ScannerScreen(
                                                                            onchanged:
                                                                                (ScannedData args) {
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
                                                                                controller.subscrbeVh(
                                                                                  result,
                                                                                  controller.vehicleData[index]["vehicle_plate_no"].toString(),
                                                                                  controller.vehicleData[index]["vehicle_brand_id"].toString(),
                                                                                );
                                                                              }
                                                                            },
                                                                          ),
                                                                        );
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            100,
                                                                        margin: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(color: Colors.black12),
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.black.withOpacity(0.15),
                                                                              blurRadius: 8,
                                                                              spreadRadius: 2,
                                                                              offset: Offset(0, 4),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Image.asset(
                                                                              "assets/images/subscribe.png",
                                                                              fit: BoxFit.cover,
                                                                              color: AppColor.primaryColor,
                                                                              height: 36,
                                                                              width: 36,
                                                                            ),
                                                                            SizedBox(height: 8),
                                                                            CustomParagraph(
                                                                              textAlign: TextAlign.center,
                                                                              text: "Subscribe Vehicle",
                                                                              color: Colors.black,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  // Subscription List Button
                                                                  Flexible(
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        await controller
                                                                            .getVhSubscriptionDetails(index);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            100,
                                                                        margin: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(color: Colors.black12),
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.black.withOpacity(0.15),
                                                                              blurRadius: 8,
                                                                              spreadRadius: 2,
                                                                              offset: Offset(0, 4),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Image.asset(
                                                                              "assets/images/subscription_details.png",
                                                                              fit: BoxFit.cover,
                                                                              color: AppColor.primaryColor,
                                                                              height: 36,
                                                                              width: 36,
                                                                            ),
                                                                            SizedBox(height: 8),
                                                                            CustomParagraph(
                                                                              textAlign: TextAlign.center,
                                                                              text: "Subscription List",
                                                                              color: Colors.black,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.normal,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 16),
                                                              // Delete Button
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5.0),
                                                                child:
                                                                    CustomElevatedButton(
                                                                  text:
                                                                      "Delete",
                                                                  btnHeight: 40,
                                                                  icon: Iconsax
                                                                      .trash,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  btnColor:
                                                                      Colors
                                                                          .red,
                                                                  onPressed:
                                                                      () {
                                                                    controller
                                                                        .onDeleteVehicle(
                                                                      controller
                                                                              .vehicleData[index]
                                                                          [
                                                                          "vehicle_plate_no"],
                                                                    );
                                                                    Get.back();
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .vertical(
                                                            top:
                                                                Radius.circular(
                                                                    7),
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            Colors.white,
                                                      );
                                                    },
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundColor: AppColor
                                                          .primaryColor
                                                          .withOpacity(.1),
                                                      child: Transform.rotate(
                                                        angle: 3.14159 / 2,
                                                        child: Icon(
                                                          Icons
                                                              .more_vert_outlined,
                                                          color: AppColor
                                                              .primaryColor,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
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
                      ],
                    ),
                  ),
      ),
    );
  }
}
