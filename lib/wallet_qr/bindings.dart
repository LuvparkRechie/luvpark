import 'package:get/get.dart';

import 'controller.dart';

class QrWalletBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrWalletController>(() => QrWalletController());
  }
}
