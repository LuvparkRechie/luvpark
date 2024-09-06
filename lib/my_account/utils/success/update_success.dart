import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_body.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/routes/routes.dart';

// ignore: must_be_immutable
class UpdateInfoSuccess extends StatefulWidget {
  const UpdateInfoSuccess({
    super.key,
  });

  @override
  State<UpdateInfoSuccess> createState() => _UpdateInfoSuccessState();
}

class _UpdateInfoSuccessState extends State<UpdateInfoSuccess> {
  Duration countdownDuration = const Duration(seconds: 3);
  Duration duration = const Duration();
  String twoDigets(int n) => n.toString().padLeft(2, '0');

  Timer? timer;
  double? mediaQueryWidth;
  bool isCountdown = true;
  BuildContext? mainContext;
  String inputPin = "";

  @override
  void initState() {
    inputPin = "";
    startTimer();
    resetTimer();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void resetTimer() {
    isCountdown = true;

    setState(() {
      duration = countdownDuration;
    });
  }

  void addTime() {
    final addSeconds = isCountdown ? -1 : 1;

    setState(() {
      var seconds = duration.inSeconds + addSeconds;

      if (seconds == 0) {
        timer?.cancel();
        isCountdown = false;
        Get.offAllNamed(Routes.login);
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final seconds = twoDigets(duration.inSeconds.remainder(60));
    Size screenSize = MediaQuery.of(context).size;
    return CustomScaffold(
        canPop: false,
        children: Padding(
          padding: EdgeInsets.fromLTRB(20, screenSize.height * .1, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Image(
                    height: 120,
                    width: 150,
                    image:
                        AssetImage("assets/images/succesfull_transaction.png"),
                  ),
                ),
                Container(
                  height: 10,
                ),
                const Center(
                  child: CustomTitle(
                    text: 'Congratulations',
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Container(
                  height: 20,
                ),
                const Center(
                  child: CustomParagraph(
                    text:
                        "You have successfully updated your account. We are redirecting you to Login Page.",
                  ),
                ),
                Container(
                  height: screenSize.height * .1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomParagraph(
                      text: "Redirecting in  ",
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.center,
                    ),
                    CustomParagraph(
                      text: seconds,
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
