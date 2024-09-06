import 'package:get/get.dart';
import 'package:luvpark_get/parking_areas/controller.dart';

class ParkingAreasBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParkingAreasController>(() => ParkingAreasController());
  }
}
