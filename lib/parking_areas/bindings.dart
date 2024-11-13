import 'package:get/get.dart';
import 'package:luvpark/parking_areas/controller.dart';

class ParkingAreasBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParkingAreasController>(() => ParkingAreasController());
  }
}
