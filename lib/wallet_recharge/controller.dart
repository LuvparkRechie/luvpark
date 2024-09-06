import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class WalletRechargeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  WalletRechargeController();
  final parameter = Get.arguments;
  Timer? _debounce;
  TextEditingController tokenAmount = TextEditingController();
  RxBool isActiveBtn = false.obs;
  RxBool isShowKeyboard = false.obs;
  RxInt? selectedPaymentType = 0.obs;
  var denoInd = (-1).obs; // no default color for pads
  var ndData = [].obs;
  final List<String> dataList = [
    "20",
    "30",
    "50",
    "100",
    "200",
    "250",
    "300",
    "500",
    "1000"
  ];

  @override
  void onInit() {
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
  Future<void> pads(int index) async {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    tokenAmount.text = dataList[index];
    denoInd.value = index; // Update the selected index
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
