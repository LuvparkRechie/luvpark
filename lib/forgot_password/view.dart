import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/custom_widgets/vertical_height.dart';
import 'package:luvpark/forgot_password/controller.dart';

import '../custom_widgets/app_color.dart';

class ForgotPassword extends GetView<ForgotPasswordController> {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("Forgot Password"),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Iconsax.arrow_left,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(overscroll: false),
          child: StretchingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            child: SingleChildScrollView(
              child: Form(
                key: controller.formKeyForgotPass,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 20),
                    CustomParagraph(
                      text:
                          "Enter your phone number below to receive password reset instructions.",
                    ),
                    Container(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomParagraph(
                        text: "Mobile Number",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    CustomMobileNumber(
                      keyboardType: TextInputType.phone,
                      hintText: "10 digit mobile number",
                      controller: controller.mobileNumber,
                      inputFormatters: [Variables.maskFormatter],
                      onChange: (value) {
                        controller.onMobileChanged(value);
                      },
                    ),
                    const VerticalHeight(height: 30),
                    CustomButton(
                      text: "Submit",
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (controller.formKeyForgotPass.currentState!
                            .validate()) {
                          controller.verifyMobile();
                        }
                      },
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
