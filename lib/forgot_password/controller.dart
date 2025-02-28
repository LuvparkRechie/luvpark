import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../functions/functions.dart';
import '../routes/routes.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController();
  final GlobalKey<FormState> formKeyForgotPass = GlobalKey<FormState>();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isLogin = false;
  RxBool isLoading = false.obs;
  RxBool isInternetConnected = true.obs;

  @override
  void onInit() {
    mobileNumber = TextEditingController();
    password = TextEditingController();
    super.onInit();
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

  Future<void> verifyMobile() async {
    String mobileNo = "63${mobileNumber.text.toString().replaceAll(" ", "")}";
    Functions().verifyMobile(mobileNo, (objData) {
      if (objData["success"]) {
        if (objData["data"]["is_verified"] == "Y") {
          Functions().getSecQdata(mobileNo, (cbData) {
            if (cbData != null) {
              Get.toNamed(Routes.forgotVerifiedAcct, arguments: mobileNo);
            }
          });
        } else {
          Get.toNamed(Routes.createNewPass, arguments: mobileNo);
        }
      }
    });
  }

  @override
  void onClose() {
    formKeyForgotPass.currentState?.reset();
    super.onClose();
  }
}
