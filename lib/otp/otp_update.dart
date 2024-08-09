import 'dart:async';

import 'package:flutter/material.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:pinput/pinput.dart';

//Update Profile
// ignore: must_be_immutable
class OtpTransferScreen extends StatefulWidget {
  int otp;
  final String mobileNo;
  Function? onCallbackTap;
  bool? isUpdateProf;
  Map<String, dynamic>? parameters;

  OtpTransferScreen(
      {super.key,
      required this.otp,
      required this.mobileNo,
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
            "Error while connecting to server, Please try again.", () {
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
                CustomTitle(
                  text: "Enter your One-Time-Pin",
                  fontSize: 20,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text:
                              "We have sent an OTP to your registered\nmobile number",
                          style: paragraphStyle(),
                          children: <TextSpan>[
                            TextSpan(
                                text: " +${widget.mobileNo}",
                                style: paragraphStyle()),
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
                      CustomParagraph(
                        text: " Incorrect pin",
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ],
                  ),
                Container(
                  height: 40,
                ),
                Center(
                  child: CustomTitle(
                    text: "Didn't you receive any code?",
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
                      CustomParagraph(
                        text: minutes != 0 || seconds != 0
                            ? "Resend OTP in"
                            : "I didn't get a code",
                        fontSize: 14,
                        color: AppColor.primaryColor,
                      ),
                      if (minutes != 0 || seconds != 0)
                        CustomParagraph(
                          text:
                              " $minutes:${seconds < 10 ? "0" : ""}$seconds ${minutes != 0 ? "minutes" : "seconds"}",
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
                          "Invalid OTP code. Please try again.", () {
                        Navigator.of(context).pop();
                      });
                      return;
                    }
                    setState(() {
                      isOtpValid = true;
                    });

                    if (mounted) {
                      widget.onCallbackTap!();
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
  }
}
