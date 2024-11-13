import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/wallet_send/index.dart';

import '../custom_widgets/app_color.dart';
import '../custom_widgets/scanner.dart';
import '../custom_widgets/variables.dart';

class WalletSend extends GetView<WalletSendController> {
  const WalletSend({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: CustomAppbar(
        title: "Send",
        onTap: () {
          Get.back();
          controller.parameter();
        },
      ),
      body: ScrollConfiguration(
        behavior: ScrollBehavior().copyWith(overscroll: false),
        child: SingleChildScrollView(
          child: Form(
            key: controller.formKeySend,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Obx(
                () => controller.isLoading.value
                    ? Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primaryColor,
                          ),
                        ),
                      )
                    : Column(
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
                                    child: controller.isLoading.value
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          )
                                        : CustomParagraph(
                                            text: !controller.isNetConn.value
                                                ? "No internet"
                                                : controller.userData.isEmpty
                                                    ? ""
                                                    : toCurrencyString(
                                                        controller.userData[0]
                                                            ["amount_bal"]),
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            textAlign: TextAlign.right,
                                          ),
                                  )
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
                            inputFormatters: [Variables.maskFormatter],
                            keyboardType: Platform.isAndroid
                                ? TextInputType.number
                                : const TextInputType.numberWithOptions(
                                    signed: true, decimal: false),
                            labelText: "Mobile Number",
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
                            suffixIcon: Icons.qr_code,
                            onIconTap: () {
                              FocusNode().unfocus();
                              Get.to(ScannerScreen(
                                onchanged: (ScannedData args) {
                                  String scannedMobileNumber = args.scannedHash;
                                  String formattedNumber = scannedMobileNumber
                                      .replaceAll(RegExp(r'\D'), '');

                                  if (formattedNumber.length >= 12) {
                                    formattedNumber =
                                        formattedNumber.substring(2);
                                  }

                                  if (formattedNumber.isEmpty ||
                                      formattedNumber.length != 10 ||
                                      formattedNumber[0] == '0') {
                                    controller.recipient.text = "";
                                    CustomDialog().errorDialog(
                                      context,
                                      "Invalid QR Code",
                                      "The scanned QR code is invalid. Please try again.",
                                      () {
                                        Get.back();
                                      },
                                    );
                                  } else {
                                    controller.recipient.text = formattedNumber;
                                    controller.onTextChange();
                                  }
                                },
                              ));
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
                              controller.pads(int.parse(text.toString()));
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
                          SizedBox(
                            height: 30,
                          ),
                          if (MediaQuery.of(context).viewInsets.bottom ==
                              0) //hide button
                            CustomButton(
                                text: "Continue",
                                btnColor: AppColor.primaryColor,
                                onPressed: () async {
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
                                        "Insufficient balance.",
                                        Colors.red,
                                        () {},
                                      );
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget myPads(data, int index) {
    double walletBalance =
        double.parse(controller.userData[0]["amount_bal"].toString());

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: InkWell(
          onTap: walletBalance >= data["value"]
              ? () {
                  controller.pads(data["value"]);
                }
              : null,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 17, 23, 17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              color: walletBalance >= data["value"]
                  ? (data["is_active"] ? AppColor.primaryColor : Colors.white)
                  : Colors.grey.shade300,
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
                  color: walletBalance >= data["value"]
                      ? (data["is_active"] ? Colors.white : Colors.black)
                      : Colors.grey,
                ),
                CustomParagraph(
                  text: "Token",
                  maxlines: 1,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: walletBalance >= data["value"]
                      ? (data["is_active"] ? Colors.white : Colors.black)
                      : Colors.grey,
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
