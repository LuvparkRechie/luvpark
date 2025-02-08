// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';

import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/variables.dart';
import '../wallet_qr/paymerchant/view.dart';
import 'controller.dart';

class WalletRechargeLoadScreen extends GetView<WalletRechargeLoadController> {
  const WalletRechargeLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: AppColor.mainColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Form(
        key: controller.topUpKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10),
                CustomButtonClose(onTap: Get.back),
                Container(height: 20),
                Text(
                  "Top-up Account",
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColor.headerColor,
                  ),
                ),
                Container(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    CustomParagraph(
                      text: "Recipient Number",
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    CustomMobileNumber(
                      hintText: "Recipient Number",
                      controller: controller.mobNum,
                      inputFormatters: [Variables.maskFormatter],
                      onChange: (value) {
                        controller.isActiveBtn.value = true;
                        controller.onSearchChanged(
                            value.replaceAll(" ", ""), false);
                      },
                    ),
                    CustomParagraph(
                      text: "Recipient Name",
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    CustomTextField(
                      isReadOnly: true,
                      controller: controller.rname,
                      hintText: "Recipient Name",
                      filledColor: Colors.grey.shade200,
                      isFilled: true,
                    ),
                    CustomParagraph(
                      text: "Amount",
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    CustomTextField(
                      hintText: "Enter amount",
                      controller: controller.amountController,
                      inputFormatters: [
                        AutoDecimalInputFormatter(),
                      ],
                      keyboardType: Platform.isAndroid
                          ? TextInputType.number
                          : const TextInputType.numberWithOptions(
                              signed: true, decimal: false),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Amount is required";
                        }
                        if (double.parse(value.toString()) < 10) {
                          return "Minimum of 10 tokens";
                        }

                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                if (MediaQuery.of(context).viewInsets.bottom ==
                    0) //hide custombutton
                  Obx(() => CustomButton(
                        text: "Continue",
                        btnColor: !controller.isActiveBtn.value
                            ? AppColor.primaryColor.withOpacity(.7)
                            : AppColor.primaryColor,
                        onPressed: !controller.isActiveBtn.value
                            ? () {}
                            : () {
                                controller.onPay();
                              },
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
