import 'package:get/get.dart';
import 'package:luvpark/my_account/utils/controller.dart';

class UpdateProfileBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateProfileController>(() => UpdateProfileController());
  }
}
