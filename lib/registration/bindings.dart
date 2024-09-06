import 'package:get/get.dart';
import 'package:luvpark_get/registration/controller.dart';

class RegistrationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegistrationController>(() => RegistrationController());
  }
}
