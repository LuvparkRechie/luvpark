import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/lock_screen/controller.dart';

import '../custom_widgets/custom_button.dart';

class LockScreen extends GetView<LockScreenController> {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.bodyColor,
        body: SafeArea(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: MediaQuery.of(context).size.width,
              child: Obx(
                () => !controller.hasNet.value
                    ? NoInternetConnected(
                        onTap: controller.unlockAccount,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/images/account_locked.svg",
                            width: MediaQuery.of(context).size.width / 2,
                            height: MediaQuery.of(context).size.width / 2,
                          ),
                          Container(height: 30),
                          CustomTitle(
                            text: "Account Locked",
                            color: Color(0xFF0078FF),
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                          Container(height: 10),
                          CustomParagraph(
                            textAlign: TextAlign.center,
                            text:
                                "Your account is locked.\nPlease wait until ${controller.formattedTime.value}.",
                          ),
                          Container(
                              height: MediaQuery.of(context).size.height * .15),
                          CustomButton(
                            text: "Switch Account",
                            onPressed: controller.switchAccount,
                          )
                        ],
                      ),
              )),
        ),
      ),
    );
  }
}
