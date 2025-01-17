import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class WalletRechargeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  WalletRechargeController();
  final parameter = Get.arguments;
  Timer? _debounce;
  final GlobalKey<FormState> formKeyBuyLoad = GlobalKey<FormState>();
  TextEditingController tokenAmount = TextEditingController();
  RxBool isActiveBtn = false.obs;
  RxBool isShowKeyboard = false.obs;
  RxInt? selectedPaymentType = 0.obs;
  var denoInd = (-1).obs; // no default color for pads
  var ndData = [].obs;
  RxList padData = [].obs;
  List dataList = [
    {"value": 100, "is_active": false},
    {"value": 150, "is_active": false},
    {"value": 200, "is_active": false},
    {"value": 300, "is_active": false},
    {"value": 400, "is_active": false},
    {"value": 500, "is_active": false},
    {"value": 750, "is_active": false},
    {"value": 1000, "is_active": false},
    {"value": 1500, "is_active": false},
  ].obs;

  @override
  void onInit() {
    padData.value = dataList;
    generateBank();
    super.onInit();
  }

  Future<void> onTextChange() async {
    denoInd.value = -1;
    selectedPaymentType = null;

    // Try to parse the input value
    final input = tokenAmount.text.replaceAll(",", "").replaceAll(".", "");
    final double? value = double.tryParse(input);

    // Check if the value is valid and meets the minimum requirement
    if (value == null || value < 20) {
      isActiveBtn.value = false;
    } else {
      isActiveBtn.value = true;
    }
  }

//function for my pads
  Future<void> pads(int value) async {
    tokenAmount.text = value.toString();
    padData.value = dataList.map((obj) {
      obj["is_active"] = (obj["value"] == value);
      return obj;
    }).toList();

    isActiveBtn.value = true;
  }

  Future<void> generateBank() async {}
  @override
  void onClose() {
    super.onClose();
  }

  void dispose() {
    _debounce?.cancel();
    tokenAmount.dispose();
    super.dispose();
  }
}
