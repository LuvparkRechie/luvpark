import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';

import '../wallet_qr/paymerchant/index.dart';

class MerchantBillerController extends GetxController
    with GetSingleTickerProviderStateMixin {
  MerchantBillerController();

  RxBool isLoadingPage = true.obs;
  RxBool isBtnLoading = false.obs;
  RxBool isNetConn = true.obs;
  RxBool isPayPage = false.obs;
  RxList merchantData = [].obs;
  RxList merchantParam = [].obs;
  RxString pkey = "".obs;
  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getMyMerchantData();
    });

    super.onInit();
  }

  Future<void> refresher() async {
    isNetConn.value = true;
    getMyMerchantData();
  }

  Future<void> getPaymentKey(items, mkey, mname, mAddress) async {
    CustomDialog().loadingDialog(Get.context!);
    final userID = await Authentication().getUserId();

    HttpRequest(api: "${ApiKeys.gApiSubFolderPayments}$userID")
        .get()
        .then((paymentResponse) {
      // Get.back();

      if (paymentResponse == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (paymentResponse == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      } else
        Get.back();
      List itemData = [
        {
          "data": items,
          'merchant_key': mkey,
          'merchant_address': mAddress,
          "merchant_name": mname,
          "payment_key": paymentResponse["items"][0]["payment_hk"],
        }
      ];

      merchantParam.value = itemData;
      Get.bottomSheet(PayMerchant(data: merchantParam));
    });
  }

  void getMyMerchantData() {
    // API endpoint
    String api = ApiKeys.gApiBillerList;

    HttpRequest(api: api).get().then(
      (response) async {
        if (response == "No Internet") {
          isLoadingPage.value = false;
          isNetConn.value = false;
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }

        // Handle null or empty response
        if (response == null ||
            response["items"] == null ||
            response["items"].isEmpty) {
          isLoadingPage.value = false;
          isNetConn.value = true;
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        //else success
        merchantData.value = response["items"];
        isLoadingPage.value = false;
        isNetConn.value = true;
      },
    );
  }

  void pageSwitcher() {
    isPayPage.value = !isPayPage.value;

    update();
  }
}
