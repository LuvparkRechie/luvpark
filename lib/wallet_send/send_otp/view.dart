import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/vertical_height.dart';
import 'package:pinput/pinput.dart';

import '../../custom_widgets/custom_appbar.dart';
import 'controller.dart';

class SendOtp extends GetView<SendOtpController> {
  const SendOtp({super.key});
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
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 15, 0),
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
                                    "We have sent an OTP to your registered\nmobile number",
                                style: GoogleFonts.manrope(
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
                  () => Directionality(
                    // Specify direction if desired
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      length: 6,
                      controller: controller.pinController,
                      androidSmsAutofillMethod:
                          AndroidSmsAutofillMethod.smsUserConsentApi,
                      listenForMultipleSmsOnAndroid: true,
                      defaultPinTheme: getDefaultPinTheme(),
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
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
                        decoration: getDefaultPinTheme().decoration!.copyWith(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: AppColor.primaryColor, width: 2),
                            ),
                      ),
                    ),
                  ),
                ),
                const VerticalHeight(height: 30),
                Obx(
                  () => CustomButton(
                    loading: controller.isLoading.value,
                    text: "Verify",
                    onPressed: controller.onVerify,
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
                    onTap: () {
                      if (controller.seconds.value == 0) {
                        controller.restartTimer();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomLinkLabel(
                          text: controller.minutes.value != 0 ||
                                  controller.seconds.value != 0
                              ? "Resend OTP in"
                              : "I didn't get a code",
                          fontSize: 14,
                        ),
                        if (controller.minutes.value != 0 ||
                            controller.seconds.value != 0)
                          CustomLinkLabel(
                            text:
                                "(${controller.minutes.value}:${controller.seconds.value < 10 ? "0" : ""}${controller.seconds.value})",
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
    );
  }
}
