import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/password_indicator.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/otp/otp_screen.dart';

// ignore: must_be_immutable
class ResetPassword extends StatefulWidget {
  // int otp;
  int? seqId;
  int? seqNo;
  String mobileNo;
  String? seca;
  ResetPassword({
    super.key,
    // required this.otp,
    required this.mobileNo,
    required this.seqId,
    required this.seca,
    required this.seqNo,
  });

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool? newPasswordVisibility = true;
  TextEditingController newPass = TextEditingController();
  bool? passwordVisibility = true;
  bool? hasEightCharacters = false;
  bool? has1Number = false;
  bool? hasUpperCase = false;
  bool isValidated = false;
  bool isObscure = true;
  int passStrength = 0;
  final numericRegex = RegExp(r'[0-9]');
  // @override
  // void initState() {
  //   newPass = TextEditingController();
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   newPass.dispose();
  //   super.dispose();
  // }

  void onPasswordChange(String password) {
    final numericRegex = RegExp(r'[0-9]');
    final upperCaseRegex = RegExp(r'[A-Z]');
    // signupDetails = [];
    has1Number = false;
    hasEightCharacters = false;
    hasUpperCase = false;

    if (password.length >= 8) {
      setState(() {
        hasEightCharacters = true;
      });
    }
    if (numericRegex.hasMatch(password)) {
      setState(() {
        has1Number = true;
      });
    }
    if (upperCaseRegex.hasMatch(password)) {
      setState(() {
        hasUpperCase = true;
      });
    }
    if (hasEightCharacters! && has1Number! && hasUpperCase!) {
      setState(() {
        isValidated = true;
      });
    } else {
      setState(() {
        isValidated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //bool isShowKeyboard = MediaQuery.of(context).viewInsets.bottom == 0;
    return CustomParent1Widget(
        appBarheaderText: "New Password",
        appBarIconClick: () {
          Navigator.of(context).pop();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      const Expanded(
                        child: CustomDisplayText(
                          label:
                              "Please provide a strong new password to protect your account.",
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF723B13),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              LabelText(text: "Password"),
              CustomTextField(
                labelText: "Password",
                controller: newPass,
                isObscure: isObscure,
                suffixIcon: isObscure ? Icons.visibility : Icons.visibility_off,
                onIconTap: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
                onChange: (value) async {
                  //  onPasswordChange(value);

                  setState(() {
                    passStrength = Variables.getPasswordStrength(value);
                  });
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
                      const CustomDisplayText(
                        label:
                            "The password should have a minimum of 8 characters, including at least one uppercase letter and a number.",
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 141, 140, 140),
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .1,
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

                        if (newPass.text.isEmpty) {
                          showAlertDialog(
                              context, "Warning", "Password must not be empty.",
                              () {
                            Navigator.of(context).pop();
                          });
                          return;
                        }

                        var resetParam = {
                          "mobile_no": widget.mobileNo,
                        };

                        CustomModal(context: context).loader();
                        HttpRequest(
                                api: ApiKeys.gApiSubFolderPutForgotPass,
                                parameters: resetParam)
                            .put()
                            .then((returnVal) {
                          if (returnVal == "No Internet") {
                            Navigator.of(context).pop();

                            showAlertDialog(context, "Error",
                                "Please check your internet connection and try again.",
                                () {
                              Navigator.pop(context);
                            });

                            return;
                          }

                          if (returnVal == null) {
                            Navigator.of(context).pop();
                            showAlertDialog(context, "Error",
                                "Error while connecting to server, Please try again.",
                                () {
                              Navigator.of(context).pop();
                            });

                            return;
                          } else {
                            if (returnVal["success"] == 'Y') {
                              Navigator.of(context).pop();
                              showAlertDialog(context, "LuvPark",
                                  "We have sent a confirmation code\nto your mobile number.",
                                  () {
                                Navigator.of(context).pop();

                                Variables.pageTrans(
                                    OTPScreen(
                                      otp: int.parse(returnVal["otp"]),
                                      mobileNo: widget.mobileNo,
                                      reqType: "RP",
                                      seqId: widget.seqId,
                                      seca: widget.seca,
                                      seqNo: widget.seqNo,
                                      newPass: newPass.text,
                                    ),
                                    context);
                              });
                            } else {
                              Navigator.of(context).pop();
                              showAlertDialog(
                                  context, "Error", returnVal["msg"], () {
                                Navigator.of(context).pop();
                              });
                            }
                          }
                        });
                      },
              ),
            ],
          ),
        ));
  }
}
