import 'package:get/get.dart';
import 'package:luvpark_get/registration/utils/otp_screen/controller.dart';

class OtpBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(() => OtpController());
  }
}
