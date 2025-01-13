import 'package:get/get.dart';

import 'controller.dart';

class payMerchantBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PayMerchantController>(() => PayMerchantController());
  }
}
