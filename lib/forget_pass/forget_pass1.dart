import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/api_keys.dart';
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
import 'package:luvpark/http_request/http_request_model.dart';
import 'package:luvpark/transfer/otp_transfer.dart';

class ForgetPass1 extends StatefulWidget {
  final String mobileNumber;
  const ForgetPass1({super.key, required this.mobileNumber});

  @override
  State<ForgetPass1> createState() => _ForgetPass1State();
}

class _ForgetPass1State extends State<ForgetPass1> {
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController password = TextEditingController();
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
  bool isLoadingPage = true;
  int passStrength = 0;
  // ignore: prefer_typing_uninitialized_variables

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  void getUserInfo() async {
    setState(() {
      mobileNumber.text = widget.mobileNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
      appbarColor: AppColor.bodyColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back),
              ),
              Container(
                height: 40,
              ),
              const Image(
                height: 100,
                width: 100,
                fit: BoxFit.contain,
                image: AssetImage(
                  "assets/images/forget_pass_image.png",
                ),
              ),
              Container(
                height: 20,
              ),
              CustomDisplayText(
                label: "Forgot Password",
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 20,
              ),
              CustomDisplayText(
                label: "Create a new strong password",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0x75353536),
                height: 0,
                letterSpacing: -0.28,
                maxLines: 1,
              ),
              Container(
                height: 20,
              ),
              LabelText(text: "Mobile Number"),
              CustomMobileNumber(
                labelText: "Mobile No",
                controller: mobileNumber,
                isReadOnly: true,
                inputFormatters: [Variables.maskFormatter],
              ),
              LabelText(text: "New Password"),
              CustomTextField(
                labelText: "Password",
                controller: password,
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
                  onTap: () async {
                    // ignore: use_build_context_synchronously

                    if (mobileNumber.text.isEmpty || password.text.isEmpty) {
                      return;
                    }

                    CustomModal(context: context).loader();

                    Map<String, dynamic> parameters = {
                      "mobile_no": "63${widget.mobileNumber}",
                    };

                    HttpRequest(
                            api: ApiKeys.gApiSubFolderPostReqOtpShare,
                            parameters: parameters)
                        .post()
                        .then(
                      (retvalue) {
                        if (retvalue == "No Internet") {
                          Navigator.pop(context);
                          showAlertDialog(context, "Error",
                              "Please check your internet connection and try again.",
                              () {
                            Navigator.pop(context);
                          });
                          return;
                        }
                        if (retvalue == null) {
                          Navigator.pop(context);
                          showAlertDialog(context, "Error",
                              "Error while connecting to server, Please try again.",
                              () {
                            Navigator.of(context).pop();
                          });
                        } else {
                          if (retvalue["success"] == "Y") {
                            Navigator.of(context).pop();
                            Variables.pageTrans(
                                OtpTransferScreen(
                                  otp: int.parse(retvalue["otp"].toString()),
                                  mobileNo: widget.mobileNumber,
                                  isForgotPassword: true,
                                  onCallbackTap: (myOtp) {
                                    submitData(myOtp.toString());
                                  },
                                ),
                                context);
                          } else {
                            Navigator.of(context).pop();
                            showAlertDialog(context, "Error", retvalue["msg"],
                                () {
                              Navigator.of(context).pop();
                            });
                          }
                        }
                      },
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void submitData(otp) {
    CustomModal(context: context).loader();
    var parameter = {
      "mobile_no": "63${widget.mobileNumber}",
      "otp": otp.toString(),
      "new_pwd": password.text,
    };

    HttpRequest(
            api: ApiKeys.gApiLuvParkPostForgetPassNotVerified,
            parameters: parameter)
        .post()
        .then((returnPost) async {
      if (returnPost == "No Internet") {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });

        return;
      }
      if (returnPost == null) {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      } else {
        if (returnPost["success"] == 'Y') {
          Navigator.of(context).pop();
          showAlertDialog(context, "Success",
              "You have successfully changed your password, to proceed please login.",
              () {
            Navigator.of(context).pop();
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          });
        } else {
          Navigator.pop(context);
          showAlertDialog(context, "Error", returnPost['msg'], () {
            Navigator.of(context).pop();
          });
        }
      }
    });
  }
}
