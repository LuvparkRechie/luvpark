import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  bool isInternetConnected = true;
  RxBool gg = false.obs;
  RxInt tabIndex = 0.obs;
  List tabName = [
    {"name": "Settings", "icon": Icons.settings},
    {"name": "Personal", "icon": Icons.person},
  ];

  void onTap(int index) {
    tabIndex.value = index;
    update();
  }

  @override
  void onInit() {
    tabIndex.value = 0;
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  SettingsController();
}
