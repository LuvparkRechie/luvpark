// ignore_for_file: prefer_const_constructors, deprecated_member_use
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/mapa/controller.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/authentication.dart';
import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/app_color.dart';
import '../custom_widgets/variables.dart';
import '../sqlite/reserve_notification_table.dart';

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
              SizedBox(height: 70),
              Align(
                alignment: Alignment.centerLeft,
                child: Image(
                  height: 58,
                  image: AssetImage("assets/images/luvpark.png"),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StretchingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 15, 15, 0),
                    children: <Widget>[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        minLeadingWidth: 18,
                        leading: Iconify(
                          MaterialSymbols.directions_car_outline_rounded,
                          color: const Color.fromARGB(221, 32, 32, 32),
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

                        onTap: () {
                          Get.toNamed(Routes.wallet);
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        minLeadingWidth: 18,
                        // leading: Iconify(MaterialSymbols.android_messages,
                        //     color: const Color(0xFF000000)),
                        leading: Icon(
                          LucideIcons.messageSquare,
                          color: const Color.fromARGB(221, 32, 32, 32),
                        ),
                        title: const CustomParagraph(
                          text: "Messages",
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),

                        onTap: () {
                          Get.toNamed(Routes.message);
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        minLeadingWidth: 18,
                        leading: Iconify(MaterialSymbols.info_outline,
                            color: const Color.fromARGB(221, 32, 32, 32)),
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        leading:
                            Iconify(MaterialSymbols.logout, color: Colors.red),
                        title: CustomTitle(
                          text: "Logout",
                          fontSize: 17,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.408,
                          color: Colors.red,
                        ),
                        onTap: () {
                          CustomDialog().customPopUp(
                            context,
                            'Logout?',
                            'Are you sure you want to logout',
                            'Cancel',
                            'Yes, log out',
                            imageName: 'pu_info',
                            btnNotBackgroundColor: Colors.transparent,
                            btnNotTextColor: AppColor.primaryColor,
                            btnOkTextColor: Colors.white,
                            btnOkBackgroundColor: AppColor.primaryColor,
                            onTapClose: () async {
                              Get.back();
                            },
                            onTapConfirm: () async {
                              Get.back();
                              CustomDialog().loadingDialog(context);
                              await Future.delayed(const Duration(seconds: 3));
                              final userLogin =
                                  await Authentication().getUserLogin();
                              List userData = [userLogin];
                              userData = userData.map((e) {
                                e["is_login"] = "N";
                                return e;
                              }).toList();
                              await NotificationDatabase.instance.deleteAll();
                              await Authentication()
                                  .setLogin(jsonEncode(userData[0]));
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.remove("last_booking");
                              Authentication().setLogoutStatus(true);
                              AwesomeNotifications().dismissAllNotifications();
                              AwesomeNotifications().cancelAll();

                              Get.back();
                              Get.offAllNamed(Routes.splash);
                            },
                            showTwoButtons: true,
                          );
                        },
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
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
                                backgroundColor: Colors.white,
                                backgroundImage: controller.myProfPic.isNotEmpty
                                    ? MemoryImage(
                                        base64Decode(
                                            controller.myProfPic.value),
                                      )
                                    : null,
                                child: controller.myProfPic.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 15,
                                        color: Colors.blueAccent,
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Column(
                              children: [
                                controller.userProfile != null &&
                                        controller.userProfile['first_name'] !=
                                            null
                                    ? CustomTitle(
                                        text:
                                            '${controller.userProfile['first_name']} ${controller.userProfile['last_name']}',
                                        color: Color(0xFF1C1C1E),
                                        fontSize: 15,
                                        fontStyle: FontStyle.normal,
                                        textAlign: TextAlign.center,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.408,
                                      )
                                    : Container(
                                        color: Colors.transparent,
                                        width: double.infinity,
                                        child: const CustomTitle(
                                          text: "Not Verified",
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal,
                                          textAlign: TextAlign.center,
                                          letterSpacing: -0.408,
                                        ),
                                      ),
                                OutlinedButton(
                                  onPressed: () {
                                    Get.toNamed(Routes.profile, arguments: () {
                                      controller.getUserData();
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Color(0xFFebebeb),
                                    side: const BorderSide(
                                        color: Colors.white, width: 1.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(58.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                  ),
                                  child: const CustomTitle(
                                    text: "View Profile",
                                    fontSize: 14,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w700,
                                    textAlign: TextAlign.center,
                                    letterSpacing: -0.408,
                                    color: Color(0xFF1C1C1E),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Center(
                        child: CustomParagraph(
                          text: 'V${Variables.version}',
                          color: const Color(0xFF9C9C9C),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 0,
                        ),
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
}
