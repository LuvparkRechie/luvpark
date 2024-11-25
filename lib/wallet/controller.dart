import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';

import '../custom_widgets/custom_text.dart';

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
  RxList<Widget> unverified = <Widget>[].obs;

  var userProfile;
  Timer? _timer;

  // Filter variables
  final GlobalKey<FormState> formKeyFilter = GlobalKey<FormState>();
  final TextEditingController fromDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getCurrentTime();
    getUserData();
  }

  void getCurrentTime() async {
    DateTime timeNow = await Functions.getTimeNow();
    toDate.text = timeNow.toString().split(" ")[0];
    fromDate.text =
        timeNow.subtract(const Duration(days: 1)).toString().split(" ")[0];
  }

  Future<void> getUserData() async {
    var item2 = await Authentication().getUserData2();
    userProfile = item2;
    unverified.value = [];
    if (item2["first_name"] == null || item2["first_name"].toString().isEmpty) {
      unverified.add(Container(
        padding: EdgeInsets.fromLTRB(23, 12, 10, 12),
        width: double.infinity,
        decoration: ShapeDecoration(
          color: Color(0xFF89C732),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          shadows: [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 15,
              offset: Offset(0, 5),
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              "assets/images/wallet_user.svg",
              width: 24,
              height: 24,
            ),
            SizedBox(
              width: 21,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTitle(
                  text: "Verification incomplete",
                  textAlign: TextAlign.start,
                  fontSize: 16,
                  color: Colors.white,
                ),
                SizedBox(height: 5),
                CustomParagraph(
                  text: "Only a few more steps to go",
                  textAlign: TextAlign.start,
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ],
        ),
      ));
    }
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

    HttpRequest(api: subApi).get().then((response) async {
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
        DateTime timeNow = await Functions.getTimeNow();
        DateTime today = timeNow.toUtc();

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
    final DateTime today = await Functions.getTimeNow();
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
