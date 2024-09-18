import 'package:get/get.dart';

import 'controller.dart';

class HelpandFeedbackBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpandFeedbackController>(() => HelpandFeedbackController());
  }
}
