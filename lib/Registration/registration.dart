import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/Registration/class/registration_class.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/password_indicator.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/webview/webview.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> page2Key = GlobalKey<FormState>();
  final GlobalKey<FormState> page3Key = GlobalKey<FormState>();
  bool isValidatedS1 = false;
  bool isValidatedS2 = false;
  bool isValidatedS3 = false;
  int totalPages = 3;
  TextEditingController firstName = TextEditingController();
  TextEditingController middleName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController birthday = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController paswordStt = TextEditingController();
  bool isInternetConnected = true;
  String imageBase64 = "";
  var dataPI = [];
  List secSubData = [];
  //page1param
  TextEditingController referralcode = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController secA1 = TextEditingController();
  TextEditingController secA2 = TextEditingController();
  TextEditingController secA3 = TextEditingController();
  TextEditingController secId1 = TextEditingController();
  TextEditingController secId2 = TextEditingController();
  TextEditingController secId3 = TextEditingController();
  bool? has1Number = false;
  bool? hasUpperCase = false;
  bool? hasEightCharacters = false;
  bool? hasText = false;
  bool isObscure = true;
  bool isShowPass = false;
  final numericRegex = RegExp(r'[0-9]');
  final upperCaseRegex = RegExp(r'[A-Z]');
  bool isAgree = false;
  bool isClickTerms = false;
  int passStrength = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isShowKeyboard = MediaQuery.of(context).viewInsets.bottom == 0;
    return CustomParent1Widget(
        appBarheaderText: "Create Account",
        appBarIconClick: () {
          FocusScope.of(context).requestFocus(FocusNode());
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 20,
                ),
                const CustomDisplayText(
                  label:
                      "Register your mobile number. We'll send you a code to help us secure your account.",
                  fontWeight: FontWeight.normal,
                  color: Colors.black54,
                  fontSize: 14,
                ),
                Container(
                  height: 20,
                ),
                LabelText(text: "Mobile Number"),
                CustomMobileNumber(
                  labelText: 'Mobile No',
                  inputFormatters: [Variables.maskFormatter],
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  controller: mobile,
                  onChange: (value) {},
                ),
                LabelText(text: "Password"),
                CustomTextField(
                  labelText: "Password",
                  controller: paswordStt,
                  isObscure: isShowPass,
                  keyboardType: TextInputType.name,
                  suffixIcon:
                      isShowPass ? Icons.visibility : Icons.visibility_off,
                  onIconTap: () {
                    setState(() {
                      isShowPass = !isShowPass;
                    });
                  },
                  onChange: (value) async {
                    setState(() {
                      passStrength = Variables.getPasswordStrength(value);
                      password.text = passStrength.toString();
                    });
                  },
                ),
                Container(
                  height: 10,
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
                        LabelText(text: "Password Strength"),
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
                        if (isShowKeyboard)
                          Container(
                            height: 20,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                // LabelText(text: "Referral Code"),
                // Stack(
                //   alignment: Alignment.centerRight,
                //   children: [
                //     CustomTextField(
                //       labelText: 'Enter Referral Code',
                //       controller: referralcode,
                //     ),
                //     InkWell(
                //       onTap: () {
                //         FlutterClipboard.paste().then((value) {
                //           setState(() {
                //             if (value.isNotEmpty) {
                //               referralcode.text = value;
                //             } else {
                //               ScaffoldMessenger.of(context).showSnackBar(
                //                 SnackBar(
                //                   content: Text('Clipboard is empty'),
                //                 ),
                //               );
                //             }
                //           });
                //         }).catchError((error) {});
                //       },
                //       child: Padding(
                //         padding: const EdgeInsets.only(
                //           right: 10,
                //           bottom: 8,
                //         ),
                //         child: FaIcon(
                //           FontAwesomeIcons.paste,
                //           size: 20,
                //           color: Colors.grey.shade700,
                //         ),
                //       ),
                //     )
                //   ],
                // ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            isAgree = !isAgree;
                          });
                        },
                        child: isAgree
                            ? Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.grey.shade300,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Icon(
                                    Icons.check_outlined,
                                    color: AppColor.primaryColor,
                                    weight: 4,
                                    size: 16,
                                  ),
                                ),
                              )
                            : Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.grey.shade300,
                                ),
                              ),
                      ),
                      Container(
                        width: 10,
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: "Agree with ",
                                  style: Platform.isAndroid
                                      ? GoogleFonts.dmSans(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14)
                                      : TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          fontFamily: "SFProTextReg",
                                        ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "Terms & Conditions",
                                      style: Platform.isAndroid
                                          ? GoogleFonts.dmSans(
                                              color: AppColor.primaryColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)
                                          : TextStyle(
                                              color: AppColor.primaryColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              fontFamily: "SFProTextReg",
                                            ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          Variables.pageTrans(WebviewPage(
                                            hasAgree: true,
                                            onAgree: () {
                                              Navigator.pop(context);
                                              setState(() {
                                                isAgree = true;
                                              });
                                            },
                                            urlDirect:
                                                "https://luvpark.ph/terms-of-use/",
                                            label: "luvpark",
                                            isBuyToken: false,
                                          ));
                                        },
                                    )
                                  ]),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 20,
                ),
                CustomButton(
                  color: AppColor.primaryColor,
                  label: "Submit",
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());

                    if (formKey.currentState!.validate()) {
                      CustomModal(context: context).loader();
                      if (Variables.getPasswordStrengthText(passStrength) !=
                          "Strong Password") {
                        Navigator.pop(context);
                        showAlertDialog(context, "Attention",
                            "For enhanced security, please create a stronger password.",
                            () {
                          Navigator.pop(context);
                        });
                        return;
                      }
                      if (isAgree) {
                        Map<String, dynamic> parameters = {
                          "mobile_no":
                              "63${mobile.text.toString().replaceAll(" ", "")}",
                          "pwd": paswordStt.text,
                        };
                        Navigator.pop(context);
                        showModalConfirmation(context, "Confirmation",
                            "Are you sure you want to proceed?", "", "Yes", () {
                          Navigator.of(context).pop();
                        }, () async {
                          Navigator.of(context).pop();
                          SubmitData().submitRegistration(context, parameters);
                        });
                      } else {
                        Navigator.pop(context);
                        showAlertDialog(context, "Attention",
                            "Your acknowledgement of our terms & conditions is required before you can continue.",
                            () {
                          Navigator.pop(context);
                        });
                      }
                    }
                  },
                ),
                Container(
                  height: 20,
                ),
              ],
            ),
          ),
        ));
  }
}
