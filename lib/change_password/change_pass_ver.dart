import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../auth/authentication.dart';
import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/app_color.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/custom_text.dart';
import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/password_indicator.dart';
import '../custom_widgets/variables.dart';
import '../functions/functions.dart';
import '../http/api_keys.dart';
import '../http/http_request.dart';
import '../routes/routes.dart';

class ChangePasswordVerified extends StatefulWidget {
  const ChangePasswordVerified({super.key});

  @override
  State<ChangePasswordVerified> createState() => _ChangePasswordVerifiedState();
}

class _ChangePasswordVerifiedState extends State<ChangePasswordVerified> {
  final secData = Get.arguments["data"][0];
  final paramMobile = Get.arguments["mobile_no"];
  final GlobalKey<FormState> secFormKey = GlobalKey<FormState>();
  TextEditingController secAns = TextEditingController();
  TextEditingController oldPass = TextEditingController();
  TextEditingController newPass = TextEditingController();
  RxInt passStrength = 0.obs;

  @override
  void initState() {
    super.initState();
    secAns = TextEditingController();
    oldPass = TextEditingController();
    newPass = TextEditingController();
  }

  void secRequestOtp() async {
    Map<String, String> reqParam = {
      "mobile_no": paramMobile.toString(),
      "secq_no": secData["secq_no"].toString(),
      "secq_id": secData["secq_id"].toString(),
      "seca": secAns.text,
      "new_pwd": newPass.text,
      "old_pwd": oldPass.text
    };

    Functions().requestOtp(reqParam, (obj) {
      if (obj["success"] == "Y") {
        Map<String, String> putParam = {
          "mobile_no": paramMobile.toString(),
          "otp": obj["otp"].toString(),
          "req_type": "UP"
        };
        Get.toNamed(
          Routes.otpField,
          arguments: {
            "mobile_no": paramMobile,
            "verify_param": putParam,
            "callback": (otp) async {
              if (otp != null) {
                CustomDialog().loadingDialog(Get.context!);

                Map<String, dynamic> postParam = {
                  "mobile_no": paramMobile.toString(),
                  "otp": otp.toString(),
                  "new_pwd": newPass.text,
                };

                HttpRequest(api: ApiKeys.putLogin, parameters: postParam)
                    .putBody()
                    .then(
                  (retvalue) {
                    Get.back();
                    if (retvalue == "No Internet") {
                      CustomDialog().errorDialog(Get.context!, "Error",
                          "Please check your internet connection and try again.",
                          () {
                        Get.back();
                      });
                      return;
                    }
                    if (retvalue == null) {
                      CustomDialog().errorDialog(Get.context!, "Error",
                          "Error while connecting to server, Please try again.",
                          () {
                        Get.back();
                      });
                    } else {
                      if (retvalue["success"] == "Y") {
                        Map<String, dynamic> data = {
                          "mobile_no": paramMobile,
                          "pwd": newPass.text,
                        };
                        final plainText = jsonEncode(data);

                        Authentication().encryptData(plainText);
                        Get.toNamed(Routes.forgotPassSuccess);
                      } else {
                        CustomDialog().errorDialog(
                          Get.context!,
                          "Error",
                          retvalue["msg"],
                          () {
                            Get.back();
                          },
                        );
                      }
                    }
                  },
                );
              }
            },
          },
        );
      }
    });
  }

  void onPasswordChanged(String value) {
    passStrength.value = Variables.getPasswordStrength(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 20),
              CustomButtonClose(onTap: () {
                Get.back();
              }),
              Container(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: secFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTitle(
                          text: "Security Question",
                          fontSize: 20,
                        ),
                        Container(height: 10),
                        CustomParagraph(
                          text: "Please provide an answer.",
                        ),
                        Container(height: 20),
                        CustomParagraph(
                          text: secData["question"],
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        CustomTextField(
                          controller: secAns,
                          hintText: "Your answer",
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please provide your security answer";
                            }

                            return null;
                          },
                        ),
                        CustomParagraph(
                          text: "Old password",
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        CustomTextField(
                          hintText: "Enter your old password",
                          controller: oldPass,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Field is required";
                            }

                            return null;
                          },
                        ),
                        CustomParagraph(
                          text: "New password",
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        CustomTextField(
                          hintText: "Enter your new password",
                          controller: newPass,
                          onChange: (value) {
                            onPasswordChanged(value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Field is required";
                            }
                            return null;
                          },
                        ),
                        Container(height: 20),
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: Colors.black
                                    .withOpacity(0.05999999865889549),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 15, 11, 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomTitle(
                                  text: "Password Strength",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -.1,
                                  wordspacing: 2,
                                ),
                                Container(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    PasswordStrengthIndicator(
                                      strength: 1,
                                      currentStrength: passStrength.value,
                                    ),
                                    Container(
                                      width: 5,
                                    ),
                                    PasswordStrengthIndicator(
                                      strength: 2,
                                      currentStrength: passStrength.value,
                                    ),
                                    Container(
                                      width: 5,
                                    ),
                                    PasswordStrengthIndicator(
                                      strength: 3,
                                      currentStrength: passStrength.value,
                                    ),
                                    Container(
                                      width: 5,
                                    ),
                                    PasswordStrengthIndicator(
                                      strength: 4,
                                      currentStrength: passStrength.value,
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 15,
                                ),
                                if (Variables.getPasswordStrengthText(
                                        passStrength.value)
                                    .isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.shield_moon,
                                        color: Variables
                                            .getColorForPasswordStrength(
                                                passStrength.value),
                                        size: 18,
                                      ),
                                      Container(
                                        width: 6,
                                      ),
                                      CustomParagraph(
                                        text: Variables.getPasswordStrengthText(
                                            passStrength.value),
                                        color: Variables
                                            .getColorForPasswordStrength(
                                                passStrength.value),
                                      ),
                                    ],
                                  ),
                                Container(
                                  height: 10,
                                ),
                                const CustomParagraph(
                                  text:
                                      "The password should have a minimum of 8 characters, including at least one uppercase letter and a number.",
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(height: 30),
                        CustomButton(
                            text: "Continue",
                            onPressed: () {
                              if (secFormKey.currentState?.validate() ??
                                  false) {
                                secRequestOtp();
                              }
                            }),
                        Container(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
