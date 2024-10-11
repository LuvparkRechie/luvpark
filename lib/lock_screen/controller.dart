import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';

import '../http/api_keys.dart';
import '../http/http_request.dart';
import '../routes/routes.dart';

class LockScreenController extends GetxController {
  LockScreenController();
  final parameter = Get.arguments;

  RxString formattedTime = "".obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getParamData();
    });
  }

  void getParamData() async {
    DateTime timeNow = DateTime.now();
    DateTime localDate = DateTime.parse(parameter[0]["locked_expiry_on"]);

    DateTime parsedDateNow = DateTime(
        timeNow.year, timeNow.month, timeNow.day, timeNow.hour, timeNow.minute);
    DateTime parsedLocDate = DateTime(localDate.year, localDate.month,
        localDate.day, localDate.hour, localDate.minute);

    formattedTime.value = DateFormat('hh:mm a').format(parsedLocDate);

    if (parsedDateNow.isBefore(parsedLocDate)) {
      timeout(parsedLocDate);
    } else {
      unlockAccount();
    }
  }

  void timeout(DateTime localDate) {
    Timer.periodic(Duration(seconds: 3), (timer) {
      DateTime timeNow = DateTime.now();

      if (timeNow.isAfter(localDate) || timeNow.isAtSameMomentAs(localDate)) {
        timer.cancel(); // Stop the timer
        unlockAccount();
      }
    });
  }

  void unlockAccount() async {
    CustomDialog().loadingDialog(Get.context!);
    HttpRequest(
            api: ApiKeys.gApiSubFolderPutClearLockTimer,
            parameters: {"mobile_no": parameter[0]["mobile_no"]})
        .put()
        .then((returnPost) {
      Get.back();
      if (returnPost == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
          unlockAccount();
        });
        return;
      }
      if (returnPost == null) {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
          unlockAccount();
        });
      } else {
        if (returnPost["success"] == 'Y') {
          Get.back();
          Get.offAndToNamed(Routes.login);
        } else {
          CustomDialog().errorDialog(Get.context!, "Error", "No data found",
              () {
            Get.back();
            unlockAccount();
          });
        }
      }
    });
  }
}
