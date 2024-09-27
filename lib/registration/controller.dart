import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';

class RegistrationController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final isAgree = Get.arguments;
  RxBool isShowPass = false.obs;
  RxBool isLoading = false.obs;
  RxInt passStrength = 0.obs;

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

  Future<void> onSubmit(
      BuildContext context, dynamic parameters, Function cb) async {
    if (isAgree) {
      CustomDialog().confirmationDialog(context, "Create Account",
          "Are you sure you want to proceed?", "No", "Yes", () {
        cb([
          {"has_net": true, "success": false, "items": []}
        ]);
        Get.back();
      }, () {
        Get.back();
        HttpRequest(api: ApiKeys.gApiLuvParkPostReg, parameters: parameters)
            .post()
            .then((returnPost) async {
          if (returnPost == "No Internet") {
            CustomDialog().internetErrorDialog(context, () {
              cb([
                {"has_net": false, "success": false, "items": []}
              ]);
              Get.back();
            });
            return;
          }

          if (returnPost == null) {
            CustomDialog().errorDialog(context, "Error",
                "Error while connecting to server, Please try again.", () {
              Get.back();
              cb([
                {"has_net": true, "success": false, "items": []}
              ]);
            });
            return;
          }
          if (returnPost["success"] != "Y") {
            CustomDialog().errorDialog(context, "Error", returnPost["msg"], () {
              cb([
                {"has_net": true, "success": false, "items": []}
              ]);
              Get.back();
            });

            return;
          } else {
            cb([
              {"has_net": true, "success": true, "items": returnPost["otp"]}
            ]);
            // Get.back();
          }
        });
      });
    } else {
      CustomDialog().errorDialog(context, "Attention",
          "Your acknowledgement of our terms & conditions is required before you can continue.",
          () {
        cb([
          {"has_net": true, "success": false, "items": []}
        ]);
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
    formKeyRegister.currentState!.reset();
    super.onClose();
  }

  RegistrationController();
}
