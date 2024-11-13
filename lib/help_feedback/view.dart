import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
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
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: StretchingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        child: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(overscroll: false),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Color(0xFF0078FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(43),
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
                      child: Icon(
                        LucideIcons.arrowLeft,
                        color: Colors.white,
                        size: 16,
                      )),
                ),
              ),
              Container(height: 20),
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
                      onTap: () {
                        Get.toNamed(Routes.aboutus);
                      },
                    ),
                    const Divider(),
                    ListTile(
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
                        text: "Know the conditions for using our application.",
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
    );
  }
}
