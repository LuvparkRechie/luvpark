import 'package:get/get.dart';

import 'controller.dart';

class SendOtpBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SendOtpController>(() => SendOtpController());
  }
}
