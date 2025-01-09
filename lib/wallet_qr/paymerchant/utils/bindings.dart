import 'package:get/get.dart';

import 'controller.dart';

class merchantQRverifyBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<payMerchantVerifyController>(
        () => payMerchantVerifyController());
  }
}
