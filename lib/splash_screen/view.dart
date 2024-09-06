import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/no_internet.dart';
import 'package:luvpark_get/login/controller.dart';
import 'package:luvpark_get/splash_screen/controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginScreenController());
    return Scaffold(
        backgroundColor: Colors.white,
        body: Obx(
          () => !controller.isNetConn.value
              ? NoInternetConnected(
                  onTap: controller.determineInitialRoute,
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
                          "assets/images/logo.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
        ));
  }
}
