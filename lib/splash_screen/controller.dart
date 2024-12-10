import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:luvpark/security/app_security.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/variables.dart';
import '../http/api_keys.dart';
import '../http/http_request.dart';
import '../sqlite/vehicle_brands_model.dart';
import '../sqlite/vehicle_brands_table.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;
  RxBool isNetConn = true.obs;
  bool rootedCheck = false;
  bool devMode = false;
  bool jailbreak = false;
  String message = '';
  @override
  void onInit() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    animation = CurvedAnimation(
        parent: _controller, curve: Curves.fastEaseInToSlowEaseOut);

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeApp();
    });
    super.onInit();
  }

  Future<void> initializeApp() async {
    List appSecurity = await AppSecurity.checkDeviceSecurity();
    bool isAppSecured = appSecurity[0]["is_secured"];
    if (isAppSecured) {
      await determineInitialRoute();
    } else {
      Variables.showSecurityPopUp(appSecurity[0]["msg"]);
    }
  }

  Future<void> determineInitialRoute() async {
    isNetConn.value = true;
    final data = await Authentication().getUserLogin();

    if (data != null) {
      Functions.getAccountStatus(data["mobile_no"], (obj) async {
        await Future.delayed(Duration(seconds: 4));
        final items = obj[0]["items"];
        if (!obj[0]["has_net"]) {
          isNetConn.value = false;
          return;
        }
        if (items.isEmpty) {
          return;
        }
        if (items[0]["login_attempt"] >= 3) {
          return;
        }
        if (items[0]["is_active"] == "N") {
          Get.offAndToNamed(Routes.login);
          return;
        } else {
          final userLogin = await Authentication().getUserLogin();

          if (userLogin["is_login"] == "N") {
            Get.offAndToNamed(Routes.login);
            return;
          } else {
            String apiParam = ApiKeys.gApiLuvParkGetVehicleBrand;
            isNetConn.value = true;

            HttpRequest(api: apiParam).get().then((returnBrandData) async {
              if (returnBrandData == "No Internet") {
                isNetConn.value = false;
                CustomDialog().internetErrorDialog(Get.context!, () {
                  Get.back();
                });
                return;
              }
              if (returnBrandData == null) {
                isNetConn.value = false;
                CustomDialog().serverErrorDialog(Get.context!, () {
                  Get.back();
                });
              } else {
                isNetConn.value = true;
                Variables.gVBrand.value = returnBrandData["items"];
                VehicleBrandsTable.instance.deleteAll();
                for (var dataRow in returnBrandData["items"]) {
                  var vbData = {
                    VHBrandsDataFields.vhTypeId:
                        int.parse(dataRow["vehicle_type_id"].toString()),
                    VHBrandsDataFields.vhBrandId:
                        int.parse(dataRow["vehicle_brand_id"].toString()),
                    VHBrandsDataFields.vhBrandName:
                        dataRow["vehicle_brand_name"].toString(),
                    VHBrandsDataFields.image: dataRow["imageb64"] == null
                        ? ""
                        : dataRow["imageb64"].toString().replaceAll("\n", ""),
                  };
                  await VehicleBrandsTable.instance.insertUpdate(vbData);
                }
                Get.offAndToNamed(Routes.map);
              }
            });
            return;
          }
        }
      });
    } else {
      Authentication().setShowPopUpNearest(false);

      Timer(const Duration(seconds: 3), () {
        Get.offAndToNamed(Routes.onboarding);
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
