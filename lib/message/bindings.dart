import 'package:get/get.dart';
import 'controller.dart';

class MessageScreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessageScreenController>(() => MessageScreenController());
  }
}
