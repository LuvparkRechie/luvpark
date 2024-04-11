import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:luvpark/classess/variables.dart';

class BiometricLogin {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> checkBiometrics() async {
    late bool checkBiometrics;
    try {
      checkBiometrics = await auth.canCheckBiometrics;

      return checkBiometrics;
    } on PlatformException {
      checkBiometrics = false;

      return checkBiometrics;
    }
  }

  void setPasswordBiometric(String myPass) async {
    Variables.encryptedSharedPreferences.setString('akong_password', myPass);
  }

  static Future<String> getPasswordBiometric(String myPass) async {
    return Variables.encryptedSharedPreferences.getString('akong_password');
  }

  void clearPassword() {
    Variables.encryptedSharedPreferences.remove('akong_password');
  }
}
