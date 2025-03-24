import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../auth/authentication.dart';
import '../custom_widgets/app_color.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/custom_text.dart';
import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/no_internet.dart';
import '../functions/functions.dart';

class GenerateReceiveQR extends StatefulWidget {
  const GenerateReceiveQR({super.key});

  @override
  State<GenerateReceiveQR> createState() => _GenerateReceiveQRState();
}

class _GenerateReceiveQRState extends State<GenerateReceiveQR> {
  bool isLoading = true;
  bool hasNet = true;
  List userData = [];
  String amount = "0.0";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    getUserBalance();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setCursorToEnd();
    });
    timerPeriodic();
  }

  Future<void> timerPeriodic() async {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      getUserBalance();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    if (amount < 50) {
      return 'Amount must not be less than 50';
    }
    if (amount > 500) {
      return 'Amount must not be greater than 500';
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

  Future<void> getUserBalance() async {
    await Functions.getUserBalance2(Get.context!, (dataBalance) async {
      if (!dataBalance[0]["has_net"]) {
        setState(() {
          isLoading = false;
          hasNet = false;
        });
        return;
      } else {
        setState(() {
          isLoading = false;
          hasNet = true;
          userData = dataBalance[0]["items"];
        });
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("QR Receive"),
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
      body: isLoading
          ? PageLoader()
          : !hasNet
              ? NoInternetConnected(onTap: () {
                  setState(() {
                    getUserBalance();
                  });
                })
              : Container(
                  padding: EdgeInsets.all(15),
                  child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              decoration: ShapeDecoration(
                                color: Colors.white,
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
                                  Image(
                                    fit: BoxFit.contain,
                                    image: AssetImage(
                                      "assets/images/logo.png",
                                    ),
                                    width: 30,
                                    height: 30,
                                  ),
                                  Container(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomParagraph(
                                          text: "Wallet Balance",
                                          fontWeight: FontWeight.w500,
                                        ),
                                        Container(height: 5),
                                        CustomParagraph(
                                          text: toCurrencyString(userData[0]
                                                  ["amount_bal"]
                                              .toString()),
                                          color: AppColor.headerColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ],
                                    ),
                                  ),
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
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(3)
                              ],
                              hintText: "Enter amount",
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              controller: amountController,
                              validator: _validateAmount,
                              onChange: (value) {
                                setState(() {
                                  amount = value.toString();
                                });
                              },
                            ),
                            Container(height: 30),
                            CustomButton(
                              text: "Generate QR Code",
                              onPressed: () async {
                                final data =
                                    await Authentication().getUserData2();

                                FocusManager.instance.primaryFocus?.unfocus();
                                if (_formKey.currentState!.validate()) {
                                  await Future.delayed(
                                      Duration(milliseconds: 200));
                                  Map<String, String> args = {
                                    "mobile_no": data["mobile_no"].toString(),
                                    "amount": amount
                                  };

                                  Get.bottomSheet(
                                    ScanGeneratedQR(
                                      onBack: () {
                                        amountController.clear();
                                        getUserBalance();
                                      },
                                      args: jsonEncode(args),
                                    ),
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      )),
                ),
    );
  }
}

class ScanGeneratedQR extends StatefulWidget {
  const ScanGeneratedQR({super.key, required this.onBack, required this.args});
  final Function onBack;
  final String args;

  @override
  State<ScanGeneratedQR> createState() => _ScanGeneratedQRState();
}

class _ScanGeneratedQRState extends State<ScanGeneratedQR> {
  late Map<String, dynamic> decoded;
  @override
  void initState() {
    super.initState();
    decoded = jsonDecode(widget.args);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(7),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
        child: Column(
          children: [
            CustomTitle(
              text: "Scan QR Code",
              fontSize: 20,
            ),
            Container(height: 5),
            CustomParagraph(
              text: "Align the QR code within the frame to scan",
              fontSize: 14,
            ),
            Container(height: 30),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
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
                      data: widget.args,
                      errorCorrectLevel: QrErrorCorrectLevel.H,
                    ),
                  ),
                ),
              ),
            ),
            CustomParagraph(
              text: "Amount requested",
              fontSize: 12,
              color: AppColor.subtitleColor,
            ),
            CustomTitle(
              text: decoded["amount"].toString(),
              fontSize: 14,
              color: AppColor.primaryColor,
            ),
            Container(height: 10),
            CustomButton(
                text: "Close",
                onPressed: () {
                  widget.onBack();
                  Get.back();
                }),
            Container(height: 30),
          ],
        ),
      ),
    );
  }
}
