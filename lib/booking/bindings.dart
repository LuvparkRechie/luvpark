import 'package:get/get.dart';
import 'package:luvpark_get/booking/controller.dart';

class BookingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(() => BookingController());
  }
}
