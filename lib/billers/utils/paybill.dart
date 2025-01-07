// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';

import '../../custom_widgets/alert_dialog.dart';
import '../../custom_widgets/app_color.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/no_internet.dart';
import '../controller.dart';

class PayBill extends StatefulWidget {
  const PayBill({super.key});

  @override
  State<PayBill> createState() => _PayBillState();
}

class _PayBillState extends State<PayBill> {
  final controller = Get.put(BillersController());
  final fav = Get.arguments;
  final args = Get.arguments;

  final _accountNumberKey = GlobalKey<FormState>();
  final _accountNameKey = GlobalKey<FormState>();
  final _amountKey = GlobalKey<FormState>();
  final _billNumberKey = GlobalKey<FormState>();
  @override
  void initState() {
    controller.clearFields();
    super.initState();
    controller.billAccNo.text = fav["account_no"] ?? '';
    controller.billerAccountName.text = fav["account_name"] ?? '';
  }

  void _submitForm() {
    bool isFavSource = args["source"] == "fav";
    final isAccountNumberValid = _accountNumberKey.currentState!.validate();
    final isAccountNameValid = _accountNameKey.currentState!.validate();
    final isAmountValid =
        args["source"] != "fav" ? _amountKey.currentState!.validate() : true;
    final isBillNumberValid = args["source"] != "fav"
        ? _billNumberKey.currentState!.validate()
        : true;

    if (isAccountNumberValid &&
        isAccountNameValid &&
        isAmountValid &&
        isBillNumberValid) {
      if (isFavSource) {
        controller.addFavorites(args);
      } else if (args["source"] == "pay" || args["source"] == "favorites") {
        controller.onPay(args);
      }
      // isFavSource ? controller.addFavorites(args) : controller.onPay(args);
    } else {
      CustomDialog().errorDialog(
        Get.context!,
        "luvpark",
        "Please fill in all required fields.",
        () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: args["source"] == "fav" ? "Add to Favorites" : "Pay Biller",
        onTap: () {
          Get.back();
          controller.clearFields();
        },
      ),
      body: !controller.isNetConn.value
          ? NoInternetConnected(
              onTap: controller.loadFavoritesAndBillers,
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTitle(
                      text: args["biller_name"],
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    Divider(
                      color: AppColor.linkLabel,
                    ),
                    SizedBox(height: 20),
                    CustomParagraph(
                      text: "Account Number",
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: _accountNumberKey,
                      child: CustomTextField(
                        controller: controller.billAccNo,
                        hintText: "Enter Account Number",
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(15),
                          FilteringTextInputFormatter.digitsOnly,
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*$')),
                        ],
                        keyboardType: Platform.isAndroid
                            ? TextInputType.numberWithOptions(decimal: true)
                            : const TextInputType.numberWithOptions(
                                signed: true, decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Account number is required";
                          } else if (value.length < 5) {
                            return "Account number must be at least 5 digits";
                          } else if (value.length > 15) {
                            return "Account number must not exceed 15 digits";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomParagraph(
                      text: "Account Name",
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: _accountNameKey,
                      child: CustomTextField(
                        controller: controller.billerAccountName,
                        hintText: "Enter Account Name",
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z\s]'))
                        ],
                        textCapitalization: TextCapitalization.characters,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Account Name is required";
                          }
                          if ((value.endsWith(' ') ||
                              value.endsWith('-') ||
                              value.endsWith('.'))) {
                            return "Account Name cannot end with a space, hyphen, or period";
                          }
                          return null;
                        },
                      ),
                    ),
                    Visibility(
                      visible: args["source"] != "fav",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          CustomParagraph(
                            text: "Amount",
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          Form(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            key: _amountKey,
                            child: CustomTextField(
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(15),
                                FilteringTextInputFormatter.digitsOnly,
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*$')),
                                AutoDecimalInputFormatter(),
                              ],
                              keyboardType: Platform.isAndroid
                                  ? TextInputType.numberWithOptions(
                                      decimal: true)
                                  : const TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                              controller: controller.amount,
                              hintText: "Enter Amount",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Amount is required";
                                }
                                final amount = double.tryParse(value);
                                if (amount == null || value.startsWith('0')) {
                                  return "Invalid amount";
                                }
                                return null;
                              },
                            ),
                          ),
                          CustomParagraph(
                            text: args["service_fee"] == null
                                ? ""
                                : " Service Fee : ${args["service_fee"]}",
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                          SizedBox(height: 10),
                          CustomParagraph(
                            text: "Bill Number",
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          Form(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            key: _billNumberKey,
                            child: CustomTextField(
                              hintText: "Enter Bill Number",
                              controller: controller.billNo,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly,
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*$')),
                              ],
                              keyboardType: Platform.isAndroid
                                  ? TextInputType.numberWithOptions(
                                      decimal: true)
                                  : const TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Bill number is required";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    if (MediaQuery.of(context).viewInsets.bottom == 0)
                      CustomButton(
                        text: args["source"] == "fav" ? "Save" : "Pay",
                        // onPressed: () {
                        // print("source:${args["source"]}");
                        // },
                        onPressed: _submitForm,
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class AutoDecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final numericValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    final value = double.tryParse(numericValue) ?? 0.0;
    final formattedValue = (value / 100).toStringAsFixed(2);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
