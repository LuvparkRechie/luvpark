import 'package:get/get.dart';

import 'controller.dart';

class MerchantBillerBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantBillerController>(() => MerchantBillerController());
  }
}
