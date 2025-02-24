import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../custom_widgets/app_color.dart';
import '../../custom_widgets/custom_text.dart';
import '../../routes/routes.dart';

class SuccessRegistration extends StatefulWidget {
  const SuccessRegistration({super.key});

  @override
  State<SuccessRegistration> createState() => _SuccessRegistrationState();
}

class _SuccessRegistrationState extends State<SuccessRegistration> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Get.offAndToNamed(Routes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1)),
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 0,
              backgroundColor: AppColor.mainColor,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: AppColor.mainColor,
                statusBarBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.light,
              ),
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: AppColor.mainColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.check, color: Colors.green, size: 30),
                    ),
                    Container(
                      height: 20,
                    ),
                    const CustomTitle(
                      text: "Congratulations!",
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    Container(
                      height: 11,
                    ),
                    Text(
                      "Let's get started. Your account has been successfully registered.",
                      style: GoogleFonts.varela(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * .25,
                    ),
                    const CustomParagraph(
                      text: "Redirecting please wait ",
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                    Container(height: 20),
                    SizedBox(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey.shade400,
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
