import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_body.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/routes/routes.dart';

class ForgetPasswordSuccess extends StatefulWidget {
  const ForgetPasswordSuccess({
    super.key,
  });

  @override
  State<ForgetPasswordSuccess> createState() => _ForgetPasswordSuccessState();
}

class _ForgetPasswordSuccessState extends State<ForgetPasswordSuccess> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      canPop: false,
      bodyColor: AppColor.bodyColor,
      children: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(height: 150),
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  "assets/images/first_ellipse.png",
                  scale: 1.2,
                ),
                Image.asset(
                  "assets/images/second_ellipse.png",
                  scale: 1.4,
                ),
                Image.asset(
                  "assets/images/shield_success.png",
                  scale: 1.6,
                ),
              ],
            ),
            Container(
              height: 40,
            ),
            CustomTitle(
              text: 'Success',
              color: AppColor.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            Container(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: CustomParagraph(
                text:
                    'Your password has been reset successfully. You can now log in with your new password',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: "Back to Login",
                    onPressed: () async {
                      Get.offAllNamed(Routes.login);
                    },
                  ),
                  Container(
                    height: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
