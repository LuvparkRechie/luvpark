import 'package:get/get.dart';
import 'package:luvpark/activate_acc/controller.dart';

class ActivateAccountBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivateAccountController>(() => ActivateAccountController());
  }
}
