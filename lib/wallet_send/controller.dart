import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';
import 'package:luvpark_get/routes/routes.dart';

import '../custom_widgets/alert_dialog.dart';

class WalletSendController extends GetxController
    with GetSingleTickerProviderStateMixin {
  WalletSendController();
  final parameter = Get.arguments;
  final GlobalKey<FormState> formKeySend = GlobalKey<FormState>();
  final TextEditingController recipient = TextEditingController();
  final TextEditingController tokenAmount = TextEditingController();
  final TextEditingController message = TextEditingController();
  final TextEditingController sub = TextEditingController();
  final GlobalKey contentKey = GlobalKey();
  RxBool isLpAccount = false.obs;
  RxBool isLoading = true.obs;

  RxBool isNetConn = true.obs;
  RxList userData = [].obs;

  RxInt denoInd = 0.obs;

  RxInt indexbtn = 0.obs;
  RxList<int> padNumbers = [10, 20, 30, 40, 50, 100, 200, 250].obs;
  Timer? _timer;

// //naa
  Future<void> onTextChange() async {
    denoInd.value = -1;
  }

//naa
  Future<void> getVerifiedAcc() async {
    CustomDialog().loadingDialog(Get.context!);

    var params =
        "${ApiKeys.gApiSubFolderVerifyNumber}?mobile_no=63${recipient.text.toString().replaceAll(" ", "")}";
    HttpRequest(
      api: params,
    ).get().then((returnData) async {
      if (returnData == "No Internet") {
        Get.back();
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData == null) {
        Get.back();
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      }

      if (returnData["items"][0]["is_valid"] == "Y") {
        sendOtp();
        return;
      } else {
        Get.back();
        CustomDialog().errorDialog(
            Get.context!, "luvpark", returnData["items"][0]["msg"], () {
          Get.back();
        });
      }
    });
  }

//naa
  Future<void> sendOtp() async {
    final item = await Authentication().getUserLogin();
    Map<String, dynamic> paramSend = {
      "mobile_no": item["mobile_no"],
    };

    HttpRequest(
            api: ApiKeys.gApiSubFolderPostReqOtpShare, parameters: paramSend)
        .post()
        .then(
      (retvalue) {
        if (retvalue == "No Internet") {
          Get.back();
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (retvalue == null) {
          Get.back();
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        } else {
          if (retvalue["success"] == "Y") {
            Get.back();
            List otpData = [
              {
                "amount": tokenAmount.text.toString().replaceAll(",", ""),
                "to_msg": message.text,
                "mobile_no": item["mobile_no"],
                "otp": int.parse(retvalue["otp"].toString()),
                "to_mobile_no": "63${recipient.text.replaceAll(" ", "")}"
              }
            ];

            Get.toNamed(
              Routes.sendOtp,
              arguments: {
                "otpData": otpData,
                "cb": () {
                  refreshUserData();
                }
              },
            );
          } else {
            Get.back();
            CustomDialog().errorDialog(Get.context!, "Error", retvalue["msg"],
                () {
              Get.back();
            });
          }
        }
      },
    );
  }

//naa
  Future<void> onBtnChange(int value) async {
    tokenAmount.text = value.toString();
    indexbtn.value = value;
  }

//naa
  Future<void> refreshUserData() async {
    isLoading.value = true;
    final userId = await Authentication().getUserId();
    String subApi = "${ApiKeys.gApiSubFolderGetBalance}?user_id=$userId";

    HttpRequest(api: subApi).get().then((returnBalance) async {
      isLoading.value = false;
      if (returnBalance == "No Internet") {
        isNetConn.value = false;

        return;
      }
      isNetConn.value = true;
      if (returnBalance["items"].isNotEmpty) {
        userData.value = returnBalance["items"];
      }
    });
  }

  Future<void> timerPeriodic() async {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      refreshUserData();
    });
  }

  @override
  void onInit() {
    timerPeriodic();

    super.onInit();
  }

  @override
  void onClose() {
    _timer!.cancel();
    super.onClose();
  }
}
