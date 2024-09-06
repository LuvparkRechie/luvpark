import 'package:get/get.dart';

import 'controller.dart';

class DashboardMapBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardMapController>(() => DashboardMapController());
  }
}
