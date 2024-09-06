import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';
import 'package:luvpark_get/routes/routes.dart';

class CreateNewPassController extends GetxController {
  CreateNewPassController();
  String parameters = Get.arguments;
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
    Map<String, dynamic> requestParam = {
      "mobile_no": parameters,
    };
    HttpRequest(
            api: ApiKeys.gApiSubFolderPostReqOtpShare, parameters: requestParam)
        .post()
        .then(
      (retvalue) {
        if (retvalue == "No Internet") {
          isLoading.value = false;
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (retvalue == null) {
          isLoading.value = false;
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        } else {
          isLoading.value = false;
          if (retvalue["success"] == "Y") {
            List args = [
              {
                "otp": int.parse(retvalue["otp"].toString()),
                "mobile_no": parameters,
                "new_pass": newPass.text,
                "isVerAcct": false,
              }
            ];

            Get.toNamed(
              Routes.forgotPassOtp,
              arguments: args,
            );
          } else {
            CustomDialog().errorDialog(Get.context!, "luvpark", retvalue["msg"],
                () {
              Get.back();
            });
          }
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
