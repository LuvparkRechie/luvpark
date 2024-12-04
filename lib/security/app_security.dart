import 'dart:io';

import 'package:flutter/services.dart';
import 'package:root_checker_plus/root_checker_plus.dart';

class AppSecurity {
  static String message = '';
  static bool rootedCheck = false;
  static bool devMode = false;
  static bool jailbreak = false;

  static Future<List> checkDeviceSecurity() async {
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
      return [
        //{'is_secured': false, 'msg': message} // please uncomment
        {'is_secured': true, 'msg': ""}
      ];
    } else {
      return [
        {'is_secured': true, 'msg': ""}
      ];
    }
  }

  static Future<void> androidRootChecker() async {
    try {
      rootedCheck = (await RootCheckerPlus.isRootChecker())!;
    } on PlatformException {
      rootedCheck = false;
    }
  }

  static Future<void> developerMode() async {
    try {
      devMode = (await RootCheckerPlus.isDeveloperMode())!;
    } on PlatformException {
      devMode = false;
    }
  }

  static Future<void> iosJailbreak() async {
    try {
      jailbreak = (await RootCheckerPlus.isJailbreak())!;
    } on PlatformException {
      jailbreak = false;
    }
  }
}
