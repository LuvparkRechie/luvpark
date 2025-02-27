import 'package:get/get.dart';

class OtpFieldScreenController extends GetxController {
  OtpFieldScreenController();
  final callback = Get.arguments["callback"];
  String parameters = Get.arguments["mobile_no"];
  String isNewAcct = Get.arguments["new_acct"] == null ? "" : "Y";
  bool isForgetVfdPass =
      Get.arguments["is_forget_vfd_pass"] == null ? false : true;

  @override
  void onInit() {
    super.onInit();
  }
}
