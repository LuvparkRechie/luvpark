// ignore_for_file: unused_import, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_cutter.dart';
import 'package:luvpark/custom_widgets/custom_cutter_top_bottom.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/main.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../notification_controller.dart';

class payMerchantVerifyController extends GetxController
    with GetSingleTickerProviderStateMixin {
  payMerchantVerifyController();
  dynamic parameter = Get.arguments;
  RxList userData = [].obs;
  RxBool isLoadingCard = true.obs;
  RxBool isNetConnCard = true.obs;
  final TextEditingController amountController = TextEditingController();
  TextEditingController myPass = TextEditingController();
  final TextEditingController tokenAmount = TextEditingController();
  RxList recipientData = [].obs;
  final TextEditingController message = TextEditingController();
  RxBool isPage2 = false.obs;
  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    refreshUserData();
  }

  Future<void> refreshUserData() async {
    isLoadingCard.value = true;
    final userId = await Authentication().getUserId();
    String subApi = "${ApiKeys.getUserBalance}$userId";

    HttpRequest(
      api: subApi,
    ).get().then((returnBalance) async {
      if (returnBalance == "No Internet") {
        isLoadingCard.value = false;
        isNetConnCard.value = false;
        return;
      }
      if (returnBalance == null) {
        isLoadingCard.value = false;
        isNetConnCard.value = false;
        return;
      }
      isLoadingCard.value = false;
      isNetConnCard.value = true;
      if (returnBalance["items"].isNotEmpty) {
        userData.value = returnBalance["items"];
      }
    });
  }

  Future<void> getUserBalance() async {
    Functions.getUserBalance2(Get.context!, (dataBalance) async {
      if (!dataBalance[0]["has_net"]) {
        isLoadingCard.value = false;
        isNetConnCard.value = false;
        userData.value = [];
        return;
      } else {
        isLoadingCard.value = false;
        isNetConnCard.value = true;
        userData.value = dataBalance[0]["items"];
      }
    });
  }

  void onPageSnap() {
    isPage2.value = !isPage2.value;
  }

//Share token
  Future<void> shareToken() async {
    final userData = await Authentication().getUserData2();
    int userId = await Authentication().getUserId();

    CustomDialog().loadingDialog(Get.context!);
    Map<String, dynamic> parameters = {
      "user_id": userId.toString(),
      "to_mobile_no": recipientData[0]["mobile_no"],
      "amount": tokenAmount.text,
      "to_msg": message.text,
      "session_id": userData["session_id"].toString(),
      "pwd": myPass.text,
    };
    HttpRequest(api: ApiKeys.postShareToken, parameters: parameters)
        .postBody()
        .then(
      (retvalue) {
        if (retvalue == "No Internet") {
          Get.back();
          CustomDialog().errorDialog(Get.context!, "Error",
              "Please check your internet connection and try again.", () {
            Get.back();
          });
          return;
        }
        if (retvalue == null) {
          Get.back();
          CustomDialog().errorDialog(Get.context!, "Error",
              "Error while connecting to server, Please try again.", () {
            if (Navigator.canPop(Get.context!)) {
              Get.back();
            }
          });
        } else {
          if (retvalue["success"] == "Y") {
            NotificationController.shareTokenNotification(
                0, 0, 'Transfer Token', "${retvalue["msg"]}.", "walletScreen");

            Get.back();

            CustomDialog().successDialog(
                Get.context!, "Success", "Transaction complete", "Okay", () {
              Get.back();
              onPageSnap();
              refreshUserData();
              Future.delayed(Duration(milliseconds: 500), () {
                Get.back();
              });
            });
            return;
          } else {
            Get.back();
            CustomDialog().errorDialog(
              Get.context!,
              "Error",
              retvalue["msg"],
              () {
                Get.back();
              },
            );
            return;
          }
        }
      },
    );
  }

  Future<void> payMerchantVerify() async {
    CustomDialog().loadingDialog(Get.context!);
    int? userid = await Authentication().getUserId();

    Map<String, dynamic> postParam = {
      "merchant_key": parameter["merchant_key"],
      "amount": parameter["amount"],
      "luvpay_id": userid,
      "payment_hk": parameter["payment_hk"],
    };

    HttpRequest(api: ApiKeys.postMerchant, parameters: postParam)
        .postBody()
        .then(
      (retvalue) {
        Get.back();
        if (retvalue == "No Internet") {
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (retvalue == null) {
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        }
        if (retvalue['success'] == "Y") {
          Get.back();
          Get.back();
          Get.toNamed(Routes.merchantReceipt, arguments: {
            "merchant_name": parameter["merchant_name"],
            "amount": parameter["amount"],
            "luvpay_id": userid,
            "payment_hk": parameter["payment_hk"],
            "reference_no": retvalue["lp_ref_no"],
            "date_time": retvalue["response_time"],
          });
        } else {
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        }
      },
    );
  }
}
