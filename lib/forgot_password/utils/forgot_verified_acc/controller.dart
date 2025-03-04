import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/routes/routes.dart';

import '../../../functions/functions.dart';

class ForgotVerifiedAcctController extends GetxController {
  ForgotVerifiedAcctController();
  String mobileNoParam = Get.arguments;

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
        "${ApiKeys.getSecQue}?mobile_no=$mobileNoParam&secq_no=$randomNumber";

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

  void secRequestOtp() async {
    Map<String, String> reqParam = {
      "mobile_no": mobileNoParam.toString(),
      "secq_no": randomNumber.toString(),
      "secq_id": questionData[0]["secq_id"].toString(),
      "seca": answer.text,
      "new_pwd": newPass.text,
    };

    Functions().requestOtp(reqParam, (obj) async {
      DateTime timeNow = await Functions.getTimeNow();
      DateTime timeExp = DateFormat("yyyy-MM-dd hh:mm:ss a")
          .parse(obj["otp_exp_dt"].toString());
      DateTime otpExpiry = DateTime(timeExp.year, timeExp.month, timeExp.day,
          timeExp.hour, timeExp.minute, timeExp.millisecond);

      // Calculate difference
      Duration difference = otpExpiry.difference(timeNow);

      if (obj["success"] == "Y" || obj["status"] == "PENDING") {
        Map<String, String> putParam = {
          "mobile_no": mobileNoParam.toString(),
          "otp": obj["otp"].toString(),
          "new_pwd": newPass.text,
        };

        Get.toNamed(
          Routes.otpField,
          arguments: {
            "time_duration": difference,
            "mobile_no": mobileNoParam,
            "req_otp_param": reqParam,
            "verify_param": putParam,
            "callback": (otp) async {
              if (otp != null) {
                CustomDialog().loadingDialog(Get.context!);

                Map<String, dynamic> postParam = {
                  "mobile_no": mobileNoParam.toString(),
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
            },
          },
        );
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
  }
}
