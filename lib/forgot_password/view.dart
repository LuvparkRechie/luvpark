import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/custom_textfield.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/custom_widgets/vertical_height.dart';
import 'package:luvpark_get/forgot_password/controller.dart';

class ForgotPassword extends GetView<ForgotPasswordController> {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        title: "",
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 15, 20),
        child: SingleChildScrollView(
          child: Form(
            key: controller.formKeyForgotPass,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                ),
                const Center(
                  child: Image(
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                    image: AssetImage(
                      "assets/images/forget_pass_image.png",
                    ),
                  ),
                ),
                Container(
                  height: 20,
                ),
                const CustomTitle(
                  text: "Forgot your Password?",
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
                Container(height: 5),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: CustomParagraph(
                    text:
                        "Enter your phone number below to receive password reset instructions",
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 50,
                ),
                CustomMobileNumber(
                  labelText: "10 digit mobile number",
                  controller: controller.mobileNumber,
                  inputFormatters: [Variables.maskFormatter],
                  onChange: (value) {
                    controller.onMobileChanged(value);
                  },
                ),
                const VerticalHeight(height: 30),
                Obx(
                  () => CustomButton(
                    text: "Submit",
                    loading: controller.isLoading.value,
                    onPressed: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      if (controller.formKeyForgotPass.currentState!
                          .validate()) {
                        controller.verifyMobile();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
