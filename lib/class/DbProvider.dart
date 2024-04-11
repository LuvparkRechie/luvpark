// ignore_for_file: file_names

import 'package:shared_preferences/shared_preferences.dart';

class DbProvider {
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  void saveAuthState(bool status) async {
    final instance = await prefs;
    instance.setBool("status", status);
  }

  Future<bool> getAuthState() async {
    final instance = await prefs;
    if (instance.containsKey("status")) {
      final value = instance.getBool("status");
      return value!;
    } else {
      return false;
    }
  }

  void saveAuthTransaction(bool status) async {
    final instance = await prefs;
    instance.setBool("status_trans", status);
  }

  Future<bool> getAuthTransaction() async {
    final instance = await prefs;
    if (instance.containsKey("status_trans")) {
      final value = instance.getBool("status_trans");
      return value!;
    } else {
      return false;
    }
  }
}
