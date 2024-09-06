import 'package:get/get.dart';
import 'package:luvpark_get/parking_details/controller.dart';

class ParkingDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParkingDetailsController>(() => ParkingDetailsController());
  }
}
