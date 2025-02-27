import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/routes/routes.dart';

import '../../../auth/authentication.dart';
import '../../../custom_widgets/alert_dialog.dart';
import '../../../http/api_keys.dart';
import '../../../http/http_request.dart';

class CreateNewPassController extends GetxController {
  CreateNewPassController();
  String mobileNoParam = Get.arguments;
  final GlobalKey<FormState> formKeyCreatePass = GlobalKey<FormState>();
  TextEditingController newPass = TextEditingController();
  TextEditingController confirmPass = TextEditingController();

  RxBool isPendingOtp = false.obs;
  RxBool isLoading = false.obs;
  RxBool isInternetConnected = true.obs;
  RxBool isShowNewPass = false.obs;
  RxBool isShowConfirmPass = false.obs;
  RxBool isFinish = true.obs;
  RxInt passStrength = 0.obs;

  RxInt totalMinutes = 0.obs; // Change this to set timer duration
  RxInt remainingSeconds = 0.obs;
  Timer? timer;

  @override
  void onInit() {
    newPass = TextEditingController();
    confirmPass = TextEditingController();

    super.onInit();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds.value--;
        isFinish.value = false;
        update();
        isFinish.value = false;
      } else {
        isFinish.value = true;
        timer.cancel();
        update();
      }
    });
  }

  void onToggleNewPass(bool isShow) {
    isShowNewPass.value = isShow;
    update();
  }

  void onToggleConfirmPass(bool isShow) {
    isShowConfirmPass.value = isShow;
    update();
  }

  void onPasswordChanged(String value) {
    passStrength.value = Variables.getPasswordStrength(value);
    update();
  }

  Future<void> requestOtp() async {
    DateTime timeNow = await Functions.getTimeNow();
    Map<String, String> reqParam = {
      "mobile_no": mobileNoParam.toString(),
      "new_pwd": newPass.text,
    };
    Functions().requestOtp(reqParam, (obj) {
      print(" obj $obj");
      if (obj["success"] == "Y") {
        Get.toNamed(
          Routes.otpField,
          arguments: {
            "mobile_no": mobileNoParam,
            "is_forget_vfd_pass": true,
            "callback": (otp) {
              if (otp != null) {
                Get.back();
                CustomDialog().loadingDialog(Get.context!);

                Map<String, dynamic> postParam = {
                  "mobile_no": mobileNoParam.toString(),
                  "otp": otp.toString(),
                  "new_pwd": newPass.text,
                };
                print("postParam $postParam");

                HttpRequest(api: ApiKeys.putLogin, parameters: postParam)
                    .putBody()
                    .then(
                  (retvalue) {
                    Get.back();
                    if (retvalue == "No Internet") {
                      CustomDialog().errorDialog(Get.context!, "Error",
                          "Please check your internet connection and try again.",
                          () {
                        Get.back();
                      });
                      return;
                    }
                    if (retvalue == null) {
                      CustomDialog().errorDialog(Get.context!, "Error",
                          "Error while connecting to server, Please try again.",
                          () {
                        Get.back();
                      });
                    } else {
                      if (retvalue["success"] == "Y") {
                        Map<String, dynamic> data = {
                          "mobile_no": mobileNoParam,
                          "pwd": newPass.text,
                        };
                        final plainText = jsonEncode(data);

                        Authentication().encryptData(plainText);
                        Get.toNamed(Routes.forgotPassSuccess);
                      } else {
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
            }
          },
        );
      } else {
        DateTime timeExp = DateFormat("yyyy-MM-dd hh:mm:ss a")
            .parse(obj["otp_exp_dt"].toString());

        // Calculate difference
        Duration difference = timeExp.difference(timeNow);

        remainingSeconds.value = difference.inSeconds;
        totalMinutes.value = difference.inMinutes;

        startTimer();
      }
    });
  }

  @override
  void onClose() {
    formKeyCreatePass.currentState?.reset();
    timer?.cancel();
    super.onClose();
  }
}
