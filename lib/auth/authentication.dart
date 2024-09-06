import 'dart:convert';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication {
  static EncryptedSharedPreferences encryptedSharedPreferences =
      EncryptedSharedPreferences();
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
    encryptedSharedPreferences.setString('akong_password', myPass);
  }

  Future<String> getPasswordBiometric() async {
    return encryptedSharedPreferences.getString('akong_password');
  }

  void clearPassword() {
    encryptedSharedPreferences.remove('akong_password');
  }

  Future<void> setUserData(data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', data);
  }

  Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userData');
  }

  Future<dynamic> getUserData2() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('userData');

    if (data == null) {
      return null;
    }
    return jsonDecode(data);
  }

  //SET LOGIN
  Future<void> setLogin(loginData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('auth_login', loginData);
  }

  //RETRIEVE LOGIN
  Future<dynamic> getUserLogin() async {
    final prefs = await SharedPreferences.getInstance();

    String? data = prefs.getString('auth_login');

    if (data == null) {
      return null;
    }
    return jsonDecode(data);
  }

  //SET BRGY
  Future<void> setBrgy(loginData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('brgy_data', loginData);
  }

  //SET CITY
  Future<void> setCity(loginData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('city_data', loginData);
  }

  //SET PROVINCE
  Future<void> setProvince(loginData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('province_data', loginData);
  }

  //SET LOGIN
  Future<void> setProfilePic(loginData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('profile_pic', loginData);
  }

  Future<dynamic> getUserProfilePic() async {
    final prefs = await SharedPreferences.getInstance();

    String? data = prefs.getString('profile_pic');

    if (data == null || data.isEmpty) {
      return "";
    }
    return jsonDecode(data);
  }

  //GET USER ID
  Future<int> getUserId() async {
    final item = await Authentication().getUserData();
    if (item == null) {
      return 0;
    } else {
      int userId = jsonDecode(item)["user_id"];

      return userId;
    }
  }

  //SET SHOW POPUP NEAEST
  Future<void> setShowPopUpNearest(bool isShow) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isShowPopUp', isShow);
  }

  Future<bool> getPopUpNearest() async {
    final prefs = await SharedPreferences.getInstance();

    bool? isShow = prefs.getBool("isShowPopUp");

    return isShow!;
  }

  //SET LAST BOOKING AREA_ID
  Future<void> setLastBooking(data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('last_booking', data);
  }

  Future<dynamic> getLastBooking() async {
    final prefs = await SharedPreferences.getInstance();

    String? data = prefs.getString('last_booking');

    if (data == null) {
      return "";
    }
    return jsonDecode(data);
  }
}
