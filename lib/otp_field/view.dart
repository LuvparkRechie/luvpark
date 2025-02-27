// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:luvpark/custom_widgets/vertical_height.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:pinput/pinput.dart';

import '../auth/authentication.dart';
import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/custom_textfield.dart';
import '../http/api_keys.dart';
import '../http/http_request.dart';
import 'controller.dart';

class OtpFieldScreen extends StatefulWidget {
  const OtpFieldScreen({super.key});

  @override
  State<OtpFieldScreen> createState() => _OtpFieldScreenState();
}

class _OtpFieldScreenState extends State<OtpFieldScreen> {
  final controller = Get.put(OtpFieldScreenController());
  String parameters = Get.arguments["mobile_no"];
  final putVerifyParam = Get.arguments["verify_param"];
  TextEditingController pinController = TextEditingController();
  Duration countdownDuration = const Duration(minutes: 2);

  Timer? timer;
  bool isLoading = false;
  bool isRequested = false;
  bool isNetConn = true;
  bool isLoadingPage = true;
  String inputPin = "";
  bool isOtpValid = true;
  int minutes = 2;
  int seconds = 0;
  int initialMinutes = 2;
  bool isRunning = false;
  int otpCode = 0;

  @override
  void initState() {
    super.initState();
    pinController = TextEditingController();
    startTimers();
    getTmrStat();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  void getTmrStat() async {
    await Authentication().enableTimer(false);
  }

  void getOtpRequest() {
    setState(() {
      inputPin = "";
    });
    CustomDialog().loadingDialog(Get.context!);
    var otpData = {"mobile_no": parameters.toString()};

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
        setState(() {
          isLoadingPage = false;
          isNetConn = true;

          inputPin = "";
          minutes = initialMinutes;
          seconds = 0;

          otpCode = int.parse(returnData["otp"].toString());
          isRequested = true;
        });
        startTimers();
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

  Future<void> startTimers() async {
    const oneSecond = Duration(seconds: 1);
    timer = Timer.periodic(oneSecond, (timer) {
      if (minutes == 0 && seconds == 0) {
        setState(() {
          timer.cancel(); // Stop the timer
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

    if (mounted) {
      setState(() {
        isRunning = true;
      });
    }
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
    if (controller.isForgetVfdPass) {
      controller.callback(int.parse(pinController.text));
      return;
    } else {
      CustomDialog().loadingDialog(Get.context!);
      // var otpData = {
      //   "mobile_no": parameters.toString(),
      //   "otp": int.parse(pinController.text),
      //   "new_acct": controller.isNewAcct
      // };
      print("putVerifyParam $putVerifyParam");

      HttpRequest(api: ApiKeys.putVerifyOtp, parameters: putVerifyParam)
          .putBody()
          .then((returnData) async {
        print("returnData $returnData");
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

          controller.callback(int.parse(pinController.text));
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
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.bodyColor,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
          backgroundColor: AppColor.primaryColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColor.primaryColor,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
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
                              CustomButtonClose(onTap: () {
                                FocusNode().unfocus();
                                Get.back();
                              }),
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
                                  const Center(
                                    child: CustomTitle(
                                      text: "OTP verification",
                                      fontSize: 24,
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
                                                  text: " +${parameters}",
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
                                onTap: (minutes == 0 && seconds == 0)
                                    ? () {
                                        restartTimer();
                                      }
                                    : null,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomLinkLabel(
                                      text: minutes != 0 || seconds != 0
                                          ? "Resend OTP in"
                                          : "Resend OTP",
                                      fontSize: 14,
                                      color: minutes != 0 || seconds != 0
                                          ? Colors.grey
                                          : AppColor.primaryColor,
                                    ),
                                    if (minutes != 0 || seconds != 0)
                                      CustomLinkLabel(
                                        text:
                                            " ($minutes:${seconds < 10 ? "0" : ""}$seconds)",
                                        color: minutes != 0 || seconds != 0
                                            ? Colors.grey
                                            : AppColor.primaryColor,
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

// class OtpFieldScreen extends GetView<OtpFieldScreenController> {
//   const OtpFieldScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     PinTheme getDefaultPinTheme() {
//       return PinTheme(
//         width: 50,
//         height: 50,
//         textStyle: paragraphStyle(
//           fontSize: 20,
//           color: isOtpValid
//               ? AppColor.primaryColor
//               : inputPin.value.length != 6
//                   ? Colors.black
//                   : Colors.red,
//         ),
//         decoration: BoxDecoration(
//           border: Border.all(
//               color: inputPin.value.isEmpty
//                   ? AppColor.borderColor
//                   : isOtpValid
//                       ? AppColor.primaryColor
//                       : inputPin.value.length != 6
//                           ? AppColor.borderColor
//                           : Colors.red,
//               width: 1),
//           borderRadius: BorderRadius.circular(5),
//           color: Colors.white,
//         ),
//       );
//     }

//     return PopScope(
//       canPop: false,
//       child: Scaffold(
//           backgroundColor: AppColor.bodyColor,
//           appBar: AppBar(
//             elevation: 0,
//             toolbarHeight: 0,
//             backgroundColor: AppColor.primaryColor,
//             systemOverlayStyle: SystemUiOverlayStyle(
//               statusBarColor: AppColor.primaryColor,
//               statusBarBrightness: Brightness.light,
//               statusBarIconBrightness: Brightness.light,
//             ),
//           ),
//           body: Obx(
//             () => isLoading.value
//                 ? PageLoader()
//                 : !isNetConn.value
//                     ? NoInternetConnected(onTap: getOtpRequest)
//                     : Padding(
//                         padding: const EdgeInsets.fromLTRB(20, 10, 15, 0),
//                         child: ScrollConfiguration(
//                           behavior:
//                               ScrollBehavior().copyWith(overscroll: false),
//                           child: StretchingOverscrollIndicator(
//                             axisDirection: AxisDirection.down,
//                             child: SingleChildScrollView(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Container(height: 20),
//                                   CustomButtonClose(onTap: () {
//                                     FocusNode().unfocus();
//                                     Get.back();
//                                   }),
//                                   Container(height: 20),
//                                   Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const Center(
//                                         child: Image(
//                                           image: AssetImage(
//                                               "assets/images/otp_logo.png"),
//                                           fit: BoxFit.contain,
//                                           width: 200,
//                                           height: 200,
//                                         ),
//                                       ),
//                                       const Center(
//                                         child: CustomTitle(
//                                           text: "OTP verification",
//                                           fontSize: 24,
//                                         ),
//                                       ),
//                                       Center(
//                                         child: RichText(
//                                           text: TextSpan(
//                                             children: [
//                                               TextSpan(
//                                                   text:
//                                                       "We have sent an OTP to registered\nmobile number",
//                                                   style: GoogleFonts.openSans(
//                                                     fontWeight: FontWeight.w500,
//                                                     fontSize: 14,
//                                                     color:
//                                                         AppColor.paragraphColor,
//                                                   ),
//                                                   children: <TextSpan>[
//                                                     TextSpan(
//                                                       text:
//                                                           " +${parameters}",
//                                                       style: GoogleFonts.inter(
//                                                         fontWeight:
//                                                             FontWeight.w600,
//                                                         color: AppColor
//                                                             .primaryColor,
//                                                         fontSize: 14,
//                                                       ),
//                                                     ),
//                                                   ]),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Container(height: 20),
//                                   Center(
//                                     child: Directionality(
//                                       // Specify direction if desired
//                                       textDirection: TextDirection.ltr,
//                                       child: Pinput(
//                                         length: 6,
//                                         controller: pinController,
//                                         defaultPinTheme: getDefaultPinTheme(),
//                                         androidSmsAutofillMethod:
//                                             AndroidSmsAutofillMethod
//                                                 .smsUserConsentApi,
//                                         hapticFeedbackType:
//                                             HapticFeedbackType.lightImpact,
//                                         onCompleted: (pin) {
//                                           if (pin.length == 6) {
//                                             onInputChanged(pin);
//                                           }
//                                         },
//                                         onChanged: (value) {
//                                           if (value.isEmpty) {
//                                             onInputChanged(value);
//                                           } else {
//                                             onInputChanged(value);
//                                           }
//                                         },
//                                         cursor: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.end,
//                                           children: [
//                                             Container(
//                                               margin: const EdgeInsets.only(
//                                                   bottom: 9),
//                                               width: 22,
//                                               height: 1,
//                                               color: AppColor.primaryColor,
//                                             ),
//                                           ],
//                                         ),
//                                         focusedPinTheme:
//                                             getDefaultPinTheme().copyWith(
//                                           decoration: getDefaultPinTheme()
//                                               .decoration!
//                                               .copyWith(
//                                                 borderRadius:
//                                                     BorderRadius.circular(5),
//                                                 border: Border.all(
//                                                     color:
//                                                         AppColor.primaryColor,
//                                                     width: 1),
//                                               ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   const VerticalHeight(height: 30),
//                                   if (MediaQuery.of(context)
//                                           .viewInsets
//                                           .bottom ==
//                                       0)
//                                     CustomButton(
//                                       loading: isLoading.value,
//                                       text: "Verify",
//                                       onPressed: verifyAccount,
//                                     ),
//                                   Container(
//                                     height: 40,
//                                   ),
//                                   const Center(
//                                     child: CustomTitle(
//                                       text: "Didn't you receive any code?",
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                   Container(
//                                     height: 2,
//                                   ),
//                                   InkWell(
//                                     onTap: (minutes.value == 0 &&
//                                             seconds.value == 0)
//                                         ? () {
//                                             restartTimer();
//                                           }
//                                         : null,
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         CustomLinkLabel(
//                                           text: minutes.value != 0 ||
//                                                   seconds.value != 0
//                                               ? "Resend OTP in"
//                                               : "Resend OTP",
//                                           fontSize: 14,
//                                           color: minutes.value !=
//                                                       0 ||
//                                                   seconds.value != 0
//                                               ? Colors.grey
//                                               : AppColor.primaryColor,
//                                         ),
//                                         if (minutes.value != 0 ||
//                                             seconds.value != 0)
//                                           CustomLinkLabel(
//                                             text:
//                                                 " (${minutes.value}:${seconds.value < 10 ? "0" : ""}${seconds.value})",
//                                             color: minutes.value !=
//                                                         0 ||
//                                                     seconds.value !=
//                                                         0
//                                                 ? Colors.grey
//                                                 : AppColor.primaryColor,
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                   Container(
//                                     height: 39,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//           )),
//     );
//   }
// }

class SuccessLoginRegistration extends StatefulWidget {
  const SuccessLoginRegistration({super.key});

  @override
  State<SuccessLoginRegistration> createState() =>
      _SuccessLoginRegistrationState();
}

class _SuccessLoginRegistrationState extends State<SuccessLoginRegistration> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Get.offAllNamed(Routes.map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1)),
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 0,
              backgroundColor: AppColor.mainColor,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: AppColor.mainColor,
                statusBarBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.light,
              ),
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: AppColor.mainColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.check, color: Colors.green, size: 30),
                    ),
                    Container(
                      height: 20,
                    ),
                    const CustomTitle(
                      text: "Congratulations!",
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    Container(
                      height: 11,
                    ),
                    Text(
                      "Let's get started. Your account has been successfully registered",
                      style: GoogleFonts.varela(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * .25,
                    ),
                    const CustomParagraph(
                      text: "Redirecting please wait ",
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                    Container(height: 10),
                    SizedBox(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey.shade400,
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
