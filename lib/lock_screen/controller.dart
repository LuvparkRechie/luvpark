import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';

import '../auth/authentication.dart';
import '../functions/functions.dart';
import '../http/api_keys.dart';
import '../http/http_request.dart';
import '../routes/routes.dart';
import '../sqlite/pa_message_table.dart';
import '../sqlite/reserve_notification_table.dart';

class LockScreenController extends GetxController {
  LockScreenController();
  final parameter = Get.arguments;
  RxBool hasNet = true.obs;

  RxString formattedTime = "".obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getParamData();
    });
  }

  void getParamData() async {
    DateTime timeNow = await Functions.getTimeNow();

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
    Timer.periodic(Duration(seconds: 3), (timer) async {
      DateTime timeNow = await Functions.getTimeNow();

      if (timeNow.isAfter(localDate) || timeNow.isAtSameMomentAs(localDate)) {
        timer.cancel(); // Stop the timer
        unlockAccount();
      }
    });
  }

  void unlockAccount() async {
    hasNet.value = true;
    CustomDialog().loadingDialog(Get.context!);
    HttpRequest(
            api: ApiKeys.unlockAccount,
            parameters: {"mobile_no": parameter[0]["mobile_no"]})
        .put()
        .then((returnPost) {
      Get.back();
      if (returnPost == "No Internet") {
        hasNet.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (returnPost == null) {
        hasNet.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
          unlockAccount();
        });
      } else {
        hasNet.value = true;
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

  void switchAccount() async {
    final uData = await Authentication().getUserData2();
    CustomDialog().confirmationDialog(Get.context!, "Switch Account",
        "Are you sure you want to switch Account?", "No", "Yes", () {
      Get.back();
    }, () async {
      Get.back();
      Functions.logoutUser(uData == null ? "" : uData["session_id"].toString(),
          (isSuccess) async {
        if (isSuccess["is_true"]) {
          await Authentication().setLogoutStatus(true);
          await Authentication().setBiometricStatus(false);
          await Authentication().remove("userData");
          await PaMessageDatabase.instance.deleteAll();
          NotificationDatabase.instance.deleteAll();
          AwesomeNotifications().cancelAllSchedules();
          AwesomeNotifications().cancelAll();
          Get.offAndToNamed(Routes.login);
        }
      });
    });
  }
}
