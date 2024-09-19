import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/auth/authentication.dart';

import '../../custom_widgets/alert_dialog.dart';
import '../../http/api_keys.dart';
import '../../http/http_request.dart';
import '../../notification_controller.dart';

class SendOtpController extends GetxController {
  SendOtpController();
  List paramArgs = Get.arguments["otpData"];
  final cbFunc = Get.arguments["cb"];
  TextEditingController pinController = TextEditingController();
  RxBool isLoading = false.obs;
  RxBool isInternetConn = true.obs;
  RxBool isOtpValid = true.obs;
  RxBool isRunning = false.obs;
  RxBool isCanSend = false.obs;
  Timer? timer;
  RxString inputPin = "".obs;
  RxInt minutes = 2.obs;
  RxInt seconds = 0.obs;
  RxInt initialMinutes = 2.obs;

  @override
  void onInit() {
    pinController = TextEditingController();
    startTimers();
    super.onInit();
  }

  Future<void> startTimers() async {
    const oneSecond = Duration(seconds: 1);
    timer = Timer.periodic(oneSecond, (timer) {
      if (minutes.value == 0 && seconds.value == 0) {
        timer.cancel(); // Stop the timer
        isRunning.value = false;
      } else if (seconds.value == 0) {
        minutes--;
        seconds.value = 59;
      } else {
        seconds--;
      }
    });

    isRunning.value = true;
  }

  void onInputChanged(String value) {
    inputPin.value = value;

    if (pinController.text == paramArgs[0]["otp"].toString()) {
      isOtpValid.value = true;
    } else {
      isOtpValid.value = false;
    }
    update();
  }

  void restartTimer() {
    if (timer!.isActive) {
      timer!.cancel();
    }
    resendFunction();
  }

  Future<void> resendFunction() async {
    isLoading.value = true;
    isInternetConn.value = true;
    var otpData = {
      "mobile_no": paramArgs[0]["mobile_no"],
      "reg_type": "REQUEST_OTP"
    };
    HttpRequest(api: ApiKeys.gApiSubFolderPutOTP, parameters: otpData)
        .put()
        .then((otpData) {
      if (otpData == "No Internet") {
        isInternetConn.value = false;
        isLoading.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (otpData == null) {
        isInternetConn.value = true;
        isLoading.value = false;

        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (otpData["success"] == 'Y') {
        isInternetConn.value = true;
        isLoading.value = false;
        paramArgs = paramArgs.map((e) {
          e["otp"] = int.parse(otpData["otp"]);
          return e;
        }).toList();
        inputPin.value = "";
        pinController.text = "";
        minutes.value = initialMinutes.value;
        seconds.value = 0;
        isRunning.value = false;
        startTimers();
        CustomDialog().successDialog(Get.context!, "Success",
            "OTP has been sent to your registered mobile number.", "Okay", () {
          Get.back();
        });
      } else {
        isInternetConn.value = true;
        isLoading.value = false;
        CustomDialog().errorDialog(Get.context!, "luvpark", otpData["msg"], () {
          Get.back();
        });
      }
    });
  }

  Future<void> verifyOtp() async {
    int userId = await Authentication().getUserId();

    CustomDialog().loadingDialog(Get.context!);
    Map<String, dynamic> parameters = {
      "user_id": userId.toString(),
      "to_mobile_no": paramArgs[0]["to_mobile_no"],
      "amount": paramArgs[0]["amount"].toString().replaceAll(",", ""),
      "to_msg": paramArgs[0]["to_msg"],
    };

    HttpRequest(api: ApiKeys.gApiSubFolderPutShareLuv, parameters: parameters)
        .put()
        .then(
      (retvalue) {
        if (retvalue == "No Internet") {
          Get.back();
          CustomDialog().errorDialog(Get.context!, "Error",
              "Please check your internet connection and try again.", () {
            Get.back();
          });
          return;
        }
        if (retvalue == null) {
          Get.back();
          CustomDialog().errorDialog(Get.context!, "Error",
              "Error while connecting to server, Please try again.", () {
            Get.back();
            if (Navigator.canPop(Get.context!)) {
              Get.back();
            }
          });
        } else {
          if (retvalue["success"] == "Y") {
            NotificationController.shareTokenNotification(
                0, 0, 'Transfer Token', "${retvalue["msg"]}.", "walletScreen");

            Get.back();

            CustomDialog().successDialog(
                Get.context!, "Success", "Transaction complete", "Okay", () {
              Get.back();
              Get.back();
              cbFunc();
            });
          } else {
            Get.back();
            CustomDialog().errorDialog(
              Get.context!,
              "Error",
              retvalue["msg"],
              () {
                Get.back();
              },
            );
          }
        }
      },
    );
  }

  void onVerify() {
    if (isLoading.value) return;
    if (inputPin.isEmpty) return;
    if ((int.parse(inputPin.toString()) !=
            int.parse(paramArgs[0]["otp"].toString())) ||
        inputPin.value.length != 6) {
      CustomDialog().errorDialog(Get.context!, "luvpark",
          "Invalid OTP code. Please try again.. Please try again.", () {
        Get.back();
      });
      return;
    }
    verifyOtp();
  }

  @override
  void onClose() {
    timer!.cancel();
    super.onClose();
  }
}
