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

class payMerchantVerifyController extends GetxController
    with GetSingleTickerProviderStateMixin {
  payMerchantVerifyController();
  dynamic parameter = Get.arguments;
  RxList userData = [].obs;
  RxBool isLoadingCard = true.obs;
  RxBool isNetConnCard = true.obs;
  final TextEditingController amountController = TextEditingController();

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onInit() {
    print("testing2: $parameter");
    super.onInit();
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

  Future<void> payMerchantVerify() async {
    CustomDialog().loadingDialog(Get.context!);
    int? userid = await Authentication().getUserId();

    Map<String, dynamic> requestParam = {
      "merchant_key": parameter["merchant_key"],
      "amount": parameter["amount"],
      "luvpay_id": userid,
      "payment_hk": parameter["payment_hk"],
    };
    HttpRequest(api: ApiKeys.gApiMerchantScan, parameters: requestParam)
        .postBody()
        .then(
      (retvalue) {
        print("retvalue: $retvalue");
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
