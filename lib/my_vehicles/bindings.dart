import 'package:get/get.dart';
import 'package:luvpark_get/my_vehicles/controller.dart';

class MyVehiclesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyVehiclesController>(() => MyVehiclesController());
  }
}
