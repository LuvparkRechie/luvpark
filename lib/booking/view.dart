import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
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
import 'package:material_symbols_icons/symbols.dart';

class BookingPage extends GetView<BookingController> {
  const BookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BookingController ct = Get.find();
    return Obx(
      () => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
        child: PopScope(
          canPop: !controller.isLoadingPage.value,
          child: Scaffold(
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
              backgroundColor: AppColor.bodyColor,
              body: SafeArea(
                child: !ct.isInternetConn.value
                    ? NoInternetConnected(
                        onTap: controller.getMyVehicle,
                      )
                    : ct.isLoadingPage.value
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
                              Container(height: 10),
                              Expanded(
                                  child: StretchingOverscrollIndicator(
                                axisDirection: AxisDirection.down,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          FocusNode().unfocus();
                                          CustomDialog().loadingDialog(context);
                                          Future.delayed(Duration(seconds: 1),
                                              () {
                                            Get.back();
                                            Get.back();
                                          });
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

                                      Container(height: 20),
                                      //Parking area
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
                                                    topLeft: Radius.circular(7),
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
                                                        child: CustomParagraph(
                                                          text: controller
                                                                      .parameters[
                                                                  "areaData"][
                                                              "park_area_name"],
                                                          maxlines: 1,
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0),
                                                        child: CustomParagraph(
                                                          text: controller
                                                                      .parameters[
                                                                  "areaData"]
                                                              ["address"],
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
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
                                                color: const Color(0xff243a4b),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topRight: Radius.circular(7),
                                                  bottomRight:
                                                      Radius.circular(7),
                                                ),
                                                border: Border.all(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                  vertical: 10,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    CustomParagraph(
                                                      text: controller
                                                                  .parameters[
                                                              "areaData"]
                                                          ["distance_display"],
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      maxlines: 2,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),

                                      Container(height: 25),
                                      //My Vehicle
                                      CustomParagraph(
                                        text: 'My Vehicle',
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                      Container(height: 10),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical:
                                              ct.selectedVh.isEmpty ? 20 : 15,
                                        ),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          border: Border.all(
                                            width: 1,
                                            color: Color(0xFFDFE7EF),
                                          ),
                                        ),
                                        child: controller.selectedVh.isEmpty
                                            ? GestureDetector(
                                                onTap: () {
                                                  ct.vehicleSelection(1);
                                                },
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: CustomParagraph(
                                                        text:
                                                            'Tap to add vehicle',
                                                        color: AppColor
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: Icon(
                                                        Symbols.add,
                                                        color: AppColor
                                                            .primaryColor,
                                                        size: 20,
                                                        weight: 1000,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        CustomParagraph(
                                                          text:
                                                              "${ct.selectedVh[0]["vehicle_plate_no"]}",
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                        Container(height: 5),
                                                        CustomParagraph(
                                                          text:
                                                              "${ct.selectedVh[0]["vehicle_type"]}",
                                                          maxlines: 2,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(width: 10),
                                                  InkWell(
                                                    onTap: () {
                                                      ct.vehicleSelection(1);
                                                    },
                                                    child: CustomParagraph(
                                                      text: "Switch vehicle",
                                                      color:
                                                          AppColor.primaryColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                              ),
                                              Container(height: 10),
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
                                                          Container(
                                                            width: 70,
                                                            height: 36,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        23,
                                                                    vertical:
                                                                        6),
                                                            clipBehavior:
                                                                Clip.antiAlias,
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
                                                              child: IconButton(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  onPressed:
                                                                      () {
                                                                    controller
                                                                        .onTapChanged(
                                                                            false);
                                                                  },
                                                                  icon: Icon(
                                                                      LucideIcons
                                                                          .minus)),
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
                                                                    color: AppColor
                                                                        .primaryColor,
                                                                    text:
                                                                        "${controller.selectedNumber.value} ${int.parse(controller.selectedNumber.value.toString()) > 1 ? "Hours" : "Hour"}",
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                  Container(
                                                                      height:
                                                                          4),
                                                                  Obx(() =>
                                                                      CustomParagraph(
                                                                        text:
                                                                            "${ct.startTime.value} - ${ct.endTime.value}",
                                                                        letterSpacing:
                                                                            -0.41,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontSize:
                                                                            12,
                                                                      )),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 70,
                                                            height: 36,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        23,
                                                                    vertical:
                                                                        6),
                                                            clipBehavior:
                                                                Clip.antiAlias,
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
                                                                onPressed: () {
                                                                  controller
                                                                      .onTapChanged(
                                                                          true);
                                                                },
                                                                icon: Icon(
                                                                    LucideIcons
                                                                        .plus)),
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
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                                Container(
                                                                  height: 5,
                                                                ),
                                                                CustomParagraph(
                                                                  text:
                                                                      "${toCurrencyString(controller.selectedVh.isEmpty ? "0" : controller.selectedVh[0]["succeeding_rate"].toString())}/Succeeding hours",
                                                                  letterSpacing:
                                                                      -0.41,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 12,
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
                                                visible:
                                                    controller.endNumber.value >
                                                        0,
                                                child: CustomParagraph(
                                                  text:
                                                      "Booking limit is up to ${controller.endNumber.value} ${controller.endNumber.value > 1 ? "Hours" : "Hour"}",
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.primaryColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Container(height: 20),
                                              CustomParagraph(
                                                text: 'My Wallet',
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                              ),
                                              Container(height: 10),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                  vertical: 15,
                                                ),
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
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomParagraph(
                                                            text:
                                                                "${toCurrencyString(controller.parameters["userData"][0]["amount_bal"].toString()).toString()}",
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                          Container(
                                                            height: 5,
                                                          ),
                                                          CustomParagraph(
                                                            text:
                                                                "Wallet balance",
                                                            letterSpacing:
                                                                -0.41,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 12,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(height: 10),
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                              )),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      width: 2,
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(height: 20),
                                    Visibility(
                                      visible: ct.displayRewards.value > 0 &&
                                          controller.selectedVh.isNotEmpty,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: CustomParagraph(
                                                    text: 'My Rewards',
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Container(width: 15),
                                                Row(
                                                  children: [
                                                    CustomTitle(
                                                      text:
                                                          "${toCurrencyString(ct.displayRewards.toString())}",
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                    Container(width: 10),
                                                    GestureDetector(
                                                      onTap: () {
                                                        controller
                                                            .onToggleRewards(
                                                                !controller
                                                                    .isUseRewards
                                                                    .value);
                                                      },
                                                      child: Container(
                                                        width: 60,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          gradient:
                                                              LinearGradient(
                                                            colors: controller
                                                                    .isUseRewards
                                                                    .value
                                                                ? [
                                                                    Colors
                                                                        .green,
                                                                    Colors
                                                                        .lightGreen
                                                                  ]
                                                                : [
                                                                    Colors.grey,
                                                                    Colors.grey
                                                                  ],
                                                          ),
                                                        ),
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            if (controller
                                                                .isUseRewards
                                                                .value)
                                                              Positioned(
                                                                left: 10,
                                                                child: Icon(
                                                                  LucideIcons
                                                                      .check,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 15,
                                                                ),
                                                              ),
                                                            if (!controller
                                                                .isUseRewards
                                                                .value)
                                                              Positioned(
                                                                right: 10,
                                                                child: Icon(
                                                                  Icons.clear,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 15,
                                                                ),
                                                              ),
                                                            AnimatedPositioned(
                                                              duration:
                                                                  Duration(
                                                                milliseconds:
                                                                    200,
                                                              ),
                                                              left: controller
                                                                      .isUseRewards
                                                                      .value
                                                                  ? 30
                                                                  : 5,
                                                              child: Container(
                                                                width: 20,
                                                                height: 20,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black26,
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
                                              ],
                                            ),
                                          ),
                                          Container(height: 10),
                                          Divider(
                                            thickness: 2,
                                            color: Colors.grey.shade200,
                                          ),
                                          Container(height: 10),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: CustomParagraph(
                                              text: 'Total payment',
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                          CustomParagraph(
                                            text: toCurrencyString(controller
                                                    .totalAmount.value)
                                                .toString(),
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(height: 20),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      child: CustomButton(
                                        text: "Confirm Booking",
                                        btnColor: controller.isDisabledBtn.value
                                            ? AppColor.primaryColor
                                                .withOpacity(.7)
                                            : AppColor.primaryColor,
                                        onPressed:
                                            controller.isDisabledBtn.value
                                                ? () {}
                                                : () {
                                                    controller.confirmBooking();
                                                  },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(height: 10),
                            ],
                          ),
              )),
        ),
      ),
    );
  }
}

class ConfirmBooking extends GetView<BookingController> {
  const ConfirmBooking({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController ct = Get.find();
    bool isNewDay = false;

    var dateIn = DateTime.parse(
        "${controller.startDate.text} ${controller.timeInParam.text}");

    var dateOut = dateIn.add(
      Duration(
        hours: controller.selectedNumber.value,
      ),
    );

    String dtOut = DateFormat('E, dd MMM yyyy').format(dateOut);
    String dtIn = DateFormat('E, dd MMM yyyy').format(dateOut);

    if (dateIn.day.toString() == dateOut.day.toString()) {
      isNewDay = false;
    } else {
      isNewDay = true;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          CustomTitle(
            text: "Confirm Booking",
            fontSize: 20,
          ),
          Container(height: 5),
          CustomParagraph(
            text: "Your booking summary",
            fontSize: 14,
          ),
          Container(height: 30),
          Row(
            children: [
              Icon(
                LucideIcons.calendarRange,
                color: Colors.blue,
              ),
              Container(width: 10),
              CustomParagraph(
                text: isNewDay ? "$dtIn → $dtOut" : dtIn,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          Container(height: 30),
          Row(
            children: [
              Icon(
                LucideIcons.clock,
                color: Colors.blue,
              ),
              Container(width: 10),
              Obx(() => CustomParagraph(
                    text: "${ct.startTime.value} → ${ct.endTime.value}",
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
          Container(height: 30),
          CustomTitle(
            text: toCurrencyString(controller.totalAmount.value).toString(),
            fontSize: 20,
            color: AppColor.headerColor,
            fontWeight: FontWeight.w600,
          ),
          CustomParagraph(
            text: "Total deducted token from your wallet",
            fontSize: 12,
          ),
          Container(height: 30),
          LayoutBuilder(builder: (context, constraints) {
            var dateIn = DateTime.parse(
                "${controller.startDate.text} ${controller.timeInParam.text}");

            var dateOut = dateIn.add(
              Duration(
                hours: controller.selectedNumber.value,
              ),
            );

            String finalDateOut =
                "${DateFormat('yyyy-MM-dd').format(DateTime.parse(dateOut.toString()))} ${controller.paramEndTime.value}";

            void bongGo(bool canChkIn) {
              Map<String, dynamic> parameters = {
                "client_id": controller.parameters["areaData"]["client_id"],
                "park_area_id": controller.parameters["areaData"]
                    ["park_area_id"],
                "vehicle_plate_no": controller.selectedVh[0]
                    ["vehicle_plate_no"],
                "vehicle_type_id":
                    controller.selectedVh[0]["vehicle_type_id"].toString(),
                "dt_in": dateIn.toString().toString().split(".")[0],
                "dt_out": finalDateOut,
                "no_hours": controller.selectedNumber,
                'base_rate': controller.selectedVh[0]["base_rate"],
                "base_hours": controller.selectedVh[0]["base_hours"],
                "succeeding_rate": controller.selectedVh[0]["succeeding_rate"],
                "disc_rate": 0,
                "tran_type": "R",
              };
              controller.submitReservation(parameters, canChkIn);
            }

            return Row(
              children: [
                if (controller.parameters["canCheckIn"])
                  Expanded(
                    child: CustomButton(
                      text: "Check-in",
                      btnColor: controller.isDisabledBtn.value
                          ? AppColor.primaryColor.withOpacity(.7)
                          : AppColor.primaryColor,
                      onPressed: controller.isDisabledBtn.value
                          ? () {}
                          : () {
                              bongGo(true);
                            },
                    ),
                  ),
                if (controller.parameters["canCheckIn"]) Container(width: 10),
                Expanded(
                  child: CustomButton(
                      text: "Book Now",
                      btnColor: controller.selectedVh.isEmpty
                          ? AppColor.primaryColor.withOpacity(.6)
                          : AppColor.primaryColor,
                      textColor: Colors.white,
                      onPressed: controller.selectedVh.isEmpty
                          ? () {}
                          : () {
                              bongGo(false);
                            }),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class VehicleTypes extends StatefulWidget {
  final int pageIndex;
  final Function cb;
  VehicleTypes({super.key, required this.pageIndex, required this.cb});

  @override
  State<VehicleTypes> createState() => _VehicleTypesState();
}

class _VehicleTypesState extends State<VehicleTypes>
    with TickerProviderStateMixin {
  PageController? pageController;
  TextEditingController plNo = TextEditingController();
  final GlobalKey<FormState> formKeyBook = GlobalKey<FormState>();

  int? radioValue;
  int? myVhSelected;
  bool isLoading = true;
  bool isFp = true;

  @override
  void initState() {
    super.initState();
    plNo = TextEditingController();
    pageController = PageController(initialPage: 0);
    exec();
  }

  @override
  void dispose() {
    super.dispose();
    pageController!.dispose();
  }

  void exec() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final BookingController ct = Get.put(BookingController());
    return Container(
        height: MediaQuery.of(context).size.height * .65,
        padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15.0),
          ),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(),
                ),
              )
            : isFp
                ? pageViewFirst(ct)
                : pageViewSecond(ct));
  }

  Widget pageViewFirst(ct) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Form(
        key: formKeyBook,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            Container(height: 20),
            Container(
              width: 100,
              height: 5,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.shade200),
            ),
            Container(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomParagraph(
                      text: "What's your plate number?",
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    Container(height: 10),
                    CustomTextField(
                      controller: plNo,
                      title: "Plate Number",
                      labelText: "Your plate number here",
                      suffixIcon: Icons.list,
                      onIconTap: () {
                        FocusNode().unfocus();
                        setState(() {
                          isLoading = true;
                        });
                        Future.delayed(Duration(seconds: 1), () {
                          setState(() {
                            isLoading = false;
                            isFp = false;
                          });
                        });
                      },
                      onChange: (value) {
                        String capitalizeWords(String input) {
                          return input.toUpperCase();
                        }

                        String text = capitalizeWords(value);
                        plNo.value = TextEditingValue(
                          text: text,
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Plate Number is required";
                        }

                        if (value.startsWith('-') || value.endsWith('-')) {
                          return "Plate Number should not start or end with a dash";
                        }
                        if ((value.endsWith(' ') ||
                            value.endsWith('-') ||
                            value.endsWith('.'))) {
                          return "Middle name cannot end with a space, hyphen, or period";
                        }

                        return null;
                      },
                    ),
                    Container(height: 20),
                    CustomParagraph(
                      text: "Vehicle Type",
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    Container(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: AppColor.borderColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < ct.ddVehiclesData.length; i++)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  radioValue = i;
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: i < ct.ddVehiclesData.length - 1
                                        ? BorderSide(
                                            color: AppColor.borderColor,
                                            width: 1.0)
                                        : BorderSide.none,
                                  ),
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      child: radioValue == i
                                          ? Icon(
                                              Icons.radio_button_checked,
                                              color: AppColor.primaryColor,
                                              size: 25,
                                            )
                                          : Icon(
                                              Icons.radio_button_unchecked,
                                              size: 25,
                                              color: Colors.black54,
                                            ),
                                    ),
                                    Container(width: 10),
                                    CustomParagraph(
                                      text: ct.ddVehiclesData[i]
                                          ["vehicle_type"],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    )
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
            ),
            Container(height: 20),
            CustomButton(
                text: "Confirm",
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  if (formKeyBook.currentState!.validate()) {
                    if (radioValue == null) {
                      await Future.delayed(Duration(milliseconds: 200), () {
                        CustomDialog().infoDialog(
                            "Unable to proceed", "Please select vehicle type",
                            () {
                          Get.back();
                        });
                      });

                      return;
                    } else {
                      List vhDatas = [ct.ddVehiclesData[radioValue]];

                      dynamic dataCb = [
                        {
                          "vehicle_type_id": vhDatas[0]["value"],
                          "vehicle_brand_id": "",
                          "vehicle_brand_name": "",
                          "vehicle_plate_no": plNo.text,
                          "image": null,
                          "base_hours": vhDatas[0]["base_hours"],
                          "base_rate": vhDatas[0]["base_rate"],
                          "succeeding_rate": vhDatas[0]["succeeding_rate"],
                          "vehicle_type": vhDatas[0]["vehicle_type"]
                        }
                      ];

                      Get.back();
                      widget.cb(dataCb);
                    }
                  }
                }),
          ],
        ),
      ),
    );
  }

  Widget pageViewSecond(ct) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 20),
          InkWell(
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              Future.delayed(Duration(seconds: 1), () {
                setState(() {
                  isLoading = false;
                  isFp = true;
                });
              });
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
              ),
            ),
          ),
          Container(height: 20),
          CustomTitle(
            text: "My Vehicles",
            fontSize: 20,
          ),
          Container(height: 20),
          Expanded(
            child: ct.myVehiclesData.isEmpty
                ? NoDataFound(
                    text: "No registered vehicle found",
                  )
                : SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: AppColor.borderColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < ct.myVehiclesData.length; i++)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  myVhSelected = i;
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: i < ct.myVehiclesData.length - 1
                                        ? BorderSide(
                                            color: AppColor.borderColor,
                                            width: 1.0)
                                        : BorderSide.none,
                                  ),
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      child: myVhSelected == i
                                          ? Icon(
                                              Icons.radio_button_checked,
                                              color: AppColor.primaryColor,
                                              size: 25,
                                            )
                                          : Icon(
                                              Icons.radio_button_unchecked,
                                              size: 25,
                                              color: Colors.black54,
                                            ),
                                    ),
                                    Container(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomParagraph(
                                            text: ct.myVehiclesData[i]
                                                ["vehicle_plate_no"],
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                          ),
                                          Container(height: 5),
                                          CustomParagraph(
                                            text: ct.myVehiclesData[i]
                                                ["vehicle_type"],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
          Visibility(
            visible: ct.myVehiclesData.isNotEmpty,
            child: CustomButton(
                text: "Confirm",
                onPressed: () {
                  List vhDatas = [ct.myVehiclesData[myVhSelected]];
                  dynamic recData = ct.ddVehiclesData;

                  Map<int, Map<String, dynamic>> recDataMap = {
                    for (var item in recData) item['value']: item
                  };
                  // Merge base_hours and succeeding_rate into vhDatas
                  for (var vh in vhDatas) {
                    int typeId = vh['vehicle_type_id'];
                    if (recDataMap.containsKey(typeId)) {
                      var rec = recDataMap[typeId];
                      vh['base_hours'] = rec?['base_hours'];
                      vh['base_rate'] = rec?['base_rate'];
                      vh['succeeding_rate'] = rec?['succeeding_rate'];
                      vh['vehicle_type'] = rec?['vehicle_type'];
                    }
                  }
                  Get.back();
                  widget.cb(vhDatas);
                }),
          ),
        ],
      ),
    );
  }
}
