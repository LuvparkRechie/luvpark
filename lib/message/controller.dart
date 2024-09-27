import 'dart:async';

import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/http/http_request.dart';

import '../http/api_keys.dart';
import '../sqlite/pa_message_table.dart';

class MessageScreenController extends GetxController {
  MessageScreenController();
  RxBool isLoading = true.obs;
  RxList messages = [].obs;
  Timer? debounce;

  @override
  void onInit() {
    refresher();
    startTimer();
    super.onInit();
  }

  @override
  void onClose() {
    debounce?.cancel();
    super.onClose();
  }

  Future<void> startTimer() async {
    if (debounce?.isActive ?? false) debounce?.cancel();

    debounce = Timer.periodic(Duration(seconds: 2), (timer) {
      refresher();
    });
  }

  Future<void> refresher() async {
    isLoading.value = true;
    getInataysiMae();
  }

  Future<void> getInataysiMae() async {
    final data = await PaMessageDatabase.instance.readAllMessage();

    messages.value = data;
  }

  Future<void> deleteMessage(int index) async {
    CustomDialog().confirmationDialog(Get.context!, "Delete Message",
        "Are you sure you want to delete this message?", "Cancel", "Yes", () {
      Get.back();
    }, () {
      Get.back();
      CustomDialog().loadingDialog(Get.context!);
      var params = {
        "push_status": "R",
        "push_msg_id": messages[index]["push_msg_id"],
      };
      HttpRequest(
              api: ApiKeys.gApiLuvParkPutUpdMessageNotif, parameters: params)
          .put()
          .then((updateData) async {
        print("updateData $updateData");
        if (updateData == "No Internet") {
          Get.back();
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (updateData == null) {
          Get.back();
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (updateData["success"] == "Y") {
          int messageId =
              int.tryParse(messages[index]["push_msg_id"].toString()) ?? -1;
          int rowsAffected =
              await PaMessageDatabase.instance.deleteMessageById(messageId);

          if (rowsAffected > 0) {
            Get.back();
            CustomDialog().successDialog(
                Get.context!, "Success", "Successfully deleted.", "Okay", () {
              Get.back();
              refresher();
            });
          } else {
            Get.back();
            CustomDialog().errorDialog(
                Get.context!, "Delete Message", "Failed to delete message.",
                () {
              Get.back();
            });
          }
        } else {
          Get.back();
          CustomDialog().infoDialog("Delete Message", updateData["msg"], () {
            Get.back();
          });
        }
      });
    });
  }

  // Future<void> deleteAll() async {
  //   if (messages.isEmpty) {
  //     CustomDialog().errorDialog(Get.context!, "luvpark", "No messages found",
  //         () {
  //       Get.back();
  //     });
  //   } else {
  //     CustomDialog().confirmationDialog(Get.context!, "luvpark",
  //         "Are you sure you want to delete all messages?", "Cancel", "Yes", () {
  //       Get.back();
  //     }, () {
  //       messages.clear();
  //       Get.back();
  //     });
  //   }
  // }
}
