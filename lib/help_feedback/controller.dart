import 'dart:convert';

import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/web_view/webview.dart';

import '../functions/functions.dart';
import '../login/controller.dart';
import '../routes/routes.dart';

class HelpandFeedbackController extends GetxController {
  RxString mobileNo = "".obs;
  RxList userData = [].obs;

  Future<void> deleteAccount() async {
    CustomDialog().loadingDialog(Get.context!);
    try {
      final mydata = await Authentication().getUserData2();

      mobileNo.value = mydata["mobile_no"];

      Map<String, dynamic> param = {
        "mobile_no": mydata["mobile_no"],
      };
      var returnData =
          await HttpRequest(api: ApiKeys.postDeleteUserAcct, parameters: param)
              .post();
      Get.back();

      if (returnData == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData["success"] == "Y") {
        _showSuccessDialog(returnData);
      } else {
        _showErrorDialog("Error on Deleting Account", returnData["msg"]);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to delete account: $e");
    }
  }

  void _showErrorDialog(String title, String message) {
    CustomDialog().errorDialog(Get.context!, title, message, () {
      Get.back();
    });
  }

  void _showSuccessDialog(Map<String, dynamic> returnData) {
    CustomDialog().successDialog(
        Get.context!,
        "Success",
        "You will be directed to delete account page. Wait for customer support",
        "Okay", () {
      Get.back();
      Get.to(WebviewPage(
        urlDirect: "https://luvpark.ph/account-deletion/",
        label: "Account Deletion",
        isBuyToken: false,
        callback: () async {
          CustomDialog().loadingDialog(Get.context!);
          Get.put(LoginScreenController());

          CustomDialog().infoDialog(
              "Account status", "Your account might not be active.", () async {
            Get.back();
            CustomDialog().loadingDialog(Get.context!);
            await Future.delayed(const Duration(seconds: 3));
            final userLogin = await Authentication().getUserLogin();
            List userData = [userLogin];
            userData = userData.map((e) {
              e["is_login"] = "N";
              return e;
            }).toList();

            await Authentication().setLogin(jsonEncode(userData[0]));

            Get.back();
            Get.offAllNamed(Routes.login);
          });
        },
      ));
    });
  }
}
