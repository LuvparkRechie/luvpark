import 'dart:async';

import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/login/login.dart';

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
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => const LoginScreen(
                  index: 1,
                )),
          ),
        );
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final seconds = twoDigets(duration.inSeconds.remainder(60));
    Size screenSize = MediaQuery.of(context).size;
    return CustomParentWidget(
        onPop: false,
        child: Padding(
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
                Center(
                  child: CustomDisplayText(
                    label: 'Congratulations',
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Container(
                  height: 20,
                ),
                Center(
                  child: CustomDisplayText(
                    label:
                        "You have successfully updated your account. We are redirecting you to Login Page.",
                    color: AppColor.textSubColor,
                    fontWeight: FontWeight.normal,
                    alignment: TextAlign.center,
                  ),
                ),
                Container(
                  height: screenSize.height * .1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomDisplayText(
                      label: "Redirecting in  ",
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.normal,
                      alignment: TextAlign.center,
                    ),
                    CustomDisplayText(
                      label: seconds,
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w600,
                      alignment: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        appbarColor: AppColor.primaryColor);
  }
}
