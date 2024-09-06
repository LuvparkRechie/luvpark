import 'package:get/get.dart';
import 'package:luvpark_get/rate_booking/controller.dart';

class RateBookingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RateBookingController>(() => RateBookingController());
  }
}
