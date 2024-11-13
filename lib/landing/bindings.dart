import 'package:get/get.dart';
import 'package:luvpark/landing/controller.dart';

class LandingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LandingController>(() => LandingController());
  }
}
