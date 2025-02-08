import 'dart:convert';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom_widgets/variables.dart';
import '../decryptor/decryptor.dart';

class Authentication {
  static EncryptedSharedPreferences encryptedSharedPreferences =
      EncryptedSharedPreferences();
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> clearStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    encryptedSharedPreferences.clear();
    prefs.clear();
  }

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

  //SET LAST BOOKING AREA_ID
  Future<void> setLastBooking(data) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('last_booking', data);
  }

  Future<dynamic> getLastBooking() async {
    final prefs = await SharedPreferences.getInstance();

    String? data = prefs.getString('last_booking');

    if (data == null) {
      return [];
    }
    if (data == '') {
      return [];
    }
    return jsonDecode(data);
  }

  //SEt logout status
  Future<void> setLogoutStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('is_logout', status);
  }

  Future<bool?> getLogoutStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isLogout = prefs.getBool("is_logout");

    return isLogout;
  }

  //SEt biometric  status
  Future<void> setBiometricStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('enable_biometric', status);
  }

  Future<bool?> getBiometricStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isLogout = prefs.getBool("enable_biometric");

    if (isLogout == null) {
      return false;
    } else {
      return isLogout;
    }
  }

  //SEt background process  status
  Future<void> enableTimer(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('enable_timer', status);
  }

  Future<bool?> getTimerStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isEnabled = prefs.getBool("enable_timer");

    if (isEnabled == null) {
      return false;
    } else {
      return isEnabled;
    }
  }

  Future<void> setAppVersion(int appVers) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('app_version', appVers);
  }

  Future<int> getAppVersion() async {
    final prefs = await SharedPreferences.getInstance();
    int? appVers = prefs.getInt("app_version");

    if (appVers == null) {
      return 0;
    } else {
      return appVers;
    }
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  //encrypt data
  Future<void> encryptData(String plaintText, [String? secretKey]) async {
    final prefs = await SharedPreferences.getInstance();
    String skey = secretKey ?? "luvpark";

    String inatayaaa = jsonEncode(skey);
    Uint8List aesKey = Functions.generateKey(inatayaaa, 16);
    final nonce = Variables.generateRandomNonce();

    final encrypted =
        await Variables.encryptData(aesKey, nonce, json.encode(plaintText));

    final concatenatedArray = Variables.concatBuffers(nonce, encrypted);
    final output = Variables.arrayBufferToBase64(concatenatedArray);

    prefs.setString("encrypt_data", output);
  }

  Future<dynamic> getEncryptedSmsKeys(String plaintText,
      [String? secretKey]) async {
    String hash = "";
    String skey = secretKey ?? "luvpark";
    final prefs = await SharedPreferences.getInstance();
    final output = prefs.getString("encrypt_data");
    hash = Uri.encodeComponent(output!);
    String inatayaaa = jsonEncode(skey);
    Uint8List aesKey = Functions.generateKey(inatayaaa, 16);

    final encryptedData = base64Decode(Uri.decodeComponent(hash));

    final nonces = encryptedData.sublist(0, 16);

    final cipherText = encryptedData.sublist(16);

    final decryptedData =
        await Encryption().decryptData(aesKey, nonces, cipherText);
    final data = utf8.decode(decryptedData);
    final dataList = await jsonDecode(data);

    return jsonDecode(dataList);
  }
}
