import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';

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
    isLoading.value = true;
    HttpRequest(
            api:
                "${ApiKeys.gApiLuvParkGetAcctStat}?mobile_no=63${mobileNumber.text.toString().replaceAll(" ", "")}")
        .get()
        .then((objData) {
      print("objData $objData");
      if (objData == "No Internet") {
        isLoading.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (objData == null) {
        isLoading.value = false;
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      } else {
        if (objData["success"] == "Y") {
          isLoading.value = false;
          if (objData["is_verified"] == "Y") {
            Get.toNamed(Routes.forgotVerifiedAcct,
                arguments:
                    "63${mobileNumber.text.toString().replaceAll(" ", "")}");
          } else {
            Get.toNamed(Routes.createNewPass,
                arguments:
                    "63${mobileNumber.text.toString().replaceAll(" ", "")}");
          }
        } else {
          isLoading.value = false;
          CustomDialog().errorDialog(Get.context!, "luvpark", objData["msg"],
              () {
            Get.back();
          });
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
