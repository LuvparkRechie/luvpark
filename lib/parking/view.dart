import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/custom_widgets/park_shimmer.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/routes/routes.dart';

import '../custom_widgets/custom_button.dart';
import 'controller.dart';

class ParkingScreen extends GetView<ParkingController> {
  const ParkingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
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
        }
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.white,
          // appBar: CustomAppbar(
          //   title: "My Parking",
          //   bgColor: AppColor.primaryColor,
          //   titleColor: Colors.white,
          //   textColor: Colors.white,
          //   hasBtnColor: false,
          //   elevation: 0,
          //   onTap: () {
          //     switch (controller.parameter) {
          //       case 'N':
          //         Get.back();
          //         break;
          //       case 'D':
          //         Get.back();
          //         break;
          //       case 'B':
          //         Get.offAndToNamed(Routes.map);
          //         break;
          //     }
          //   },
          // ),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColor.primaryColor,
            toolbarHeight: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: AppColor.primaryColor,
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.light,
            ),
          ),
          body: Obx(
            () => StretchingOverscrollIndicator(
              axisDirection: AxisDirection.down,
              child: ScrollConfiguration(
                behavior: ScrollBehavior().copyWith(overscroll: false),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: AppColor.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        LucideIcons.arrowLeft,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
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
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomTitle(
                                      text: "My Parking",
                                      textAlign: TextAlign.center,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Column(
                                  children: [],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                            child: Container(
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D62C3),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Row(children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (controller.tabLoading.value) {
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
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeOut,
                                      padding: const EdgeInsets.all(10),
                                      decoration:
                                          controller.currentPage.value != 0
                                              ? decor2()
                                              : decor1(),
                                      child: Center(
                                        child: CustomParagraph(
                                          text: "Bookings",
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color:
                                              controller.currentPage.value != 0
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
                                      if (controller.tabLoading.value) {
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
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeOut,
                                      padding: const EdgeInsets.all(10),
                                      decoration:
                                          controller.currentPage.value != 1
                                              ? decor2()
                                              : decor1(),
                                      child: Center(
                                          child: CustomParagraph(
                                        text: "Active Parking",
                                        fontWeight: FontWeight.w500,
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
                    Expanded(
                      child: controller.isLoading.value ||
                              controller.tabLoading.value
                          ? const ParkShimmer()
                          : !controller.hasNet.value
                              ? NoInternetConnected(
                                  onTap: controller.onRefresh,
                                )
                              : Container(
                                  color: AppColor.bodyColor,
                                  child: controller.resData.isEmpty
                                      ? NoDataFound(
                                          text: "No parking found",
                                          onTap: controller.onRefresh,
                                        )
                                      : RefreshIndicator(
                                          onRefresh: controller.onRefresh,
                                          child: ListView.separated(
                                              padding: EdgeInsets.only(
                                                  top: 15, bottom: 5),
                                              itemBuilder: (context, index) {
                                                final bookingTimeExp =
                                                    controller.formatDuration(
                                                        controller
                                                                .resData[index]
                                                            ["time_remaining"]);

                                                String title =
                                                    controller.resData[index]
                                                        ["park_area_name"];
                                                String subTitle =
                                                    controller.resData[index]
                                                        ["ticket_ref_no"];
                                                String date =
                                                    Variables.convertDateFormat(
                                                        controller
                                                                .resData[index]
                                                            ["dt_in"]);
                                                String time =
                                                    "${Variables.convertTime(controller.resData[index]["dt_in"].toString().split(" ")[1])} - ${Variables.convertTime(controller.resData[index]["dt_out"].toString().split(" ")[1])}";
                                                String totalAmt =
                                                    toCurrencyString(controller
                                                        .resData[index]
                                                            ["amount"]
                                                        .toString());
                                                String status = controller
                                                                .resData[index]
                                                            ["status"] ==
                                                        "U"
                                                    ? "${controller.resData[index]["is_auto_extend"].toString() == "Y" ? "EXTENDED" : "ACTIVE"} PARKING"
                                                    : "CONFIRMED";

                                                return ListCard(
                                                  bookingTimeExp,
                                                  title: title,
                                                  subTitle: subTitle,
                                                  date: date,
                                                  time: time,
                                                  totalAmt: totalAmt,
                                                  status: status,
                                                  data:
                                                      controller.resData[index],
                                                  currentTab: controller
                                                      .currentPage.value,
                                                );
                                              },
                                              separatorBuilder:
                                                  (context, index) =>
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                              itemCount:
                                                  controller.resData.length),
                                        ),
                                ),
                    ),
                  ],
                ),
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
  final String title, subTitle, date, time, totalAmt, status, bookingTimeExp;
  final int currentTab;
  final dynamic data;

  const ListCard(
    this.bookingTimeExp, {
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
        // controller.getParkingDetails(data);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFE8E6E6)),
          ),
          shadows: const [
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["park_area_name"],
                        style: listTitleStyle(),
                      ),
                      Container(height: 10),
                      Text(
                        data["address"],
                        style: subtitleStyle(),
                      ),
                    ],
                  ),
                ),
                CustomTitle(text: data["amount"])
              ],
            ),
            Container(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.time_to_leave_outlined,
                          size: 18,
                          color: AppColor.iconListColor,
                        ),
                        Container(width: 5),
                        Flexible(
                          child: AutoSizeText(
                            "${data["vehicle_plate_no"]}",
                            style: subtitleStyle(
                                fontWeight: FontWeight.w700,
                                color: const Color.fromARGB(255, 53, 51, 51)),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 10),
                Expanded(
                  flex: 3,
                  child: data["is_auto_extend"] == "N"
                      ? SizedBox()
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              LucideIcons.checkCircle,
                              color: Colors.green,
                              size: 15,
                            ),
                            Container(width: 5),
                            AutoSizeText(
                              "Auto Extend Parking",
                              style: subtitleStyle(
                                fontWeight: FontWeight.w700,
                                color: const Color.fromARGB(255, 53, 51, 51),
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                ),
              ],
            ),
            Container(height: 10),
            Divider(),
            Container(height: 10),
            bookingTimeExp == "Expired"
                ? Center(
                    child: CustomParagraph(
                      text: "Expired Parking",
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        color: AppColor.iconListColor,
                        size: 18,
                      ),
                      Container(width: 5),
                      Expanded(
                        child: Text(
                          "Time left",
                          style: subtitleStyle(
                              fontWeight: FontWeight.w700,
                              color: const Color.fromARGB(255, 53, 51, 51)),
                        ),
                      ),
                      CustomParagraph(
                        text: "$bookingTimeExp",
                        color: bookingTimeExp == "Expired"
                            ? Colors.red
                            : AppColor.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
            Container(height: 20),
            Row(
              children: [
                if (data["can_cancelBooking"])
                  Expanded(
                    child: CustomButton(
                      text: "Cancel Booking",
                      btnColor: Colors.white,
                      bordercolor: AppColor.primaryColor,
                      textColor: AppColor.primaryColor,
                      onPressed: () {
                        controller.cancelAdvanceParking(data);
                      },
                    ),
                  ),
                if (data["can_cancelBooking"]) Container(width: 10),
                Expanded(
                  child: CustomButton(
                    text: "View Details",
                    onPressed: () {
                      controller.getParkingDetails(data);
                    },
                  ),
                ),
              ],
            )
          ],
        ),
        //  Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           ListTile(
        //             contentPadding: EdgeInsets.zero,
        //             leading: CircleAvatar(
        //               backgroundColor: currentTab == 0
        //                   ? const Color(0xFFF0E6C3)
        //                   : const Color(0xFFEAF3EA),
        //               child: SvgPicture.asset(
        //                 "assets/dashboard_icon/${currentTab == 0 ? "orange_check" : "green_check"}.svg",
        //                 height: 24,
        //                 width: 24,
        //               ),
        //             ),
        //             title: Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               children: [
        //                 Expanded(
        //                   child: CustomTitle(
        //                     text: title,
        //                     color: AppColor.primaryColor,
        //                     letterSpacing: -0.41,
        //                     maxlines: 1,
        //                     fontSize: 16,
        //                     fontWeight: FontWeight.w700,
        //                   ),
        //                 ),
        //                 if (data["is_auto_extend"] == "Y")
        //                   Align(
        //                     alignment: Alignment.centerRight,
        //                     child: Container(
        //                       padding: EdgeInsets.symmetric(
        //                           horizontal: 8, vertical: 4),
        //                       decoration: BoxDecoration(
        //                         color: const Color.fromARGB(255, 253, 244, 255),
        //                         borderRadius: BorderRadius.circular(7),
        //                       ),
        //                       child: CustomParagraph(
        //                         text: "Auto-extend",
        //                         color: Colors.purple,
        //                         fontWeight: FontWeight.w700,
        //                         fontSize: 12,
        //                         textAlign: TextAlign.center,
        //                       ),
        //                     ),
        //                   ),
        //               ],
        //             ),
        //             subtitle: CustomParagraph(
        //               text: subTitle,
        //               fontSize: 14,
        //               letterSpacing: -0.41,
        //             ),
        //           ),
        //           Row(
        //             children: [
        //               const SizedBox(
        //                 width: 35.50,
        //                 height: 35.50,
        //                 child: Image(
        //                   image:
        //                       AssetImage("assets/dashboard_icon/calendar.png"),
        //                   fit: BoxFit.contain,
        //                 ),
        //               ),
        //               Container(width: 8),
        //               CustomParagraph(
        //                 text: date,
        //                 fontSize: 12,
        //                 fontWeight: FontWeight.w600,
        //                 letterSpacing: -0.41,
        //               ),
        //               Container(width: 15),
        //               Flexible(
        //                 child: Padding(
        //                   padding: const EdgeInsets.only(right: 10),
        //                   child: Row(
        //                     mainAxisAlignment: MainAxisAlignment.end,
        //                     children: [
        //                       const SizedBox(
        //                         width: 35.50,
        //                         height: 35.50,
        //                         child: Image(
        //                           image: AssetImage(
        //                               "assets/dashboard_icon/clock.png"),
        //                           fit: BoxFit.contain,
        //                         ),
        //                       ),
        //                       Container(width: 8),
        //                       Flexible(
        //                         child: CustomParagraph(
        //                           text: time,
        //                           fontSize: 12,
        //                           fontWeight: FontWeight.w600,
        //                           letterSpacing: -0.41,
        //                           maxlines: 1,
        //                         ),
        //                       )
        //                     ],
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ],
        //       ),
        //     ),
        //     Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        //       decoration: const BoxDecoration(
        //           color: Color(0xFF2495eb),
        //           borderRadius:
        //               BorderRadius.vertical(bottom: Radius.circular(10))),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           Row(
        //             children: [
        //               CustomTitle(
        //                 text: "Total Paid:",
        //                 color: Colors.white,
        //                 letterSpacing: -0.41,
        //                 fontSize: 14,
        //                 fontWeight: FontWeight.w700,
        //               ),
        //               Container(
        //                 width: 5,
        //               ),
        //               CustomTitle(
        //                 text: totalAmt,
        //                 color: Colors.white,
        //                 fontWeight: FontWeight.w700,
        //                 letterSpacing: -0.41,
        //                 fontSize: 14,
        //               ),
        //             ],
        //           ),
        //           Icon(
        //             Icons.chevron_right,
        //             color: Colors.white,
        //             size: 30,
        //           ),
        //         ],
        //       ),
        //     )
        //   ],
        // ),
      ),
    );
  }
}
