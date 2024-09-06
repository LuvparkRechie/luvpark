import 'package:get/get.dart';
import 'package:luvpark_get/activate_acc/controller.dart';

class ActivateAccBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivateAccountController>(() => ActivateAccountController());
  }
}
