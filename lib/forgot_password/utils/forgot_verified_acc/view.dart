import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:luvpark/custom_widgets/password_indicator.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/custom_widgets/vertical_height.dart';

import 'controller.dart';

class ForgotVerifiedAcct extends GetView<ForgotVerifiedAcctController> {
  const ForgotVerifiedAcct({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
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
      body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Obx(
            () => controller.isLoading.value
                ? const PageLoader()
                : !controller.isInternetConn.value
                    ? NoInternetConnected(
                        onTap: controller.getSecQdata,
                      )
                    : ScrollConfiguration(
                        behavior: ScrollBehavior().copyWith(overscroll: false),
                        child: StretchingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          child: SingleChildScrollView(
                            child: Form(
                              key: controller.formKeyForgotVerifiedAcc,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(height: 20),
                                  CustomButtonClose(onTap: () {
                                    Get.back();
                                  }),
                                  Container(height: 20),
                                  CustomTitle(
                                    text: "Security Question",
                                    fontSize: 20,
                                  ),
                                  Container(height: 10),
                                  CustomParagraph(
                                    text: "Please provide an answer.",
                                  ),
                                  Container(height: 20),

                                  CustomParagraph(
                                    text: controller.questionData[0]
                                        ["question"],
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),

                                  CustomTextField(
                                    title: "Answer",
                                    hintText: "Enter your answer",
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    controller: controller.answer,
                                    isReadOnly: controller.isVerifiedAns.value,
                                  ),

                                  //IF succcess
                                  if (controller.isVerifiedAns.value)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomParagraph(
                                          text: "New Password",
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                        CustomTextField(
                                          title: "Password",
                                          hintText: "Enter your new password",
                                          controller: controller.newPass,
                                          isObscure:
                                              !controller.isShowNewPass.value,
                                          suffixIcon:
                                              !controller.isShowNewPass.value
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                          onChange: (value) {
                                            controller.onPasswordChanged(value);
                                          },
                                          onIconTap: () {
                                            controller.onToggleNewPass(
                                                !controller
                                                    .isShowNewPass.value);
                                          },
                                          validator: (txtValue) {
                                            if (txtValue == null ||
                                                txtValue.isEmpty) {
                                              return "Field is required";
                                            }
                                            return null;
                                          },
                                        ),
                                        Container(
                                          clipBehavior: Clip.antiAlias,
                                          decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 1,
                                                color: Colors.black.withOpacity(
                                                    0.05999999865889549),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
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
                                                          controller
                                                              .passStrength
                                                              .value,
                                                    ),
                                                    Container(
                                                      width: 5,
                                                    ),
                                                    PasswordStrengthIndicator(
                                                      strength: 2,
                                                      currentStrength:
                                                          controller
                                                              .passStrength
                                                              .value,
                                                    ),
                                                    Container(
                                                      width: 5,
                                                    ),
                                                    PasswordStrengthIndicator(
                                                      strength: 3,
                                                      currentStrength:
                                                          controller
                                                              .passStrength
                                                              .value,
                                                    ),
                                                    Container(
                                                      width: 5,
                                                    ),
                                                    PasswordStrengthIndicator(
                                                      strength: 4,
                                                      currentStrength:
                                                          controller
                                                              .passStrength
                                                              .value,
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  height: 15,
                                                ),
                                                if (Variables
                                                        .getPasswordStrengthText(
                                                            controller
                                                                .passStrength
                                                                .value)
                                                    .isNotEmpty)
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.shield_moon,
                                                        color: Variables
                                                            .getColorForPasswordStrength(
                                                                controller
                                                                    .passStrength
                                                                    .value),
                                                        size: 18,
                                                      ),
                                                      Container(
                                                        width: 6,
                                                      ),
                                                      CustomParagraph(
                                                        text: Variables
                                                            .getPasswordStrengthText(
                                                                controller
                                                                    .passStrength
                                                                    .value),
                                                        color: Variables
                                                            .getColorForPasswordStrength(
                                                                controller
                                                                    .passStrength
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
                                      ],
                                    ),

                                  const VerticalHeight(height: 30),
                                  CustomButton(
                                      text: controller.isVerifiedAns.value
                                          ? "Submit"
                                          : "Verify",
                                      loading: controller.isBtnLoading.value,
                                      onPressed: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        if (controller.formKeyForgotVerifiedAcc
                                            .currentState!
                                            .validate()) {
                                          if (controller.isVerifiedAns.value) {
                                            if (controller.passStrength.value ==
                                                4) {
                                              controller.onSubmit();
                                              return;
                                            }
                                          } else {
                                            controller.onVerify();
                                          }
                                        }
                                      })
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
          )),
    );
  }
}
