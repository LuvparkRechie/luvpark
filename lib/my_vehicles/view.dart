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
                                  )
                                ],
                              ),
                              child: Icon(
                                LucideIcons.arrowLeft,
                                color: Colors.white,
                                size: 16,
                              )),
                        ),
                        Container(height: 20),
                        Text(
                          "My Vehicles",
                          style: GoogleFonts.openSans(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: AppColor.headerColor,
                          ),
                        ),
                        Container(height: 20),
                        InkWell(
                          onTap: () {
                            controller.getVehicleDropDown();
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF8bd0ce),
                                ),
                                child: Icon(LucideIcons.plus),
                              ),
                              Container(width: 10),
                              CustomParagraph(
                                text: "Add vehicle",
                                fontWeight: FontWeight.w700,
                                color: AppColor.headerColor,
                              )
                            ],
                          ),
                        ),
                        Container(height: 30),
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
                                                bottom: 5),
                                            child: Stack(
                                              fit: StackFit.loose,
                                              alignment: Alignment.topRight,
                                              children: [
                                                Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 15),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey.shade300,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  CustomParagraph(
                                                                    text: controller
                                                                        .vehicleData[
                                                                            index]
                                                                            [
                                                                            "vehicle_brand_name"]
                                                                        .toString()
                                                                        .toUpperCase(),
                                                                    color: AppColor
                                                                        .headerColor,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                  Container(
                                                                      height:
                                                                          5),
                                                                  CustomParagraph(
                                                                    maxlines: 1,
                                                                    text: controller
                                                                        .vehicleData[
                                                                            index]
                                                                            [
                                                                            "vehicle_plate_no"]
                                                                        .toString()
                                                                        .toUpperCase(),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                  Container(
                                                                      height:
                                                                          5),
                                                                  Container(
                                                                      height:
                                                                          10),
                                                                  CustomButton(
                                                                      btnHeight:
                                                                          40,
                                                                      text:
                                                                          "Subscribe",
                                                                      onPressed:
                                                                          () {
                                                                        FocusNode()
                                                                            .unfocus();

                                                                        Get.to(
                                                                            ScannerScreen(
                                                                          onchanged:
                                                                              (ScannedData args) {
                                                                            String
                                                                                result =
                                                                                args.scannedHash;

                                                                            print("result $result");

                                                                            if (result.isEmpty) {
                                                                              CustomDialog().errorDialog(
                                                                                context,
                                                                                "Invalid QR Code",
                                                                                "The scanned QR code is invalid. Please try again.",
                                                                                () {
                                                                                  Get.back();
                                                                                },
                                                                              );
                                                                              return;
                                                                            } else {
                                                                              controller.subscrbeVh(result, controller.vehicleData[index]["vehicle_plate_no"].toString(), controller.vehicleData[index]["vehicle_brand_id"].toString());
                                                                            }
                                                                          },
                                                                        ));
                                                                      })
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                width: 60,
                                                                height: 60,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  image:
                                                                      DecorationImage(
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    image: controller.vehicleData[index]["image"] ==
                                                                                null ||
                                                                            controller
                                                                                .vehicleData[index][
                                                                                    "image"]
                                                                                .isEmpty
                                                                        ? AssetImage("assets/images/no_image.png")
                                                                            as ImageProvider
                                                                        : MemoryImage(
                                                                            base64Decode(
                                                                              removeInvalidCharacters(controller.vehicleData[index]["image"]),
                                                                            ),
                                                                          ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )

                                                    //  ListTile(
                                                    //   title: Row(
                                                    //     mainAxisAlignment:
                                                    //         MainAxisAlignment.start,
                                                    //     children: [
                                                    //       CustomTitle(
                                                    //         text: controller
                                                    //                 .vehicleData[index]
                                                    //             ["vehicle_brand_name"],
                                                    //         maxlines: 1,
                                                    //       ),
                                                    //     ],
                                                    //   ),
                                                    //   subtitle: CustomParagraph(
                                                    //       minFontSize: 10,
                                                    //       text:
                                                    //           'Plate number: ${controller.vehicleData[index]["vehicle_plate_no"]}',
                                                    //       maxlines: 1),
                                                    //   leading: Container(
                                                    //     width: 50,
                                                    //     height: 50,
                                                    //     decoration: BoxDecoration(
                                                    //       shape: BoxShape.circle,
                                                    //       image: DecorationImage(
                                                    //         fit: BoxFit.contain,
                                                    //         image: controller.vehicleData[
                                                    //                             index]
                                                    //                         ["image"] ==
                                                    //                     null ||
                                                    //                 controller
                                                    //                     .vehicleData[
                                                    //                         index]
                                                    //                         ["image"]
                                                    //                     .isEmpty
                                                    //             ? AssetImage(
                                                    //                     "assets/images/no_image.png")
                                                    //                 as ImageProvider
                                                    //             : MemoryImage(
                                                    //                 base64Decode(
                                                    //                   removeInvalidCharacters(
                                                    //                       controller.vehicleData[
                                                    //                               index]
                                                    //                           [
                                                    //                           "image"]),
                                                    //                 ),
                                                    //               ),
                                                    //       ),
                                                    //     ),
                                                    //   ),
                                                    //   trailing: Container(
                                                    //     decoration: const BoxDecoration(
                                                    //       shape: BoxShape.circle,
                                                    //       color: Color(0xFFF9D9D9),
                                                    //     ),
                                                    //     padding:
                                                    //         const EdgeInsets.all(5.0),
                                                    //     child: const Icon(
                                                    //       Icons.delete,
                                                    //       color: Color(0xFFD34949),
                                                    //       size: 15.0,
                                                    //     ),
                                                    //   ),
                                                    //   onTap: () {
                                                    //     controller.onDeleteVehicle(
                                                    //         controller
                                                    //                 .vehicleData[index]
                                                    //             ["vehicle_plate_no"]);
                                                    //   },
                                                    // ),

                                                    ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5, right: 5),
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.onDeleteVehicle(
                                                          controller.vehicleData[
                                                                  index][
                                                              "vehicle_plate_no"]);
                                                    },
                                                    child: Icon(
                                                      Iconsax.trash,
                                                      color: Colors.red,
                                                      size: 20,
                                                    ),
                                                  ),
                                                )
                                              ],
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
