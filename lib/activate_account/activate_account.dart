import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/http_request/http_request_model.dart';
import 'package:luvpark/login/login.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class ActivateAccountScreen extends StatefulWidget {
  final String? mobileNo;
  final String? password;
  const ActivateAccountScreen({
    super.key,
    required this.mobileNo,
    required this.password,
  });

  @override
  // ignore: no_logic_in_create_state
  State<ActivateAccountScreen> createState() => _ActivateAccountScreenState();
}

class _ActivateAccountScreenState extends State<ActivateAccountScreen>
    with TickerProviderStateMixin {
  TextEditingController pinController = TextEditingController();
  Duration countdownDuration = const Duration(minutes: 5);
  Duration duration = const Duration();
  bool isCountdown = false;
  Timer? timer;
  double? mediaQueryWidth;
  String twoDigets(int n) => n.toString().padLeft(2, '0');
  BuildContext? mainContext;
  int? screenOtp;
  bool isRequested = false;
  String inputPin = "";
  bool isOtpValid = true;
  @override
  void initState() {
    isCountdown = false;
    inputPin = "";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      resendFunction();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void resetTimer() {
    isCountdown = true;

    setState(() {
      duration = countdownDuration;
    });
  }

  void addTime() {
    final addSeconds = isCountdown ? -1 : 1;

    setState(() {
      final seconds = duration.inSeconds + addSeconds;

      if (seconds == 0) {
        timer?.cancel();
        isCountdown = false;
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  void resendFunction() {
    CustomModal(context: context).loader();
    var otpData = {
      "mobile_no": widget.mobileNo.toString(),
      "reg_type": "REQUEST_OTP"
    };

    HttpRequest(api: ApiKeys.gApiSubFolderPutOTP, parameters: otpData)
        .put()
        .then((returnData) async {
      if (returnData == "No Internet") {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });

        return;
      }
      if (returnData == null) {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });

        return;
      }

      if (returnData["success"] == 'Y') {
        Navigator.of(context).pop();

        setState(() {
          screenOtp = int.parse(returnData["otp"]);
          isRequested = true;
        });
        startTimer();
        resetTimer();

        showAlertDialog(context, "Success",
            "OTP has been sent to your registered mobile number.", () {
          Navigator.of(context).pop();
        });
      } else {
        Navigator.of(context).pop();
        showAlertDialog(context, "LuvPark", returnData["msg"], () {
          Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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

    final minutes = twoDigets(duration.inMinutes.remainder(60));
    final seconds = twoDigets(duration.inSeconds.remainder(60));
    // ignore: unused_local_variable
    var mmaincontext = context;
    if (MediaQuery.of(context).size.width > 400) {
      mediaQueryWidth = 400;
    } else {
      mediaQueryWidth = MediaQuery.of(context).size.width;
    }
    bool isShowKeyboard = MediaQuery.of(context).viewInsets.bottom == 0;

    return CustomParentWidget(
      appbarColor: Colors.white,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: AppColor.bodyColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTitle(
                    text: "Activate Account",
                    fontSize: 20,
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          !isRequested
                              ? TextSpan(
                                  text:
                                      "Your account is not yet activated.\n Please confirm below",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.normal,
                                    color: AppColor.textSecondaryColor,
                                    fontSize: 14,
                                  ),
                                )
                              : TextSpan(
                                  text: "We have sent you a ",
                                  style: GoogleFonts.varela(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  children: <TextSpan>[
                                      TextSpan(
                                        text: "One Time Password,",
                                        style: Platform.isAndroid
                                            ? GoogleFonts.dmSans(
                                                color: AppColor.primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              )
                                            : TextStyle(
                                                color: AppColor.primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "SFProTextReg",
                                              ),
                                      ),
                                      TextSpan(
                                          text: " please confirm below.",
                                          style: Platform.isAndroid
                                              ? GoogleFonts.dmSans(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                )
                                              : TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  fontFamily: "SFProTextReg",
                                                )),
                                    ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Directionality(
                    // Specify direction if desired
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      length: 6,
                      controller: pinController,
                      androidSmsAutofillMethod:
                          AndroidSmsAutofillMethod.smsUserConsentApi,
                      listenForMultipleSmsOnAndroid: true,
                      defaultPinTheme: defaultPinTheme,
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
                      // onCompleted: (pin) {
                      //   if (pin.length == 6) {
                      //     setState(() {
                      //       inputPin = pin;
                      //     });
                      //   }
                      // },
                      // onChanged: (value) {
                      //   setState(() {
                      //     inputPin = "";
                      //   });
                      // },
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
                          border: Border.all(
                              color: AppColor.primaryColor, width: 2),
                        ),
                      ),
                      submittedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColor.bodyColor,
                          border: Border.all(
                              color: isOtpValid
                                  ? AppColor.primaryColor
                                  : Colors.red,
                              width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Don't receive OTP? ",
                          style: GoogleFonts.varela(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        isCountdown
                            ? TextSpan(
                                text: "Resend OTP in ($minutes:$seconds)",
                                style: GoogleFonts.varela(
                                  color: AppColor.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : TextSpan(
                                text: "Resend",
                                style: GoogleFonts.varela(
                                    color: AppColor.primaryColor),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    resendFunction();
                                  },
                              ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  CustomButton(
                      label: "Confirm",
                      onTap: () async {
                        if (pinController.text.isEmpty) return;
                        // ignore: use_build_context_synchronously
                        CustomModal(context: context).loader();
                        var otpData = {
                          "mobile_no": widget.mobileNo.toString(),
                          "reg_type": "VERIFY",
                          "otp": int.parse(pinController.text)
                        };

                        HttpRequest(
                                api: ApiKeys.gApiSubFolderPutOTP,
                                parameters: otpData)
                            .put()
                            .then((returnData) async {
                          if (returnData == "No Internet") {
                            Navigator.of(context).pop();
                            showAlertDialog(context, "Error",
                                'Please check your internet connection and try again.',
                                () {
                              Navigator.of(context).pop();
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
                            Navigator.of(context).pop();
                            // ignore: use_build_context_synchronously
                            showAlertDialog(context, "Success",
                                "Congratulations! Your account has been activated!",
                                () async {
                              Navigator.of(context).pop();
                              Variables.pageTrans(
                                  LoginScreen(index: 1), context);
                            });
                          } else {
                            Navigator.of(context).pop();
                            showAlertDialog(context, "Error",
                                "Invalid OTP code. Please try again.. Please try again.",
                                () {
                              pinController.text = "";
                              Navigator.of(context).pop();
                            });
                          }
                        });
                      }),
                  !isShowKeyboard
                      ? const Text("")
                      : Container(
                          height: 10,
                        ),
                  !isShowKeyboard
                      ? const Text("")
                      : CustomButtonCancel(
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
        ),
      ),
    );
  }
}
