import 'package:get/get.dart';

import 'controller.dart';

class OtpUpdateBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpUpdateController>(() => OtpUpdateController());
  }
}
