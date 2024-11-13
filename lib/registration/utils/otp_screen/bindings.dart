import 'package:get/get.dart';
import 'package:luvpark/registration/utils/otp_screen/controller.dart';

class OtpBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(() => OtpController());
  }
}
