import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/mapa/controller.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:luvpark_get/sqlite/reserve_notification_table.dart';
import 'package:luvpark_get/web_view/webview.dart';

import '../custom_widgets/variables.dart';

class CustomDrawer extends GetView<DashboardMapController> {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    controller.onDrawerOpen();
    return Drawer(
        child: Obx(
      () => Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/profile_bg.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
            width: double.infinity,
            child: SafeArea(
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(height: 10),
                      const Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: SizedBox(
                          height: 56,
                          width: double.infinity,
                          child: Image(
                            image: AssetImage("assets/images/luvpark.png"),
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 44.5,
                          backgroundColor: Colors.white,
                          backgroundImage: controller.myProfPic.isNotEmpty
                              ? MemoryImage(
                                  base64Decode(controller.myProfPic.value),
                                )
                              : null,
                          child: controller.myProfPic.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 44,
                                  color: Colors.blueAccent,
                                )
                              : null,
                        ),
                      ),
                      Container(height: 10),
                      controller.userProfile != null &&
                              controller.userProfile['first_name'] != null
                          ? CustomTitle(
                              text:
                                  '${controller.userProfile['first_name']} ${controller.userProfile['last_name']}',
                              color: Colors.white,
                              fontSize: 18,
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
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                textAlign: TextAlign.center,
                                letterSpacing: -0.408,
                              ),
                            ),
                      Container(height: 10),
                      OutlinedButton(
                        onPressed: () {
                          Get.toNamed(Routes.profile);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side:
                              const BorderSide(color: Colors.white, width: 1.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(58.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        ),
                        child: const CustomTitle(
                          text: "My Profile and Settings",
                          fontSize: 14,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w700,
                          textAlign: TextAlign.center,
                          letterSpacing: -0.408,
                          color: Colors.white,
                        ),
                      ),
                      Container(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              children: <Widget>[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: CustomTitle(
                    text: "My Account".toUpperCase(),
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    letterSpacing: -0.408,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF616161),
                  ),
                ),
                ListTile(
                  leading:
                      SvgPicture.asset('assets/drawer_icon/drawer_parking.svg'),
                  title: const CustomTitle(
                    text: "My Parking",
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.408,
                    color: Color(0xFF1C1C1E),
                  ),
                  trailing: Icon(Icons.chevron_right_sharp,
                      color: AppColor.primaryColor),
                  onTap: () {
                    Get.toNamed(Routes.parking, arguments: "D");
                  },
                ),
                // ListTile(
                //   leading:
                //       SvgPicture.asset('assets/drawer_icon/drawer_parking.svg'),
                //   title: const CustomTitle(
                //     text: "My Vehicles",
                //     fontSize: 14,
                //     fontStyle: FontStyle.normal,
                //     fontWeight: FontWeight.w700,
                //     letterSpacing: -0.408,
                //     color: Color(0xFF1C1C1E),
                //   ),
                //   trailing: Icon(Icons.chevron_right_sharp,
                //       color: AppColor.primaryColor),
                //   onTap: () {
                //     Get.toNamed(Routes.myVehicles);
                //   },
                // ),
                ListTile(
                  leading:
                      SvgPicture.asset('assets/drawer_icon/drawer_wallet.svg'),
                  title: const CustomTitle(
                    text: "Wallet",
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.408,
                    color: Color(0xFF1C1C1E),
                  ),
                  trailing: Icon(Icons.chevron_right_sharp,
                      color: AppColor.primaryColor),
                  onTap: () {
                    Get.toNamed(Routes.wallet);
                  },
                ),
                Divider(color: Colors.grey[350]),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: CustomTitle(
                    text: "Help and Support".toUpperCase(),
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    letterSpacing: -0.408,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF616161),
                  ),
                ),
                ListTile(
                  leading: SvgPicture.asset(
                      'assets/drawer_icon/drawer_settings.svg'),
                  title: const CustomTitle(
                    text: "About Us",
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.408,
                    color: Color(0xFF1C1C1E),
                  ),
                  trailing: Icon(Icons.chevron_right_sharp,
                      color: AppColor.primaryColor),
                  onTap: () {
                    Get.toNamed(Routes.aboutus);
                  },
                ),
                ListTile(
                  leading:
                      SvgPicture.asset('assets/drawer_icon/drawer_faq.svg'),
                  title: const CustomTitle(
                    text: "FAQs",
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.408,
                    color: Color(0xFF1C1C1E),
                  ),
                  trailing: Icon(Icons.chevron_right_sharp,
                      color: AppColor.primaryColor),
                  onTap: () {
                    Get.toNamed(Routes.faqpage);
                  },
                ),
                ListTile(
                  leading:
                      SvgPicture.asset('assets/drawer_icon/drawer_tou.svg'),
                  title: const CustomTitle(
                    text: "Terms of Use",
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.408,
                    color: Color(0xFF1C1C1E),
                  ),
                  trailing: Icon(Icons.chevron_right_sharp,
                      color: AppColor.primaryColor),
                  onTap: () {
                    Get.to(const WebviewPage(
                      urlDirect: "https://luvpark.ph/terms-of-use/",
                      label: "Terms of Use",
                      isBuyToken: false,
                    ));
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset('assets/drawer_icon/drawer_pp.svg'),
                  title: const CustomTitle(
                    text: "Privacy Policy",
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.408,
                    color: Color(0xFF1C1C1E),
                  ),
                  trailing: Icon(Icons.chevron_right_sharp,
                      color: AppColor.primaryColor),
                  onTap: () {
                    Get.to(const WebviewPage(
                      urlDirect: "https://luvpark.ph/privacy-policy/",
                      label: "Privacy Policy",
                      isBuyToken: false,
                    ));
                  },
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    CustomDialog().customPopUp(
                      context,
                      'Logout?',
                      'Are you sure you want to logout',
                      'Cancel',
                      'Yes, log out',
                      imageName: 'pu_confirmation',
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
                        final userLogin = await Authentication().getUserLogin();
                        List userData = [userLogin];
                        userData = userData.map((e) {
                          e["is_login"] = "N";
                          return e;
                        }).toList();
                        await NotificationDatabase.instance.deleteAll();
                        await Authentication()
                            .setLogin(jsonEncode(userData[0]));

                        Get.back();
                        Get.offAllNamed(Routes.splash);
                      },
                      showTwoButtons: true,
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color(0xFFBD2424).withOpacity(0.12),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(58.0),
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(horizontal: 20.0),
                    ),
                  ),
                  child: const CustomTitle(
                    text: "Log out",
                    fontSize: 14,
                    color: Color(0xFFBD2424),
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.center,
                    letterSpacing: -0.408,
                  ),
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
          Container(height: 20),
        ],
      ),
    ));
  }
}
