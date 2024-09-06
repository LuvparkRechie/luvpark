import 'package:get/get.dart';
import 'package:luvpark_get/booking_notice/controller.dart';

class BookingNoticeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingNoticeController>(() => BookingNoticeController());
  }
}
