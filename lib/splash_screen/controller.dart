import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:get/get.dart';
import 'package:luvpark/security/app_security.dart';
import 'package:new_version_plus/new_version_plus.dart';

import '../auth/authentication.dart';
import '../custom_widgets/variables.dart';
import '../functions/functions.dart';
import '../http/http_request.dart';
import '../routes/routes.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;
  RxBool isNetConn = true.obs;
  bool rootedCheck = false;
  bool devMode = false;
  bool jailbreak = false;
  String message = '';
  String release = "";
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

    final response = await HttpRequest(api: "").pingInternet();
    if (response == "Success") {
      final newVersion = NewVersionPlus(
        iOSId: 'com.cmds.luvpark',
        androidId: 'com.cmds.luvpark',
      );

      basicStatusCheck(newVersion);
    } else {
      isNetConn.value = false;
    }
  }

  basicStatusCheck(NewVersionPlus newVersion) async {
    final version = await newVersion.getVersionStatus();
    final data = await Authentication().getUserLogin();
    if (version != null && version.canUpdate) {
      release = version.releaseNotes ?? "A new version is available!";
      newVersion.showUpdateDialog(
          context: Get.context!,
          versionStatus: version,
          dialogTitle: 'Update Required',
          dialogText:
              'A new version (${version.storeVersion}) is available. Please update to continue using the app.',
          launchModeVersion: LaunchModeVersion.external,
          allowDismissal: false,
          dismissAction: () {
            ScaffoldMessenger.of(Get.context!).showSnackBar(
              const SnackBar(
                content: Text(
                    'The app will now close. Please update from the store.'),
                duration: Duration(seconds: 2),
              ),
            );
            Future.delayed(Duration(seconds: 2), () {
              FlutterExitApp.exitApp(iosForceExit: true);
            });
          });
      return;
    } else {
      final vhData = await Functions.getVhBrands();
      if (vhData["response"] == "No Internet") {
        isNetConn.value = false;
        return;
      }
      if (vhData["response"] == "Success") {
        if (data != null) {
          Functions.getAccountStatus(data["mobile_no"], (obj) async {
            final items = obj[0]["items"];
            print("items $items");

            if (!obj[0]["has_net"]) {
              isNetConn.value = false;
              return;
            }
            if (items.isEmpty) {
              Get.offAndToNamed(Routes.onboarding);
              return;
            }
            if (items[0]["login_attempt"] >= 5) {
              Get.toNamed(
                Routes.activate,
                arguments: items["mobile_no"],
              );
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
                Get.offAndToNamed(Routes.map);
                return;
              }
            }
          });
        } else {
          Timer(const Duration(seconds: 3), () {
            Get.offAndToNamed(Routes.onboarding);
          });
        }
      } else {
        isNetConn.value = false;
      }
    }
  }

  advancedStatusCheck(NewVersionPlus newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      debugPrint(status.releaseNotes);
      debugPrint(status.appStoreLink);
      debugPrint(status.localVersion);
      debugPrint(status.storeVersion);
      debugPrint(status.canUpdate.toString());
      newVersion.showUpdateDialog(
        context: Get.context!,
        versionStatus: status,
        dialogTitle: 'Custom Title',
        dialogText: 'Custom Text',
        launchModeVersion: LaunchModeVersion.external,
        allowDismissal: false,
      );
    }
  }

  @override
  void onClose() {
    _controller.dispose();
    super.onClose();
  }

  SplashController();
}
