import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';
import 'package:luvpark_get/routes/routes.dart';

import '../custom_widgets/alert_dialog.dart';
import '../functions/functions.dart';

class WalletSendController extends GetxController
    with GetSingleTickerProviderStateMixin {
  WalletSendController();
  final parameter = Get.arguments;
  final GlobalKey<FormState> formKeySend = GlobalKey<FormState>();
  final TextEditingController recipient = TextEditingController();
  final TextEditingController tokenAmount = TextEditingController();
  final TextEditingController message = TextEditingController();
  final TextEditingController sub = TextEditingController();
  final GlobalKey contentKey = GlobalKey();
  RxBool isLpAccount = false.obs;
  RxBool isLoading = true.obs;
  RxBool isBtnDisabled = true.obs;
  RxBool isInternetConn = true.obs;
  RxBool isValidNumber = false.obs;
  RxList userData = [].obs;
  RxList logs = [].obs;
  RxInt denoInd = 0.obs;
  RxDouble amountBalance = 0.0.obs;
  RxString myBalance = "".obs;
  RxInt indexbtn = 0.obs;
  RxList<int> padNumbers = [10, 20, 30, 40, 50, 100, 200, 250].obs;
  void onPageChanged(bool agree) {
    update();
  }

  Future<void> onTextChange() async {
    denoInd.value = -1;

    if (recipient.value.text.isEmpty ||
        tokenAmount.text.isEmpty ||
        double.parse(
                tokenAmount.text.replaceAll(",", "").replaceAll(".", "")) <=
            0) {
      isBtnDisabled.value = true;
    } else {
      isBtnDisabled.value = false;
    }
  }

  Future<void> getConsumersData() async {
    Functions.getUserBalance(Get.context!, (dataBalance) async {
      if (!dataBalance[0]["has_net"]) {
        isLoading.value = false;
        isInternetConn.value = false;
        return;
      } else {
        userData.value = dataBalance[0]["items"];
        getLogs();
      }
    });
  }

  Future<void> getVerifiedAcc() async {
    CustomDialog().loadingDialog(Get.context!);

    var params =
        "${ApiKeys.gApiSubFolderVerifyNumber}?mobile_no=63${recipient.text.toString().replaceAll(" ", "")}";
    HttpRequest(
      api: params,
    ).get().then((returnData) async {
      if (returnData == "No Internet") {
        Get.back();
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData == null) {
        Get.back();
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      }

      if (returnData["items"][0]["is_valid"] == "Y") {
        sendOtp();
        return;
      } else {
        Get.back();
        CustomDialog().errorDialog(
            Get.context!, "luvpark", returnData["items"][0]["msg"], () {
          Get.back();
        });
      }
    });
  }

  Future<void> sendOtp() async {
    final item = await Authentication().getUserLogin();
    Map<String, dynamic> paramSend = {
      "mobile_no": item["mobile_no"],
    };

    HttpRequest(
            api: ApiKeys.gApiSubFolderPostReqOtpShare, parameters: paramSend)
        .post()
        .then(
      (retvalue) {
        if (retvalue == "No Internet") {
          Get.back();
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (retvalue == null) {
          Get.back();
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        } else {
          if (retvalue["success"] == "Y") {
            Get.back();
            List otpData = [
              {
                "amount": tokenAmount.text.toString().replaceAll(",", ""),
                "to_msg": message.text,
                "mobile_no": item["mobile_no"],
                "otp": int.parse(retvalue["otp"].toString()),
                "to_mobile_no": "63${recipient.text.replaceAll(" ", "")}"
              }
            ];

            Get.toNamed(
              Routes.sendOtp,
              arguments: otpData,
            );
          } else {
            Get.back();
            CustomDialog().errorDialog(Get.context!, "Error", retvalue["msg"],
                () {
              Get.back();
            });
          }
        }
      },
    );
  }

  Future<void> onContinue() async {
    FocusManager.instance.primaryFocus!.unfocus();
    if (isBtnDisabled.value) {
      CustomDialog().errorDialog(Get.context!, "Attention",
          "Please ensure that you have filled out the provided form before we can proceed.",
          () {
        Get.back();
      });
      return;
    }
  }

  Future<void> getLogs() async {
    myBalance.value = "";
    final item = await Authentication().getUserData();
    String userId = jsonDecode(item!)['user_id'].toString();

    isLoading.value = true;

    String subApi = "${ApiKeys.gApiSubFolderGetBalance}?user_id=$userId";

    HttpRequest(api: subApi).get().then((response) {
      if (response == "No Internet") {
        isLoading.value = false;
        isInternetConn.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () => Get.back());
        return;
      }
      if (response == null) {
        isLoading.value = true;
        isInternetConn.value = true;
        CustomDialog().errorDialog(
          Get.context!,
          "Error",
          "Error while connecting to server, Please contact support.",
          () => Get.back(),
        );
        return;
      }

      if (response["items"].isNotEmpty) {
        isLoading.value = false;
        isInternetConn.value = true;
        logs.value = response["items"];
      } else {
        isLoading.value = false;
        isInternetConn.value = true;
        CustomDialog().errorDialog(
          Get.context!,
          "luvpark",
          "No amenities found in this area.",
          () => Get.back(),
        );
      }
    });
  }

  Future<void> onBtnChange(int value) async {
    tokenAmount.text = value.toString();
    indexbtn.value = value;
  }

  @override
  void onInit() {
    getConsumersData();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
