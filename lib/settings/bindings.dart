import 'package:get/get.dart';
import 'package:luvpark_get/settings/controller.dart';

class SettingsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
