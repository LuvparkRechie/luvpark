import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';
import 'package:luvpark_get/routes/routes.dart';

class ForgotVerifiedAcctController extends GetxController {
  ForgotVerifiedAcctController();
  String parameters = Get.arguments;

  TextEditingController answer = TextEditingController();
  TextEditingController newPass = TextEditingController();
  final GlobalKey<FormState> formKeyForgotVerifiedAcc = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxBool isBtnLoading = false.obs;
  RxBool isInternetConn = true.obs;
  RxBool isShowNewPass = false.obs;
  RxBool isVerifiedAns = false.obs;
  RxList questionData = [].obs;
  RxInt passStrength = 0.obs;
  RxString question = "".obs;
  int? randomNumber;

  @override
  void onInit() {
    answer = TextEditingController();
    Random random = Random();
    randomNumber = random.nextInt(3) + 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSecQdata();
    });
    super.onInit();
  }

  void onPasswordChanged(String value) {
    passStrength.value = Variables.getPasswordStrength(value);
    update();
  }

  void onToggleNewPass(bool isShow) {
    isShowNewPass.value = isShow;
    update();
  }

  void getSecQdata() {
    isInternetConn.value = true;
    isLoading.value = true;

    String subApi =
        "${ApiKeys.gApiSubFolderGetDropdownSeq}?mobile_no=$parameters&secq_no=$randomNumber";

    HttpRequest(api: subApi).get().then((returnData) {
      if (returnData == "No Internet") {
        isInternetConn.value = false;
        isLoading.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });

        return;
      }
      if (returnData == null) {
        isInternetConn.value = true;
        isLoading.value = false;
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      } else {
        isInternetConn.value = true;
        isLoading.value = false;
        if (returnData["items"].isNotEmpty) {
          questionData.value = returnData["items"];
        } else {
          CustomDialog().errorDialog(Get.context!, "luvpark",
              "Make sure that you've entered the correct phone number.", () {
            Get.back();
          });
          return;
        }
      }
    });
  }

  Future<void> onVerify() async {
    FocusManager.instance.primaryFocus!.unfocus();
    isBtnLoading.value = true;
    var forgotParam = {
      "secq_no": randomNumber,
      "mobile_no": parameters,
      "secq_id": questionData[0]["secq_id"],
      "seca": answer.text
    };

    HttpRequest(
            api: ApiKeys.gApiSubFolderPostPutGetResetPass,
            parameters: forgotParam)
        .post()
        .then((returnData) {
      isBtnLoading.value = false;
      isVerifiedAns.value = false;
      if (returnData == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (returnData == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      } else {
        if (returnData["success"] == 'Y') {
          isVerifiedAns.value = true;
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: ((context) => ResetPassword(
          //           mobileNo: widget.mobileNumber,
          //           seqId: questionData["secq_id"],
          //           seca: sqa.text,
          //           seqNo: randomNumber,
          //         )),
          //   ),
          // );
        } else {
          CustomDialog().errorDialog(Get.context!, "luvpark", returnData["msg"],
              () {
            Get.back();
          });
        }
      }
    });
  }

  Future<void> onSubmit() async {
    FocusManager.instance.primaryFocus!.unfocus();
    isBtnLoading.value = true;
    dynamic resetParam = {
      "mobile_no": parameters,
    };

    HttpRequest(api: ApiKeys.gApiSubFolderPutForgotPass, parameters: resetParam)
        .put()
        .then((returnData) {
      isBtnLoading.value = false;

      if (returnData == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (returnData == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      } else {
        if (returnData["success"] == 'Y') {
          List args = [
            {
              "otp": int.parse(returnData["otp"].toString()),
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
          CustomDialog().errorDialog(Get.context!, "luvpark", returnData["msg"],
              () {
            Get.back();
          });
        }
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
  }
}
