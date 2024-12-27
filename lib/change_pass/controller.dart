import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/authentication.dart';
import '../http/api_keys.dart';
import '../http/http_request.dart';
import '../routes/routes.dart';

class ChangePasswordController extends GetxController {
  ChangePasswordController();

  final GlobalKey<FormState> formKeyChangePass = GlobalKey<FormState>();
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController newConfirmPassword = TextEditingController();
  RxBool isShowOldPass = false.obs;
  RxBool isShowNewPass = false.obs;
  RxBool isShowNewPassConfirm = false.obs;
  RxInt passStrength = 0.obs;

  @override
  void onInit() {
    oldPassword = TextEditingController();
    newPassword = TextEditingController();
    newConfirmPassword = TextEditingController();
    // resetFields();
    print("inahatayaya");
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    formKeyChangePass.currentState!.reset();
  }

// //Refresh kn ma click get.back -->
//   void resetFields() {
//     oldPassword.clear();
//     newPassword.clear();
//     newConfirmPassword.clear();
//     isShowOldPass.value = false;
//     isShowNewPass.value = false;
//     isShowNewPassConfirm.value = false;
//     passStrength.value = 0;
//     update();
//   }

  void onToggleOldPass(bool isShow) {
    isShowOldPass.value = isShow;
    update();
  }

  void onToggleNewPass(bool isShow) {
    isShowNewPass.value = isShow;
    update();
  }

  void onToggleConfirmNewPass(bool isShow) {
    isShowNewPassConfirm.value = isShow;
    update();
  }

  void onPasswordChanged(String value) {
    passStrength.value = Variables.getPasswordStrength(value);
    update();
  }

  void onPasswordConfirmChanged(String value) {
    // passStrength.value = Variables.getPasswordStrength(value);
    update();
  }

  Future<void> onSubmit() async {
    // Close any open keyboards
    FocusManager.instance.primaryFocus!.unfocus();

    // Validate the form first
    if (!formKeyChangePass.currentState!.validate()) {
      return; // Stop submission if the form is not valid
    }

    // Proceed with password change logic if validation passes
    if (newPassword.text != newConfirmPassword.text) {
      CustomDialog().errorDialog(
          Get.context!, "luvpark", "Passwords do not match, please try again.",
          () {
        Get.back();
      });
      return;
    }

    // Continue with password change process
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var akongP = prefs.getString('userData');

    // ignore: use_build_context_synchronously
    CustomDialog().loadingDialog(Get.context!);

    var changePassParam = {
      "old_pwd": oldPassword.text,
      "new_pwd": newPassword.text,
      "user_id": jsonDecode(akongP!)['user_id'].toString(),
    };

    HttpRequest(
      api: ApiKeys.gApiSubFolderChangePass,
      parameters: changePassParam,
    ).put().then((returnPut) {
      if (returnPut == "No Internet") {
        Get.back();
        CustomDialog().errorDialog(Get.context!, "luvpark",
            "Please check your internet connection and try again.", () {
          Get.back();
        });
        return;
      }

      if (returnPut == null) {
        Get.back();
        CustomDialog().errorDialog(Get.context!, "luvpark",
            "Error while connecting to server, please try again.", () {
          Get.back();
        });
        return;
      }

      if (returnPut["success"] == "Y") {
        Get.back();
        CustomDialog().successDialog(
            Get.context!, "Success", "Successfully changed password!", "Okay",
            () async {
          Get.back();
          CustomDialog().loadingDialog(Get.context!);
          await Future.delayed(const Duration(seconds: 1));
          final userLogin = await Authentication().getUserLogin();
          List userData = [userLogin];
          userData = userData.map((e) {
            e["is_login"] = "N";
            return e;
          }).toList();

          await Authentication().setLogin(jsonEncode(userData[0]));
          await Authentication().setBiometricStatus(false);
          Get.back();
          Get.offAllNamed(Routes.login);
        });
      } else {
        Get.back();
        CustomDialog().errorDialog(Get.context!, "luvpark", returnPut["msg"],
            () {
          Get.back();
        });
      }
    });
  }
}
