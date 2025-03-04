// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart' as dtTime;
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:luvpark/custom_widgets/vertical_height.dart';
import 'package:pinput/pinput.dart';

import '../auth/authentication.dart';
import '../custom_widgets/alert_dialog.dart';
import '../functions/functions.dart';
import '../http/api_keys.dart';
import '../http/http_request.dart';

class OtpFieldScreen extends StatefulWidget {
  final dynamic arguments;
  const OtpFieldScreen({super.key, this.arguments});

  @override
  State<OtpFieldScreen> createState() => _OtpFieldScreenState();
}

class _OtpFieldScreenState extends State<OtpFieldScreen> {
  TextEditingController pinController = TextEditingController();
  Duration countdownDuration = const Duration(minutes: 2);

  Timer? timer;
  bool isLoading = false;
  bool isRequested = false;
  bool isNetConn = true;
  bool isLoadingPage = true;
  String inputPin = "";
  bool isOtpValid = true;
  bool isRunning = false;
  int otpCode = 0;
  Duration paramOtpExp =
      Duration(seconds: 0); // Default value to prevent null errors

  @override
  void initState() {
    pinController = TextEditingController();
    paramOtpExp =
        widget.arguments["time_duration"] ?? Duration(minutes: 3, seconds: 59);

    startCountdown();

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startCountdown() {
    if (paramOtpExp.inMilliseconds <= 0) return; // Prevent running if already 0

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (paramOtpExp.inSeconds <= 0) {
        t.cancel();
      } else {
        setState(() {
          paramOtpExp -= const Duration(seconds: 1);
        });
      }
    });

    print("paramOtpExp $paramOtpExp");
  }

  String formatDuration(Duration d) {
    String minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  void getTmrStat() async {
    await Authentication().enableTimer(false);
  }

  void getOtpRequest() async {
    setState(() {
      inputPin = "";
    });
    CustomDialog().loadingDialog(Get.context!);
    DateTime timeNow = await Functions.getTimeNow();
    var otpData = widget.arguments["req_otp_param"];
    HttpRequest(api: ApiKeys.postGenerateOtp, parameters: otpData)
        .postBody()
        .then((returnData) async {
      if (returnData == "No Internet") {
        setState(() {
          inputPin = "";
          isLoadingPage = false;
          isNetConn = false;
        });
        Get.back();
        CustomDialog().errorDialog(Get.context!, "Error",
            "Please check your internet connection and try again.", () {
          Get.back();
        });

        return;
      }
      if (returnData == null) {
        setState(() {
          inputPin = "";
          isLoadingPage = false;
          isNetConn = true;
        });
        Get.back();
        CustomDialog().errorDialog(Get.context!, "Error",
            "Error while connecting to server, Please try again.", () {
          Get.back();
        });

        return;
      }

      if (returnData["success"] == 'Y') {
        Get.back();
        DateTime timeExp = dtTime.DateFormat("yyyy-MM-dd hh:mm:ss a")
            .parse(returnData["otp_exp_dt"].toString());
        DateTime otpExpiry = DateTime(timeExp.year, timeExp.month, timeExp.day,
            timeExp.hour, timeExp.minute, timeExp.millisecond);

        // Calculate difference
        Duration difference = otpExpiry.difference(timeNow);

        setState(() {
          isLoadingPage = false;
          isNetConn = true;

          inputPin = "";

          otpCode = int.parse(returnData["otp"].toString());
          isRequested = true;
          paramOtpExp = difference;
        });

        startCountdown();

        getTmrStat();
      } else {
        setState(() {
          inputPin = "";
          isLoadingPage = false;
          isNetConn = true;
        });
        Get.back();
        CustomDialog().errorDialog(Get.context!, "LuvPark", returnData["msg"],
            () {
          Get.back();
        });
        return;
      }
    });
  }

  void onInputChanged(String value) {
    inputPin = value;

    if (int.parse(pinController.text) == otpCode) {
      isOtpValid = true;
    } else {
      isOtpValid = false;
    }
    setState(() {});
  }

  void restartTimer() {
    if (timer!.isActive) {
      setState(() {
        timer!.cancel();
      });
    }
    getOtpRequest();
  }

  Future<void> verifyAccount() async {
    if (inputPin.length != 6) {
      CustomDialog().errorDialog(
          Get.context!, "Invalid OTP", "Please complete the 6-digits OTP", () {
        setState(() {
          isLoading = false;
        });
        Get.back();
      });
      return;
    }
    if (widget.arguments["is_forget_vfd_pass"] != null &&
        widget.arguments["is_forget_vfd_pass"]) {
      widget.arguments["callback"](int.parse(pinController.text));
      return;
    } else {
      CustomDialog().loadingDialog(Get.context!);
      // var otpData = {
      //   "mobile_no": parameters.toString(),
      //   "otp": int.parse(pinController.text),
      //   "new_acct": controller.isNewAcct
      // };

      HttpRequest(
              api: ApiKeys.putVerifyOtp,
              parameters: widget.arguments["verify_param"])
          .putBody()
          .then((returnData) async {
        if (returnData == "No Internet") {
          Get.back();

          CustomDialog().errorDialog(Get.context!, "Error",
              'Please check your internet connection and try again.', () {
            Get.back();
          });

          return;
        }
        if (returnData == null) {
          Get.back();
          CustomDialog().errorDialog(Get.context!, "Error",
              "Error while connecting to server, Please try again.", () {
            Get.back();
          });

          return;
        }
        if (returnData["success"] == 'Y') {
          Get.back();
          Get.back();

          widget.arguments["callback"](int.parse(pinController.text));
          return;
        } else {
          Get.back();
          CustomDialog().errorDialog(Get.context!, "Error", returnData["msg"],
              () {
            setState(() {
              pinController.text = "";
            });
            Get.back();
          });
          return;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    PinTheme getDefaultPinTheme() {
      return PinTheme(
        width: 50,
        height: 50,
        textStyle: paragraphStyle(
          fontSize: 20,
          color: AppColor.primaryColor,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.borderColor, width: 1),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
      );
    }

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColor.bodyColor,
        appBar: AppBar(
          elevation: 1,
          backgroundColor: AppColor.primaryColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColor.primaryColor,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
          title: Text("OTP Verification"),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Iconsax.arrow_left,
              color: Colors.white,
            ),
          ),
        ),
        body: isLoading
            ? PageLoader()
            : !isNetConn
                ? NoInternetConnected(onTap: getOtpRequest)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 15, 0),
                    child: ScrollConfiguration(
                      behavior: ScrollBehavior().copyWith(overscroll: false),
                      child: StretchingOverscrollIndicator(
                        axisDirection: AxisDirection.down,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(height: 20),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Center(
                                    child: Image(
                                      image: AssetImage(
                                          "assets/images/otp_logo.png"),
                                      fit: BoxFit.contain,
                                      width: 200,
                                      height: 200,
                                    ),
                                  ),
                                  Center(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text:
                                                  "We have sent an OTP to registered\nmobile number",
                                              style: GoogleFonts.openSans(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: AppColor.paragraphColor,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      " +${widget.arguments["mobile_no"].toString()}",
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColor.primaryColor,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(height: 20),
                              Center(
                                child: Directionality(
                                  // Specify direction if desired
                                  textDirection: TextDirection.ltr,
                                  child: Pinput(
                                    length: 6,
                                    controller: pinController,
                                    defaultPinTheme: getDefaultPinTheme(),
                                    androidSmsAutofillMethod:
                                        AndroidSmsAutofillMethod
                                            .smsUserConsentApi,
                                    hapticFeedbackType:
                                        HapticFeedbackType.lightImpact,
                                    onCompleted: (pin) {
                                      if (pin.length == 6) {
                                        onInputChanged(pin);
                                      }
                                    },
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        onInputChanged(value);
                                      } else {
                                        onInputChanged(value);
                                      }
                                    },
                                    cursor: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 9),
                                          width: 22,
                                          height: 1,
                                          color: AppColor.primaryColor,
                                        ),
                                      ],
                                    ),
                                    focusedPinTheme:
                                        getDefaultPinTheme().copyWith(
                                      decoration: getDefaultPinTheme()
                                          .decoration!
                                          .copyWith(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: AppColor.primaryColor,
                                                width: 1),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              const VerticalHeight(height: 30),
                              if (MediaQuery.of(context).viewInsets.bottom == 0)
                                CustomButton(
                                  loading: isLoading,
                                  text: "Verify",
                                  onPressed: verifyAccount,
                                ),
                              Container(
                                height: 40,
                              ),
                              const Center(
                                child: CustomTitle(
                                  text: "Didn't you receive any code?",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                height: 2,
                              ),
                              InkWell(
                                onTap: paramOtpExp.inSeconds <= 0
                                    ? () {
                                        restartTimer();
                                      }
                                    : null,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomLinkLabel(
                                      text: paramOtpExp.inSeconds <= 0
                                          ? "Resend OTP in"
                                          : "Resend OTP",
                                      fontSize: 14,
                                      color: paramOtpExp.inSeconds <= 0
                                          ? Colors.grey
                                          : AppColor.primaryColor,
                                    ),
                                    if (paramOtpExp.inSeconds > 0)
                                      CustomLinkLabel(
                                        text:
                                            " (${formatDuration(paramOtpExp)})",
                                        color: Colors.grey,
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 39,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
