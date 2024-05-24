import 'package:flutter/material.dart';

import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/login/login.dart';

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
    return CustomParentWidget(
      appbarColor: AppColor.bodyColor,
      child: Padding(
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
            CustomDisplayText(
              label: 'Woo hooo!',
              color: AppColor.primaryColor,
              fontWeight: FontWeight.bold,
            ),
            Container(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: CustomDisplayText(
                label:
                    'Your password has been reset successfully. You can now log in with your new password',
                alignment: TextAlign.center,
                maxLines: 2,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    label: "Back to Login",
                    onTap: () async {
                      Variables.pageTrans(
                          LoginScreen(
                            index: 1,
                          ),
                          context);
                    },
                  ),
                  Container(
                    height: 10,
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
