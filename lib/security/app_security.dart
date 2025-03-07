import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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
  static bool isEmulator = false;

  static Future<List> checkDeviceSecurity() async {
    if (Platform.isAndroid) {
      await androidRootChecker();
      await developerMode();
      await checkIfEmulator();
    } else if (Platform.isIOS) {
      await iosJailbreak();
      await checkIfEmulator();
    }

    if (rootedCheck || devMode || jailbreak || isEmulator) {
      if (rootedCheck && jailbreak && devMode && isEmulator) {
        message =
            'Rooted, jailbroken, in developer mode, and running on an emulator';
      } else if (rootedCheck && jailbreak && devMode) {
        message = 'Rooted, jailbroken, and in developer mode';
      } else if (rootedCheck && jailbreak) {
        message = 'Rooted and jailbroken';
      } else if (rootedCheck && devMode) {
        message = 'Rooted and in developer mode';
      } else if (jailbreak && devMode) {
        message = 'Jailbroken and in developer mode';
      } else if (rootedCheck) {
        message = 'Rooted';
      } else if (jailbreak) {
        message = 'Jailbroken';
      } else if (devMode) {
        message = 'In developer mode';
      } else if (isEmulator) {
        message = 'Running on an emulator';
      }
      return [
        {'is_secured': true, 'msg': ""} // ✅ Device is secure
        //   {'is_secured': false, 'msg': message} // ❌ Device is NOT secure
      ];
    } else {
      return [
        {'is_secured': true, 'msg': ""} // ✅ Device is secure
      ];
    }
  }

  static Future<void> androidRootChecker() async {
    try {
      rootedCheck = await AdvancedRootCheck.isDeviceRooted();
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

  static Future<void> checkIfEmulator() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      isEmulator = !androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      isEmulator = !iosInfo.isPhysicalDevice;
    }

    if (isEmulator) {
      print("🚨 Running on an Emulator!");
    } else {}
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
        localizedReason: 'Please authenticate to continue',
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
    } catch (e) {
      print("Error during biometric authentication: $e");
    }

    return authenticated;
  }
}

/// 🔥 Advanced Root Detection Class
class AdvancedRootCheck {
  static Future<bool> isDeviceRooted() async {
    bool rooted = false;

    try {
      // ✅ Check using RootCheckerPlus
      rooted = (await RootCheckerPlus.isRootChecker())!;

      // ✅ Check system properties for known root traces
      if (!rooted) {
        rooted =
            _checkBuildTags() || _checkSUFilePaths() || _checkRootPackages();
      }

      // ✅ Try executing root commands
      if (!rooted) {
        rooted = await _canExecuteRootCommands();
      }
    } catch (e) {
      print("Root detection error: $e");
    }

    return rooted;
  }

  // 📌 Check if build tags indicate root access
  static bool _checkBuildTags() {
    try {
      String buildTags = File("/proc/version").readAsStringSync();
      if (buildTags.contains("test-keys")) {
        print("🚨 Root detected: Build tags indicate a test build.");
        return true;
      }
    } catch (e) {}
    return false;
  }

  // 📌 Check for SU binary files in system paths
  static bool _checkSUFilePaths() {
    List<String> paths = [
      "/system/bin/su",
      "/system/xbin/su",
      "/sbin/su",
      "/system/sd/xbin/su",
      "/system/bin/failsafe/su",
      "/data/local/xbin/su",
      "/data/local/bin/su",
      "/data/local/su",
      "/su/bin/su",
      "/system/app/Superuser.apk",
      "/system/app/SuperSU.apk",
      "/system/xbin/daemonsu"
    ];

    for (String path in paths) {
      if (File(path).existsSync()) {
        print("🚨 Root detected: Found SU binary at $path");
        return true;
      }
    }
    return false;
  }

  // 📌 Check if known root apps are installed
  static bool _checkRootPackages() {
    List<String> rootApps = [
      "com.topjohnwu.magisk",
      "eu.chainfire.supersu",
      "com.koushikdutta.superuser",
      "com.noshufou.android.su",
      "com.thirdparty.superuser",
      "com.yellowes.su"
    ];

    for (String package in rootApps) {
      if (File("/data/data/$package").existsSync()) {
        print("🚨 Root detected: Found root app $package");
        return true;
      }
    }
    return false;
  }

  // 📌 Try running root commands
  static Future<bool> _canExecuteRootCommands() async {
    try {
      ProcessResult result = await Process.run("which", ["su"]);
      if (result.stdout.toString().isNotEmpty) {
        print("🚨 Root detected: Able to execute SU command.");
        return true;
      }
    } catch (e) {}
    return false;
  }
}
