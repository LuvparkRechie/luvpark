import 'package:get/get.dart';

import 'controller.dart';

class MerchantQRverifyBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<payMerchantVerifyController>(
        () => payMerchantVerifyController());
  }
}
