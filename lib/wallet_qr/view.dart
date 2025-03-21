// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../custom_widgets/app_color.dart';
import '../wallet_qr/controller.dart';

class QrWallet extends GetView<QrWalletController> {
  const QrWallet({super.key});

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
        title: Text("QR Code"),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 15),
            for (int i = 0; i < controller.optionData.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: CustomParagraph(
                      text: controller.optionData[i]["label"],
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  Container(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: () {
                        controller.onOptionTap(i);
                      },
                      child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 3,
                                  offset: Offset(0, 0),
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7)),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.primaryColor.withOpacity(0.1),
                                ),
                                child: Icon(
                                  controller.optionData[i]["icon"],
                                  color: AppColor.primaryColor,
                                  size: 24,
                                ),
                              ),
                              Container(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTitle(
                                      text: controller.optionData[i]["title"],
                                      fontSize: 14,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    Container(height: 5),
                                    CustomParagraph(
                                      text: controller.optionData[i]
                                          ["subtitle"],
                                      fontSize: 12,
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: 10,
                              ),
                              const Icon(Icons.chevron_right_sharp,
                                  color: Color(0xFF1C1C1E))
                            ],
                          )),
                    ),
                  ),
                  Container(height: 15),
                ],
              )
          ],
        ),
      ),
    );
  }
}
