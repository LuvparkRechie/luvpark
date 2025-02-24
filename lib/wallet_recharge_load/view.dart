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
        body: Obx(
          () => Form(
            key: controller.topUpKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 10),
                    CustomButtonClose(onTap: () async {
                      FocusManager.instance.primaryFocus!.unfocus();
                      await Future.delayed(Duration(milliseconds: 200));
                      Get.back();
                    }),
                    Container(height: 20),
                    Text(
                      "Buy Load",
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
                          onChange: (d) {
                            controller.onTextChange();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Amount is required";
                            }
                            if (double.parse(value.toString()) <
                                controller.dataList[0]["value"]) {
                              return "Minimum of ${controller.dataList[0]["value"]} tokens";
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    for (int i = 0; i < controller.padData.length; i += 3)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int j = i;
                              j < i + 3 && j < controller.padData.length;
                              j++)
                            myPads(controller.padData[j], j)
                        ],
                      ),
                    const SizedBox(
                      height: 30,
                    ),
                    if (MediaQuery.of(context).viewInsets.bottom ==
                        0) //hide custombutton

                      CustomButton(
                        text: "Continue",
                        btnColor: !controller.isActiveBtn.value
                            ? AppColor.primaryColor.withOpacity(.7)
                            : AppColor.primaryColor,
                        onPressed: !controller.isActiveBtn.value
                            ? () {}
                            : () {
                                controller.onPay();
                              },
                      )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget myPads(data, int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: InkWell(
          onTap: () {
            controller.pads(data["value"]);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              color: data["is_active"] ? AppColor.primaryColor : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomParagraph(
                  maxlines: 1,
                  minFontSize: 8,
                  text: "${data["value"]}",
                  fontWeight: FontWeight.w700,
                  color: data["is_active"] ? Colors.white : Colors.black,
                ),
                CustomParagraph(
                  text: "Token",
                  maxlines: 1,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: data["is_active"] ? Colors.white : null,
                  minFontSize: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
