// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/custom_widgets/vertical_height.dart';
import 'package:luvpark/routes/routes.dart';

import '../security/app_security.dart';
import 'controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginScreenController controller = Get.put(LoginScreenController());

  @override
  void initState() {
    super.initState();
    if (Variables.inactiveTmr != null) {
      Variables.inactiveTmr!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          elevation: 0,
          toolbarHeight: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColor.bodyColor,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        body: Container(
          width: double.infinity,
          color: AppColor.bodyColor,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              children: [
                Expanded(
                  child: StretchingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    child: ScrollConfiguration(
                      behavior:
                          const ScrollBehavior().copyWith(overscroll: false),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            const Image(
                              image: AssetImage(
                                  "assets/images/onboardluvpark.png"),
                              width: 120,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 30),
                            const CustomTitle(
                              text: "Welcome to luvpark",
                              color: Colors.black,
                              maxlines: 1,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              textAlign: TextAlign.center,
                              letterSpacing: -.1,
                            ),
                            const SizedBox(height: 10),
                            CustomParagraph(
                              textAlign: TextAlign.start,
                              text:
                                  "Enter your mobile number and password to log in",
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                            ),
                            const VerticalHeight(height: 25),
                            Row(
                              children: [
                                CustomParagraph(
                                  text: "Mobile Number",
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            CustomMobileNumber(
                              hintText: "10 digit mobile number",
                              controller: controller.mobileNumber,
                              inputFormatters: [Variables.maskFormatter],
                              keyboardType: TextInputType.number,
                            ),
                            const VerticalHeight(height: 10),
                            Row(
                              children: [
                                CustomParagraph(
                                  text: "Password",
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            Obx(
                              () => CustomTextField(
                                hintText: "Enter your password",
                                controller: controller.password,
                                isObscure: !controller.isShowPass.value,
                                suffixIcon: !controller.isShowPass.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                onIconTap: () {
                                  controller.visibilityChanged(
                                      !controller.isShowPass.value);
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Forgot Password',
                                      style: paragraphStyle(
                                        color: AppColor.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = controller.isLoading.value
                                            ? () {}
                                            : () async {
                                                Get.toNamed(Routes.forgotPass);
                                              },
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Obx(
                              () => Column(
                                children: [
                                  CustomElevatedButton(
                                    btnwidth: double.infinity,
                                    loading: controller.isLoading.value,
                                    text: "Log in with Mobile Number",
                                    iconColor: Colors.white,
                                    textColor: Colors.white,
                                    icon: Icons.phone_android_rounded,
                                    btnColor: AppColor.primaryColor,
                                    fontSize: 13,
                                    onPressed: () {
                                      controller.counter++;
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      if (controller.isLoading.value) return;
                                      controller.toggleLoading(
                                          !controller.isLoading.value);

                                      if (controller
                                          .mobileNumber.text.isEmpty) {
                                        controller.toggleLoading(
                                            !controller.isLoading.value);
                                        CustomDialog().snackbarDialog(
                                            context,
                                            "Mobile number is empty",
                                            Colors.red,
                                            () {});
                                        return;
                                      } else if (controller
                                              .mobileNumber.text.length !=
                                          12) {
                                        controller.toggleLoading(
                                            !controller.isLoading.value);
                                        CustomDialog().snackbarDialog(
                                            context,
                                            "Incorrect mobile number",
                                            Colors.red,
                                            () {});
                                        return;
                                      }
                                      if (controller.password.text.isEmpty) {
                                        controller.toggleLoading(
                                            !controller.isLoading.value);
                                        CustomDialog().snackbarDialog(
                                            context,
                                            "Password is empty",
                                            Colors.red,
                                            () {});
                                        return;
                                      }
                                      Map<String, dynamic> postParam = {
                                        "mobile_no":
                                            "63${controller.mobileNumber.text.toString().replaceAll(" ", "")}",
                                        "pwd": controller.password.text,
                                      };

                                      controller.postLogin(context, postParam,
                                          (data) {
                                        controller.toggleLoading(
                                            !controller.isLoading.value);

                                        if (data[0]["items"].isNotEmpty) {
                                          Get.offAndToNamed(Routes.map);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  CustomElevatedButton(
                                    btnwidth: double.infinity,
                                    loading: controller.isLoading.value,
                                    text: "Create Account",
                                    // textColor: const Color(0xFF424242)
                                    //     .withOpacity(0.8),
                                    textColor: Colors.black,
                                    // borderColor: const Color(0xFF424242)
                                    //.withOpacity(0.5),
                                    borderColor: AppColor.borderColor,
                                    btnColor: AppColor.bodyColor,
                                    fontSize: 13,
                                    onPressed: () {
                                      Get.offAndToNamed(Routes.landing);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Biometric Button at the Bottom
                Obx(
                  () => Visibility(
                    visible: controller.isToggle.value,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: CustomElevatedButton(
                        btnColor: AppColor.primaryColor,
                        btnHeight: 40,
                        fontSize: 13,
                        textColor: Colors.white,
                        loading: controller.isLoading.value,
                        text: Platform.isIOS
                            ? "Log in with Face ID"
                            : "Log in with biometric",
                        borderRadius: 40,
                        icon: Platform.isIOS
                            ? LucideIcons.scanFace
                            : LucideIcons.fingerprint,
                        onPressed: () async {
                          String? mpass =
                              await Authentication().getPasswordBiometric();
                          final mmobile = await Authentication().getUserData2();

                          bool isGG = await AppSecurity.authenticateBio();

                          if (isGG) {
                            CustomDialog().loadingDialog(context);
                            Map<String, dynamic> postParam = {
                              "mobile_no": "${mmobile["mobile_no"]}",
                              "pwd": mpass,
                            };

                            controller.postLogin(context, postParam, (data) {
                              Get.back();

                              if (data[0]["items"].isNotEmpty) {
                                Get.offAndToNamed(Routes.map);
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
