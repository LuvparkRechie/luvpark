import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/wallet_qr/paymerchant/utils/controller.dart';

import '../../../custom_widgets/custom_textfield.dart';
import '../../../otp_field/view.dart';

class MerchantQRverify extends StatefulWidget {
  const MerchantQRverify({super.key});

  @override
  State<MerchantQRverify> createState() => _MerchantQRverifyState();
}

class _MerchantQRverifyState extends State<MerchantQRverify> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.put(payMerchantVerifyController());
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    controller.getUserBalance();
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
        title: Text("Review and Pay"),
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
      backgroundColor: AppColor.bodyColor,
      resizeToAvoidBottomInset: true, // Adjust screen when keyboard appears
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
          // Wrap entire body to make it scrollable
          child: Obx(
            () => Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 30),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(7),
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 15),
                          child: CustomParagraph(
                              fontSize: 12,
                              text:
                                  "Please take time to review the details below before clicking Pay"),
                        ),
                        Container(
                            width: double.infinity,
                            color: AppColor.scafColor,
                            child: Image.asset(
                              fit: BoxFit.fill,
                              "assets/images/pu_confirmation.png",
                            )),
                        SizedBox(height: 10),
                        _buildDetailRow("Merchant: ",
                            "${_capitalize(controller.parameter["merchant_name"] ?? "N/A")}"),
                        _buildDetailRow(
                          "Available Balance: ",
                          !controller.isNetConnCard.value
                              ? "........"
                              : controller.isLoadingCard.value
                                  ? "........"
                                  : toCurrencyString(controller.userData[0]
                                          ["amount_bal"]
                                      .toString()),
                        ),
                        _buildTotalAmount(
                            controller.parameter["amount"].toString()),
                      ],
                    ),
                  ),
                  Container(height: 20),
                  CheckboxListTile(
                    value: isVerified,
                    onChanged: (value) {
                      setState(() {
                        isVerified = value ?? false;
                      });
                    },
                    title: CustomParagraph(
                      text:
                          "I confirm the transaction details and agree to proceed with the payment.",
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(15, 30, 15, 15),
                      child: CustomButton(
                        btnColor: isVerified
                            ? AppColor.primaryColor
                            : AppColor.primaryColor.withOpacity(0.5),
                        text:
                            "Pay ${controller.parameter["amount"].toString()}",
                        onPressed: isVerified
                            ? () async {
                                Get.to(ConfirmPasswordMerchant());
                              }
                            : () {},
                      )),
                ],
              ),
            ),
          )),
    );
  }
}

Widget _buildDetailRow(String text, String value) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 15, left: 15, right: 15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CustomParagraph(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            text: text,
            color: AppColor.primaryColor,
          ),
        ),
        Expanded(
          child: CustomParagraph(
            text: value,
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Colors.blueAccent,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}

Widget _buildTotalAmount(amount) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 15, left: 15, right: 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomParagraph(
          text: "Total Amount",
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: AppColor.primaryColor,
        ),
        CustomParagraph(
          text: amount,
          fontSize: 15,
          color: Colors.blueAccent,
          fontWeight: FontWeight.w700,
        ),
      ],
    ),
  );
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

class ConfirmPasswordMerchant extends StatefulWidget {
  const ConfirmPasswordMerchant({super.key});

  @override
  State<ConfirmPasswordMerchant> createState() =>
      _ConfirmPasswordMerchantState();
}

class _ConfirmPasswordMerchantState extends State<ConfirmPasswordMerchant> {
  final GlobalKey<FormState> confirmFormKey = GlobalKey<FormState>();
  bool isShowPass = false;
  @override
  void initState() {
    controller.myPass = TextEditingController();
    super.initState();
  }

  void visibilityChanged(bool visible) {
    isShowPass = visible;
    setState(() {});
  }

  final controller = Get.put(payMerchantVerifyController());
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
        title: Text("Confirm Password"),
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
      body: Form(
        key: confirmFormKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 20),
              CustomParagraph(
                text: "Confirm password to proceed.",
              ),
              Container(height: 20),
              CustomParagraph(
                text: "Input password",
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              CustomTextField(
                hintText: "Enter your password",
                controller: controller.myPass,
                isObscure: isShowPass,
                suffixIcon:
                    !isShowPass ? Icons.visibility_off : Icons.visibility,
                onIconTap: () {
                  visibilityChanged(!isShowPass);
                },
                validator: (d) {
                  if (d == null || d.isEmpty) {
                    return "Password is required";
                  }
                  return null;
                },
              ),
              Container(height: 30),
              CustomButton(
                  text: "Continue",
                  onPressed: () async {
                    final uData = await Authentication().getUserData2();

                    if (confirmFormKey.currentState!.validate()) {
                      Map<String, String> requestParam = {
                        "mobile_no": uData["mobile_no".toString()].toString(),
                        "pwd": controller.myPass.text
                      };
                      CustomDialog().loadingDialog(Get.context!);
                      DateTime timeNow = await Functions.getTimeNow();
                      Get.back();
                      Functions().requestOtp(requestParam, (objData) async {
                        DateTime timeExp = DateFormat("yyyy-MM-dd hh:mm:ss a")
                            .parse(objData["otp_exp_dt"].toString());
                        DateTime otpExpiry = DateTime(
                            timeExp.year,
                            timeExp.month,
                            timeExp.day,
                            timeExp.hour,
                            timeExp.minute,
                            timeExp.millisecond);

                        // Calculate difference
                        Duration difference = otpExpiry.difference(timeNow);

                        if (objData["success"] == "Y" ||
                            objData["status"] == "PENDING") {
                          Map<String, String> putParam = {
                            "mobile_no": uData["mobile_no"].toString(),
                            "otp": objData["otp"].toString(),
                            "req_type": "SR"
                          };

                          Object args = {
                            "time_duration": difference,
                            "mobile_no":
                                uData["mobile_no".toString()].toString(),
                            "req_otp_param": requestParam,
                            "verify_param": putParam,
                            "callback": (otp) async {
                              if (otp != null) {
                                controller.payMerchantVerify();
                              }
                            },
                          };

                          Get.to(
                            OtpFieldScreen(
                              arguments: args,
                            ),
                            transition: Transition.rightToLeftWithFade,
                            duration: Duration(milliseconds: 400),
                          );
                        }
                      });
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
