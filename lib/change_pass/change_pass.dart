import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/DbProvider.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/biometric_login.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/password_indicator.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool? confirmPasswordVisibility = true;
  bool? newPasswordVisibility = true;
  bool isActive = false;
  bool? passwordVisibility = true;
  bool? hasEightCharacters = false;
  bool? has1Number = false;
  bool? hasUpperCase = false;
  bool isObscureOld = true;
  bool isObscureNew = true;
  bool isObscureConfirm = true;
  int passStrength = 0;
  TextEditingController oldPass = TextEditingController();
  TextEditingController newPass = TextEditingController();
  TextEditingController confirmPass = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  triggerChange() {
    final numericRegex = RegExp(r'[0-9]');
    final upperCaseRegex = RegExp(r'[A-Z]');
    // signupDetails = [];
    setState(() {
      has1Number = false;
      hasEightCharacters = false;
      hasUpperCase = false;
      if (newPass.text.length >= 8) {
        setState(() {
          hasEightCharacters = true;
        });
      }
      if (numericRegex.hasMatch(newPass.text)) {
        setState(() {
          has1Number = true;
        });
      }
      if (upperCaseRegex.hasMatch(newPass.text)) {
        setState(() {
          hasUpperCase = true;
        });
      }
      if (oldPass.text.isEmpty ||
          newPass.text.isEmpty ||
          confirmPass.text.isEmpty) {
        setState(() {
          isActive = false;
        });
      }

      if (hasEightCharacters! &&
          has1Number! &&
          hasUpperCase! &&
          oldPass.text.isNotEmpty &&
          newPass.text.isNotEmpty &&
          confirmPass.text.isNotEmpty) {
        setState(() {
          isActive = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
        canPop: true,
        appBarheaderText: "Change Password",
        appBarIconClick: () {
          Navigator.of(context).pop();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 10,
              ),
              Container(
                color: const Color(0xFFFDFDEA),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF723B13),
                      ),
                      Container(
                        width: 10,
                      ),
                      Expanded(
                        child: CustomDisplayText(
                          label:
                              "Your new password must be different from previous used passwords.",
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF723B13),
                          fontSize: 14,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 30,
              ),
              CustomTextField(
                title: "Old Password",
                labelText: "Enter old password",
                controller: oldPass,
                isObscure: isObscureOld,
                suffixIcon:
                    !isObscureOld ? Icons.visibility : Icons.visibility_off,
                onIconTap: () {
                  setState(() {
                    isObscureOld = !isObscureOld;
                  });
                },
              ),
              CustomTextField(
                title: "New Password",
                labelText: "Enter new password",
                controller: newPass,
                isObscure: isObscureNew,
                suffixIcon:
                    !isObscureNew ? Icons.visibility : Icons.visibility_off,
                onIconTap: () {
                  setState(() {
                    isObscureNew = !isObscureNew;
                  });
                },
                onChange: (value) async {
                  setState(() {
                    passStrength = Variables.getPasswordStrength(value);
                  });
                },
              ),
              CustomTextField(
                title: "Confirm Password",
                labelText: "Enter new password again",
                controller: confirmPass,
                isObscure: isObscureConfirm,
                suffixIcon:
                    !isObscureConfirm ? Icons.visibility : Icons.visibility_off,
                onIconTap: () {
                  setState(() {
                    isObscureConfirm = !isObscureConfirm;
                  });
                },
                onChange: (value) async {
                  // setState(() {
                  //   passStrength = getPasswordStrength(value);
                  // });
                },
              ),
              Container(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 239, 244, 248),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Password Strength",
                        style: GoogleFonts.varela(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        height: 15,
                      ),
                      Row(
                        children: [
                          PasswordStrengthIndicator(
                            strength: 1,
                            currentStrength: passStrength,
                          ),
                          Container(
                            width: 5,
                          ),
                          PasswordStrengthIndicator(
                            strength: 2,
                            currentStrength: passStrength,
                          ),
                          Container(
                            width: 5,
                          ),
                          PasswordStrengthIndicator(
                            strength: 3,
                            currentStrength: passStrength,
                          ),
                          Container(
                            width: 5,
                          ),
                          PasswordStrengthIndicator(
                            strength: 4,
                            currentStrength: passStrength,
                          ),
                        ],
                      ),
                      Container(
                        height: 15,
                      ),
                      if (Variables.getPasswordStrengthText(passStrength)
                          .isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.checkmark_shield_fill,
                              color: AppColor.primaryColor,
                              size: 18,
                            ),
                            Container(
                              width: 6,
                            ),
                            CustomDisplayText(
                              label: Variables.getPasswordStrengthText(
                                  passStrength),
                              fontWeight: FontWeight.w600,
                              color: Variables.getColorForPasswordStrength(
                                  passStrength),
                              fontSize: 15,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      Container(
                        height: 10,
                      ),
                      CustomDisplayText(
                        label:
                            "The password should have a minimum of 8 characters, including at least one uppercase letter and a number.",
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 141, 140, 140),
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 30,
              ),
              CustomButton(
                  label: "Submit",
                  color: passStrength < 4
                      ? AppColor.primaryColor.withOpacity(.7)
                      : AppColor.primaryColor,
                  onTap: passStrength < 4
                      ? () {}
                      : () async {
                          FocusManager.instance.primaryFocus!.unfocus();
                          if (newPass.text != confirmPass.text) {
                            showAlertDialog(context, "Error",
                                "Password do not match, Please try again.", () {
                              Navigator.of(context).pop();
                            });
                            return;
                          }
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          var akongP = prefs.getString(
                            'userData',
                          );
                          // ignore: use_build_context_synchronously
                          CustomModal(context: context).loader();
                          var changePassParam = {
                            "old_pwd": oldPass.text,
                            "new_pwd": newPass.text,
                            "user_id": jsonDecode(akongP!)['user_id'].toString()
                          };
                          HttpRequest(
                                  api: ApiKeys.gApiSubFolderChangePass,
                                  parameters: changePassParam)
                              .put()
                              .then((returnPut) {
                            if (returnPut == "No Internet") {
                              Navigator.pop(context);
                              showAlertDialog(context, "Error",
                                  "Please check your internet connection and try again.",
                                  () {
                                Navigator.pop(context);
                              });
                              return;
                            }
                            if (returnPut == null) {
                              Navigator.pop(context);
                              showAlertDialog(context, "Error",
                                  "Error while connecting to server, Please try again.",
                                  () {
                                Navigator.of(context).pop();
                              });
                            }
                            if (returnPut["success"] == "Y") {
                              BiometricLogin().clearPassword();
                              DbProvider().saveAuthTransaction(false);
                              DbProvider().saveAuthState(false);
                              BiometricLogin()
                                  .setPasswordBiometric(newPass.text);
                              DbProvider().saveAuthState(false);
                              Navigator.pop(context);
                              showAlertDialog(context, "Success",
                                  "Your Password has been changed!", () async {
                                CustomModal(context: context).loader();
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                var logData = pref.getString(
                                  'loginData',
                                );
                                var mappedLogData = [jsonDecode(logData!)];
                                mappedLogData[0]["is_active"] = "N";
                                pref.setString(
                                    "loginData", jsonEncode(mappedLogData[0]!));
                                Future.delayed(const Duration(seconds: 1), () {
                                  Navigator.pop(context);
                                  Variables.pageTrans(
                                      const LoginScreen(
                                        index: 1,
                                      ),
                                      context);
                                });
                              });
                            } else {
                              Navigator.pop(context);

                              showAlertDialog(
                                  context, "LuvPark", returnPut["msg"], () {
                                Navigator.of(context).pop();
                              });
                            }
                          });
                        }),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.10,
              ),
            ],
          ),
        ));
  }
}
