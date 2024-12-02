import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:root_checker_plus/root_checker_plus.dart';

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
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    animation = CurvedAnimation(
        parent: _controller, curve: Curves.fastEaseInToSlowEaseOut);

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeApp();
    });
    super.onInit();
  }

  Future<void> initializeApp() async {
    await checkDeviceSecurity();
    // await determineInitialRoute();
  }

  Future<void> checkDeviceSecurity() async {
    if (Platform.isAndroid) {
      await androidRootChecker();
      await developerMode();
    } else if (Platform.isIOS) {
      await iosJailbreak();
    }
    if (rootedCheck || devMode || jailbreak) {
      if (rootedCheck && jailbreak && devMode) {
        message = 'rooted, jailbroken, and in developer mode';
      } else if (rootedCheck && jailbreak) {
        message = 'rooted and jailbroken';
      } else if (rootedCheck && devMode) {
        message = 'rooted and in developer mode';
      } else if (jailbreak && devMode) {
        message = 'jailbroken and in developer mode';
      } else if (rootedCheck) {
        message = 'rooted';
      } else if (jailbreak) {
        message = 'jailbroken';
      } else if (devMode) {
        message = 'in developer mode';
      }
      showExitWarning(message);
    } else {
      await determineInitialRoute();
    }
  }

  Future<void> androidRootChecker() async {
    try {
      rootedCheck = (await RootCheckerPlus.isRootChecker())!;
    } on PlatformException {
      rootedCheck = false;
    }
  }

  Future<void> developerMode() async {
    try {
      devMode = (await RootCheckerPlus.isDeveloperMode())!;
    } on PlatformException {
      devMode = false;
    }
  }

  Future<void> iosJailbreak() async {
    try {
      jailbreak = (await RootCheckerPlus.isJailbreak())!;
    } on PlatformException {
      jailbreak = false;
    }
  }

  void showExitWarning(msg) {
    CustomDialog().securityDialog(
        "Security Warning",
        'Your device is $msg. '
            'For security reasons, the app will now close.', () {
      if (Platform.isAndroid || Platform.isIOS) {
        SystemNavigator.pop();
      } else {
        exit(0);
      }
    });
    // showDialog(
    //   context: Get.context!,
    //   barrierDismissible: false,
    //   builder: (context) => AlertDialog(
    //     title: Text('Security Warning'),
    //     content: Text(
    //       'Your device is rooted, jailbroken, or in developer mode. '
    //       'For security reasons, the app will now close.',
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () {
    //
    //         },
    //         child: Text('OK'),
    //       ),
    //     ],
    //   ),
    // );
  }

  Future<void> determineInitialRoute() async {
    isNetConn.value = true;
    final data = await Authentication().getUserLogin();

    if (data != null) {
      Functions.getAccountStatus(data["mobile_no"], (obj) async {
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
