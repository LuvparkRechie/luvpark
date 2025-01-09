// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/routes/routes.dart';

import '../custom_widgets/app_color.dart';
import '../wallet_qr/controller.dart';

class QrWallet extends GetView<QrWalletController> {
  const QrWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Send",
        onTap: () {
          Get.back();
        },
      ),
      backgroundColor: AppColor.bodyColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  CustomParagraph(
                      text: "Pay using QR",
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 16),
                ],
              ),
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
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.qr_code_rounded,
                        color: AppColor.primaryColor,
                        size: 24,
                      ),
                    ),
                    title: const CustomTitle(
                      text: "QR Pay",
                      fontSize: 14,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.408,
                    ),
                    subtitle: const CustomParagraph(
                      text:
                          "Enable QR Pay for fast and secure payment transactions directly from your account.",
                      letterSpacing: -0.408,
                      fontSize: 12,
                    ),
                    trailing: const Icon(Icons.chevron_right_sharp,
                        color: Color(0xFF1C1C1E)),
                    onTap: () {
                      Get.toNamed(Routes.paywithQR);
                    },
                  ),
                  Divider(color: Colors.grey.shade500),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                    child: Row(
                      children: [
                        Flexible(
                          child: CustomParagraph(
                              text:
                                  "Scan and Pay through our partnered Merchants",
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColor.primaryColor,
                        size: 24,
                      ),
                    ),
                    title: const CustomTitle(
                      text: "Scan Merchant Code",
                      fontSize: 14,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.408,
                    ),
                    subtitle: const CustomParagraph(
                      text:
                          "Scan with our merchant's QR code for fast and secure payment transactions directly from your account.",
                      letterSpacing: -0.408,
                      fontSize: 12,
                    ),
                    trailing: const Icon(Icons.chevron_right_sharp,
                        color: Color(0xFF1C1C1E)),
                    onTap: () async {
                      FocusManager.instance.primaryFocus!.unfocus();
                      controller.requestCameraPermission();
                    },
                  ),
                  Divider(color: Colors.grey.shade500),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                    child: Row(
                      children: [
                        Flexible(
                          child: CustomParagraph(
                              text: "Receive money through QR",
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Iconsax.scan,
                        color: AppColor.primaryColor,
                        size: 24,
                      ),
                    ),
                    title: const CustomTitle(
                      text: "QR Receive",
                      fontSize: 14,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.408,
                    ),
                    subtitle: const CustomParagraph(
                      text:
                          "Receive money quickly and securely by sharing your QR Code with other luvpark accounts",
                      letterSpacing: -0.408,
                      fontSize: 12,
                    ),
                    trailing: const Icon(Icons.chevron_right_sharp,
                        color: Color(0xFF1C1C1E)),
                    onTap: () {
                      Get.toNamed(Routes.myQR);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
