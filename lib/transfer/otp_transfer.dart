import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:pinput/pinput.dart';

// ignore: must_be_immutable
class OtpTransferScreen extends StatefulWidget {
  int otp;
  final String mobileNo;
  final bool? isForgotPassword;
  final Function(String)? onCallbackTap;
  bool? isUpdateProf;
  Map<String, dynamic>? parameters;

  OtpTransferScreen(
      {super.key,
      required this.otp,
      required this.mobileNo,
      required this.isForgotPassword,
      this.onCallbackTap});

  @override
  // ignore: no_logic_in_create_state
  State<OtpTransferScreen> createState() => _OtpTransferScreenState();
}

class _OtpTransferScreenState extends State<OtpTransferScreen>
    with TickerProviderStateMixin {
  Timer? timer;
  bool isOtpValid = true;
  String inputPin = "";

  int initialMinutes = 5;
  int minutes = 5;
  int seconds = 0;
  bool isRunning = false;
  bool canResend = false;
  @override
  void initState() {
    inputPin = "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTimers();
    });

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
    setState(() {
      minutes = initialMinutes;
      seconds = 0;
      isRunning = false;
      resendFunction();
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
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
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
          widget.otp = int.parse(returnData["otp"]);
          inputPin.isEmpty;
        });

        showAlertDialog(context, "Success",
            "OTP has been sent to your registered mobile number.", () {
          Navigator.of(context).pop();
          startTimers();
        });
      } else {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error", returnData["msg"], () {
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
    return CustomParentWidget(
        appbarColor: AppColor.primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 41,
                ),
                CustomDisplayText(
                  label: "Enter your One-Time-Pin",
                  fontWeight: FontWeight.w700,
                  color: AppColor.textHeaderLabelColor,
                  fontSize: 20,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text:
                              "We have sent an OTP to your registered\nmobile number",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: AppColor.textSecondaryColor,
                            fontSize: 14,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: " +63${widget.mobileNo}",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
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
                          label:
                              " $minutes:${seconds < 10 ? "0" : ""}$seconds ${minutes != 0 ? "minutes" : "seconds"}",
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
                      setState(() {
                        isOtpValid = false;
                      });
                      showAlertDialog(context, "Error",
                          "Invalid OTP code. Please try again.. Please try again.",
                          () {
                        Navigator.of(context).pop();
                      });
                      return;
                    }
                    setState(() {
                      isOtpValid = true;
                    });

                    if (mounted) {
                      if (widget.isForgotPassword!) {
                        widget.onCallbackTap!(inputPin);
                      } else {
                        widget.onCallbackTap!("");
                      }
                    }
                  },
                ),
                Container(
                  height: 10,
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
        ));
    // return Sizer(builder: (context, orientation, deviceType) {
    //   return MediaQuery(
    //     data: MediaQuery.of(context)
    //         .copyWith(textScaler: const TextScaler.linear(1)),
    //     child: WillPopScope(
    //       onWillPop: () async {
    //         showModalConfirmation(context, "Confirmation",
    //             "Do you want to close this page?", "Cancel", () {
    //           Navigator.of(context).pop();
    //         }, () async {
    //           Navigator.pop(context);
    //         });

    //         return false;
    //       },
    //       child: Scaffold(
    //         appBar: AppbarWidget(
    //           appbarColor: AppColor.bodyColor,
    //         ),
    //         body: SafeArea(
    //           child: Container(
    //             width: MediaQuery.of(context).size.width,
    //             height: MediaQuery.of(context).size.height,
    //             color: AppColor.bodyColor,
    //             child:  ),
    //         ),
    //       ),
    //     ),
    //   );
    // });
  }
}
