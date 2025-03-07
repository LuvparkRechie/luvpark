import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/custom_widgets/app_color.dart';

import '../../auth/authentication.dart';
import '../../custom_widgets/alert_dialog.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/password_indicator.dart';
import '../../custom_widgets/variables.dart';
import '../../custom_widgets/vertical_height.dart';
import '../../functions/functions.dart';
import '../../http/api_keys.dart';
import '../../http/http_request.dart';
import '../../otp_field/index.dart';
import '../../routes/routes.dart';

class ChangePassNewProtocol extends StatefulWidget {
  final String mobileNo;
  final String userId;
  const ChangePassNewProtocol(
      {super.key, required this.mobileNo, required this.userId});

  @override
  State<ChangePassNewProtocol> createState() => _ChangePassNewProtocolState();
}

class _ChangePassNewProtocolState extends State<ChangePassNewProtocol> {
  final GlobalKey<FormState> formKeyChangePass = GlobalKey<FormState>();
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController newConfirmPassword = TextEditingController();
  RxBool isShowOldPass = false.obs;
  RxBool isShowNewPass = false.obs;
  RxBool isShowNewPassConfirm = false.obs;
  RxInt passStrength = 0.obs;

  @override
  void initState() {
    super.initState();
  }

  void onToggleOldPass(bool isShow) {
    isShowOldPass.value = isShow;
    setState(() {});
  }

  void onToggleNewPass(bool isShow) {
    isShowNewPass.value = isShow;
    setState(() {});
  }

  void onToggleConfirmNewPass(bool isShow) {
    isShowNewPassConfirm.value = isShow;
    setState(() {});
  }

  void onPasswordChanged(String value) {
    passStrength.value = Variables.getPasswordStrength(value);
    setState(() {});
  }

  void onPasswordConfirmChanged(String value) {
    // passStrength.value = Variables.getPasswordStrength(value);
    setState(() {});
  }

  Future<void> onSubmit() async {
    CustomDialog().loadingDialog(context);
    DateTime timeNow = await Functions.getTimeNow();
    Get.back();
    // Close any open keyboards
    FocusManager.instance.primaryFocus!.unfocus();

    // Validate the form first
    if (!formKeyChangePass.currentState!.validate()) {
      return; // Stop submission if the form is not valid
    }

    // Proceed with password change logic if validation passes
    if (newPassword.text != newConfirmPassword.text) {
      CustomDialog().errorDialog(
          Get.context!, "luvpark", "Passwords do not match, please try again.",
          () {
        Get.back();
      });
      return;
    }

    Map<String, String> reqParam = {
      "mobile_no": widget.mobileNo.toString(),
      "req_type": "SR",
    };
    Functions().requestOtp(reqParam, (obj) async {
      DateTime timeExp = DateFormat("yyyy-MM-dd hh:mm:ss a")
          .parse(obj["otp_exp_dt"].toString());
      DateTime otpExpiry = DateTime(timeExp.year, timeExp.month, timeExp.day,
          timeExp.hour, timeExp.minute, timeExp.millisecond);

      // Calculate difference
      Duration difference = otpExpiry.difference(timeNow);

      if (obj["success"] == "Y" || obj["status"] == "PENDING") {
        Map<String, String> putParam = {
          "mobile_no": widget.mobileNo.toString(),
          "otp": obj["otp"].toString(),
          "req_type": "SR"
        };
        Object args = {
          "time_duration": difference,
          "mobile_no": widget.mobileNo,
          "req_otp_param": reqParam,
          "verify_param": putParam,
          "is_forget_vfd_pass": true,
          "callback": (otp) async {
            if (otp != null) {
              CustomDialog().loadingDialog(Get.context!);

              Map<String, dynamic> postParam = {
                "mobile_no": widget.mobileNo,
                "otp": otp.toString(),
                "new_pwd": newPassword.text,
              };

              HttpRequest(api: ApiKeys.putLogin, parameters: postParam)
                  .putBody()
                  .then(
                (retvalue) async {
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
                      Get.back();
                      CustomDialog().successDialog(
                          Get.context!, "Success", retvalue["msg"], "Okay",
                          () async {
                        Get.back();
                        CustomDialog().loadingDialog(Get.context!);
                        await Future.delayed(const Duration(seconds: 1));
                        final userLogin = await Authentication().getUserLogin();
                        if (userLogin == null) {
                          Get.back();
                          Get.offAllNamed(Routes.login);
                          return;
                        }

                        List userData = [userLogin];
                        userData = userData.map((e) {
                          e["is_login"] = "N";
                          return e;
                        }).toList();

                        await Authentication()
                            .setLogin(jsonEncode(userData[0]));
                        await Authentication().setBiometricStatus(false);
                        Get.back();
                        Get.offAllNamed(Routes.login);
                      });
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Form(
          key: formKeyChangePass,
          child: StretchingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20),
                  CustomButtonClose(onTap: () {
                    Get.back();
                  }),
                  Container(height: 20),
                  CustomTitle(
                    text: "Change Password",
                    fontSize: 20,
                  ),
                  Container(height: 10),
                  CustomParagraph(
                    text:
                        "Your new password must be different from previous used passwords.",
                  ),
                  Container(height: 20),
                  CustomParagraph(
                    text: "New Password",
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  CustomTextField(
                    title: "New Password",
                    hintText: "Create your new password",
                    controller: newPassword,
                    isObscure: !isShowNewPass.value,
                    suffixIcon: !isShowNewPass.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onChange: (value) {
                      onPasswordChanged(value);
                    },
                    onIconTap: () {
                      onToggleNewPass(!isShowNewPass.value);
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    validator: (txtValue) {
                      if (txtValue == null || txtValue.isEmpty) {
                        return "Field is required";
                      }
                      if (txtValue == oldPassword.text) {
                        return "New password must be different";
                      }
                      if (txtValue.trim().length < 8 ||
                          txtValue.trim().length > 32) {
                        return "Password must be between 8 and 32 characters";
                      }
                      if (passStrength.value == 1) {
                        return "Very Weak Password";
                      }
                      if (passStrength.value == 2) {
                        return "Weak Password";
                      }
                      if (passStrength.value == 3) {
                        return "Medium Password";
                      }

                      return null;
                    },
                  ),
                  CustomParagraph(
                    text: "Confirm Password",
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  CustomTextField(
                    title: "Confirm Password",
                    hintText: "Confirm your new password",
                    controller: newConfirmPassword,
                    isObscure: !isShowNewPassConfirm.value,
                    suffixIcon: !isShowNewPassConfirm.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onChange: (value) {
                      onPasswordConfirmChanged(value);
                    },
                    onIconTap: () {
                      onToggleConfirmNewPass(!isShowNewPassConfirm.value);
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    validator: (txtValue) {
                      if (txtValue == null || txtValue.isEmpty) {
                        return "Field is required";
                      }
                      if (txtValue.trim().length < 8 ||
                          txtValue.trim().length > 32) {
                        return "Password must be between 8 and 32 characters";
                      }
                      if (txtValue != newPassword.text) {
                        return "New passwords do not match";
                      }

                      return null;
                    },
                  ),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: Colors.black.withOpacity(0.05999999865889549),
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
                                  color: Variables.getColorForPasswordStrength(
                                      passStrength.value),
                                  size: 18,
                                ),
                                Container(
                                  width: 6,
                                ),
                                CustomParagraph(
                                  text: Variables.getPasswordStrengthText(
                                      passStrength.value),
                                  color: Variables.getColorForPasswordStrength(
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
                  const VerticalHeight(height: 30),
                  if (MediaQuery.of(context).viewInsets.bottom == 0)
                    CustomButton(text: "Submit", onPressed: onSubmit)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
