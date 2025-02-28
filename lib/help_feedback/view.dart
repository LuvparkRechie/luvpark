import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:luvpark/web_view/webview.dart';

import 'controller.dart';

class HelpandFeedback extends GetView<HelpandFeedbackController> {
  const HelpandFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("Help & Feedback"),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: StretchingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 20),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primaryColor.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Icon(
                              LucideIcons.info,
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
                          text: "Help and Feedback",
                          fontStyle: FontStyle.normal,
                          color: Color(0xFF1C1C1E),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(height: 30),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            LucideIcons.bookmark,
                            color: AppColor.primaryColor,
                            size: 20,
                          ),
                        ),
                        title: const CustomTitle(
                          text: "About Us",
                          fontSize: 14,
                          fontStyle: FontStyle.normal,
                        ),
                        subtitle: const CustomParagraph(
                          text:
                              "Know the meaning and purpose of the application.",
                          fontSize: 12,
                        ),
                        trailing: const Icon(Icons.chevron_right_sharp,
                            color: Color(0xFF1C1C1E)),
                        onTap: () async {
                          CustomDialog().loadingDialog(context);
                          final response =
                              await HttpRequest(api: "").linkToPage();
                          Get.back();
                          if (response == "Success") {
                            Get.to(const WebviewPage(
                              urlDirect: "https://luvpark.ph/about-us/",
                              label: "About Us",
                              isBuyToken: false,
                            ));
                          } else {
                            CustomDialog().internetErrorDialog(context, () {
                              Get.back();
                            });
                          }
                        },
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            LucideIcons.fileQuestion,
                            color: AppColor.primaryColor,
                            size: 20,
                          ),
                        ),
                        title: const CustomTitle(
                          text: "FAQs",
                          fontSize: 14,
                          fontStyle: FontStyle.normal,
                        ),
                        subtitle: const CustomParagraph(
                          text:
                              "Your guide to common questions and quick solutions.",
                          fontSize: 12,
                        ),
                        trailing: const Icon(Icons.chevron_right_sharp,
                            color: Color(0xFF1C1C1E)),
                        onTap: () {
                          Get.toNamed(Routes.faqpage);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            LucideIcons.fileCheck,
                            color: AppColor.primaryColor,
                            size: 20,
                          ),
                        ),
                        title: const CustomTitle(
                          text: "Terms of Use",
                          fontSize: 14,
                          fontStyle: FontStyle.normal,
                        ),
                        subtitle: const CustomParagraph(
                          text:
                              "Know the conditions for using our application.",
                          fontSize: 12,
                        ),
                        trailing: const Icon(Icons.chevron_right_sharp,
                            color: Color(0xFF1C1C1E)),
                        onTap: () async {
                          CustomDialog().loadingDialog(context);
                          final response =
                              await HttpRequest(api: "").linkToPage();
                          Get.back();
                          if (response == "Success") {
                            Get.to(const WebviewPage(
                              urlDirect: "https://luvpark.ph/terms-of-use/",
                              label: "Terms of Use",
                              isBuyToken: false,
                            ));
                          } else {
                            CustomDialog().internetErrorDialog(context, () {
                              Get.back();
                            });
                          }
                        },
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primaryColor.withOpacity(0.1),
                          ),
                          child: Icon(
                            LucideIcons.fileKey,
                            color: AppColor.primaryColor,
                            size: 20,
                          ),
                        ),
                        title: const CustomTitle(
                          text: "Privacy Policy",
                          fontSize: 14,
                          fontStyle: FontStyle.normal,
                        ),
                        subtitle: const CustomParagraph(
                          text:
                              "Understand how we handle your personal information.",
                          fontSize: 12,
                        ),
                        trailing: const Icon(Icons.chevron_right_sharp,
                            color: Color(0xFF1C1C1E)),
                        onTap: () async {
                          CustomDialog().loadingDialog(context);
                          final response =
                              await HttpRequest(api: "").linkToPage();
                          Get.back();
                          if (response == "Success") {
                            Get.to(const WebviewPage(
                              urlDirect: "https://luvpark.ph/privacy-policy/",
                              label: "Privacy Policy",
                              isBuyToken: false,
                            ));
                          } else {
                            CustomDialog().internetErrorDialog(context, () {
                              Get.back();
                            });
                          }
                        },
                      ),
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
