import 'package:get/get.dart';

import 'controller.dart';

class paywithQRBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<paywithQRController>(() => paywithQRController());
  }
}
