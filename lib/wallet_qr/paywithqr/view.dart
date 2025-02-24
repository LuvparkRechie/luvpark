import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'controller.dart';

class paywithQR extends GetView<paywithQRController> {
  const paywithQR({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      backgroundColor: AppColor.bodyColor,
      body: Obx(
        () => !controller.isInternetConn.value
            ? NoInternetConnected(onTap: controller.getQrData)
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 20),
                    CustomButtonClose(onTap: () {
                      Get.back();
                    }),
                    Container(height: 20),
                    Center(
                      child: CustomTitle(
                        text: "Scan to Pay",
                        fontSize: 20,
                      ),
                    ),
                    Container(height: 10),
                    Center(
                      child: CustomParagraph(
                        text:
                            "Align the QR code within the frame to proceed with payment.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(height: 20),
                    Container(
                      margin: const EdgeInsets.all(40),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: PrettyQrView(
                        decoration: const PrettyQrDecoration(
                          background: Colors.white,
                          image: PrettyQrDecorationImage(
                            image: AssetImage("assets/images/logo.png"),
                          ),
                        ),
                        qrImage: QrImage(
                          QrCode.fromData(
                            data: controller.payKey.value,
                            errorCorrectLevel: QrErrorCorrectLevel.H,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton.icon(
                          onPressed: controller.generateQr,
                          icon: Icon(
                            Icons.refresh,
                            color: AppColor.primaryColor,
                          ),
                          label: CustomParagraph(text: "Generate QR")),
                    ),
                    Container(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: controller.saveQr,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.download,
                                color: AppColor.primaryColor,
                              ),
                              Container(height: 10),
                              CustomParagraph(text: "Download")
                            ],
                          ),
                        ),
                        Container(width: 60),
                        GestureDetector(
                          onTap: controller.shareQr,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.share,
                                color: AppColor.primaryColor,
                              ),
                              Container(height: 10),
                              CustomParagraph(text: "Share")
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
