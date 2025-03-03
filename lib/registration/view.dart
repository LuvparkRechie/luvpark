// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/custom_widgets/password_indicator.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/custom_widgets/vertical_height.dart';
import 'package:luvpark/registration/controller.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:iconsax/iconsax.dart';
import '../custom_widgets/app_color.dart';

class RegistrationPage extends GetView<RegistrationController> {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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
            title: Text("Create Account"),
            centerTitle: true,
          ),
          body: Container(
            color: AppColor.primaryColor,
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: ScrollConfiguration(
                behavior: ScrollBehavior().copyWith(overscroll: false),
                child: StretchingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  child: SingleChildScrollView(
                    child: GetBuilder<RegistrationController>(builder: (ctxt) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: Form(
                          key: controller.formKeyRegister,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              const CustomParagraph(
                                textAlign: TextAlign.start,
                                text:
                                    "Sign up to book, connect, and take advantage of exclusive promos!",
                                fontSize: 13,
                              ),
                              const VerticalHeight(height: 20),
                              CustomParagraph(
                                text: "Mobile Number",
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              CustomMobileNumber(
                                hintText: "10 digit mobile number",
                                controller: controller.mobileNumber,
                                keyboardType: TextInputType.numberWithOptions(),
                                inputFormatters: [Variables.maskFormatter],
                                onChange: (value) {
                                  controller.onMobileChanged(value);
                                },
                              ),
                              CustomParagraph(
                                text: "Password",
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              Obx(
                                () => CustomTextField(
                                  hintText: "Enter Password",
                                  controller: controller.password,
                                  isObscure: controller.isShowPass.value,
                                  suffixIcon: controller.isShowPass.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  onIconTap: () {
                                    controller.visibilityChanged(
                                        !controller.isShowPass.value);
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'\s')),
                                    LengthLimitingTextInputFormatter(30),
                                  ],
                                  validator: (txtValue) {
                                    if (txtValue == null || txtValue.isEmpty) {
                                      return "Field is required";
                                    }
                                    if (txtValue.length < 8 ||
                                        txtValue.length > 32) {
                                      return "Password must be between 8 and 32 characters";
                                    }

                                    return null;
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
                                    color: Colors.grey.shade50,
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
                                          fontSize: 14,
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
                                                size: 15,
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
                                          height: 5,
                                        ),
                                        const CustomParagraph(
                                          text:
                                              "The password should have a minimum of 8 characters, including at least one uppercase letter and a number.",
                                          fontSize: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30.0),
                              if (MediaQuery.of(context).viewInsets.bottom == 0)
                                CustomElevatedButton(
                                  text: "Create Account",
                                  btnwidth: double.infinity,
                                  btnColor: AppColor.primaryColor,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    FocusScope.of(Get.context!)
                                        .requestFocus(FocusNode());
                                    if (controller.formKeyRegister.currentState!
                                        .validate()) {
                                      if (Variables.getPasswordStrengthText(
                                              controller.passStrength.value) !=
                                          "Strong Password") {
                                        CustomDialog().infoDialog(
                                            "Invalid Password",
                                            "For enhanced security, please create a stronger password.",
                                            () {
                                          Get.back();
                                        });
                                        return;
                                      }
                                      controller.onSubmit();
                                    }
                                  },
                                ),
                              Container(
                                height: 30,
                              ),
                              if (MediaQuery.of(context).viewInsets.bottom == 0)
                                Center(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Already a luvpark user? ",
                                          style: paragraphStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        TextSpan(
                                          text: 'Login',
                                          style: paragraphStyle(
                                            color: AppColor.primaryColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              Get.offAllNamed(Routes.login);
                                            },
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
