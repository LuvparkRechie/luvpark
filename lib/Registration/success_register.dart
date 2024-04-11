import 'dart:async';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/login/class/login_class.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';

class SuccessRegistration extends StatefulWidget {
  final String mobile;
  final String acctStatusTxt;
  const SuccessRegistration(
      {super.key, required this.mobile, required this.acctStatusTxt});

  @override
  State<SuccessRegistration> createState() => _SuccessRegistrationState();
}

class _SuccessRegistrationState extends State<SuccessRegistration> {
  final EncryptedSharedPreferences encryptedSharedPreferences =
      EncryptedSharedPreferences();
  Duration countdownDuration = const Duration(seconds: 3);
  Duration duration = const Duration();
  String twoDigets(int n) => n.toString().padLeft(2, '0');

  Timer? timer;
  bool isCountdown = true;
  String inputPin = "";
  bool isClicked = false;
  bool isInternetConnected = true;

  @override
  void initState() {
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

        Variables.encryptedSharedPreferences
            .getString('akong_password')
            .then((String value) {
          LoginComponent().loginFunc(value, widget.mobile, context, (callBack) {
            setState(() {
              if (callBack[1] == "No Internet") {
                isInternetConnected = false;
              } else {
                isInternetConnected = true;
              }
            });
          });
        });
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final seconds = twoDigets(duration.inSeconds.remainder(60));
    return PopScope(
      canPop: true,
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1)),
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 0,
              backgroundColor: !isInternetConnected
                  ? AppColor.bodyColor
                  : AppColor.mainColor,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: !isInternetConnected
                    ? AppColor.bodyColor
                    : AppColor.mainColor,
                statusBarBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.light,
              ),
            ),
            body: Container(
              width: screenSize.width,
              height: screenSize.height,
              color: !isInternetConnected
                  ? AppColor.bodyColor
                  : AppColor.mainColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: !isInternetConnected
                    ? NoInternetConnected(
                        onTap: () {
                          setState(() {
                            isInternetConnected = true;
                          });
                          startTimer();
                          resetTimer();
                        },
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.check,
                                color: Colors.green, size: 30),
                          ),
                          Container(
                            height: 20,
                          ),
                          CustomDisplayText(
                            label: "Congratulations!",
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),

                          Container(
                            height: 11,
                          ),
                          Text(
                            "Let's get started. Your account has been successfully ${widget.acctStatusTxt}!",
                            style: GoogleFonts.varela(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            height: screenSize.height * .25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomDisplayText(
                                label: "Redirecting in  ",
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                              CustomDisplayText(
                                label: seconds,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          // CustomButtonRegistration(
                          //   label: "Go to Dashboard",
                          //   color: Colors.white,
                          //   textColor: AppColor.mainColor,
                          //   onTap: () async {
                          //     if (isClicked) return;
                          //     setState(() {
                          //       isClicked = true;
                          //     });

                          //   },
                          // ),
                          // Container(
                          //   height: 10,
                          // ),
                          // CustomButtonRegistration(
                          //   label: "More security options",
                          //   textColor: Colors.white,
                          //   onTap: () {
                          //     // showAlertDialog(context, "Error",
                          //     //     "We're currently working on it, Please try again later.",
                          //     //     () {
                          //     //   Navigator.of(context).pop();
                          //     // });
                          //     CustomModal(context: context).loader();
                          //     Future.delayed(const Duration(seconds: 2), () {
                          //       Navigator.pop(context);
                          //       Navigator.push(
                          //           context,
                          //           PageTransition(
                          //             type: PageTransitionType.leftToRightWithFade,
                          //             duration: const Duration(seconds: 1),
                          //             alignment: Alignment.centerLeft,
                          //             child: const MoreSecurityOptions(),
                          //           ));
                          //     });
                          //   },
                          // ),
                        ],
                      ),
              ),
            )),
      ),
    );
  }
}
