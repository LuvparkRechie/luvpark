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
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/main.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class PayMerchantController extends GetxController
    with GetSingleTickerProviderStateMixin {
  PayMerchantController();
  dynamic parameter = Get.arguments;
  Map<String, dynamic> get merchantDetails => parameter["data"][0];
  String get merchantName => parameter["merchant_name"];
  String get paramPHK => parameter["payment_key"];
  String get paramMKEY => parameter["merchant_key"];
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

  String toCurrencyString(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return "Amount is required.";
    }

    double? amount = double.tryParse(
      value.replaceAll(',', ''),
    );

    if (amount == null || amount <= 0) {
      return "Enter an amount greater than 0.00.";
    }

    return null;
  }
}
