import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/login/controller.dart';
import 'package:luvpark_get/routes/routes.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;
  RxBool isNetConn = true.obs;

  @override
  void onInit() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    animation = CurvedAnimation(
        parent: _controller, curve: Curves.fastEaseInToSlowEaseOut);

    _controller.forward();
    determineInitialRoute();
    super.onInit();
  }

  Future<void> determineInitialRoute() async {
    isNetConn.value = true;
    final data = await Authentication().getUserLogin();

    if (data != null) {
      final LoginScreenController lgCt = Get.find<LoginScreenController>();

      lgCt.getAccountStatus(Get.context, data["mobile_no"], (obj) async {
        final items = obj[0]["items"];
        if (!obj[0]["has_net"]) {
          isNetConn.value = false;
          return;
        }
        if (items.isEmpty) {
          return;
        }

        if (items[0]["is_active"] == "N") {
          Get.toNamed(Routes.login);
        } else {
          final userLogin = await Authentication().getUserLogin();

          if (userLogin["is_login"] == "N") {
            Get.toNamed(Routes.login);
          } else {
            final uPass = await Authentication().getPasswordBiometric();
            Map<String, dynamic> postParam = {
              "mobile_no": data["mobile_no"],
              "pwd": uPass,
            };
            lgCt.postLogin(Get.context, postParam, (data) {
              if (!data[0]["has_net"]) {
                isNetConn.value = false;
                return;
              }
              isNetConn.value = true;
              if (data[0]["items"].isNotEmpty) {
                Get.toNamed(Routes.map);
              }
            });
          }
        }
      });
    } else {
      Authentication().setShowPopUpNearest(false);

      Timer(const Duration(seconds: 3), () {
        Get.toNamed(Routes.onboarding);
      });
    }
  }

  @override
  void onClose() {
    _controller.dispose();
    super.onClose();
  }

  SplashController();
}
