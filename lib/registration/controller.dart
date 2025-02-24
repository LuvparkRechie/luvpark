import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final isAgree = Get.arguments;
  RxBool isShowPass = false.obs;
  RxBool isLoading = false.obs;
  RxInt passStrength = 0.obs;
  RxInt storedOtp = 0.obs;

  final GlobalKey<FormState> formKeyRegister = GlobalKey<FormState>();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isLogin = false;
  bool isInternetConnected = true;

  bool isTappedReg = false;
  var usersLogin = [];

  void toggleLoading(bool value) {
    isLoading.value = value;
  }

  void onPasswordChanged(String value) {
    passStrength.value = Variables.getPasswordStrength(value);
    update();
  }

  void onMobileChanged(String value) {
    if (value.startsWith("0")) {
      mobileNumber.text =
          value.substring(1); // Update mobileNumber with substring
    } else {
      mobileNumber.text = value; // Update mobileNumber with original value
    }
    update();
  }

  Future<void> onSubmit() async {
    String devKey = await Functions().getUniqueDeviceId();
    Map<String, dynamic> parameters = {
      "mobile_no": "63${mobileNumber.text.toString().replaceAll(" ", "")}",
      "pwd": password.text,
      "device_key": devKey.toString(),
    };

    if (isAgree) {
      CustomDialog().confirmationDialog(Get.context!, "Create Account",
          "Are you sure you want to proceed?", "No", "Yes", () {
        Get.back();
      }, () {
        Get.back();
        CustomDialog().loadingDialog(Get.context!);

        HttpRequest(api: ApiKeys.postUserReg, parameters: parameters)
            .postBody()
            .then((returnPost) async {
          Get.back();
          if (returnPost == "No Internet") {
            CustomDialog().internetErrorDialog(Get.context!, () {
              Get.back();
            });
            return;
          }

          if (returnPost == null) {
            CustomDialog().serverErrorDialog(Get.context!, () {
              Get.back();
            });
            return;
          }
          if (returnPost["success"] == "Y") {
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool('isLoggedIn', false);
            final plainText = jsonEncode(parameters);
            Authentication().encryptData(plainText);

            Get.toNamed(Routes.otpField, arguments: {
              "mobile_no": "63${mobileNumber.text.replaceAll(" ", "")}",
              "new_acct": 'Y',
              "callback": (otp) async {
                FocusManager.instance.primaryFocus?.unfocus();
                CustomDialog().successDialog(
                    Get.context!,
                    "Success",
                    "Your account has been successfully registered.",
                    "Okay", () {
                  Get.back();
                  Get.offAllNamed(Routes.login);
                });
              }
            });
            return;
          } else {
            CustomDialog()
                .errorDialog(Get.context!, "luvpark", returnPost["msg"], () {
              Get.back();
            });
            // Get.back();
            return;
          }
        });
      });
    } else {
      CustomDialog().errorDialog(Get.context!, "Attention",
          "Your acknowledgement of our terms & conditions is required before you can continue.",
          () {
        Get.back();
      });
    }
  }

  void visibilityChanged(bool visible) {
    isShowPass.value = visible;
    update();
  }

  @override
  void onInit() {
    mobileNumber = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    if (formKeyRegister.currentState != null) {
      formKeyRegister.currentState!.reset();
    }

    super.onClose();
  }

  RegistrationController();
}
