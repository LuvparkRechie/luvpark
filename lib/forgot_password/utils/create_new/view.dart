import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/custom_widgets/password_indicator.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/custom_widgets/vertical_height.dart';
import 'package:luvpark/forgot_password/utils/create_new/controller.dart';

class CreateNewPassword extends GetView<CreateNewPassController> {
  const CreateNewPassword({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: AppBar(
        leading: null,
        elevation: 0,
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Obx(() {
            int minutes = controller.remainingSeconds.value ~/ 60;
            int seconds = controller.remainingSeconds.value % 60;

            return Form(
              // autovalidateMode: AutovalidateMode.always,
              key: controller.formKeyCreatePass,
              child: StretchingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 20),
                      CustomButtonClose(onTap: () {
                        Get.back();
                      }),
                      Container(height: 20),
                      CustomTitle(
                        text: "Create a new password",
                        fontSize: 20,
                      ),
                      Container(height: 10),
                      CustomParagraph(
                        text:
                            "Your new password must be different from previous used passwords.",
                      ),
                      const VerticalHeight(height: 20),
                      CustomParagraph(
                        text: "New password",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      CustomTextField(
                        hintText: "New password",
                        controller: controller.newPass,
                        isObscure: !controller.isShowNewPass.value,
                        suffixIcon: !controller.isShowNewPass.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        onChange: (value) {
                          controller.onPasswordChanged(value);
                        },
                        onIconTap: () {
                          controller
                              .onToggleNewPass(!controller.isShowNewPass.value);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          LengthLimitingTextInputFormatter(30),
                        ],
                        validator: (txtValue) {
                          if (txtValue == null || txtValue.isEmpty) {
                            return "Field is required";
                          }
                          if (txtValue.length < 8 || txtValue.length > 32) {
                            return "Password must be between 8 and 32 characters";
                          }
                          if (controller.passStrength.value == 1) {
                            return "Very Weak Password";
                          }
                          if (controller.passStrength.value == 2) {
                            return "Weak Password";
                          }
                          if (controller.passStrength.value == 3) {
                            return "Medium Password";
                          }
                          return null;
                        },
                      ),
                      CustomParagraph(
                        text: "Confirm password",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      CustomTextField(
                        hintText: "Confirm password",
                        controller: controller.confirmPass,
                        isObscure: !controller.isShowConfirmPass.value,
                        suffixIcon: !controller.isShowConfirmPass.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        onIconTap: () {
                          controller.onToggleConfirmPass(
                              !controller.isShowConfirmPass.value);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          LengthLimitingTextInputFormatter(30),
                        ],
                        validator: (txtValue) {
                          if (txtValue == null || txtValue.isEmpty) {
                            return "Field is required";
                          }
                          if (txtValue != controller.newPass.text) {
                            return "Password doesn't match";
                          }
                          if (Variables.getPasswordStrengthText(
                                  controller.passStrength.value) !=
                              "Strong Password") {
                            return "For enhanced security, please create a stronger password.";
                          }
                          return null;
                        },
                      ),
                      Container(height: 10),
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color:
                                  Colors.black.withOpacity(0.05999999865889549),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 15, 11, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      color:
                                          Variables.getColorForPasswordStrength(
                                              controller.passStrength.value),
                                      size: 18,
                                    ),
                                    Container(
                                      width: 6,
                                    ),
                                    CustomParagraph(
                                      text: Variables.getPasswordStrengthText(
                                          controller.passStrength.value),
                                      color:
                                          Variables.getColorForPasswordStrength(
                                              controller.passStrength.value),
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
                      const VerticalHeight(height: 30),
                      CustomButton(
                          text:
                              "${!controller.isFinish.value ? "Time left" : "Proceed"} ${!controller.isFinish.value ? "- ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}" : ""}",
                          btnColor: !controller.isFinish.value
                              ? AppColor.primaryColor.withOpacity(.7)
                              : null,
                          onPressed: !controller.isFinish.value
                              ? () {}
                              : () async {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  if (controller.formKeyCreatePass.currentState!
                                      .validate()) {
                                    controller.requestOtp();
                                  }
                                }),
                      Container(height: 20),
                    ],
                  ),
                ),
              ),
            );
          })),
    );
  }
}
