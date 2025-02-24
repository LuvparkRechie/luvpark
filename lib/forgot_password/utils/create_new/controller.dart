import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/routes/routes.dart';

import '../../../auth/authentication.dart';
import '../../../http/api_keys.dart';
import '../../../http/http_request.dart';

class CreateNewPassController extends GetxController {
  CreateNewPassController();
  String mobileNoParam = Get.arguments;
  final GlobalKey<FormState> formKeyCreatePass = GlobalKey<FormState>();
  TextEditingController newPass = TextEditingController();
  TextEditingController confirmPass = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool isInternetConnected = true.obs;
  RxBool isShowNewPass = false.obs;
  RxBool isShowConfirmPass = false.obs;
  RxInt passStrength = 0.obs;

  @override
  void onInit() {
    newPass = TextEditingController();
    confirmPass = TextEditingController();
    super.onInit();
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
    isLoading.value = true;
    Get.toNamed(
      Routes.otpField,
      arguments: {
        "mobile_no": mobileNoParam,
        "is_forget_vfd_pass": true,
        "callback": (otp) {
          Get.back();
          isLoading.value = false;
          CustomDialog().loadingDialog(Get.context!);

          Map<String, dynamic> postParam = {
            "mobile_no": mobileNoParam,
            "otp": otp.toString(),
            "new_pwd": newPass.text,
          };

          HttpRequest(api: ApiKeys.putLogin, parameters: postParam)
              .putBody()
              .then(
            (retvalue) {
              Get.back();
              if (retvalue == "No Internet") {
                CustomDialog().errorDialog(Get.context!, "Error",
                    "Please check your internet connection and try again.", () {
                  Get.back();
                });
                return;
              }
              if (retvalue == null) {
                CustomDialog().errorDialog(Get.context!, "Error",
                    "Error while connecting to server, Please try again.", () {
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
      },
    );
  }

  @override
  void onClose() {
    formKeyCreatePass.currentState?.reset();
    super.onClose();
  }
}
