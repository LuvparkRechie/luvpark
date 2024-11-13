import 'package:get/get.dart';
import 'package:luvpark/parking/index.dart';

class ParkingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParkingController>(() => ParkingController());
  }
}
