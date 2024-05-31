import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/http_request/http_request_model.dart';
import 'package:luvpark/login/login.dart';

class LockScreen extends StatefulWidget {
  final int timeDuration;
  final int mobile;
  const LockScreen(
      {super.key, required this.timeDuration, required this.mobile});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  //timer
  // Duration countdownDuration = const Duration(minutes: 5);
  Duration duration = const Duration();
  String twoDigets(int n) => n.toString().padLeft(2, '0');
  Timer? timer;
  bool isCountdown = true;

  @override
  void initState() {
    super.initState();
    startTimer();
    resetTimer();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void resetTimer() {
    isCountdown = true;

    setState(() {
      duration = Duration(minutes: widget.timeDuration);
    });
  }

  void addTime() {
    final addSeconds = isCountdown ? -1 : 1;

    setState(() {
      final seconds = duration.inSeconds + addSeconds;

      if (seconds == 0) {
        timer?.cancel();
        isCountdown = false;
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  void unlockAccount() {
    CustomModal(context: context).loader();
    HttpRequest(
        api: ApiKeys.gApiSubFolderPutClearLockTimer,
        parameters: {"mobile_no": widget.mobile}).put().then((returnPost) {
      if (returnPost == "No Internet") {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again", () {
          unlockAccount();
          Navigator.pop(context);
        });
        return;
      }
      if (returnPost == null) {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      } else {
        if (returnPost["success"] == 'Y') {
          Timer(const Duration(seconds: 1), () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(
                  index: 1,
                ),
              ),
            );
          });
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        } else {
          Navigator.pop(context);
          showAlertDialog(context, "Error", returnPost['msg'], () {
            Navigator.of(context).pop();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = twoDigets(duration.inMinutes.remainder(60));
    final seconds = twoDigets(duration.inSeconds.remainder(60));

    if (int.parse(minutes) == 0 && int.parse(seconds) == 1) {
      setState(() {
        timer?.cancel();
      });
      SchedulerBinding.instance.addPostFrameCallback((_) {
        unlockAccount();
      });
    }
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: PopScope(
        // onPopInvoked: () async => false,
        onPopInvoked: (didPop) async => false,
        child: SafeArea(
          child: Scaffold(
            body: Container(
              color: AppColor.bodyColor,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image(
                      height: MediaQuery.of(context).size.height * 0.30,
                      width: MediaQuery.of(context).size.width,
                      image: const AssetImage(
                        "assets/images/lock_screen.png",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: AutoSizeText(
                        "ACCOUNT LOCKED",
                        style: GoogleFonts.prompt(
                          color: AppColor.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.prompt(
                                  color: AppColor.primaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        "Your account has been locked due to multiple failed attempts. It will be unlocked after ",
                                    style: GoogleFonts.prompt(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "$minutes:$seconds ",
                                    style: GoogleFonts.prompt(
                                      color: Colors.blue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "minutes.",
                                    style: GoogleFonts.prompt(
                                      color: AppColor.primaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
