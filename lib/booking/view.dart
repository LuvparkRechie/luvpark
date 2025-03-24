import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/booking/index.dart';
import 'package:luvpark/booking/utils/my_vh_list.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';

class BookingPage extends GetView<BookingController> {
  const BookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
        child: PopScope(
          canPop: !controller.isLoadingPage.value,
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
              title: Text(
                  controller.pageInd.value == 1 ? "Choose Vehicle" : "Book"),
              centerTitle: true,
              leading: GestureDetector(
                onTap: () {
                  if (controller.pageInd.value == 1) {
                    controller.pageInd.value = 0;
                    return;
                  } else {
                    Get.back();
                  }
                },
                child: Icon(
                  Iconsax.arrow_left,
                  color: Colors.white,
                ),
              ),
            ),
            body: !controller.isInternetConn.value
                ? NoInternetConnected(
                    onTap: controller.getMyVehicle,
                  )
                : controller.isLoadingPage.value ||
                        controller.stBookTime.value.isEmpty
                    ? const Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          // Fade + Slide Transition
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(
                                    1.0, 0.0), // Start slightly lower
                                end: Offset.zero, // End at normal position
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut, // Smooth easing
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: controller.pageInd.value == 0
                            ? pageOne()
                            : MyVhList(
                                noOfHrs: controller.noOfHours.value,
                                vhData: controller.myVehiclesData,
                                vhType: controller.ddVehiclesData,
                                cb: (dataCb) {
                                  controller.pageInd.value = 0;
                                  controller.initializedBookParam(dataCb);
                                },
                              ),
                      ),
          ),
        ),
      ),
    );
  }

  Widget pageOne() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: mainBody(controller),
          ),
        ),
        totalPayment(controller),
      ],
    );
  }

  Padding mainBody(BookingController ct) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          parkingDetailsandVehicle(ct),
          SizedBox(height: 20),
          parkTime(),
          SizedBox(height: 20),
          walletBal(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Container walletBal() {
    final BookingController ct = Get.find();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
            visible: ct.displayRewards.value > 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: Row(
                children: [
                  Image.asset(height: 30, "assets/images/rewardicon.png"),
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
                        text: toCurrencyString(ct.displayRewards.toString()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: ct.postBookParam.isEmpty
                ? false
                : ct.displayRewards.value > 0
                    ? true
                    : false,
            child: Column(
              children: [
                Divider(),
                Row(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container parkingDetailsandVehicle(BookingController ct) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: MediaQuery.of(Get.context!).size.width,
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
                      ct.postBookParam.isEmpty
                          ? GestureDetector(
                              onTap: () {
                                controller.pageInd.value = 1;
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomParagraph(
                                      text: 'Tap to add vehicle',
                                      color: AppColor.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Icon(
                                      LucideIcons.plusSquare,
                                      color: AppColor.primaryColor,
                                      size: 20,
                                      weight: 1000,
                                    ),
                                  ),
                                  Container(width: 10)
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
                                        text:
                                            "${ct.postBookParam["vehicle_plate_no"]}",
                                        color: AppColor.primaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      Container(height: 5),
                                      CustomParagraph(
                                        text: "${ct.vhTypeDisp.value}",
                                        maxlines: 2,
                                        fontSize: 12,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 10),
                                InkWell(
                                  onTap: () {
                                    controller.pageInd.value = 1;
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
      width: MediaQuery.of(Get.context!).size.width,
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
                text: toCurrencyString(ct.postBookParam.isEmpty
                        ? "0"
                        : ct.postBookParam["amount"].toString())
                    .toString(),
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ],
          ),
          SizedBox(height: 20),
          CustomButton(
              btnColor: ct.postBookParam.isEmpty
                  ? AppColor.primaryColor.withOpacity(.7)
                  : AppColor.primaryColor,
              text: "Confirm Booking",
              onPressed:
                  ct.postBookParam.isEmpty ? () {} : controller.confirmBooking)
        ],
      ),
    );
  }

  Container parkTime() {
    final BookingController ct = Get.find();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      width: MediaQuery.of(Get.context!).size.width,
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
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
            text: "Parking Time",
          ),
          CustomParagraph(
            fontWeight: FontWeight.w500,
            color: AppColor.primaryColor,
            fontSize: 18,
            text:
                "${ct.noOfHours.value} ${int.parse(ct.noOfHours.value.toString()) > 1 ? "Hours" : "Hour"}",
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
                    text:
                        "${DateFormat('h:mm a').format(DateTime.parse(ct.stBookTime.value)).toString()}",
                    color: Colors.black87,
                  ),
                  CustomParagraph(
                    text:
                        "${DateFormat('E, dd MMM yyyy').format(DateTime.parse(ct.stBookTime.value))}",
                    color: Colors.black54,
                    fontSize: 10,
                  ),
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
                    text:
                        "${DateFormat('h:mm a').format(DateTime.parse(ct.endBookTime.value)).toString()}",
                    color: Colors.black87,
                  ),
                  CustomParagraph(
                      text: ct.is24Hrs.value
                          ? "${DateFormat('E, dd MMM yyyy').format(DateTime.parse(ct.endBookTime.value))}"
                          : "${DateFormat('E, dd MMM yyyy').format(DateTime.parse(ct.stBookTime.value))}",
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
