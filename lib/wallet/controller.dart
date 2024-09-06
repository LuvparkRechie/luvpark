import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/functions/functions.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';

class WalletController extends GetxController
    with GetSingleTickerProviderStateMixin {
  WalletController();
  late StreamController<void> _dataController;
  late StreamSubscription<void> dataSubscription;
  RxBool isLoading = true.obs;
  RxBool isNetConn = true.obs;
  RxList logs = [].obs;
  RxList userData = [].obs;
  var userImage;
  RxString fname = "".obs;
  RxList filterLogs = [].obs;

  //FILTER VARIABLES
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
    _dataController = StreamController<void>();
    getUserBalance();
  }

  void streamData() {
    dataSubscription = _dataController.stream.listen((data) {});
    fetchDataPeriodically();
  }

  void fetchDataPeriodically() async {
    dataSubscription = Stream.periodic(const Duration(seconds: 10), (count) {
      fetchData();
    }).listen((event) {});
  }

  Future<void> fetchData() async {
    await Future.delayed(const Duration(seconds: 5));
    getUserBalance();
  }

  Future<void> getUserBalance() async {
    print("Get user balance");
    final userPp = await Authentication().getUserProfilePic();
    var uData = await Authentication().getUserData();
    var item = jsonDecode(uData!);
    userImage = userPp;

    if (item['first_name'] == null) {
      fname.value = "Not specified";
    } else {
      fname.value =
          "${item['first_name'].toString()} ${item['last_name'].toString()}";
    }

    Functions.getUserBalance2(Get.context!, (dataBalance) async {
      if (!dataBalance[0]["has_net"]) {
        isLoading.value = false;
        isNetConn.value = false;

        return;
      } else {
        userData.value = dataBalance[0]["items"];
        getLogs();
      }
    });
  }

  Future<void> onRefresh() async {
    if (isLoading.value) return;
    isLoading.value = true;
    isNetConn.value = true;
    getUserBalance();
  }

  Future<void> applyFilter() async {
    FocusManager.instance.primaryFocus!.unfocus();
    if (fromDate.text.isEmpty || toDate.text.isEmpty) {
      return;
    } else {
      Get.back();
      getLogs();
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

//Get logs | transaction Page
  Future<void> getLogs() async {
    print("get logs");
    final item = await Authentication().getUserData();
    String userId = jsonDecode(item!)['user_id'].toString();
    isLoading.value = true;

    String subApi =
        "${ApiKeys.gApiSubFolderGetTransactionLogs}?user_id=$userId&tran_date_from=${fromDate.text}&tran_date_to=${toDate.text}";

    HttpRequest(api: subApi).get().then((response) {
      print("response $response");
      if (response == "No Internet") {
        isLoading.value = false;
        isNetConn.value = false;
        logs.value = [];
        CustomDialog().internetErrorDialog(Get.context!, () => Get.back());
        return;
      }
      if (response == null) {
        isLoading.value = false;
        isNetConn.value = true;
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

        DateTime today = DateTime.now().toUtc();
        String todayString = today.toIso8601String().substring(0, 10);
        // print(response["items"]);
        List filteredTransactions = response["items"].where((transaction) {
          String transactionDate =
              transaction['tran_date'].toString().split("T")[0];

          return transactionDate == todayString;
        }).toList();

        logs.value = filteredTransactions;
        streamData();
      } else {
        _dataController.close();

        isLoading.value = false;
        isNetConn.value = true;

        logs.value = [];
      }
    });
  }

  @override
  void onClose() {
    _dataController.close();
    dataSubscription.cancel();
    super.onClose();
  }
}
