import 'package:get/get.dart';
import 'package:luvpark_get/onboarding/controller.dart';

class OnboardingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
