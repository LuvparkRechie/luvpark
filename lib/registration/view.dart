// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/custom_textfield.dart';
import 'package:luvpark_get/custom_widgets/password_indicator.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/custom_widgets/vertical_height.dart';
import 'package:luvpark_get/registration/controller.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom_widgets/app_color.dart';

class RegistrationPage extends GetView<RegistrationController> {
  const RegistrationPage({Key? key}) : super(key: key);

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
              statusBarColor: AppColor.primaryColor,
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.light,
            ),
          ),
          body: Container(
            color: AppColor.primaryColor,
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30))),
              child: ScrollConfiguration(
                behavior: ScrollBehavior().copyWith(overscroll: false),
                child: StretchingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  child: SingleChildScrollView(
                    child: GetBuilder<RegistrationController>(builder: (ctxt) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                        child: Form(
                          key: controller.formKeyRegister,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(height: 20),
                              Image(
                                image: AssetImage(
                                    "assets/images/onboardluvpark.png"),
                                width: 100,
                                fit: BoxFit.contain,
                              ),
                              Image(
                                image: const AssetImage(
                                    "assets/images/onboard5.png"),
                                width: MediaQuery.of(Get.context!).size.width *
                                    .55,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                              CustomTitle(
                                text: "Create account",
                                color: Colors.black,
                                maxlines: 1,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                textAlign: TextAlign.center,
                                letterSpacing: -.1,
                              ),
                              Container(height: 10),
                              const CustomParagraph(
                                textAlign: TextAlign.center,
                                text:
                                    "Create an account to connect, explore,\n and enjoy all we offer.",
                              ),
                              const VerticalHeight(height: 30),
                              CustomMobileNumber(
                                labelText: "10 digit mobile number",
                                controller: controller.mobileNumber,
                                inputFormatters: [Variables.maskFormatter],
                                onChange: (value) {
                                  controller.onMobileChanged(value);
                                },
                              ),
                              const VerticalHeight(height: 5),
                              Obx(
                                () => CustomTextField(
                                  title: "Password",
                                  labelText: "Enter your password",
                                  controller: controller.password,
                                  isObscure: controller.isShowPass.value,
                                  suffixIcon: controller.isShowPass.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  onIconTap: () {
                                    controller.visibilityChanged(
                                        !controller.isShowPass.value);
                                  },
                                  onChange: (value) {
                                    controller.onPasswordChanged(value);
                                  },
                                ),
                              ),
                              Container(height: 10),
                              Obx(
                                () => Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: Colors.black
                                            .withOpacity(0.05999999865889549),
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12, 15, 11, 18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CustomTitle(
                                          text: "Password Strength",
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -.1,
                                          wordspacing: 2,
                                        ),
                                        Container(
                                          height: 15,
                                        ),
                                        Row(
                                          children: [
                                            PasswordStrengthIndicator(
                                              strength: 1,
                                              currentStrength:
                                                  controller.passStrength.value,
                                            ),
                                            Container(
                                              width: 5,
                                            ),
                                            PasswordStrengthIndicator(
                                              strength: 2,
                                              currentStrength:
                                                  controller.passStrength.value,
                                            ),
                                            Container(
                                              width: 5,
                                            ),
                                            PasswordStrengthIndicator(
                                              strength: 3,
                                              currentStrength:
                                                  controller.passStrength.value,
                                            ),
                                            Container(
                                              width: 5,
                                            ),
                                            PasswordStrengthIndicator(
                                              strength: 4,
                                              currentStrength:
                                                  controller.passStrength.value,
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 15,
                                        ),
                                        if (Variables.getPasswordStrengthText(
                                                controller.passStrength.value)
                                            .isNotEmpty)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.shield_moon,
                                                color: Variables
                                                    .getColorForPasswordStrength(
                                                        controller.passStrength
                                                            .value),
                                                size: 18,
                                              ),
                                              Container(
                                                width: 6,
                                              ),
                                              CustomParagraph(
                                                text: Variables
                                                    .getPasswordStrengthText(
                                                        controller.passStrength
                                                            .value),
                                                color: Variables
                                                    .getColorForPasswordStrength(
                                                        controller.passStrength
                                                            .value),
                                              ),
                                            ],
                                          ),
                                        Container(
                                          height: 10,
                                        ),
                                        const CustomParagraph(
                                          text:
                                              "The password should have a minimum of 8 characters, including at least one uppercase letter and a number.",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              CustomButton(
                                text: "Submit",
                                loading: controller.isLoading.value,
                                onPressed: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  if (controller.formKeyRegister.currentState!
                                      .validate()) {
                                    if (Variables.getPasswordStrengthText(
                                            controller.passStrength.value) !=
                                        "Strong Password") {
                                      CustomDialog().snackbarDialog(
                                          context,
                                          'For enhanced security, please create a stronger password.',
                                          Colors.red,
                                          () {});
                                      return;
                                    }
                                    if (controller.isLoading.value) return;
                                    controller.toggleLoading(
                                        !controller.isLoading.value);
                                    Map<String, dynamic> parameters = {
                                      "mobile_no":
                                          "63${controller.mobileNumber.text.toString().replaceAll(" ", "")}",
                                      "pwd": controller.password.text,
                                    };
                                    controller.onSubmit(context, parameters,
                                        (data) async {
                                      controller.toggleLoading(
                                          !controller.isLoading.value);
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setBool('isLoggedIn', false);
                                      Authentication().setPasswordBiometric(
                                          controller.password.text);

                                      if (data[0]["success"]) {
                                        // ignore: use_build_context_synchronously
                                        CustomDialog().successDialog(
                                            context,
                                            "Success",
                                            "We have sent an activation code to your mobile number.",
                                            "Continue", () async {
                                          Get.back();
                                          List argsParam = [
                                            {
                                              "otp": int.parse(
                                                  data[0]["items"].toString()),
                                              'mobile_no':
                                                  parameters["mobile_no"],
                                              "req_type": "VERIFY",
                                              "seq_id": 0,
                                              "seca": "",
                                              "seq_no": 1,
                                              "new_pass":
                                                  controller.password.text,
                                            }
                                          ];
                                          controller
                                              .formKeyRegister.currentState
                                              ?.reset();
                                          Get.toNamed(Routes.otp,
                                              arguments: argsParam);
                                        });
                                      }
                                    });
                                  }
                                },
                              ),
                              Container(
                                height: 20,
                              ),
                              Center(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Already a luvpark user? ",
                                        style: paragraphStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      TextSpan(
                                        text: 'Login',
                                        style: paragraphStyle(
                                          color: AppColor.primaryColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = controller.isLoading.value
                                              ? () {}
                                              : () async {
                                                  Get.toNamed(Routes.login);
                                                },
                                      ),
                                    ],
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // Ensures that if the text is too long, it will be truncated with an ellipsis
                                  maxLines: 1,
                                ),
                              ),
                              Container(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
