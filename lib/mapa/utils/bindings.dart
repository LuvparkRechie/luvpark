import 'package:get/get.dart';
import 'package:luvpark_get/mapa/utils/controller.dart';

class FilterMapBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FilterMapController>(() => FilterMapController());
  }
}
