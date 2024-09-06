import 'package:get/get.dart';
import 'package:luvpark_get/parking/index.dart';

class ParkingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParkingController>(() => ParkingController());
  }
}
