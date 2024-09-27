import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:luvpark_get/web_view/webview.dart';

import 'controller.dart';

class HelpandFeedback extends GetView<HelpandFeedbackController> {
  const HelpandFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: const CustomAppbar(title: ""),
      body: StretchingOverscrollIndicator(
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
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.408,
                      ),
                      subtitle: const CustomParagraph(
                        text:
                            "Know the meaning and purpose of the application.",
                        letterSpacing: -0.408,
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
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.408,
                      ),
                      subtitle: const CustomParagraph(
                        text:
                            "Your guide to common questions and quick solutions.",
                        letterSpacing: -0.408,
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
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.408,
                      ),
                      subtitle: const CustomParagraph(
                        text: "Know the conditions for using our application.",
                        letterSpacing: -0.408,
                        fontSize: 12,
                      ),
                      trailing: const Icon(Icons.chevron_right_sharp,
                          color: Color(0xFF1C1C1E)),
                      onTap: () {
                        Get.to(const WebviewPage(
                          urlDirect: "https://luvpark.ph/terms-of-use/",
                          label: "Terms of Use",
                          isBuyToken: false,
                        ));
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
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.408,
                      ),
                      subtitle: const CustomParagraph(
                        text:
                            "Understand how we handle your personal information.",
                        letterSpacing: -0.408,
                        fontSize: 12,
                      ),
                      trailing: const Icon(Icons.chevron_right_sharp,
                          color: Color(0xFF1C1C1E)),
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
            ],
          ),
        ),
      ),
    );
  }
}
