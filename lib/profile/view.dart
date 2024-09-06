import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/page_loader.dart';
import 'package:luvpark_get/profile/controller.dart';
import 'package:luvpark_get/routes/routes.dart';

import '../custom_widgets/custom_text.dart';

class Profile extends GetView<ProfileScreenController> {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          toolbarHeight: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: controller.isLoading.value
            ? const PageLoader()
            : Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      fit: StackFit.loose,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage("assets/images/profile_bg.png"),
                            ),
                          ),
                          child: SafeArea(
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.chevron_left,
                                            color: Colors.white,
                                          ),
                                          CustomParagraph(
                                            text: "Back",
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: CustomTitle(
                                            text: "My Account",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.bodyColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: CircleAvatar(
                                radius: 44.5,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    controller.myprofile.value.isNotEmpty
                                        ? MemoryImage(
                                            base64Decode(
                                                controller.myprofile.value),
                                          )
                                        : null,
                                child: controller.myprofile.value.isEmpty
                                    ? const Icon(Icons.person,
                                        size: 44, color: Colors.blueAccent)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 40),
                  Column(
                    children: [
                      controller.userData[0]['first_name'] != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomTitle(
                                  text:
                                      '${controller.userData[0]['first_name']} ${controller.userData[0]['last_name']}',
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontStyle: FontStyle.normal,
                                  textAlign: TextAlign.center,
                                ),
                                Container(width: 5),
                                Icon(
                                  Icons.verified,
                                  color: AppColor.primaryColor,
                                )
                              ],
                            )
                          : const Center(
                              child: CustomTitle(
                                text: "Not Verified",
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                textAlign: TextAlign.center,
                              ),
                            ),
                      Center(
                        child: CustomParagraph(
                          text: "+${controller.userData[0]['mobile_no']}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(height: 10),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 15, 20),
                        child: Container(
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 1, color: Color(0x26616161)),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(
                                    Iconsax.personalcard,
                                    color: AppColor.primaryColor,
                                  ),
                                  title: const CustomTitle(
                                    text: "My Account",
                                    fontSize: 14,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.408,
                                    color: Color(0xFF1C1C1E),
                                  ),
                                  trailing: Icon(Icons.chevron_right_sharp,
                                      color: AppColor.primaryColor),
                                  onTap: () {
                                    Get.toNamed(Routes.myaccount);
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  leading: Icon(
                                    Iconsax.car,
                                    color: AppColor.primaryColor,
                                  ),
                                  title: const CustomTitle(
                                    text: "My Vehicles",
                                    fontSize: 14,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.408,
                                    color: Color(0xFF1C1C1E),
                                  ),
                                  trailing: Icon(Icons.chevron_right_sharp,
                                      color: AppColor.primaryColor),
                                  onTap: () {
                                    Get.toNamed(Routes.myVehicles);
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  leading: Icon(
                                    Iconsax.setting_2,
                                    color: AppColor.primaryColor,
                                  ),
                                  title: const CustomTitle(
                                    text: "Security Settings",
                                    fontSize: 14,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.408,
                                    color: Color(0xFF1C1C1E),
                                  ),
                                  trailing: Icon(Icons.chevron_right_sharp,
                                      color: AppColor.primaryColor),
                                  onTap: () {
                                    Get.toNamed(Routes.security);
                                  },
                                ),
                                // Add more ListTiles here if needed
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
