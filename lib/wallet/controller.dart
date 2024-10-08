import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/functions/functions.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';

class WalletController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Observable variables
  RxBool isLoadingCard = true.obs;
  RxBool isLoadingLogs = true.obs;
  RxBool isNetConnCard = true.obs;
  RxBool isNetConnLogs = true.obs;
  RxList logs = [].obs;
  RxList userData = [].obs;
  RxString userImage = "".obs;
  RxString fname = "".obs;
  RxList filterLogs = [].obs;

  Timer? _timer;

  // Filter variables
  final GlobalKey<FormState> formKeyFilter = GlobalKey<FormState>();
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    DateTime timeNow = DateTime.now();
    toDate.text = timeNow.toString().split(" ")[0];
    fromDate.text =
        timeNow.subtract(const Duration(days: 1)).toString().split(" ")[0];
    getUlala();
  }

  Future<void> getUlala() async {
    final userPp = await Authentication().getUserProfilePic();
    var uData = await Authentication().getUserData();
    var item = jsonDecode(uData!);
    userImage.value = userPp;

    fname.value = item['first_name'] == null
        ? "Not specified"
        : "${item['first_name']} ${item['last_name']}";

    getUserBalance();
    timerPeriodic();
  }

  Future<void> timerPeriodic() async {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      getUserBalance();
      getLogs();
    });
  }

  Future<void> onRefresh() async {
    if (isLoadingCard.value) return;

    _timer?.cancel();
    isLoadingCard.value = true;
    isLoadingLogs.value = true;
    isNetConnCard.value = true;
    isNetConnLogs.value = true;

    timerPeriodic();
  }

  Future<void> getUserBalance() async {
    Functions.getUserBalance2(Get.context!, (dataBalance) async {
      if (!dataBalance[0]["has_net"]) {
        isLoadingCard.value = false;
        isNetConnCard.value = false;
        userData.value = [];
        return;
      } else {
        isLoadingCard.value = false;
        isNetConnCard.value = true;

        userData.value = dataBalance[0]["items"];

        getLogs();
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
        isLoadingLogs.value = false;
        isNetConnLogs.value = false;
        return;
      }

      if (response == null) {
        isLoadingLogs.value = false;
        isNetConnLogs.value = true;
        return;
      }

      if (response["items"].isNotEmpty) {
        DateTime today = DateTime.now().toUtc();
        String todayString = today.toIso8601String().substring(0, 10);

        List filteredTransactions = response["items"].where((transaction) {
          String transactionDate =
              transaction['tran_date'].toString().split("T")[0];
          return transactionDate == todayString;
        }).toList();

        logs.value = filteredTransactions;
        isLoadingLogs.value = false;
        isNetConnLogs.value = true;
      } else {
        isLoadingLogs.value = false;
        isNetConnLogs.value = true;
      }
    });
  }

  Future<void> applyFilter() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (fromDate.text.isEmpty || toDate.text.isEmpty) {
      return;
    } else {
      Get.back();
      getLogs();
    }
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final DateTime today = DateTime.now();
    final DateTime firstDateLimit = today.subtract(const Duration(days: 29));

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
      initialDate: today,
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

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
