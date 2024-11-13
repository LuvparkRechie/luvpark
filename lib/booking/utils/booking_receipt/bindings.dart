import 'package:get/get.dart';
import 'package:luvpark/booking/utils/booking_receipt/controller.dart';

class BookingReceiptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingReceiptController>(() => BookingReceiptController());
  }
}
