import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/vertical_height.dart';
import 'package:luvpark/registration/utils/otp_screen/controller.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:pinput/pinput.dart';

import '../../../custom_widgets/custom_appbar.dart';

class OtpScreen extends GetView<OtpController> {
  const OtpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    PinTheme getDefaultPinTheme() {
      return PinTheme(
        width: 50,
        height: 50,
        textStyle: paragraphStyle(
          fontSize: 20,
          color: controller.isOtpValid.value
              ? AppColor.primaryColor
              : controller.inputPin.value.length != 6
                  ? Colors.black
                  : Colors.red,
        ),
        decoration: BoxDecoration(
          border: Border.all(
              color: controller.inputPin.isEmpty
                  ? AppColor.borderColor
                  : controller.isOtpValid.value
                      ? AppColor.primaryColor
                      : controller.inputPin.value.length != 6
                          ? AppColor.borderColor
                          : Colors.red,
              width: 2),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppbar(
        elevation: 0,
        bgColor: Colors.white,
        textColor: Colors.black,
        titleColor: Colors.black,
        statusBarBrightness: Brightness.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 15, 0),
        child: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(overscroll: false),
          child: StretchingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: Image(
                          image: AssetImage("assets/images/otp_logo.png"),
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
                                      text:
                                          " +${controller.paramArgs[0]["mobile_no"]}",
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
                      ),
                    ],
                  ),
                  Container(height: 20),
                  Obx(
                    () => Center(
                      child: Directionality(
                        // Specify direction if desired
                        textDirection: TextDirection.ltr,

                        child: Pinput(
                          mainAxisAlignment: MainAxisAlignment.center,
                          length: 6,
                          controller: controller.pinController,
                          defaultPinTheme: getDefaultPinTheme(),
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          androidSmsAutofillMethod:
                              AndroidSmsAutofillMethod.smsUserConsentApi,
                          onCompleted: (pin) {
                            if (pin.length == 6) {
                              controller.onInputChanged(pin);
                            }
                          },
                          onChanged: (value) {
                            if (value.isEmpty) {
                              controller.onInputChanged(value);
                            } else {
                              controller.onInputChanged(value);
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
                          focusedPinTheme: getDefaultPinTheme().copyWith(
                            decoration:
                                getDefaultPinTheme().decoration!.copyWith(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: AppColor.primaryColor,
                                          width: 2),
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const VerticalHeight(height: 30),
                  if (MediaQuery.of(context).viewInsets.bottom == 0)
                    Obx(
                      () => CustomButton(
                        loading: controller.isLoading.value,
                        text: "Verify",
                        onPressed: () {
                          if (controller.isLoading.value) {
                            controller.onVerify();
                            return;
                          }
                          controller.onVerify();
                        },
                      ),
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
                  Obx(
                    () => InkWell(
                      onTap: (controller.minutes.value == 0 &&
                              controller.seconds.value == 0)
                          ? () {
                              controller.restartTimer();
                            }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomLinkLabel(
                            text: controller.minutes.value != 0 ||
                                    controller.seconds.value != 0
                                ? "Resend OTP in"
                                : "Resend OTP",
                            fontSize: 14,
                            color: controller.minutes.value != 0 ||
                                    controller.seconds.value != 0
                                ? Colors.grey
                                : AppColor.primaryColor,
                          ),
                          if (controller.minutes.value != 0 ||
                              controller.seconds.value != 0)
                            CustomLinkLabel(
                              text:
                                  " (${controller.minutes.value}:${controller.seconds.value < 10 ? "0" : ""}${controller.seconds.value})",
                              color: controller.minutes.value != 0 ||
                                      controller.seconds.value != 0
                                  ? Colors.grey
                                  : AppColor.primaryColor,
                            ),
                        ],
                      ),
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
    );
  }
}

class SuccessRegistration extends StatefulWidget {
  const SuccessRegistration({super.key});

  @override
  State<SuccessRegistration> createState() => _SuccessRegistrationState();
}

class _SuccessRegistrationState extends State<SuccessRegistration> {
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
