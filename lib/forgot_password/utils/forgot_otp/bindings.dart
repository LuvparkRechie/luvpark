import 'package:get/get.dart';

import 'controller.dart';

class ForgotPassOtpBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPassOtpController>(() => ForgotPassOtpController());
  }
}
