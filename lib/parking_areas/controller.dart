import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../functions/functions.dart';

class ParkingAreasController extends GetxController {
  ParkingAreasController();
  bool isInternetConnected = true;
  final dataNearest = Get.arguments["data"];
  final Function callback = Get.arguments["callback"];
  RxList searchedZone = [].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadDisplay = true.obs;
  RxList markerData = [].obs;
  RxBool isOpenParking = false.obs;
  Timer? debounce;

  void onSearch(String value) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    List subData = dataNearest;
    subData = dataNearest.where((e) {
      return e["park_area_name"]
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase()) ||
          e["address"].toString().toLowerCase().contains(value.toLowerCase());
    }).toList();

    Duration duration = const Duration(seconds: 2);
    debounce = Timer(duration, () {
      Future.delayed(Duration(milliseconds: 200), () {
        initData(subData);
      });
    });

    update();
  }

  void onListTap(bool load) {
    isLoading.value = load;
    update();
  }

  String getIconAssetForPwd(String parkingTypeCode, String vehicleTypes) {
    switch (parkingTypeCode) {
      case "S":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/dashboard_icon/street/cmp_street.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/street/motor_pwd_street.png';
        } else {
          return 'assets/dashboard_icon/street/car_pwd_street.png';
        }
      case "P":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/dashboard_icon/private/cmp_private.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/private/motor_pwd_private.png';
        } else {
          return 'assets/dashboard_icon/private/car_pwd_private.png';
        }
      case "C":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/dashboard_icon/commercial/cmp_commercial.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/commercial/motor_pwd_commercial.png';
        } else {
          return 'assets/dashboard_icon/commercial/car_pwd_commercial.png';
        }
      default:
        return 'assets/dashboard_icon/valet/valet.png';
    }
  }

  String getIconAssetForNonPwd(String parkingTypeCode, String vehicleTypes) {
    switch (parkingTypeCode) {
      case "S":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/dashboard_icon/street/car_motor_street.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/street/motor_street.png';
        } else {
          return 'assets/dashboard_icon/street/car_street.png';
        }
      case "P":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/dashboard_icon/private/car_motor_private.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/private/motor_private.png';
        } else {
          return 'assets/dashboard_icon/private/car_private.png';
        }
      case "C":
        if (vehicleTypes.contains("Motorcycle") &&
            vehicleTypes.contains("Trikes and Cars")) {
          return 'assets/dashboard_icon/commercial/car_motor_commercial.png';
        } else if (vehicleTypes.contains("Motorcycle")) {
          return 'assets/dashboard_icon/commercial/motor_commercial.png';
        } else {
          return 'assets/dashboard_icon/commercial/car_commercial.png';
        }
      case "V":
        return 'assets/dashboard_icon/valet/valet.png'; // Valet
      default:
        return 'assets/dashboard_icon/default.png'; // Fallback icon
    }
  }

  String formatTime(String time) {
    return "${time.substring(0, 2)}:${time.substring(2)}";
  }

  void initData(List data) async {
    FocusManager.instance.primaryFocus!.unfocus();
    isLoadDisplay.value = true;

    List<Future<Map<String, dynamic>>> futures =
        data.map<Future<Map<String, dynamic>>>((e) async {
      String finalSttime = formatTime(e["start_time"]);
      String finalEndtime = formatTime(e["end_time"]);
      bool isOpen =
          await Functions.checkAvailability(finalSttime, finalEndtime);
      e["is_open"] = isOpen; // Update the parking availability

      return e;
    }).toList();

    List<Map<String, dynamic>> results = await Future.wait(futures);

    searchedZone.value = results;
    isLoadDisplay.value = false;
  }

  void clearSearch() {
    initData(dataNearest);
  }

  @override
  void onInit() {
    initData(dataNearest);
    super.onInit();
  }
}
