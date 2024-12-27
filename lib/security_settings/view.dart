import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:luvpark/security_settings/index.dart';

class Security extends GetView<SecuritySettingsController> {
  const Security({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SecuritySettingsController());
    return Scaffold(
        backgroundColor: AppColor.bodyColor,
        appBar: const CustomAppbar(title: ""),
        body: Obx(
          () => controller.isLoading.value
              ? const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  ),
                )
              : StretchingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(overscroll: false),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        AppColor.primaryColor.withOpacity(0.1),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Iconsax.shield_tick,
                                      color: AppColor.primaryColor,
                                      size: 55,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 10,
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomTitle(
                                  text: "Security Settings",
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.408,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ],
                            ),
                            Container(height: 20),
                          ],
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const CustomTitle(
                                  text: "Change Password",
                                  fontSize: 14,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.408,
                                ),
                                subtitle: const CustomParagraph(
                                  text:
                                      "Update your current password to ensure your account remains secure.",
                                  letterSpacing: -0.408,
                                  fontSize: 12,
                                ),
                                trailing: const Icon(Icons.chevron_right_sharp,
                                    color: Color(0xFF1C1C1E)),
                                onTap: () {
                                  Get.toNamed(Routes.changepassword);
                                },
                              ),
                              Visibility(
                                visible: controller.isBiometricSupported.value,
                                child: Column(
                                  children: [
                                    Divider(color: Colors.grey.shade500),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: const CustomTitle(
                                        text: "Biometric Authentication",
                                        fontSize: 14,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.408,
                                      ),
                                      subtitle: const CustomParagraph(
                                        text:
                                            "Use your device's biometric for a quick and secure login.",
                                        letterSpacing: -0.408,
                                        fontSize: 12,
                                      ),
                                      trailing: GestureDetector(
                                        onTap: () {
                                          controller
                                              .toggleBiometricAuthentication(
                                                  !controller.isToggle.value);
                                        },
                                        child: Container(
                                          width: 50,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            gradient: LinearGradient(
                                              colors: controller.isToggle.value
                                                  ? [
                                                      Colors.green,
                                                      Colors.lightGreen
                                                    ]
                                                  : [Colors.grey, Colors.grey],
                                            ),
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              if (controller.isToggle.value)
                                                Positioned(
                                                  left: 10,
                                                  child: Icon(
                                                    LucideIcons.check,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              if (!controller.isToggle.value)
                                                Positioned(
                                                  right: 10,
                                                  child: Icon(
                                                    Icons.clear,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              AnimatedPositioned(
                                                duration: Duration(
                                                  milliseconds: 200,
                                                ),
                                                left: controller.isToggle.value
                                                    ? 30
                                                    : 5,
                                                child: Container(
                                                  width: 15,
                                                  height: 15,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black26,
                                                        blurRadius: 2.0,
                                                        spreadRadius: 1.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(color: Colors.grey.shade500),
                              // ListTile(
                              //   contentPadding: EdgeInsets.zero,
                              //   title: const CustomTitle(
                              //     text: "Foreground Process",
                              //     fontSize: 14,
                              //     fontStyle: FontStyle.normal,
                              //     fontWeight: FontWeight.w700,
                              //     letterSpacing: -0.408,
                              //   ),
                              //   subtitle: const CustomParagraph(
                              //     text:
                              //         "Actively running and interacting with the user in the app's main interface.",
                              //     letterSpacing: -0.408,
                              //     fontSize: 12,
                              //   ),
                              //   trailing: GestureDetector(
                              //     onTap: () {
                              //       controller.toggleBiometricAuthentication(
                              //           !controller.isToggle.value);
                              //     },
                              //     child: Container(
                              //       width: 50,
                              //       height: 25,
                              //       decoration: BoxDecoration(
                              //         borderRadius: BorderRadius.circular(30),
                              //         gradient: LinearGradient(
                              //           colors: controller.isToggle.value
                              //               ? [Colors.green, Colors.lightGreen]
                              //               : [Colors.grey, Colors.grey],
                              //         ),
                              //       ),
                              //       child: Stack(
                              //         alignment: Alignment.center,
                              //         children: [
                              //           if (controller.isToggle.value)
                              //             Positioned(
                              //               left: 10,
                              //               child: Icon(
                              //                 LucideIcons.check,
                              //                 color: Colors.white,
                              //                 size: 12,
                              //               ),
                              //             ),
                              //           if (!controller.isToggle.value)
                              //             Positioned(
                              //               right: 10,
                              //               child: Icon(
                              //                 Icons.clear,
                              //                 color: Colors.white,
                              //                 size: 12,
                              //               ),
                              //             ),
                              //           AnimatedPositioned(
                              //             duration: Duration(
                              //               milliseconds: 200,
                              //             ),
                              //             left: controller.isToggle.value
                              //                 ? 30
                              //                 : 5,
                              //             child: Container(
                              //               width: 15,
                              //               height: 15,
                              //               decoration: BoxDecoration(
                              //                 color: Colors.white,
                              //                 borderRadius:
                              //                     BorderRadius.circular(30),
                              //                 boxShadow: [
                              //                   BoxShadow(
                              //                     color: Colors.black26,
                              //                     blurRadius: 2.0,
                              //                     spreadRadius: 1.0,
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // Divider(color: Colors.grey.shade500),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey.shade500),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withOpacity(0.1),
                              ),
                              child: const Icon(
                                Iconsax.profile_delete,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                            title: const CustomTitle(
                              text: "Delete Your Account",
                              fontSize: 14,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.408,
                            ),
                            subtitle: const CustomParagraph(
                              text:
                                  "Permanently remove your account. All associated data will be erased.",
                              letterSpacing: -0.408,
                              fontSize: 12,
                            ),
                            trailing: const Icon(Icons.chevron_right_sharp,
                                color: Color(0xFF1C1C1E)),
                            onTap: () {
                              controller.deleteAccount();
                            },
                          ),
                        ),
                        Container(height: 20),
                      ],
                    ),
                  ),
                ),
        ));
  }
}
