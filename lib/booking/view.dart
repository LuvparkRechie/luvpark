import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/booking/index.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';

class BookingPage extends GetView<BookingController> {
  const BookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
        child: PopScope(
          canPop: true, //!controller.isBtnLoading.value,
          child: Listener(
            onPointerDown: (PointerDownEvent event) {
              controller.onUserInteraction();
            },
            child: Scaffold(
                backgroundColor: AppColor.bodyColor,
                body: SafeArea(
                  child: !controller.isInternetConn.value
                      ? NoInternetConnected(
                          onTap: controller.getMyVehicle,
                        )
                      : controller.isLoadingPage.value
                          ? const Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: StretchingOverscrollIndicator(
                                  axisDirection: AxisDirection.down,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 20, 15, 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                                  borderRadius:
                                                      BorderRadius.circular(43),
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
                                        Container(height: 26),
                                        CustomParagraph(
                                          text: "You are parking at",
                                          color: AppColor.headerColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                        Container(height: 15),
                                        Row(
                                          children: [
                                            Expanded(
                                                flex: 3,
                                                child: Container(
                                                  height: 71,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff1F313F),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(7),
                                                      bottomLeft:
                                                          Radius.circular(7),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        spreadRadius: 1,
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                    border: Border.all(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 15,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
                                                          child: CustomTitle(
                                                            text: controller
                                                                        .parameters[
                                                                    "areaData"][
                                                                "park_area_name"],
                                                            maxlines: 1,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
                                                          child:
                                                              CustomParagraph(
                                                            text: controller
                                                                        .parameters[
                                                                    "areaData"]
                                                                ["address"],
                                                            fontSize: 12,
                                                            color:
                                                                Colors.white70,
                                                            maxlines: 2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                height: 71,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xff243a4b),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(7),
                                                    bottomRight:
                                                        Radius.circular(7),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      spreadRadius: 1,
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(2, 2),
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 15,
                                                    vertical: 10,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      CustomParagraph(
                                                        text: controller
                                                                    .parameters[
                                                                "areaData"][
                                                            "distance_display"],
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        letterSpacing: -0.41,
                                                        maxlines: 2,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Container(height: 24),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomParagraph(
                                              text: "Vehicle details",
                                              color: AppColor.headerColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                            Container(height: 10),
                                            Container(
                                              height:
                                                  controller.selectedVh.isEmpty
                                                      ? 71
                                                      : null,
                                              padding: EdgeInsets.all(12),
                                              decoration: ShapeDecoration(
                                                color: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      width: 1,
                                                      color: Color(0xFFDFE7EF)),
                                                  borderRadius:
                                                      BorderRadius.circular(7),
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
                                              child: InkWell(
                                                onTap: () {
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) {
                                                    controller.displaySelVh();
                                                  });
                                                },
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 10,
                                                          right: 10,
                                                        ),
                                                        child: controller
                                                                .selectedVh
                                                                .isEmpty
                                                            ? CustomParagraph(
                                                                text:
                                                                    "Tap to add vehicle",
                                                                color: controller
                                                                        .selectedVh
                                                                        .isEmpty
                                                                    ? AppColor
                                                                        .primaryColor
                                                                    : Colors
                                                                        .grey,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                letterSpacing:
                                                                    -0.41,
                                                              )
                                                            : Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  CustomParagraph(
                                                                    text: controller
                                                                            .selectedVh[0]
                                                                        [
                                                                        "vehicle_plate_no"],
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColor
                                                                        .headerColor,
                                                                  ),
                                                                  Container(
                                                                      height:
                                                                          5),
                                                                  CustomParagraph(
                                                                    text: controller
                                                                            .selectedVh[0]
                                                                        [
                                                                        "vehicle_type"],
                                                                    letterSpacing:
                                                                        -0.41,
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                                ],
                                                              ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 15),
                                                      child: controller
                                                              .selectedVh
                                                              .isNotEmpty
                                                          ? CustomParagraph(
                                                              text:
                                                                  "Switch vehicle",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: AppColor
                                                                  .primaryColor,
                                                            )
                                                          : Icon(
                                                              Icons.add,
                                                              color: AppColor
                                                                  .primaryColor,
                                                              size: 20,
                                                            ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        Visibility(
                                          visible:
                                              controller.selectedVh.isNotEmpty,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(height: 20),
                                              CustomParagraph(
                                                text:
                                                    "How long do you want to park?",
                                                fontSize: 16,
                                                color: AppColor.headerColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              Container(height: 15),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: ShapeDecoration(
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        width: 1,
                                                        color:
                                                            Color(0xFFDFE7EF)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
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
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10),
                                                      child: Row(
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              if (controller
                                                                  .selectedVh
                                                                  .isEmpty) {
                                                                return;
                                                              }
                                                              controller
                                                                  .onTapChanged(
                                                                      false);
                                                            },
                                                            child: Container(
                                                              width: 70,
                                                              height: 36,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          23,
                                                                      vertical:
                                                                          6),
                                                              clipBehavior: Clip
                                                                  .antiAlias,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border(
                                                                  right:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .black12,
                                                                  ),
                                                                ),
                                                              ),
                                                              child: Center(
                                                                child:
                                                                    IconButton(
                                                                        padding:
                                                                            EdgeInsets
                                                                                .zero,
                                                                        onPressed:
                                                                            null,
                                                                        icon:
                                                                            Icon(
                                                                          LucideIcons
                                                                              .minus,
                                                                          color:
                                                                              Colors.black,
                                                                        )),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 8.0),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  CustomParagraph(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColor
                                                                        .primaryColor,
                                                                    text:
                                                                        "${controller.selectedNumber.value} ${int.parse(controller.selectedNumber.value.toString()) > 1 ? "Hours" : "Hour"}",
                                                                  ),
                                                                  Container(
                                                                      height:
                                                                          4),
                                                                  CustomParagraph(
                                                                    text:
                                                                        "${controller.startTime.value} - ${controller.endTime.value}",
                                                                    fontSize:
                                                                        10,
                                                                    letterSpacing:
                                                                        -0.41,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              if (controller
                                                                  .selectedVh
                                                                  .isEmpty)
                                                                return;
                                                              controller
                                                                  .onTapChanged(
                                                                      true);
                                                            },
                                                            child: Container(
                                                              width: 70,
                                                              height: 36,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          23,
                                                                      vertical:
                                                                          6),
                                                              clipBehavior: Clip
                                                                  .antiAlias,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border(
                                                                  left:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .black12,
                                                                  ),
                                                                ),
                                                              ),
                                                              child: IconButton(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  onPressed:
                                                                      null,
                                                                  icon: Icon(
                                                                    LucideIcons
                                                                        .plus,
                                                                    color: Colors
                                                                        .black,
                                                                  )),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: Colors.black12,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10,
                                                          horizontal: 20),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                CustomTitle(
                                                                  text:
                                                                      "Auto Extend",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 15,
                                                                ),
                                                                Container(
                                                                  height: 5,
                                                                ),
                                                                CustomParagraph(
                                                                  text:
                                                                      "${toCurrencyString(controller.selectedVh.isEmpty ? "0" : controller.selectedVh[0]["succeeding_rate"].toString())}/Succeeding hours",
                                                                  letterSpacing:
                                                                      -0.41,
                                                                  fontSize: 10,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(width: 10),
                                                          GestureDetector(
                                                            onTap: () {
                                                              controller.toggleExtendChecked(
                                                                  !controller
                                                                      .isExtendchecked
                                                                      .value);
                                                            },
                                                            child: Container(
                                                              width: 60,
                                                              height: 30,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: controller
                                                                          .isExtendchecked
                                                                          .value
                                                                      ? [
                                                                          Colors
                                                                              .green,
                                                                          Colors
                                                                              .lightGreen
                                                                        ]
                                                                      : [
                                                                          Colors
                                                                              .red,
                                                                          Colors
                                                                              .redAccent
                                                                        ],
                                                                ),
                                                              ),
                                                              child: Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  if (controller
                                                                      .isExtendchecked
                                                                      .value)
                                                                    Positioned(
                                                                      left: 10,
                                                                      child:
                                                                          Icon(
                                                                        LucideIcons
                                                                            .check,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  if (!controller
                                                                      .isExtendchecked
                                                                      .value)
                                                                    Positioned(
                                                                      right: 10,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .clear,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  AnimatedPositioned(
                                                                    duration:
                                                                        Duration(
                                                                      milliseconds:
                                                                          200,
                                                                    ),
                                                                    left: controller
                                                                            .isExtendchecked
                                                                            .value
                                                                        ? 30
                                                                        : 5,
                                                                    child:
                                                                        Container(
                                                                      width: 20,
                                                                      height:
                                                                          20,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(30),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.black26,
                                                                            blurRadius:
                                                                                4.0,
                                                                            spreadRadius:
                                                                                2.0,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(height: 5),
                                              Visibility(
                                                visible: controller
                                                    .numbersList.isNotEmpty,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      12,
                                                    ),
                                                  ),
                                                  child: CustomParagraph(
                                                    text:
                                                        "Booking limit is up to ${controller.numbersList.length} ${controller.numbersList.length > 1 ? "Hours" : "Hour"}",
                                                    color:
                                                        AppColor.primaryColor,
                                                    fontSize: 6,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(height: 20),

                                        //payment details

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomParagraph(
                                              text: "Payment details",
                                              fontSize: 16,
                                              color: AppColor.headerColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            Container(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(7),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColor.primaryColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(7),
                                                        bottomLeft:
                                                            Radius.circular(7),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              Color(0x0C000000),
                                                          blurRadius: 15,
                                                          offset: Offset(0, 5),
                                                          spreadRadius: 0,
                                                        )
                                                      ],
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        CustomTitle(
                                                          text: toCurrencyString(controller
                                                                  .parameters[
                                                                      "userData"]
                                                                      [0][
                                                                      "amount_bal"]
                                                                  .toString())
                                                              .toString(),
                                                          fontSize: 16,
                                                          maxlines: 1,
                                                          color: Colors.white,
                                                        ),
                                                        Container(height: 5),
                                                        const CustomParagraph(
                                                          text:
                                                              "Wallet Balance",
                                                          letterSpacing: -0.41,
                                                          fontSize: 10,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(7),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(7),
                                                        bottomRight:
                                                            Radius.circular(7),
                                                      ),
                                                      border: Border(
                                                        bottom: BorderSide(
                                                            width: 1,
                                                            color: Color(
                                                                0xFFDFE7EF)),
                                                        right: BorderSide(
                                                            width: 1,
                                                            color: Color(
                                                                0xFFDFE7EF)),
                                                        top: BorderSide(
                                                            width: 1,
                                                            color: Color(
                                                                0xFFDFE7EF)),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              Color(0x0C000000),
                                                          blurRadius: 15,
                                                          offset: Offset(0, 5),
                                                          spreadRadius: 0,
                                                        )
                                                      ],
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        CustomTitle(
                                                          text: toCurrencyString(
                                                                  controller
                                                                      .displayRewards
                                                                      .toString())
                                                              .toString(),
                                                          fontSize: 16,
                                                          maxlines: 1,
                                                        ),
                                                        Container(height: 5),
                                                        const CustomParagraph(
                                                          text: "Rewards",
                                                          letterSpacing: -0.41,
                                                          fontSize: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(height: 20),
                                            // if (double.parse(
                                            //         controller.rewardsCon.text) !=
                                            //     0.0)
                                            if (double.parse(controller
                                                        .parameters["userData"]
                                                    [0]["points_bal"]) !=
                                                0.0)
                                              GestureDetector(
                                                onTap: () {
                                                  controller
                                                      .toggleRewardChecked(
                                                          !controller
                                                              .isRewardchecked
                                                              .value);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 15),
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  decoration: ShapeDecoration(
                                                    color: Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          width: 1,
                                                          color: Color(
                                                              0xFFDFE7EF)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                    ),
                                                    shadows: [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x0C000000),
                                                        blurRadius: 15,
                                                        offset: Offset(0, 5),
                                                        spreadRadius: 0,
                                                      )
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 20.0,
                                                      right: 20,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              controller
                                                                      .isRewardchecked
                                                                      .value
                                                                  ? Icons
                                                                      .check_circle_outline
                                                                  : Icons
                                                                      .circle_outlined,
                                                              color: controller
                                                                      .isRewardchecked
                                                                      .value
                                                                  ? AppColor
                                                                      .primaryColor
                                                                  : Colors.grey,
                                                            ),
                                                            Container(width: 5),
                                                            const Expanded(
                                                              child:
                                                                  CustomTitle(
                                                                text:
                                                                    "Use Reward Points",
                                                                fontSize: 14,
                                                                letterSpacing:
                                                                    -0.41,
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              ),
                                                            ),
                                                            Container(width: 5),
                                                            if (controller
                                                                .isRewardchecked
                                                                .value)
                                                              GestureDetector(
                                                                onTap: () {
                                                                  if (double.parse(controller.parameters["userData"]
                                                                              [
                                                                              0]
                                                                          [
                                                                          "points_bal"]) ==
                                                                      0.0) {
                                                                    CustomDialog().errorDialog(
                                                                        context,
                                                                        "luvpark",
                                                                        "You don't have enough rewards to proceed.",
                                                                        () {
                                                                      Get.back();
                                                                    });
                                                                    return;
                                                                  }
                                                                  Get.dialog(
                                                                    RewardsDialog(
                                                                      data: controller
                                                                          .parameters,
                                                                      cb: (data) {
                                                                        controller
                                                                            .computeRewards(data);
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                                child: Icon(
                                                                  Icons
                                                                      .edit_note,
                                                                  color: AppColor
                                                                      .primaryColor,
                                                                ),
                                                              )
                                                          ],
                                                        ),
                                                        if (controller
                                                            .isRewardchecked
                                                            .value)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            child: Column(
                                                              children: [
                                                                const Divider(
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    const CustomParagraph(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        text:
                                                                            ' Reward Points :',
                                                                        letterSpacing:
                                                                            -0.41),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              20),
                                                                      child:
                                                                          CustomParagraph(
                                                                        text: toCurrencyString(controller
                                                                            .usedRewards
                                                                            .toString()),
                                                                        color: AppColor
                                                                            .primaryColor,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Container(
                                                                    height: 5),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    const CustomParagraph(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      text:
                                                                          ' Token :',
                                                                      letterSpacing:
                                                                          -0.41,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              20),
                                                                      child:
                                                                          CustomParagraph(
                                                                        text: toCurrencyString(controller
                                                                            .tokenRewards
                                                                            .toString()),
                                                                        color: AppColor
                                                                            .primaryColor,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Container(
                                                                    height: 10),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    CustomParagraph(
                                                                      text:
                                                                          ' Total ',
                                                                      letterSpacing:
                                                                          -0.41,
                                                                      color: AppColor
                                                                          .headerColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              20),
                                                                      child:
                                                                          CustomParagraph(
                                                                        text: toCurrencyString(controller.totalAmount.value)
                                                                            .toString(),
                                                                        color: AppColor
                                                                            .primaryColor,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Container(
                                              height: 10,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                        top: BorderSide(
                                            color: Colors.grey.shade100)),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(7),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20,
                                        left: 20.0,
                                        right: 20.0,
                                        bottom: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomParagraph(
                                                text: "Total",
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.headerColor,
                                              ),
                                            ),
                                            CustomTitle(
                                              color: AppColor.headerColor,
                                              text: toCurrencyString(
                                                  controller.totalAmount.value),
                                            ),
                                          ],
                                        ),
                                        Container(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomButton(
                                                  loading: controller
                                                      .isSubmitBooking.value,
                                                  text: controller.parameters[
                                                          "canCheckIn"]
                                                      ? "Check In"
                                                      : "Book now",
                                                  btnColor: controller
                                                          .selectedVh.isEmpty
                                                      ? AppColor.primaryColor
                                                          .withOpacity(.6)
                                                      : AppColor.primaryColor,
                                                  textColor: Colors.white,
                                                  onPressed: controller
                                                          .selectedVh.isEmpty
                                                      ? () {}
                                                      : () {
                                                          var dateIn =
                                                              DateTime.parse(
                                                                  "${controller.startDate.text} ${controller.timeInParam.text}");

                                                          var dateOut =
                                                              dateIn.add(
                                                            Duration(
                                                              hours: controller
                                                                  .selectedNumber
                                                                  .value,
                                                            ),
                                                          );

                                                          String finalDateOut =
                                                              "${DateFormat('yyyy-MM-dd').format(DateTime.parse(dateOut.toString()))} ${controller.paramEndTime.value}";

                                                          void bongGo() {
                                                            Map<String, dynamic>
                                                                parameters = {
                                                              "client_id": controller
                                                                          .parameters[
                                                                      "areaData"]
                                                                  ["client_id"],
                                                              "park_area_id": controller
                                                                          .parameters[
                                                                      "areaData"]
                                                                  [
                                                                  "park_area_id"],
                                                              "vehicle_plate_no":
                                                                  controller
                                                                          .selectedVh[0]
                                                                      [
                                                                      "vehicle_plate_no"],
                                                              "vehicle_type_id":
                                                                  controller
                                                                      .selectedVh[
                                                                          0][
                                                                          "vehicle_type_id"]
                                                                      .toString(),
                                                              "dt_in": dateIn
                                                                  .toString()
                                                                  .toString()
                                                                  .split(
                                                                      ".")[0],
                                                              "dt_out":
                                                                  finalDateOut,
                                                              "no_hours": controller
                                                                  .selectedNumber,
                                                              "tran_type": "R",
                                                            };

                                                            controller
                                                                .submitReservation(
                                                                    parameters);
                                                          }

                                                          if (controller
                                                              .isExtendchecked
                                                              .value) {
                                                            bongGo();
                                                          } else {
                                                            CustomDialog()
                                                                .confirmationDialog(
                                                                    context,
                                                                    "Enable Auto Extend",
                                                                    "Your parking duration will be automatically extended using your available balance if it is enabled.\n\nWould you like to enable it?",
                                                                    "No",
                                                                    "Yes", () {
                                                              Get.back();
                                                              controller
                                                                  .isExtendchecked
                                                                  .value = false;
                                                              bongGo();
                                                            }, () {
                                                              Get.back();
                                                              controller
                                                                  .isExtendchecked
                                                                  .value = true;
                                                              bongGo();
                                                            });
                                                          }
                                                          print(
                                                              "militaryTime  ");
                                                        }),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                )),
          ),
        ),
      ),
    );
  }
}

class BookingDuration extends GetView<BookingController> {
  final List numbersList;
  final String maxHours;
  final Function(int) onTap;
  const BookingDuration(
      {super.key,
      required this.numbersList,
      required this.maxHours,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    BookingController ct = Get.put(BookingController());
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          height: numbersList.length >= 5
              ? MediaQuery.of(context).size.height * .50
              : null,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(17),
              topRight: Radius.circular(17),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 15,
                          width: 200,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(56)),
                          ),
                        ),
                        Container(
                          height: 6,
                          width: 71,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.all(Radius.circular(56)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomTextField(
                    labelText: "Input number of hours",
                    title: "No. of hours",
                    controller: controller.noHours,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    keyboardType: Platform.isAndroid
                        ? TextInputType.number
                        : const TextInputType.numberWithOptions(
                            signed: true, decimal: false),
                    onChange: (value) {
                      controller.noHours.text =
                          value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                      controller.inpDisplay.text =
                          value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

                      if (value.isNotEmpty &&
                          int.parse(value) >
                              int.parse(controller.parameters["areaData"]
                                      ["res_max_hours"]
                                  .toString()) &&
                          int.parse(controller.parameters["areaData"]
                                      ["res_max_hours"]
                                  .toString()) !=
                              0) {
                        CustomDialog().errorDialog(context, "luvpark",
                            "Booking limit is up to ${controller.parameters["areaData"]["res_max_hours"].toString()} hours only.",
                            () {
                          Get.back();
                          controller.noHours.text = controller.noHours.text
                              .substring(0, controller.noHours.text.length - 1);

                          controller.inpDisplay.text = controller.noHours.text
                              .substring(0, controller.noHours.text.length - 1);
                          controller.inpDisplay.text = controller.noHours.text
                              .substring(0, controller.noHours.text.length - 1);

                          controller.noHours.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: controller.noHours.text.length));

                          controller.selectedNumber.value =
                              int.parse(controller.noHours.text);
                        });
                      }

                      controller.selectedNumber.value =
                          (controller.noHours.text.isEmpty
                              ? null
                              : int.parse(controller.noHours.text))!;
                    },
                  ),
                ],
              ),
              Container(height: 10),
              if (numbersList.isNotEmpty)
                if (numbersList.length >= 5)
                  if (MediaQuery.of(context).viewInsets.bottom == 0)
                    Expanded(
                      child: ListView.separated(
                          itemBuilder: (context, index) {
                            return numberHoursWidget(numbersList, index, ct);
                          },
                          separatorBuilder: (context, index) {
                            return const Divider(
                              height: 2,
                            );
                          },
                          itemCount: numbersList.length),
                    ),
              if (MediaQuery.of(context).viewInsets.bottom == 0)
                if (numbersList.isNotEmpty)
                  if (numbersList.length < 5)
                    for (int i = 0; i < numbersList.length; i++)
                      numberHoursWidget(numbersList, i, ct),
              if (MediaQuery.of(context).viewInsets.bottom == 0)
                const Divider(),
              if (MediaQuery.of(context).viewInsets.bottom == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomButton(
                      text: "Confirm",
                      onPressed: () {
                        if (controller.selectedNumber.value == 0) return;
                        controller.inputTimeLabel.value =
                            "${controller.selectedNumber.value} ${controller.selectedNumber.value > 1 ? "Hours" : "Hour"}";
                        onTap(controller.selectedNumber.value);
                        Get.back();
                      }),
                ),
              if (Platform.isIOS) Container(height: 20),
            ],
          ),
        ));
  }

  Widget numberHoursWidget(data, i, ct) {
    return Obx(
      () => Container(
        color: controller.selectedNumber.value == data[i]
            ? const Color(0xFFe8f3fe)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ListTile(
            onTap: () {
              controller.onTapChanged(i);
            },
            contentPadding: EdgeInsets.zero,
            title: CustomParagraph(
              text: '${data[i]} ${data[i] > 1 ? "hours" : "hour"}',
              color: controller.selectedNumber.value == numbersList[i]
                  ? AppColor.primaryColor
                  : Colors.black,
            ),
            trailing: controller.selectedNumber.value == data[i]
                ? Icon(Icons.check, color: AppColor.primaryColor)
                : null,
          ),
        ),
      ),
    );
  }
}

class VehicleOption extends GetView<BookingController> {
  final Function callback;
  const VehicleOption({super.key, required this.callback});

  @override
  Widget build(BuildContext context) {
    final BookingController ct = Get.find();

    return Wrap(
      children: [
        Obx(
          () => Container(
            height: controller.isFirstScreen.value
                ? MediaQuery.of(context).viewInsets.bottom != 0
                    ? MediaQuery.of(context).viewInsets.bottom
                    : null
                : MediaQuery.of(context).size.height * .50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 10),
                  InkWell(
                    onTap: () {
                      if (!controller.isFirstScreen.value) {
                        controller
                            .onScreenChanged(!controller.isFirstScreen.value);
                        return;
                      }
                      Get.back();
                    },
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                    ),
                  ),
                  Container(height: 20),
                  controller.isFirstScreen.value
                      ? Form(
                          key: controller.bookKey,
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomParagraph(
                                  text: "What's your plate number?",
                                  fontSize: 16,
                                  color: AppColor.headerColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                Container(height: 10),
                                CustomTextField(
                                  labelText: "Plate No.",
                                  controller: controller.plateNo,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'\s')),
                                  ],
                                  validator: (data) {
                                    if (data == null || data.isEmpty) {
                                      return "Plate no is required";
                                    }
                                    if (!data
                                        .contains(RegExp(r'^[A-Z0-9-]+$'))) {
                                      return "Plate No. should only contain letters, numbers, and dashes";
                                    }
                                    if (data.startsWith('-') ||
                                        data.endsWith('-')) {
                                      return "Plate No. should not start or end with a dash";
                                    }
                                    return null;
                                  },
                                ),
                                if (MediaQuery.of(context).viewInsets.bottom ==
                                    0)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 15.0, bottom: 10),
                                        child: customDropdown(
                                          labelText: "Vehicle type",
                                          items: controller.ddVehiclesData,
                                          selectedValue:
                                              controller.dropdownValue,
                                          onChanged: (newValue) {
                                            controller.dropdownValue = newValue;
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Vehicle type is required";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Container(height: 30),
                                      CustomButton(
                                        text: "Confirm",
                                        onPressed: () {
                                          if (ct.bookKey.currentState!
                                              .validate()) {
                                            dynamic selVh = ct.ddVehiclesData
                                                .where((element) {
                                              return element["value"] ==
                                                  int.parse(ct.dropdownValue!
                                                      .toString());
                                            }).toList()[0];

                                            callback([
                                              {
                                                'vehicle_type_id': ct
                                                    .dropdownValue!
                                                    .toString(),
                                                'vehicle_brand_id': 0,
                                                'vehicle_brand_name':
                                                    selVh["text"],
                                                'vehicle_plate_no':
                                                    controller.plateNo.text,
                                                'base_hours':
                                                    selVh["base_hours"],
                                                'base_rate': selVh["base_rate"],
                                                'succeeding_rate':
                                                    selVh["succeeding_rate"],
                                                'vehicle_type': selVh["text"]
                                              }
                                            ]);
                                            Get.back();
                                          }
                                        },
                                      ),
                                      Container(height: 15),
                                      CustomButtonCancel(
                                          borderColor: Colors.black,
                                          textColor: Colors.black,
                                          color: AppColor.bodyColor,
                                          text: "My Vehicle",
                                          onPressed: () {
                                            controller.onScreenChanged(
                                                !ct.isFirstScreen.value);
                                          }),
                                      if (Platform.isIOS) Container(height: 20),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: controller.myVehiclesData.isEmpty
                              ? const NoDataFound(
                                  text:
                                      "Your registered vehicle isn’t suitable for this area. Please consider other options ",
                                )
                              : Scrollbar(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    itemCount: controller.myVehiclesData.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            CustomTitle(
                                              text: controller
                                                      .myVehiclesData[index]
                                                  ["vehicle_plate_no"],
                                              fontSize: 14,
                                            ),
                                          ],
                                        ),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            CustomParagraph(
                                              text: controller
                                                      .myVehiclesData[index]
                                                  ["vehicle_brand_name"],
                                              fontSize: 12,
                                            ),
                                          ],
                                        ),
                                        leading: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Icon(
                                            int.parse(controller
                                                        .myVehiclesData[index]
                                                            ["vehicle_type_id"]
                                                        .toString()) ==
                                                    1
                                                ? Icons.motorcycle_outlined
                                                : Icons.time_to_leave,
                                          ),
                                        ),
                                        trailing: const Icon(
                                            Icons.keyboard_arrow_right),
                                        onTap: () {
                                          List vhDatas = [
                                            controller.myVehiclesData[index]
                                          ];
                                          dynamic recData =
                                              controller.ddVehiclesData;

                                          Map<int, Map<String, dynamic>>
                                              recDataMap = {
                                            for (var item in recData)
                                              item['value']: item
                                          };

                                          // Merge base_hours and succeeding_rate into vhDatas
                                          for (var vh in vhDatas) {
                                            int typeId = vh['vehicle_type_id'];
                                            if (recDataMap
                                                .containsKey(typeId)) {
                                              var rec = recDataMap[typeId];
                                              vh['base_hours'] =
                                                  rec?['base_hours'];
                                              vh['base_rate'] =
                                                  rec?['base_rate'];
                                              vh['succeeding_rate'] =
                                                  rec?['succeeding_rate'];
                                              vh['vehicle_type'] =
                                                  rec?['vehicle_type'];
                                            }
                                          }
                                          Get.back();
                                          callback(vhDatas);
                                        },
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return Divider(
                                        color: Colors.black
                                            .withOpacity(0.05000000074505806),
                                      );
                                    },
                                  ),
                                ),
                        ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class RewardsDialog extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function cb;
  const RewardsDialog({super.key, required this.data, required this.cb});

  @override
  State<RewardsDialog> createState() => _RewardsDialogState();
}

class _RewardsDialogState extends State<RewardsDialog> {
  final TextEditingController rewardsCon = TextEditingController();

  bool isExceed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomTitle(
                      text: "Reward Points",
                      fontWeight: FontWeight.w700,
                      fontSize: 19,
                    ),
                    Container(height: 20),
                    const CustomParagraph(
                        text: "Enter desired amount to be used"),
                    Container(height: 5),
                    CustomTextField(
                      labelText: "Amount",
                      controller: rewardsCon,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChange: (value) {
                        if (int.parse(value) >
                            double.parse(
                                widget.data["userData"][0]["points_bal"])) {
                          setState(() {
                            isExceed = true;
                            rewardsCon.text =
                                value.substring(0, value.length - 1);
                          });
                        } else {
                          setState(() {
                            isExceed = false;
                          });
                        }
                      },
                    ),
                    if (isExceed)
                      const CustomParagraph(
                        text:
                            "Reward points inputted should not be greater than the total bill for parking",
                        maxlines: 2,
                        fontSize: 10,
                        color: Colors.red,
                      ),
                    Container(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            int amtReward = int.parse(rewardsCon.text);

                            Get.back();
                            widget.cb(amtReward);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
