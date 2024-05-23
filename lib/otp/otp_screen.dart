import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/Registration/success_register.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/login/login.dart';
import 'package:pinput/pinput.dart';

// ignore: must_be_immutable
class OTPScreen extends StatefulWidget {
  int? otp;
  int? seqId;
  String? seca;
  int? seqNo;
  String? mobileNo;
  String? reqType;
  String? newPass;
  OTPScreen({
    super.key,
    required this.otp,
    required this.mobileNo,
    required this.reqType,
    required this.seca,
    required this.seqId,
    required this.seqNo,
    required this.newPass,
  });

  @override
  // ignore: no_logic_in_create_state
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with TickerProviderStateMixin {
  bool isLoadingPage = true;
  bool isOtpValid = true;
  String inputPin = "";

  int secondsRemaining = 300; // Initial countdown duration in seconds
  Timer? timer;
  int initialMinutes = 5;
  int minutes = 5;
  int seconds = 0;
  bool isRunning = false;
  @override
  void initState() {
    super.initState();

    // Start the countdown timer
    startTimers();
    getUserData();
  }

  void startTimers() {
    const oneSecond = Duration(seconds: 1);
    timer = Timer.periodic(oneSecond, (timer) {
      if (minutes == 0 && seconds == 0) {
        // Timer has reached 0
        timer.cancel(); // Stop the timer
        setState(() {
          isRunning = false;
        });
      } else if (seconds == 0) {
        setState(() {
          minutes--;
          seconds = 59;
        });
      } else {
        setState(() {
          seconds--;
        });
      }
    });
    setState(() {
      isRunning = true;
    });
  }

  void restartTimer() {
    if (timer!.isActive) {
      timer!.cancel();
    }

    resendFunction();
  }

  getUserData() async {
    setState(() {
      isLoadingPage = false;
    });
  }

  void resendFunction() {
    CustomModal(context: context).loader();
    setState(() {
      widget.otp = 0;
    });
    if (widget.reqType == "RP") {
      var forgotParam = {
        "mobile_no": widget.mobileNo,
      };
      HttpRequest(
              api: ApiKeys.gApiSubFolderPutForgotPass, parameters: forgotParam)
          .put()
          .then((forgotPassReturnVal) {
        if (forgotPassReturnVal == null) {
          Navigator.of(context).pop();
          showAlertDialog(context, "Error",
              "Error while connecting to server, Please try again.", () {
            Navigator.of(context).pop();
          });

          return;
        }
        if (forgotPassReturnVal["success"] == 'Y') {
          setState(() {
            widget.otp = 0;
          });
          Navigator.of(context).pop();
          setState(() {
            widget.otp = int.parse(forgotPassReturnVal["otp"]);
            minutes = initialMinutes;
            seconds = 0;
            inputPin = "";
            isRunning = false;
          });
          startTimers();
          showAlertDialog(context, "Success",
              "OTP has been sent to your registered mobile number.", () {
            Navigator.of(context).pop();
          });
        } else {
          Navigator.of(context).pop();
          showAlertDialog(context, "Error", forgotPassReturnVal["msg"], () {
            Navigator.of(context).pop();
          });
        }
      });
    } else {
      var otpData = {"mobile_no": widget.mobileNo, "reg_type": "REQUEST_OTP"};
      HttpRequest(api: ApiKeys.gApiSubFolderPutOTP, parameters: otpData)
          .put()
          .then((otpData) {
        if (otpData == null) {
          Navigator.of(context).pop();
          showAlertDialog(context, "Error",
              "Error while connecting to server, Please try again.", () {
            Navigator.of(context).pop();
          });

          return;
        }
        if (otpData["success"] == 'Y') {
          Navigator.of(context).pop();
          setState(() {
            widget.otp = int.parse(otpData["otp"]);
            inputPin = "";
            minutes = initialMinutes;
            seconds = 0;
            isRunning = false;
          });
          startTimers();
          showAlertDialog(context, "Success",
              "OTP has been sent to your registered mobile number.", () {
            Navigator.of(context).pop();
          });
        } else {
          Navigator.of(context).pop();
          showAlertDialog(context, "Error", otpData["msg"], () {
            Navigator.of(context).pop();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getUserData();
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(
        fontSize: 24,
        color: isOtpValid ? AppColor.primaryColor : Colors.red,
      ),
      decoration: BoxDecoration(
        border: Border.all(
            color: inputPin.isEmpty
                ? AppColor.borderColor
                : isOtpValid
                    ? AppColor.primaryColor
                    : Colors.red,
            width: 2),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
    );

    return CustomParentWidget(
      appbarColor: AppColor.bodyColor,
      onPop: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 41,
              ),
              CustomDisplayText(
                  label: "Enter verification code",
                  fontWeight: FontWeight.w700,
                  color: AppColor.textHeaderLabelColor,
                  fontSize: 20),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text:
                            "We have sent an OTP to your registered\nmobile number",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          color: AppColor.textSecondaryColor,
                          fontSize: 14,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: " +${widget.mobileNo}",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: AppColor.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ]),
                  ],
                ),
              ),
              Container(
                height: 21,
              ),
              Directionality(
                // Specify direction if desired
                textDirection: TextDirection.ltr,
                child: Pinput(
                  length: 6,
                  androidSmsAutofillMethod:
                      AndroidSmsAutofillMethod.smsUserConsentApi,
                  listenForMultipleSmsOnAndroid: true,
                  defaultPinTheme: defaultPinTheme,
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (pin) {
                    if (pin.length == 6) {
                      setState(() {
                        inputPin = pin;
                      });
                    }
                  },
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        isOtpValid = true;
                        inputPin = "";
                      });
                    }
                  },
                  cursor: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        width: 22,
                        height: 1,
                        color: AppColor.primaryColor,
                      ),
                    ],
                  ),
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      borderRadius: BorderRadius.circular(5),
                      border:
                          Border.all(color: AppColor.primaryColor, width: 2),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      borderRadius: BorderRadius.circular(5),
                      color: AppColor.bodyColor,
                      border: Border.all(
                          color:
                              isOtpValid ? AppColor.primaryColor : Colors.red,
                          width: 2),
                    ),
                  ),

                  // errorPinTheme: defaultPinTheme.copyBorderWith(
                  //   border: Border.all(color: Colors.redAccent),
                  // ),
                ),
              ),
              Container(
                height: 11,
              ),
              if (!isOtpValid)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.warning_outlined,
                      size: 14,
                      color: Colors.red,
                    ),
                    Text(
                      " Incorrect pin",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              Container(
                height: 40,
              ),
              Center(
                child: CustomDisplayText(
                  label: "Didn't you receive any code?",
                  fontWeight: FontWeight.w600,
                  color: AppColor.textHeaderLabelColor,
                  fontSize: 14,
                ),
              ),
              Container(
                height: 2,
              ),
              InkWell(
                onTap: () {
                  if (minutes <= 2) {
                    restartTimer();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomDisplayText(
                      label: minutes != 0 || seconds != 0
                          ? "Resend OTP in"
                          : "I didn't get a code",
                      fontWeight: FontWeight.w600,
                      color: AppColor.primaryColor,
                      fontSize: 14,
                    ),
                    if (minutes != 0 || seconds != 0)
                      CustomDisplayText(
                        label: "($minutes:${seconds < 10 ? "0" : ""}$seconds)",
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryColor,
                        fontSize: 14,
                      ),
                  ],
                ),
              ),
              Container(
                height: 39,
              ),
              CustomButton(
                label: "Confirm",
                onTap: () {
                  if (inputPin.isEmpty) return;
                  if ((int.parse(inputPin.toString()) !=
                          int.parse(widget.otp.toString())) ||
                      inputPin.length != 6) {
                    showAlertDialog(context, "Error",
                        "Invalid OTP code. Please try again.. Please try again.",
                        () {
                      Navigator.of(context).pop();
                    });
                    return;
                  }

                  CustomModal(context: context).loader();
                  if (widget.reqType.toString() == "RP") {
                    if (widget.otp == int.parse(inputPin)) {
                      var resetParam = {
                        "mobile_no": widget.mobileNo,
                        "new_pwd": widget.newPass,
                        "otp": int.parse(inputPin),
                      };
                      HttpRequest(
                              api: ApiKeys.gApiSubFolderPostPutGetResetPass,
                              parameters: resetParam)
                          .put()
                          .then((returnPost) {
                        if (returnPost == "No Internet") {
                          Navigator.pop(context);
                          showAlertDialog(context, "Error",
                              "Please check your internet connection and try again.",
                              () {
                            Navigator.pop(context);
                          });
                          return;
                        }
                        if (returnPost == null) {
                          Navigator.pop(context);
                          showAlertDialog(context, "Error",
                              "Error while connecting to server, Please try again.",
                              () {
                            Navigator.of(context).pop();
                          });
                        } else {
                          if (returnPost["success"] == 'Y') {
                            //  BiometricLogin().clearPassword();
                            Navigator.of(context).pop();
                            showAlertDialog(context, "Success",
                                "You have succesfully changed your password. Please login to continue.",
                                () {
                              setState(() {
                                timer!.cancel();
                                // DbProvider().saveAuthState(false);
                                // BiometricLogin()
                                //     .setPasswordBiometric(widget.newPass!);
                              });
                              Navigator.of(context).pop();

                              Variables.pageTrans(
                                  const LoginScreen(
                                    index: 1,
                                  ),
                                  context);
                            });
                          } else {
                            Navigator.pop(context);
                            showAlertDialog(context, "Error", returnPost['msg'],
                                () {
                              Navigator.of(context).pop();
                            });
                          }
                        }
                      });
                    } else {
                      Navigator.of(context).pop();

                      showAlertDialog(context, "Error",
                          "Invalid OTP code. Please try again.. Please try again.",
                          () {
                        Navigator.of(context).pop();
                      });
                      return;
                    }
                  } else {
                    //REGISTER CONFIRMATION
                    //ACCOUNT ACTIVATION
                    if (widget.otp == int.parse(inputPin)) {
                      var otpData = {
                        "mobile_no": widget.mobileNo,
                        "reg_type": "VERIFY",
                        "otp": int.parse(inputPin)
                      };

                      HttpRequest(
                              api: ApiKeys.gApiSubFolderPutOTP,
                              parameters: otpData)
                          .put()
                          .then((returnData) async {
                        if (returnData == "No Internet") {
                          Navigator.pop(context);
                          showAlertDialog(context, "Error",
                              "Please check your internet connection and try again.",
                              () {
                            Navigator.pop(context);
                          });
                          return;
                        }
                        if (returnData == null) {
                          Navigator.of(context).pop();
                          showAlertDialog(context, "Error",
                              "Error while connecting to server, Please try again.",
                              () {
                            Navigator.of(context).pop();
                          });

                          return;
                        }
                        if (returnData["success"] == 'Y') {
                          timer!.cancel();
                          Navigator.of(context).pop();
                          Variables.pageTrans(
                              SuccessRegistration(
                                mobile: widget.mobileNo!,
                                acctStatusTxt: "Registered",
                              ),
                              context);
                        } else {
                          Navigator.of(context).pop();
                          showAlertDialog(context, "Error", returnData["msg"],
                              () {
                            Navigator.of(context).pop();
                          });
                        }
                      });
                    } else {
                      Navigator.of(context).pop();
                      showAlertDialog(context, "Error",
                          'Invalid OTP code. Please try again.. Please try again.',
                          () {
                        Navigator.of(context).pop();
                      });
                    }
                  }
                },
              ),
              Container(
                height: 13,
              ),
              CustomButtonCancel(
                  color: AppColor.btnDisabled,
                  textColor: const Color(0xFF2563EB),
                  label: "Cancel",
                  onTap: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
