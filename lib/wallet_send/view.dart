// ignore_for_file: prefer_const_constructors, unrelated_type_equality_checks

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/custom_textfield.dart';
import 'package:luvpark_get/wallet_send/index.dart';

import '../custom_widgets/app_color.dart';
import '../custom_widgets/variables.dart';

class WalletSend extends GetView<WalletSendController> {
  const WalletSend({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Send",
        onTap: () {
          Get.back();
          controller.parameter();
        },
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Form(
          key: controller.formKeySend,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 15,
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  7,
                                ),
                              ),
                              child: Icon(
                                Icons.wallet_rounded,
                                color: AppColor.primaryColor,
                              ),
                            ),
                            Container(
                              width: 10,
                            ),
                            const CustomParagraph(
                              text: "Available Balance",
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              fontSize: 12,
                              textAlign: TextAlign.center,
                            ),
                            Expanded(
                              child: CustomParagraph(
                                text: !controller.isNetConn.value
                                    ? "No internet"
                                    : controller.userData.isEmpty
                                        ? ""
                                        : toCurrencyString(controller
                                            .userData[0]["amount_bal"]),
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    CustomMobileNumber(
                      onChange: (text) {
                        controller.onTextChange();
                      },
                      controller: controller.recipient,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$')),
                      ],
                      keyboardType: Platform.isAndroid
                          ? TextInputType.number
                          : const TextInputType.numberWithOptions(
                              signed: true, decimal: false),
                      labelText: "Recipient's Mobile Number",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Field is required';
                        }
                        if (value.toString().replaceAll(" ", "").length <
                            10) {
                          return 'Invalid mobile number';
                        }
                        if (value.toString().replaceAll(" ", "")[0] ==
                            '0') {
                          return 'Invalid mobile number';
                        }
        
                        return null;
                      },
                    ),
                    CustomTextField(
                      labelText: "Amount",
                      controller: controller.tokenAmount,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$')),
                      ],
                      keyboardType: Platform.isAndroid
                          ? TextInputType.number
                          : const TextInputType.numberWithOptions(
                              signed: true, decimal: false),
                      onChange: (text) {
                        controller.onTextChange();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Amount is required";
                        }
        
                        double parsedValue;
                        try {
                          parsedValue = double.parse(value);
                        } catch (e) {
                          return "Invalid amount";
                        }
        
                        double availableBalance;
                        try {
                          availableBalance = double.parse(controller
                              .userData[0]["amount_bal"]
                              .toString());
                        } catch (e) {
                          return "Error retrieving balance";
                        }
                        if (parsedValue < 10) {
                          return "Amount must not be less than 10";
                        }
                        if (parsedValue > availableBalance) {
                          return "You don't have enough balance to proceed";
                        }
        
                        return null;
                      },
                    ),
                    CustomTextField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                          90,
                        ),
                      ],
                      labelText: "Note",
                      controller: controller.message,
                    ),
                    for (int i = 0;
                        i < controller.padNumbers.length;
                        i += 4)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int j = i;
                              j < i + 4 && j < controller.padNumbers.length;
                              j++)
                            myPads((controller.padNumbers[j]), j),
                        ],
                      ),
                    SizedBox(
                      height: 30,
                    ),
                    if (MediaQuery.of(context).viewInsets.bottom ==
                        0) //hide button
                      CustomButton(
                          text: "Continue",
                          btnColor: AppColor.primaryColor,
                          onPressed: () async {
                            // controller.
                            if (controller.formKeySend.currentState!
                                .validate()) {
                              final item =
                                  await Authentication().getUserLogin();
        
                              if (item["mobile_no"].toString() ==
                                  "63${controller.recipient.text.replaceAll(" ", "")}") {
                                CustomDialog().snackbarDialog(
                                    context,
                                    "Please use another number.",
                                    Colors.red,
                                    () {});
                                return;
                              }
                              if (double.parse(controller.userData[0]
                                          ["amount_bal"]
                                      .toString()) <
                                  double.parse(controller.tokenAmount.text
                                      .toString()
                                      .removeAllWhitespace)) {
                                CustomDialog().snackbarDialog(
                                    context,
                                    "Insuficient balance.",
                                    Colors.red,
                                    () {});
                                return;
                              }
                              CustomDialog().confirmationDialog(
                                  context,
                                  "Confirmation",
                                  "Are you sure you want to proceed?",
                                  "Back",
                                  "Yes", () {
                                Get.back();
                              }, () {
                                Get.back();
                                controller.getVerifiedAcc();
                              });
                            }
                          })
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Widget myPads(int value, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.onBtnChange(value);
        },
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: InkWell(
              // onTap: () => onTapChange("$value", index),
              child: Container(
            padding: const EdgeInsets.fromLTRB(20, 17, 20, 17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1), // Color(0xFF2563EB) corresponds to #2563EB
              color: controller.indexbtn.value == value
                  ? AppColor.primaryColor
                  : AppColor.bodyColor, // Background color
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Equivalent to flex-shrink: 0
              children: [
                AutoSizeText(
                  "$value",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: controller.indexbtn.value == value
                        ? Colors.white
                        : Colors.black,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
                CustomTitle(
                  text: "Token",
                  fontWeight: FontWeight.w500,
                  color: controller.indexbtn.value == value
                      ? Colors.white
                      : Colors.black,
                  fontSize: 12,
                  maxlines: 1,
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
