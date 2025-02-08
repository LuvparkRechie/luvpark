// ignore_for_file: prefer_const_constructors, deprecated_member_use
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/mapa/controller.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/variables.dart';
import '../mapa/utils/legend/legend_dialog.dart';
import '../sqlite/reserve_notification_table.dart';

class CustomDrawer extends GetView<DashboardMapController> {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    controller.onDrawerOpen();
    return Drawer(
      backgroundColor: AppColor.primaryColor,
      child: SafeArea(
        child: Obx(
          () => ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: Column(
              children: [
                Container(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
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
                                  base64Decode(controller.myProfPic.value),
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
                      Expanded(
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              controller.userProfile != null &&
                                      controller.userProfile['first_name'] !=
                                          null
                                  ? CustomParagraph(
                                      text: controller.userProfile['last_name']
                                                      .length >
                                                  15 ||
                                              controller
                                                      .userProfile['first_name']
                                                      .length >
                                                  15
                                          ? '${controller.userProfile['first_name'].split(" ")[0]}'
                                          : '${controller.userProfile['first_name']} ${controller.userProfile['last_name']}',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.normal,
                                      textAlign: TextAlign.center,
                                      fontSize: 16,
                                      maxlines: 1,
                                      minFontSize: 8,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : CustomTitle(
                                      text: "Not Verified",
                                      color: Colors.white,
                                    ),
                              OutlinedButton(
                                onPressed: () {
                                  Get.toNamed(Routes.myaccount, arguments: () {
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
                                child: CustomParagraph(
                                  text: "View Profile",
                                  fontSize: 14,
                                  fontStyle: FontStyle.normal,
                                  textAlign: TextAlign.center,
                                  color: AppColor.bodyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: StretchingOverscrollIndicator(
                      axisDirection: AxisDirection.down,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 15, 15, 0),
                        children: <Widget>[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            minLeadingWidth: 18,
                            leading: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.topRight,
                              children: [
                                Icon(
                                  LucideIcons.messageSquare,
                                  color: AppColor.primaryColor,
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
                                            fontFamily: "openSans",
                                            fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            title: CustomParagraph(
                              text: "Messages",
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w600,
                              color: AppColor.headerColor,
                            ),
                            trailing: Icon(
                              LucideIcons.chevronRight,
                              color: Colors.black38,
                              size: 18,
                            ),
                            onTap: () async {
                              Get.toNamed(Routes.message);
                            },
                          ),
                          ...controller.menuIcons.map((e) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              minLeadingWidth: 18,
                              leading: Icon(
                                e["icon"],
                                color: AppColor.primaryColor,
                              ),
                              title: CustomParagraph(
                                text: e["label"],
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w600,
                                color: AppColor.headerColor,
                              ),
                              trailing: Icon(
                                LucideIcons.chevronRight,
                                color: Colors.black38,
                                size: 18,
                              ),
                              onTap: () {
                                print("e $e");
                                controller.onMenuIconsTap(e["index"]);
                              },
                            );
                          }).toList(),
                          Container(height: 20),
                          Divider(
                            color: Colors.black45,
                          ),
                          Container(height: 30),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.helpfeedback);
                            },
                            child: CustomParagraph(
                              text: "Help & Feedback",
                              color: Colors.black,
                            ),
                          ),
                          Container(height: 10),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.security);
                            },
                            child: CustomParagraph(
                              text: "Security Settings",
                              color: Colors.black,
                            ),
                          ),
                          Container(height: 10),
                          GestureDetector(
                            onTap: () {
                              CustomDialog().confirmationDialog(
                                  context,
                                  "Logout",
                                  "Are you sure you want to logout?",
                                  "No",
                                  "Yes", () {
                                Get.back();
                              }, () async {
                                Get.back();
                                CustomDialog().loadingDialog(context);
                                await Future.delayed(
                                    const Duration(seconds: 3));
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
                                AwesomeNotifications()
                                    .dismissAllNotifications();
                                AwesomeNotifications().cancelAll();

                                Get.back();
                                Get.offAllNamed(Routes.login);
                              });
                            },
                            child: CustomParagraph(
                              text: "Logout",
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.primaryColor,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(
                              7.0), // Set the border radius
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
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                            subtitle: CustomParagraph(
                              text: "Parking Icons, Zones etc.",
                              maxlines: 1,
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
                      Container(height: 10),
                      Center(
                        child: CustomParagraph(
                          text: 'V${Variables.version}',
                          color: Colors.black54,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 0,
                        ),
                      ),
                      Container(height: Platform.isIOS ? 25 : 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
