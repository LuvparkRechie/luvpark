import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';

import '../auth/authentication.dart';
import '../http/api_keys.dart';
import '../http/http_request.dart';

class ActivateAccountController extends GetxController {
  ActivateAccountController();
  final callback = Get.arguments["callback"];
  String parameters = Get.arguments["mobile_no"];
  RxBool isAgree = false.obs;
  RxBool isLoading = false.obs;
  RxString? password;
  TextEditingController pinController = TextEditingController();
  Duration countdownDuration = const Duration(minutes: 2);
  Duration duration = const Duration();
  bool isCountdown = false;
  Timer? timer;
  double? mediaQueryWidth;
  String twoDigets(int n) => n.toString().padLeft(2, '0');
  BuildContext? mainContext;

  bool isRequested = false;
  RxBool isNetConn = true.obs;
  RxBool isLoadingPage = true.obs;
  RxString inputPin = "".obs;
  bool isOtpValid = true;
  RxInt minutes = 2.obs;
  RxInt seconds = 0.obs;
  RxInt initialMinutes = 2.obs;
  RxBool isRunning = false.obs;
  RxInt otpCode = 0.obs;

  @override
  void onInit() {
    pinController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTmrStat();
      getOtpRequest();
    });
    super.onInit();
  }

  void getTmrStat() async {
    await Authentication().enableTimer(false);
  }

  void getOtpRequest() {
    inputPin.value = "";
    CustomDialog().loadingDialog(Get.context!);
    var otpData = {
      "mobile_no": parameters.toString(),
      "reg_type": "REQUEST_OTP"
    };

    print("otp param $otpData");

    HttpRequest(api: ApiKeys.gApiSubFolderPutOTP, parameters: otpData)
        .put()
        .then((returnData) async {
      if (returnData == "No Internet") {
        inputPin.value = "";
        isLoadingPage.value = false;
        isNetConn.value = false;
        Get.back();
        CustomDialog().errorDialog(Get.context!, "Error",
            "Please check your internet connection and try again.", () {
          Get.back();
        });

        return;
      }
      if (returnData == null) {
        inputPin.value = "";
        isLoadingPage.value = false;
        isNetConn.value = true;
        Get.back();
        CustomDialog().errorDialog(Get.context!, "Error",
            "Error while connecting to server, Please try again.", () {
          Get.back();
        });

        return;
      }

      if (returnData["success"] == 'Y') {
        Get.back();
        isLoadingPage.value = false;
        isNetConn.value = true;
        pinController.clear();
        inputPin.value = "";
        minutes.value = initialMinutes.value;
        seconds.value = 0;
        otpCode.value = int.parse(returnData["otp"]);
        isRequested = true;

        startTimers();
      } else {
        inputPin.value = "";
        isLoadingPage.value = false;
        isNetConn.value = true;
        Get.back();
        CustomDialog().errorDialog(Get.context!, "LuvPark", returnData["msg"],
            () {
          Get.back();
        });
      }
    });
  }

  void onInputChanged(String value) {
    inputPin.value = value;

    if (int.parse(pinController.text) == otpCode.value) {
      isOtpValid = true;
    } else {
      isOtpValid = false;
    }
    update();
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

  void restartTimer() {
    if (timer!.isActive) {
      timer!.cancel();
    }
    resendFunction();
  }

  void resendFunction() {
    inputPin.value = "";
    CustomDialog().loadingDialog(Get.context!);
    var otpData = {
      "mobile_no": parameters.toString(),
      "reg_type": "REQUEST_OTP"
    };

    HttpRequest(api: ApiKeys.gApiSubFolderPutOTP, parameters: otpData)
        .put()
        .then((returnData) async {
      if (returnData == "No Internet") {
        inputPin.value = "";
        Get.back();
        CustomDialog().errorDialog(Get.context!, "Error",
            "Please check your internet connection and try again.", () {
          Get.back();
        });

        return;
      }
      if (returnData == null) {
        inputPin.value = "";
        Get.back();
        CustomDialog().errorDialog(Get.context!, "Error",
            "Error while connecting to server, Please try again.", () {
          Get.back();
        });

        return;
      }

      if (returnData["success"] == 'Y') {
        Get.back();

        pinController.clear();
        inputPin.value = "";
        minutes.value = initialMinutes.value;
        seconds.value = 0;
        otpCode.value = int.parse(returnData["otp"]);
        isRequested = true;

        startTimers();
        CustomDialog().successDialog(Get.context!, "Success",
            "OTP has been sent to registered mobile number.", "Okay", () {
          Get.back();
        });
      } else {
        inputPin.value = "";
        Get.back();
        CustomDialog().errorDialog(Get.context!, "LuvPark", returnData["msg"],
            () {
          Get.back();
        });
      }
    });
  }

  Future<void> verifyAccount() async {
    if (inputPin.value.length != 6) {
      CustomDialog().errorDialog(
          Get.context!, "Invalid OTP", "Please complete the 6-digits OTP", () {
        isLoading.value = false;
        Get.back();
      });
      return;
    }

    CustomDialog().loadingDialog(Get.context!);
    var otpData = {
      "mobile_no": parameters.toString(),
      "reg_type": "VERIFY",
      "otp": int.parse(pinController.text)
    };
    print("otpData $otpData");
    HttpRequest(api: ApiKeys.gApiSubFolderPutOTP, parameters: otpData)
        .put()
        .then((returnData) async {
      print("returnData $returnData");
      if (returnData == "No Internet") {
        Get.back();
        CustomDialog().errorDialog(Get.context!, "Error",
            'Please check your internet connection and try again.', () {
          Get.back();
        });

        return;
      }
      if (returnData == null) {
        Get.back();
        CustomDialog().errorDialog(Get.context!, "Error",
            "Error while connecting to server, Please try again.", () {
          Get.back();
        });

        return;
      }
      if (returnData["success"] == 'Y') {
        Get.back();
        callback();
      } else {
        Get.back();
        CustomDialog().errorDialog(Get.context!, "Error",
            "Your OTP code is incorrect.\nPlease try again.", () {
          pinController.text = "";
          Get.back();
        });
      }
    });
  }

  @override
  void onClose() {
    timer!.cancel();
    super.onClose();
  }
}
