import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:get/get.dart';

import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/routes/routes.dart';
import 'controller.dart';

class payMerchant extends StatefulWidget {
  const payMerchant({super.key});

  @override
  State<payMerchant> createState() => _payMerchantState();
}

class _payMerchantState extends State<payMerchant> {
  final controller = payMerchantController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller.getUserBalance();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setCursorToEnd();
    });
  }

  void _setCursorToEnd() {
    controller.amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.amountController.text.length));
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }

    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount greater than zero';
    }

    final balance = controller.userData[0]["amount_bal"];
    final balanceAmount = balance is double
        ? balance
        : double.tryParse(balance.toString()) ?? 0.0;

    if (amount > balanceAmount) {
      return 'Insufficient balance';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Pay Merchant",
      ),
      backgroundColor: AppColor.bodyColor,
      body: Obx(
        () => Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 150),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Send to: ",
                        style: paragraphStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "${_capitalize(controller.merchantName)}",
                        style: paragraphStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: AppColor.bodyColor,
                width: double.infinity,
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
                    child: CustomTextField(
                      hintText: "Enter amount",
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      controller: controller.amountController,
                      inputFormatters: [
                        AutoDecimalInputFormatter(),
                      ],
                      validator: _validateAmount,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Balance: ",
                        style: paragraphStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: !controller.isNetConnCard.value
                            ? "........"
                            : controller.isLoadingCard.value
                                ? "........"
                                : toCurrencyString(controller.userData[0]
                                        ["amount_bal"]
                                    .toString()),
                        style: paragraphStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      child: CustomElevatedButton(
                        btnwidth: double.infinity,
                        text: "Pay Merchant",
                        btnColor: AppColor.primaryColor,
                        btnHeight: 40,
                        textColor: Colors.white,
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            Get.offNamed(
                              Routes.merchantQRverify,
                              arguments: {
                                "merchant_name": controller.merchantName,
                                "amount": controller.amountController.text,
                                "merchant_key": controller.paramMKEY,
                                "payment_hk": controller.paramPHK,
                              },
                            );
                          }
                        },
                      ),
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

class AutoDecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // Remove non-numeric characters
    final numericValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Format as decimal (e.g., "123" -> "1.23")
    final value = double.tryParse(numericValue) ?? 0.0;
    final formattedValue = (value / 100).toStringAsFixed(2);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}
