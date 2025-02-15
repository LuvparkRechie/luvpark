import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/login/controller.dart';
import 'package:luvpark/splash_screen/controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginScreenController());
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: AppColor.primaryColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColor.primaryColor,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: Obx(
          () => !controller.isNetConn.value
              ? NoInternetConnected(
                  onTap: controller.initializeApp,
                )
              : ScaleTransition(
                  scale: controller.animation,
                  child: Center(
                    child: Hero(
                      tag: "logo",
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.asset(
                          "assets/images/luvpark_logo.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
        ));
  }
}
