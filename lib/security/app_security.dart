import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
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
        //   {'is_secured': false, 'msg': message}
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

  static Future<bool> authenticateBio() async {
    final LocalAuthentication auth = LocalAuthentication();

    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
        localizedReason: 'Please authenticate to quick',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Biometric authentication required!',
            cancelButton: 'No thanks',
          ),
          IOSAuthMessages(
            cancelButton: 'No thanks',
          ),
        ],
      );
    } catch (e) {}

    return authenticated;
  }
}
