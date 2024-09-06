import 'package:get/get.dart';

import 'controller.dart';

class WalletRechargeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletRechargeController>(() => WalletRechargeController());
  }
}
