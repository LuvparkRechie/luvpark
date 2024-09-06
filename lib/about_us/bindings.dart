import 'package:get/get.dart';
import 'package:luvpark_get/about_us/controller.dart';

class AboutUsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AboutUsController>(() => AboutUsController());
  }
}
