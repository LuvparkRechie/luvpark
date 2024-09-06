import 'package:get/get.dart';
import 'package:luvpark_get/transaction_history/controller.dart';

class TransactionHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionHistoryController>(
        () => TransactionHistoryController());
  }
}
