import 'package:get/get.dart';
import 'package:luvpark_get/my_account/controller.dart';

class MyAccountBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyAccountScreenController>(() => MyAccountScreenController());
  }
}
