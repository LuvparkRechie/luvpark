import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/functions/functions.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';

class TransactionHistoryController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TransactionHistoryController();
  RxBool isLoading = true.obs;
  RxBool isNetConn = true.obs;
  bool isAllowToSync = true;

  RxList logs = [].obs;
  RxList userData = [].obs;
  RxString fname = "".obs;

  final GlobalKey<FormState> formKeyFilter = GlobalKey<FormState>();
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    DateTime timeNow = DateTime.now();
    toDate.text = timeNow.toString().split(" ")[0];
    fromDate.text =
        timeNow.subtract(const Duration(days: 29)).toString().split(" ")[0];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getUserBalance();
    });
  }

  Future<void> fetchData() async {
    if (isAllowToSync) {
      try {
        isLoading.value = true;
        await getUserBalance();
      } catch (e) {
        isLoading.value = false;
        isNetConn.value = false;
        CustomDialog().errorDialog(
          Get.context!,
          "luvpark",
          "Error while connecting to server, Please contact support.",
          () => Get.back(),
        );
      }
    }
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final DateTime today = DateTime.now();
    final DateTime firstDateLimit =
        today.subtract(const Duration(days: 29)); // Limit to the last 29 days

    DateTime? firstDate;
    DateTime? lastDate;

    if (isStartDate) {
      firstDate = firstDateLimit; // Allow selection starting from 29 days ago
      lastDate = today; // Prevent selecting dates after today
    } else {
      firstDate =
          DateTime.parse(fromDate.text); // Start date selected by the user
      lastDate = today; // Prevent selecting dates after today
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? DateTime.parse(fromDate.text) : DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      final formattedDate = pickedDate.toString().split(' ')[0];
      if (isStartDate) {
        fromDate.text = formattedDate;
      } else {
        toDate.text = formattedDate;
      }
    }
  }

  Future<void> getUserBalance() async {
    var uData = await Authentication().getUserData();
    var item = jsonDecode(uData!);
    fname.value = "${item['first_name']} ${item['last_name']}";

    Functions.getUserBalance(Get.context!, (dataBalance) async {
      if (!dataBalance[0]["has_net"]) {
        isLoading.value = false;
        isNetConn.value = false;
        isAllowToSync = false;
        return;
      } else {
        userData.value = dataBalance[0]["items"];
        await getLogs();
      }
    });
  }

  Future<void> getLogs() async {
    final item = await Authentication().getUserData();
    String userId = jsonDecode(item!)['user_id'].toString();

    String subApi =
        "${ApiKeys.gApiSubFolderGetTransactionLogs}?user_id=$userId&tran_date_from=${fromDate.text}&tran_date_to=${toDate.text}";

    HttpRequest(api: subApi).get().then((response) {
      if (response == "No Internet") {
        isAllowToSync = false;
        isLoading.value = false;
        isNetConn.value = false;
        logs.value = [];
        CustomDialog().internetErrorDialog(Get.context!, () => Get.back());
        return;
      }
      if (response == null) {
        isLoading.value = false;
        isNetConn.value = true;
        isAllowToSync = false;
        logs.value = [];
        CustomDialog().errorDialog(
          Get.context!,
          "luvpark",
          "Error while connecting to server, Please contact support.",
          () => Get.back(),
        );
        return;
      }

      if (response["items"].isNotEmpty) {
        isLoading.value = false;
        isNetConn.value = true;
        isAllowToSync = true;
        logs.value = response["items"];
      } else {
        isLoading.value = false;
        isNetConn.value = true;
        isAllowToSync = false;
        logs.value = [];
      }
    });
  }
}
