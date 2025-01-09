import 'package:get/get.dart';

import 'controller.dart';

class walletBillerBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<walletBillerController>(() => walletBillerController());
  }
}
