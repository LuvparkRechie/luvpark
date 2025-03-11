// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/booking/index.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/app_color.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/custom_text.dart';
import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/no_internet.dart';

class BookingPageNew extends StatefulWidget {
  const BookingPageNew({super.key});

  @override
  State<BookingPageNew> createState() => _BookingPageNewState();
}

class _BookingPageNewState extends State<BookingPageNew> {
  @override
  Widget build(BuildContext context) {
    final ct = Get.put(BookingController());

    return Obx(
      () => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
        child: PopScope(
          canPop: !ct.isLoadingPage.value,
          child: Scaffold(
            backgroundColor: AppColor.bodyColor,
            appBar: AppBar(
              elevation: 1,
              backgroundColor: AppColor.primaryColor,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: AppColor.primaryColor,
                statusBarBrightness: Brightness.dark,
                statusBarIconBrightness: Brightness.light,
              ),
              title: Text("Book"),
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
            body: SafeArea(
              child: !ct.isInternetConn.value
                  ? NoInternetConnected(
                      onTap: ct.getMyVehicle,
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
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    mainBody(ct),
                                  ],
                                ),
                              ),
                            ),
                            totalPayment(ct),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Padding mainBody(BookingController ct) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          parkingDetailsandVehicle(ct),
          SizedBox(height: 20),
          parkTime(),
          // if (!ct.selectedVh[0]["isAllowSubscription"])
          //   Visibility(
          //     visible: ct.maxHrs.value > 0,
          //     child: CustomParagraph(
          //       text: "  Parking will be closing soon.",
          //       color:
          //           ct.maxHrs.value == 1 ? Colors.red : AppColor.primaryColor,
          //       fontSize: 12,
          //     ),
          //   ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: Color(0xFFDFE7EF)),
                borderRadius: BorderRadius.circular(7),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(height: 30, "assets/images/logo.png"),
                          SizedBox(width: 14),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomParagraph(
                                text: "Wallet balance",
                                fontWeight: FontWeight.w600,
                              ),
                              CustomTitle(
                                text:
                                    "${toCurrencyString(ct.parameters["userData"][0]["amount_bal"].toString()).toString()}",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Visibility(
                    visible:
                        ct.displayRewards.value > 0 && ct.selectedVh.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                      child: Row(
                        children: [
                          Image.asset(
                              height: 30, "assets/images/rewardicon.png"),
                          SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomParagraph(
                                text: "Rewards",
                                fontWeight: FontWeight.w600,
                              ),
                              CustomTitle(
                                text: toCurrencyString(
                                    ct.displayRewards.toString()),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                      visible: ct.displayRewards.value > 0 &&
                          ct.selectedVh.isNotEmpty,
                      child: Divider()),
                  Visibility(
                    visible:
                        ct.displayRewards.value > 0 && ct.selectedVh.isNotEmpty,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomParagraph(
                          text: "Do you want to use rewards?",
                          fontSize: 12,
                        ),
                        Checkbox(
                          value: ct.isUseRewards.value,
                          onChanged: (bool? value) {
                            ct.onToggleRewards(value ?? false);
                          },
                          activeColor: AppColor.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container parkingDetailsandVehicle(BookingController ct) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: MediaQuery.of(context).size.width,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFDFE7EF)),
          borderRadius: BorderRadius.circular(7),
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
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: StretchingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomParagraph(
                        text: ct.parameters["areaData"]["park_area_name"],
                        maxlines: 1,
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      CustomParagraph(
                        text: ct.parameters["areaData"]["address"],
                        fontSize: 12,
                        color: Colors.black,
                        maxlines: 2,
                      ),
                      SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Iconsax.location4,
                            color: Colors.black,
                            size: 15,
                          ),
                          SizedBox(width: 3),
                          CustomParagraph(
                            text: ct.parameters["areaData"]["distance_display"],
                            color: Colors.black,
                            fontSize: 12,
                            maxlines: 2,
                            fontWeight: FontWeight.w300,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Divider(
                        color: Colors.grey,
                      ),
                      SizedBox(height: 5),
                      ct.selectedVh.isEmpty
                          ? GestureDetector(
                              onTap: () {
                                ct.vehicleSelection(1);
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomParagraph(
                                      text: 'Tap to add vehicle',
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Icon(
                                      Symbols.add,
                                      color: Colors.black,
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
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomParagraph(
                                        text: "${ct.plateNo.text}",
                                        color: AppColor.primaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      Container(height: 5),
                                      CustomParagraph(
                                        text:
                                            "${ct.selectedVh[0]["vehicle_type"]}",
                                        maxlines: 2,
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
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColor.primaryColor,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: CustomParagraph(
                                      text: "Switch vehicle",
                                      color: AppColor.primaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container totalPayment(BookingController ct) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.blue.shade100,
          ),
        ),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
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
                text: toCurrencyString(ct.totalAmount.value).toString(),
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ],
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: ct.isDisabledBtn.value
                ? () {}
                : () {
                    // ct.confirmBooking();
                  },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade300),
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    ct.isDisabledBtn.value
                        ? AppColor.primaryColor.withOpacity(.7)
                        : Colors.blue.shade400,
                    ct.isDisabledBtn.value
                        ? AppColor.primaryColor
                        : Colors.blue.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(5, 5),
                    blurRadius: 15,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.7),
                    offset: Offset(-5, -5),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: CustomTitle(
                  text: "Confirm Booking",
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class parkTime extends StatelessWidget {
  const parkTime({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final BookingController ct = Get.find();

    var dateIn = DateTime.parse("${ct.startDate.text} ${ct.timeInParam.text}");

    String dtIn = DateFormat('E, dd MMM yyyy').format(dateIn);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      width: MediaQuery.of(context).size.width,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFDFE7EF)),
          borderRadius: BorderRadius.circular(7),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomParagraph(
            fontWeight: FontWeight.w500,
            fontSize: 10,
            text: "Parking Time",
          ),
          CustomParagraph(
            fontWeight: FontWeight.w500,
            color: AppColor.primaryColor,
            fontSize: 18,
            text:
                "${ct.bookingHrs.value} ${int.parse(ct.bookingHrs.value.toString()) > 1 ? "Hours" : "Hour"}",
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomParagraph(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    text: 'Check in',
                  ),
                  CustomTitle(
                    text: ct.startTime.value,
                    color: Colors.black87,
                  ),
                  CustomParagraph(
                      text: dtIn, color: Colors.black54, fontSize: 10),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomParagraph(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    text: 'Check out',
                  ),
                  CustomTitle(
                    text: ct.is24hrsValue.value
                        ? ct.startTime.value
                        : ct.closingTime.value,
                    color: Colors.black87,
                  ),
                  CustomParagraph(
                      text: ct.is24hrsValue.value ? "${ct.out24hrs}" : dtIn,
                      color: Colors.black54,
                      fontSize: 10),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.info_outlined, size: 15, color: AppColor.primaryColor),
              SizedBox(width: 5),
              CustomParagraph(
                text: "Payment based on hours consumed",
                color: AppColor.primaryColor,
                fontSize: 12,
              ),
            ],
          )
        ],
      ),
    );
  }
}
