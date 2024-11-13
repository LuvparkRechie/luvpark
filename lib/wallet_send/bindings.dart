import 'package:get/get.dart';
import 'package:luvpark/wallet_send/index.dart';

class WalletSendBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletSendController>(() => WalletSendController());
  }
}
