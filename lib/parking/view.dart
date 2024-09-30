import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/no_data_found.dart';
import 'package:luvpark_get/custom_widgets/no_internet.dart';
import 'package:luvpark_get/custom_widgets/park_shimmer.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/routes/routes.dart';

import 'controller.dart';

class ParkingScreen extends GetView<ParkingController> {
  const ParkingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColor.bodyColor,
        appBar: CustomAppbar(
          title: "My Parking",
          bgColor: AppColor.primaryColor,
          titleColor: Colors.white,
          textColor: Colors.white,
          elevation: 0,
          onTap: () {
            switch (controller.parameter) {
              case 'N':
                Get.back();
                break;
              case 'D':
                Get.back();
                break;
              case 'B':
                Get.offAndToNamed(Routes.map);
                break;
            }
          },
        ),
        body: Obx(
          () => StretchingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            child: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(overscroll: false),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 1),
                          blurRadius: 1,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          child: Container(
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D62C3),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: const Color(0xFF0D62C3),
                              ),
                            ),
                            child: Row(children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (controller.isLoading.value) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Loading on progress, Please wait...'),
                                          duration: Duration(seconds: 2),
                                          backgroundColor: Colors.blue,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }
                                    controller.onTabTapped(0);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                    padding: const EdgeInsets.all(10),
                                    decoration:
                                        controller.currentPage.value != 0
                                            ? decor2()
                                            : decor1(),
                                    child: Center(
                                      child: CustomParagraph(
                                        text: "Reservations",
                                        fontSize: 14,
                                        color: controller.currentPage.value != 0
                                            ? Colors.white38
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(width: 5),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (controller.isLoading.value) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Loading on progress, Please wait...'),
                                          duration: Duration(seconds: 2),
                                          backgroundColor: Colors.blue,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }
                                    controller.onTabTapped(1);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                    padding: const EdgeInsets.all(10),
                                    decoration:
                                        controller.currentPage.value != 1
                                            ? decor2()
                                            : decor1(),
                                    child: Center(
                                        child: CustomParagraph(
                                      text: "Active Parking",
                                      fontSize: 14,
                                      color: controller.currentPage.value != 1
                                          ? Colors.white38
                                          : Colors.white,
                                    )),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 10),
                  Expanded(
                    child: controller.isLoading.value
                        ? const ParkShimmer()
                        : !controller.hasNet.value
                            ? NoInternetConnected(
                                onTap: controller.onRefresh,
                              )
                            : controller.resData.isEmpty
                                ? const NoDataFound(
                                    text: "No parking found",
                                  )
                                : RefreshIndicator(
                                    onRefresh: controller.onRefresh,
                                    child: ListView.separated(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 15),
                                        itemBuilder: (context, index) {
                                          String title = controller
                                              .resData[index]["park_area_name"];
                                          String subTitle = controller
                                              .resData[index]["ticket_ref_no"];
                                          String date =
                                              Variables.convertDateFormat(
                                                  controller.resData[index]
                                                      ["dt_in"]);
                                          String time =
                                              "${Variables.convertTime(controller.resData[index]["dt_in"].toString().split(" ")[1])} - ${Variables.convertTime(controller.resData[index]["dt_out"].toString().split(" ")[1])}";
                                          String totalAmt = toCurrencyString(
                                              controller.resData[index]
                                                      ["amount"]
                                                  .toString());
                                          String status = controller
                                                          .resData[index]
                                                      ["status"] ==
                                                  "U"
                                              ? "${controller.resData[index]["is_auto_extend"].toString() == "Y" ? "EXTENDED" : "ACTIVE"} PARKING"
                                              : "CONFIRMED";

                                          return ListCard(
                                            title: title,
                                            subTitle: subTitle,
                                            date: date,
                                            time: time,
                                            totalAmt: totalAmt,
                                            status: status,
                                            data: controller.resData[index],
                                            currentTab:
                                                controller.currentPage.value,
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(
                                              height: 15,
                                            ),
                                        itemCount: controller.resData.length),
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

//selected tab
  BoxDecoration decor1() {
    return BoxDecoration(
      color: Colors.white30,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(
        color: Colors.transparent,
      ),
    );
  }

//unselected tab
  BoxDecoration decor2() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      color: const Color(0xFF0D62C3),
      border: Border.all(
        color: const Color(0xFF0D62C3),
      ),
    );
  }
}

class ListCard extends GetView<ParkingController> {
  final String title, subTitle, date, time, totalAmt, status;
  final int currentTab;
  final dynamic data;

  const ListCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.date,
    required this.time,
    required this.totalAmt,
    required this.status,
    required this.data,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        controller.getParkingDetails(data);
      },
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFE8E6E6)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: currentTab == 0
                          ? const Color(0xFFF0E6C3)
                          : const Color(0xFFEAF3EA),
                      child: SvgPicture.asset(
                        "assets/dashboard_icon/${currentTab == 0 ? "orange_check" : "green_check"}.svg",
                        height: 24,
                        width: 24,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomTitle(
                            text: title,
                            color: AppColor.primaryColor,
                            letterSpacing: -0.41,
                            maxlines: 1,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (data["is_auto_extend"] == "Y")
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 253, 244, 255),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: CustomParagraph(
                                text: "Auto-extend",
                                color: Colors.purple,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: CustomParagraph(
                      text: subTitle,
                      fontSize: 14,
                      letterSpacing: -0.41,
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 35.50,
                        height: 35.50,
                        child: Image(
                          image:
                              AssetImage("assets/dashboard_icon/calendar.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                      Container(width: 8),
                      CustomParagraph(
                        text: date,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.41,
                      ),
                      Container(width: 15),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(
                                width: 35.50,
                                height: 35.50,
                                child: Image(
                                  image: AssetImage(
                                      "assets/dashboard_icon/clock.png"),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Container(width: 8),
                              Flexible(
                                child: CustomParagraph(
                                  text: time,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.41,
                                  maxlines: 1,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: const BoxDecoration(
                  color: Color(0xFF2495eb),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(10))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomTitle(
                        text: "Total Paid:",
                        color: Colors.white,
                        letterSpacing: -0.41,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      Container(
                        width: 5,
                      ),
                      CustomTitle(
                        text: totalAmt,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.41,
                        fontSize: 14,
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
