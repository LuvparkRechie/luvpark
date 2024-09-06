import 'package:get/get.dart';
import 'package:luvpark_get/splash_screen/controller.dart';

class SplashBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
