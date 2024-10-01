// ignore_for_file: prefer_const_constructors, deprecated_member_use
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/mapa/controller.dart';
import 'package:luvpark_get/routes/routes.dart';

import '../mapa/utils/legend/legend_dialog.dart';

class CustomDrawer extends GetView<DashboardMapController> {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    controller.onDrawerOpen();
    return Drawer(
      child: Obx(
        () => ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(overscroll: false),
          child: Column(
            children: [
              SizedBox(
                height: 70,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Space between elements
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: controller.myProfPic.isNotEmpty
                                    ? MemoryImage(
                                        base64Decode(
                                            controller.myProfPic.value),
                                      )
                                    : null,
                                child: controller.myProfPic.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 32,
                                        color: AppColor.primaryColor,
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Aligns text and button to the left
                              children: [
                                controller.userProfile != null &&
                                        controller.userProfile['first_name'] !=
                                            null
                                    ? CustomTitle(
                                        text:
                                            '${controller.userProfile['first_name']} ${controller.userProfile['last_name']}',
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,
                                        textAlign: TextAlign.center,
                                        letterSpacing: -0.408,
                                      )
                                    : CustomTitle(
                                        text: "NOT VERIFIED",
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,
                                        textAlign: TextAlign.center,
                                        fontSize: 14,
                                        letterSpacing: -0.408,
                                      ),
                                OutlinedButton(
                                  onPressed: () {
                                    Get.toNamed(Routes.profile, arguments: () {
                                      controller.getUserData();
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor:
                                        AppColor.primaryColor.withOpacity(0.1),
                                    side: const BorderSide(
                                        color: Colors.white, width: 1.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(58.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                  ),
                                  child: CustomTitle(
                                    text: "View Profile",
                                    fontSize: 14,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w700,
                                    textAlign: TextAlign.center,
                                    letterSpacing: -0.408,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(),
              Expanded(
                child: StretchingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 15, 15, 0),
                    children: <Widget>[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        minLeadingWidth: 18,
                        leading: Icon(
                          LucideIcons.car,
                          color: Colors.black,
                        ),
                        title: const CustomParagraph(
                          text: "My Parking",
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                        onTap: () {
                          Get.toNamed(Routes.parking, arguments: "D");
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        minLeadingWidth: 18,
                        // leading: Iconify(MaterialSymbols.wallet,
                        //     color: const Color(0xFF000000)),
                        leading: Icon(
                          LucideIcons.walletCards,
                          color: const Color.fromARGB(221, 32, 32, 32),
                        ),
                        title: const CustomParagraph(
                          text: "Wallet",
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),

                        onTap: () async {
                          Get.toNamed(Routes.wallet);
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        minLeadingWidth: 18,
                        leading: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topRight,
                          children: [
                            Icon(
                              LucideIcons.messageSquare,
                              color: const Color.fromARGB(221, 32, 32, 32),
                            ),
                            Visibility(
                              visible: controller.unreadMsg.value != 0,
                              child: Positioned(
                                top: -13,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColor.primaryColor,
                                  ),
                                  child: AutoSizeText(
                                    "${controller.unreadMsg.value}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Manrope",
                                        fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        title: const CustomParagraph(
                          text: "Messages",
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                        onTap: () async {
                          Get.toNamed(Routes.message);
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        minLeadingWidth: 18,
                        leading: Icon(
                          LucideIcons.info,
                          color: Colors.black,
                        ),
                        title: const CustomParagraph(
                          text: "Help & Feedback",
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                        onTap: () {
                          Get.toNamed(Routes.helpfeedback);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black12, // Set the border color
                      width: 1.0, // Set the border width
                    ),
                    borderRadius:
                        BorderRadius.circular(7.0), // Set the border radius
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      minLeadingWidth: 18,
                      leading: SvgPicture.asset(
                        "assets/drawer_icon/learn_more.svg",
                        fit: BoxFit.contain,
                      ),
                      title: const CustomParagraph(
                        text: "Learn More",
                        fontSize: 16,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                      subtitle: CustomParagraph(
                        text: "Parking Icons, Zones etc.",
                        letterSpacing: -0.408,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        Get.back();
                        Get.dialog(LegendDialogScreen(
                          callback: () {
                            controller.dashboardScaffoldKey.currentState
                                ?.openDrawer();
                          },
                        ));
                      },
                    ),
                  ),
                ),
              ),
              Center(
                child: CustomParagraph(
                  text: 'V${Variables.version}',
                  color: const Color(0xFF9C9C9C),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 0,
                ),
              ),
              Container(height: Platform.isIOS ? 25 : 10),
            ],
          ),
        ),
      ),
    );
  }
}
