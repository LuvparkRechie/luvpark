import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

import '../custom_widgets/custom_expansion.dart';
import '../custom_widgets/variables.dart';

class BookingPage extends GetView<BookingController> {
  const BookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
        child: PopScope(
          canPop: !controller.isLoadingPage.value,
          child: Listener(
            onPointerDown: (PointerDownEvent event) {
              controller.onUserInteraction();
            },
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
                                            CustomDialog()
                                                .loadingDialog(context);
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
                                        // Container(
                                        //   width: double.infinity,
                                        //   padding: EdgeInsets.all(15),
                                        //   decoration: BoxDecoration(
                                        //     borderRadius:
                                        //         BorderRadius.circular(15),
                                        //     color: Colors.grey.shade300,
                                        //   ),
                                        //   child: Row(
                                        //     children: [
                                        //       Expanded(
                                        //         child: Column(
                                        //           crossAxisAlignment:
                                        //               CrossAxisAlignment.start,
                                        //           children: [
                                        //             CustomTitle(
                                        //                 text: controller
                                        //                             .parameters[
                                        //                         "areaData"]
                                        //                     ["park_area_name"]),
                                        //             Container(height: 5),
                                        //             CustomParagraph(
                                        //               text:
                                        //                   controller.parameters[
                                        //                           "areaData"]
                                        //                       ["address"],
                                        //               maxlines: 2,
                                        //             )
                                        //           ],
                                        //         ),
                                        //       ),
                                        //       Container(width: 10),
                                        //       CustomParagraph(
                                        //         text:
                                        //             "${controller.parameters["areaData"]["distance_display"].toString().split("away")[0]}\naway",
                                        //         fontSize: 10,
                                        //         color: AppColor.primaryColor,
                                        //         fontWeight: FontWeight.w600,
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
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

                                        Container(height: 20),
                                        Form(
                                          key: controller.formKeyBook,
                                          autovalidateMode:
                                              AutovalidateMode.disabled,
                                          child: Column(
                                            children: [
                                              CustomTextField(
                                                isReadOnly: controller
                                                    .isSubscribed.value,
                                                isFilled: controller
                                                    .isSubscribed.value,
                                                filledColor:
                                                    Colors.grey.shade200,
                                                labelText: "Plate No",
                                                controller: controller.plateNo,
                                                suffixIcon: LucideIcons.menu,
                                                onIconTap: () {
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) {
                                                    controller.displaySelVh();
                                                  });
                                                },
                                                onChange: (value) {
                                                  String trimmedValue = value
                                                      .toUpperCase()
                                                      .replaceFirst(
                                                          RegExp(
                                                              r'[^a-zA-Z0-9. ]'),
                                                          '');

                                                  if (trimmedValue.isNotEmpty) {
                                                    controller.plateNo.value =
                                                        TextEditingValue(
                                                      text: Variables
                                                          .capitalizeAllWord(
                                                              trimmedValue),
                                                      selection: controller
                                                          .plateNo.selection,
                                                    );
                                                    controller.selectedVh[0][
                                                            "vehicle_plate_no"] =
                                                        Variables
                                                            .capitalizeAllWord(
                                                                trimmedValue);
                                                  } else {
                                                    controller.plateNo.value =
                                                        TextEditingValue(
                                                      text: "",
                                                      selection: TextSelection
                                                          .collapsed(offset: 0),
                                                    );
                                                    controller.selectedVh[0][
                                                            "vehicle_plate_no"] =
                                                        Variables
                                                            .capitalizeAllWord(
                                                                trimmedValue);
                                                  }
                                                  controller.onFieldChanged();
                                                },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Plate No. is required";
                                                  }

                                                  if (value.startsWith('-') ||
                                                      value.endsWith('-')) {
                                                    return "Plate No. should not start or end with a dash";
                                                  }
                                                  if ((value.endsWith(' ') ||
                                                      value.endsWith('-') ||
                                                      value.endsWith('.'))) {
                                                    return "Middle name cannot end with a space, hyphen, or period";
                                                  }

                                                  return "";
                                                },
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15.0, bottom: 10),
                                                child: customDropdown(
                                                  isDisabled: controller
                                                      .isSubscribed.value,
                                                  labelText: "Vehicle type",
                                                  items:
                                                      controller.ddVehiclesData,
                                                  selectedValue:
                                                      controller.dropdownValue,
                                                  onChanged: (value) {
                                                    controller.dropdownValue =
                                                        value;
                                                    controller.onFieldChanged();
                                                    controller
                                                        .onChangedVtype(value);
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
                                            ],
                                          ),
                                        ),
                                        Container(height: 10),
                                        CustomTitle(
                                          text: "How long do you want to park?",
                                          fontSize: 16,
                                        ),
                                        Container(height: 15),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: AppColor
                                                            .borderColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: controller
                                                            .isSubscribed.value
                                                        ? Colors.grey.shade200
                                                        : Colors.grey.shade50),
                                                child: TextFormField(
                                                  readOnly: controller
                                                      .isSubscribed.value,
                                                  controller:
                                                      controller.noHours,
                                                  textAlign: TextAlign.center,
                                                  autofocus: false,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 10,
                                                            horizontal: 12),
                                                    hintText: "1 Hour",
                                                    border: InputBorder.none,
                                                    hintStyle: paragraphStyle(
                                                      color: AppColor.hintColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    labelStyle: paragraphStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            AppColor.hintColor),
                                                    floatingLabelStyle:
                                                        TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  style: paragraphStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 20),
                                                  onChanged: (value) {
                                                    controller.onFieldChanged();
                                                    if (int.parse(
                                                            value.toString()) >
                                                        4) {
                                                      CustomDialog().infoDialog(
                                                          "Booking Limit Exceed",
                                                          "You have atleast 4 hours of booking.",
                                                          () {
                                                        Get.back();
                                                        controller
                                                                .noHours.text =
                                                            "${controller.endNumber.value}";
                                                        controller
                                                                .selectedNumber
                                                                .value =
                                                            controller.endNumber
                                                                .value;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            Container(width: 10),
                                            Container(
                                              decoration: ShapeDecoration(
                                                shape: CircleBorder(),
                                                color: controller
                                                        .isSubscribed.value
                                                    ? Colors.grey.shade200
                                                    : Colors.grey.shade100,
                                              ),
                                              child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: controller
                                                          .isSubscribed.value
                                                      ? () {}
                                                      : () {
                                                          if (controller
                                                              .selectedVh
                                                              .isEmpty) return;
                                                          controller
                                                              .onTapChanged(
                                                                  false);
                                                        },
                                                  icon: Icon(
                                                    LucideIcons.minus,
                                                    color:
                                                        AppColor.primaryColor,
                                                  )),
                                            ),
                                            Container(width: 10),
                                            Container(
                                              decoration: ShapeDecoration(
                                                  shape: CircleBorder(),
                                                  color: controller
                                                          .isSubscribed.value
                                                      ? AppColor.primaryColor
                                                          .withOpacity(.7)
                                                      : AppColor.primaryColor),
                                              child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: controller
                                                          .isSubscribed.value
                                                      ? () {}
                                                      : () {
                                                          if (controller
                                                              .selectedVh
                                                              .isEmpty) return;
                                                          controller
                                                              .onTapChanged(
                                                                  true);
                                                        },
                                                  icon: Icon(
                                                    LucideIcons.plus,
                                                    color: Colors.white,
                                                  )),
                                            ),
                                          ],
                                        ),

                                        Container(height: 10),
                                        Visibility(
                                          visible:
                                              controller.endNumber.value > 0,
                                          child: CustomParagraph(
                                            text:
                                                "Booking limit is up to ${controller.endNumber.value} ${controller.endNumber.value > 1 ? "Hours" : "Hour"}",
                                            fontSize: 6,
                                          ),
                                        ),
                                        Container(height: 20),
                                        CustomTitle(
                                          text: "Payment Details",
                                          fontSize: 16,
                                        ),
                                        Container(height: 10),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              width: 1,
                                              color: Color(0xFFDFE7EF),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                leading: Icon(
                                                  Icons.check_circle_outline,
                                                  color: Colors.green,
                                                  size: 20,
                                                ),
                                                title: Text(
                                                  "Current Balance",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                trailing: CustomParagraph(
                                                  text: toCurrencyString(
                                                          controller.parameters[
                                                                  "userData"][0]
                                                                  ["amount_bal"]
                                                              .toString())
                                                      .toString(),
                                                  color: AppColor.headerColor,
                                                  fontWeight: FontWeight.w500,
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              Visibility(
                                                visible: double.parse(controller
                                                        .displayRewards
                                                        .toString()) >
                                                    0,
                                                child: Container(
                                                  height: 1,
                                                  color: Colors.grey.shade200,
                                                  width: double.infinity,
                                                ),
                                              ),
                                              Visibility(
                                                visible: double.parse(controller
                                                        .displayRewards
                                                        .toString()) >
                                                    0,
                                                child: CustomExpandableItem(
                                                  trailingIcon:
                                                      LucideIcons.edit,
                                                  trailTap: () {
                                                    Get.bottomSheet(
                                                      rewardDialog(),
                                                      isScrollControlled: true,
                                                      isDismissible: false,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  15.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  15.0),
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.white,
                                                    );
                                                  },
                                                  leading: Icon(
                                                    controller.isExpandedPansion
                                                            .value
                                                        ? Icons
                                                            .check_circle_outline
                                                        : Icons.circle_outlined,
                                                    color: controller
                                                            .isExpandedPansion
                                                            .value
                                                        ? Colors.green
                                                        : Colors.grey,
                                                    size: 20,
                                                  ),
                                                  title: "Points",
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              CustomParagraph(
                                                                text:
                                                                    "Points: ",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 12,
                                                              ),
                                                              CustomParagraph(
                                                                text: toCurrencyString(controller
                                                                        .displayRewards
                                                                        .toString())
                                                                    .toString(),
                                                                color: AppColor
                                                                    .headerColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                maxlines: 1,
                                                              ),
                                                            ],
                                                          ),
                                                          Container(height: 15),
                                                          for (dynamic data
                                                              in controller
                                                                  .pointsData)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          5),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  CustomParagraph(
                                                                    text:
                                                                        "${data["name"]}:",
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                  CustomParagraph(
                                                                    text: toCurrencyString(
                                                                            data["value"].toString())
                                                                        .toString(),
                                                                    color: AppColor
                                                                        .headerColor,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    maxlines: 1,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(height: 20),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: controller.isSubscribed.value
                                                ? Colors.grey.shade200
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              width: 1,
                                              color: Color(0xFFDFE7EF),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomTitle(
                                                      text: "Auto Extend",
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 15,
                                                    ),
                                                    Container(
                                                      height: 5,
                                                    ),
                                                    CustomParagraph(
                                                      text:
                                                          "${toCurrencyString(controller.selectedVh.isEmpty ? "0" : controller.selectedVh[0]["succeeding_rate"].toString())}/Succeeding hours",
                                                      letterSpacing: -0.41,
                                                      fontSize: 10,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(width: 10),
                                              GestureDetector(
                                                onTap: controller
                                                        .isSubscribed.value
                                                    ? () {}
                                                    : () {
                                                        controller
                                                            .toggleExtendChecked(
                                                                !controller
                                                                    .isExtendchecked
                                                                    .value);
                                                      },
                                                child: Container(
                                                  width: 60,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    gradient: LinearGradient(
                                                      colors: controller
                                                              .isExtendchecked
                                                              .value
                                                          ? [
                                                              Colors.green,
                                                              Colors.lightGreen
                                                            ]
                                                          : [
                                                              Colors.red,
                                                              Colors.redAccent
                                                            ],
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      if (controller
                                                          .isExtendchecked
                                                          .value)
                                                        Positioned(
                                                          left: 10,
                                                          child: Icon(
                                                            LucideIcons.check,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      if (!controller
                                                          .isExtendchecked
                                                          .value)
                                                        Positioned(
                                                          right: 10,
                                                          child: Icon(
                                                            Icons.clear,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      AnimatedPositioned(
                                                        duration: Duration(
                                                          milliseconds: 200,
                                                        ),
                                                        left: controller
                                                                .isExtendchecked
                                                                .value
                                                            ? 30
                                                            : 5,
                                                        child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black26,
                                                                blurRadius: 4.0,
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
                                        Container(height: 10),
                                        CustomParagraph(
                                          text:
                                              "Your parking duration will be automatically extended using your "
                                              "available balance if it is enabled.",
                                          fontSize: 10,
                                        ),
                                        Container(height: 20),

                                        //end
                                      ],
                                    ),
                                  ),
                                )),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(15)),
                                    border: Border(
                                      top: BorderSide(
                                        width: 1,
                                        color: Color(0xFFDFE7EF),
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(height: 20),
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
                                            text: toCurrencyString(controller
                                                    .totalAmount.value)
                                                .toString(),
                                            fontSize: 20,
                                            color: AppColor.headerColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ],
                                      ),
                                      Container(height: 20),
                                      CustomButton(
                                        text: "Book Now",
                                        btnColor: controller.isDisabledBtn.value
                                            ? AppColor.primaryColor
                                                .withOpacity(.7)
                                            : AppColor.primaryColor,
                                        onPressed: controller
                                                .isDisabledBtn.value
                                            ? () {}
                                            : () {
                                                print(controller.selectedVh);
                                                controller.confirmBooking();
                                              },
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
      ),
    );
  }

  Container rewardDialog() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 30, 15, 10),
      height: MediaQuery.of(Get.context!).size.height * .50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              controller.rewardsCon.clear();
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
          Container(
            height: 20,
          ),
          CustomTitle(
            text: "Reward points",
            fontSize: 20,
          ),
          CustomTextField(
            labelText: "Amount",
            controller: controller.rewardsCon,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChange: (value) {
              if (int.parse(value.toString()) >=
                  int.parse(controller.totalAmount.value)) {
                FocusManager.instance.primaryFocus!.unfocus();
                Future.delayed(Duration(milliseconds: 500), () {
                  CustomDialog().infoDialog("Amount Exceed", "Invalid amount",
                      () {
                    Get.back();
                    controller.rewardsCon.text =
                        value.substring(0, value.length - 1);
                  });
                });
              }
            },
          ),
          Container(height: 10),
          CustomParagraph(
            text:
                "Reward points should not be greater than the total bill for parking",
            maxlines: 2,
            fontSize: 10,
          ),
          Container(height: 50),
          CustomButton(
            text: "Proceed",
            onPressed: () {},
          )
        ],
      ),
    );
  }
}

class MyVhList extends GetView<BookingController> {
  final Function callback;
  const MyVhList(this.callback, {super.key});

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
      backgroundColor: AppColor.bodyColor,
      body: Container(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        color: AppColor.bodyColor,
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
              "My Vehicle",
              style: GoogleFonts.openSans(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: AppColor.headerColor,
              ),
            ),
            Container(height: 10),
            CustomParagraph(text: "Choose vehicle from the list"),
            Container(height: 20),
            Expanded(
              child: controller.myVehiclesData.isEmpty
                  ? NoDataFound(
                      text: "No registered vehicle",
                    )
                  : Scrollbar(
                      child: ListView.builder(
                        itemCount: controller.myVehiclesData.length,
                        itemBuilder: (context, index) {
                          String removeInvalidCharacters(String input) {
                            final RegExp validChars =
                                RegExp(r'[^A-Za-z0-9+/=]');

                            return input.replaceAll(validChars, '');
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () {
                                List vhDatas = [
                                  controller.myVehiclesData[index]
                                ];
                                dynamic recData = controller.ddVehiclesData;

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
                                    vh['succeeding_rate'] =
                                        rec?['succeeding_rate'];
                                    vh['vehicle_type'] = rec?['vehicle_type'];
                                  }
                                }
                                Get.back();
                                callback(vhDatas);
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
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
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomParagraph(
                                                  text: controller
                                                      .myVehiclesData[index]
                                                          ["vehicle_brand_name"]
                                                      .toString()
                                                      .toUpperCase(),
                                                  color: AppColor.headerColor,
                                                  fontSize: 12,
                                                ),
                                                Container(height: 5),
                                                CustomParagraph(
                                                  text: controller
                                                      .myVehiclesData[index]
                                                          ["vehicle_plate_no"]
                                                      .toString()
                                                      .toUpperCase(),
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  fit: BoxFit.contain,
                                                  image: controller.myVehiclesData[
                                                                      index]
                                                                  ["image"] ==
                                                              null ||
                                                          controller
                                                              .myVehiclesData[
                                                                  index]
                                                                  ["image"]
                                                              .isEmpty
                                                      ? AssetImage(
                                                              "assets/images/no_image.png")
                                                          as ImageProvider
                                                      : MemoryImage(
                                                          base64Decode(
                                                            removeInvalidCharacters(
                                                                controller.myVehiclesData[
                                                                        index]
                                                                    ["image"]),
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmBooking extends GetView<BookingController> {
  const ConfirmBooking({super.key});

  @override
  Widget build(BuildContext context) {
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
              CustomParagraph(
                text:
                    "${controller.startTime.value} → ${controller.endTime.value}",
                fontWeight: FontWeight.w500,
              ),
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
          CustomButton(
              text:
                  controller.parameters["canCheckIn"] ? "Check In" : "Confirm",
              btnColor: controller.selectedVh.isEmpty
                  ? AppColor.primaryColor.withOpacity(.6)
                  : AppColor.primaryColor,
              textColor: Colors.white,
              onPressed: controller.selectedVh.isEmpty
                  ? () {}
                  : () {
                      var dateIn = DateTime.parse(
                          "${controller.startDate.text} ${controller.timeInParam.text}");

                      var dateOut = dateIn.add(
                        Duration(
                          hours: controller.selectedNumber.value,
                        ),
                      );

                      String finalDateOut =
                          "${DateFormat('yyyy-MM-dd').format(DateTime.parse(dateOut.toString()))} ${controller.paramEndTime.value}";

                      void bongGo() {
                        Map<String, dynamic> parameters = {
                          "client_id": controller.parameters["areaData"]
                              ["client_id"],
                          "park_area_id": controller.parameters["areaData"]
                              ["park_area_id"],
                          "vehicle_plate_no": controller.selectedVh[0]
                              ["vehicle_plate_no"],
                          "vehicle_type_id": controller.selectedVh[0]
                                  ["vehicle_type_id"]
                              .toString(),
                          "dt_in": dateIn.toString().toString().split(".")[0],
                          "dt_out": finalDateOut,
                          "no_hours": controller.selectedNumber,
                          'base_rate': controller.selectedVh[0]["base_rate"],
                          "base_hours": controller.selectedVh[0]["base_hours"],
                          "succeeding_rate": controller.selectedVh[0]
                              ["succeeding_rate"],
                          "disc_rate": 0,
                          "tran_type": "R",
                        };
                        controller.submitReservation(parameters);
                      }

                      bongGo();
                    }),
        ],
      ),
    );
  }
}
