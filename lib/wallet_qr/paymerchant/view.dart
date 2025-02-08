import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';

import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text.dart';
import '../../functions/functions.dart';
import '../../routes/routes.dart';

class PayMerchant extends StatefulWidget {
  final List data;
  const PayMerchant({super.key, required this.data});

  @override
  State<PayMerchant> createState() => _PayMerchantState();
}

class _PayMerchantState extends State<PayMerchant> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  List userData = [];
  bool isLoadingMerch = true;
  bool hasNet = true;

  @override
  void initState() {
    super.initState();
    getUserBalance();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setCursorToEnd();
    });
  }

  Future<void> getUserBalance() async {
    setState(() {
      isLoadingMerch = true;
      hasNet = true;
    });
    Functions.getUserBalance2(Get.context!, (dataBalance) async {
      if (!dataBalance[0]["has_net"]) {
        return;
      } else {
        isLoadingMerch = false;
        hasNet = true;
        userData = dataBalance[0]["items"];
      }
      setState(() {});
    });
  }

  void _setCursorToEnd() {
    amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountController.text.length));
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }

    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount greater than zero';
    }

    final balance = userData[0]["amount_bal"];
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
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(7),
        ),
        color: Colors.white,
      ),
      child: isLoadingMerch
          ? PageLoader()
          : !hasNet
              ? NoInternetConnected()
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(height: 20),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColor.iconBgColor),
                                    padding: EdgeInsets.all(10),
                                    child: Icon(
                                      Iconsax.bill,
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                  Container(width: 10),
                                  CustomTitle(
                                    text:
                                        "${_capitalize(widget.data[0]["merchant_name"])}",
                                    fontSize: 18,
                                  )
                                ],
                              ),
                              Container(height: 15),
                              CustomParagraph(
                                text: widget.data[0]["merchant_address"],
                              ),
                              Container(height: 20),
                              Container(
                                padding: EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: ShapeDecoration(
                                  color: Colors.grey.shade50,
                                  shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          width: 1, color: Color(0xFFE8E6E6)),
                                      borderRadius: BorderRadius.circular(7)),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x0C000000),
                                      blurRadius: 15,
                                      offset: Offset(0, 5),
                                      spreadRadius: 0,
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColor.iconBgColor,
                                      ),
                                      padding: EdgeInsets.all(5),
                                      child: Image(
                                        fit: BoxFit.contain,
                                        image: AssetImage(
                                          "assets/images/logo.png",
                                        ),
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                    Container(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomParagraph(
                                            text: "Wallet Balance",
                                            color: AppColor.headerColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          Container(height: 5),
                                          CustomParagraph(
                                            text: "luvpark payment",
                                            fontSize: 13,
                                          ),
                                        ],
                                      ),
                                    ),
                                    CustomParagraph(
                                      text: toCurrencyString(
                                          userData[0]["amount_bal"].toString()),
                                      color: AppColor.headerColor,
                                      fontWeight: FontWeight.w700,
                                      maxlines: 1,
                                    )
                                  ],
                                ),
                              ),
                              Container(height: 20),
                              CustomParagraph(
                                text: "Amount",
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              CustomTextField(
                                hintText: "Enter payment amount",
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                controller: amountController,
                                inputFormatters: [
                                  AutoDecimalInputFormatter(),
                                ],
                                validator: _validateAmount,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: MediaQuery.of(context).viewInsets.bottom == 0,
                        child: CustomButton(
                            text: "Pay Merchant",
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                Get.toNamed(
                                  Routes.merchantQRverify,
                                  arguments: {
                                    "merchant_name": widget.data[0]
                                        ["merchant_name"],
                                    "amount": amountController.text,
                                    "merchant_key": widget.data[0]
                                        ["merchant_key"],
                                    "payment_hk": widget.data[0]["payment_key"],
                                  },
                                );
                              }
                            }),
                      ),
                      Container(height: 20),
                    ],
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
