import 'package:get/get.dart';
import 'package:luvpark/wallet_qr/myqr/controller.dart';

class myQRBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<myQRController>(() => myQRController());
  }
}
