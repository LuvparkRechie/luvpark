import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/custom_textfield.dart';
import 'package:luvpark_get/custom_widgets/password_indicator.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/custom_widgets/vertical_height.dart';
import 'package:luvpark_get/forgot_password/utils/create_new/controller.dart';

class CreateNewPassword extends GetView<CreateNewPassController> {
  const CreateNewPassword({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: const CustomAppbar(),
      body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Obx(
            () => Form(
              key: controller.formKeyCreatePass,
              child: StretchingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomTitle(
                        text: "Create a new password",
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.1,
                        wordspacing: 4,
                      ),
                      Container(height: 10),
                      const CustomParagraph(
                        text:
                            "Your new password must be different from previous used passwords.",
                      ),
                      const VerticalHeight(height: 30),
                      const CustomTitle(
                        text: "New Password",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -.1,
                        wordspacing: 2,
                      ),
                      CustomTextField(
                        title: "Password",
                        labelText: "Enter your new password",
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
                        validator: (txtValue) {
                          if (txtValue == null || txtValue.isEmpty) {
                            return "Field is required";
                          }
                          return null;
                        },
                      ),
                      const CustomTitle(
                        text: "Confirm Password",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -.1,
                        wordspacing: 2,
                      ),
                      CustomTextField(
                        title: "Password",
                        labelText: "Confirm your new password",
                        controller: controller.confirmPass,
                        isObscure: !controller.isShowConfirmPass.value,
                        suffixIcon: !controller.isShowConfirmPass.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        onIconTap: () {
                          controller.onToggleConfirmPass(
                              !controller.isShowConfirmPass.value);
                        },
                        validator: (txtValue) {
                          if (txtValue == null || txtValue.isEmpty) {
                            return "Field is required";
                          }
                          if (txtValue != controller.newPass.text) {
                            return "Password doesn't match";
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
                          text: "Create password",
                          loading: controller.isLoading.value,
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            if (controller.formKeyCreatePass.currentState!
                                .validate()) {
                              controller.requestOtp();
                            }
                          })
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
