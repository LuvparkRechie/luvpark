// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';

import '../routes/routes.dart';

class ParkingController extends GetxController
    with GetTickerProviderStateMixin {
  ParkingController();
  String parameter = Get.arguments;
  late TabController tabController;
  TextEditingController searchCtrl = TextEditingController();

  PageController pageController = PageController();
  RxInt currentPage = 0.obs;
  RxList resData = [].obs;
  RxString qrKey = "".obs;
  RxBool hasNet = false.obs;
  RxDouble tabHeight = 0.0.obs;
  bool isAllowToSync = true;
  RxInt tabIndex = 0.obs;
  RxBool tabLoading = true.obs;
  RxBool isLoading = true.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: 2);

    if (parameter == "N") {
      onTabTapped(1);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      onRefresh();
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    pageController.dispose();
    searchCtrl.dispose();

    _timer!.cancel();
    super.onClose();
  }

  void onTimerRun() {
    _timer = Timer.periodic(Duration(seconds: 5), (t) async {
      final id = await Authentication().getUserId();
      String api =
          "${currentPage.value == 1 ? ApiKeys.getActiveParking : ApiKeys.getParkingRes}$id";

      final returnData = await HttpRequest(api: api).get();
      print("apii2$api");
      List itemData = returnData["items"];

      if (itemData.isEmpty) {
        resData.value = itemData;
        isLoading.value = false;
      } else {
        initializeTimers(itemData);
      }
    });
  }

  void onTabTapped(int index) {
    currentPage.value = index;
    tabLoading.value = true;

    getReserveData(index == 0 ? "C" : "U");
  }

  Future<void> onRefresh() async {
    isLoading.value = true;
    if (_timer != null) {
      _timer!.cancel();
    }

    getReserveData(currentPage.value == 0 ? "C" : "U");
  }

  //Get Reserve Data
  Future<void> getReserveData(String status) async {
    final id = await Authentication().getUserId();

    String api =
        "${currentPage.value == 1 ? ApiKeys.getActiveParking : ApiKeys.getParkingRes}$id";
    final returnData = await HttpRequest(api: api).get();
    print("apii1 $api");

    tabLoading.value = false;
    if (returnData == "No Internet") {
      isLoading.value = false;
      hasNet.value = false;
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    isLoading.value = false;
    hasNet.value = true;
    if (returnData == null) {
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    } else {
      resData.value = [];
      List itemData = returnData["items"];

      if (itemData.isEmpty) {
        resData.value = itemData;
        isLoading.value = false;
      } else {
        initializeTimers(itemData);
      }

      onTimerRun();
    }
  }

  // BTN details
  Future<void> getParkingDetails(dynamic data) async {
    CustomDialog().loadingDialog(Get.context!);
    int userId = await Authentication().getUserId();

    await getEncryptQr(data["ticket_id"]);
    var dateInRelated = "";
    var dateOutRelated = "";
    dateInRelated = data["dt_in"];
    dateOutRelated = data["dt_out"];
    DateTime now = await Functions.getTimeNow();
    DateTime resDate = DateTime.parse(data["reservation_date"].toString());

    Map<String, dynamic> parameters = {
      "client_id": userId,
      "park_area_id": data["park_area_id"],
      "vehicle_type_id": data["vehicle_type_id"],
      "vehicle_plate_no": data["vehicle_plate_no"],
      "dt_in": dateInRelated,
      "dt_out": dateOutRelated,
      "no_hours": data["no_hours"].toString(),
      "tran_type": "E",
    };
    dynamic args = {
      'ticketId': data["ticket_id"],
      'spaceName': data["park_area_name"],
      'parkArea': data["park_area_name"],
      'startDate': data["dt_in"],
      'endDate': data["dt_out"],
      'closing_date': data["end_time"],
      'startTime': dateInRelated.toString().split(" ")[1].toString(),
      'endTime': dateOutRelated.toString().split(" ")[1].toString(),
      'plateNo': data["vehicle_plate_no"],
      'hours': data["no_hours"].toString(),
      'amount': data["amount"].toString(),
      'refno': data["ticket_ref_no"].toString(),
      'lat': double.parse(data["latitude"].toString()),
      'long': double.parse(data["longitude"].toString()),
      'canReserved': true,
      'isReserved': false,
      'isShowRate': false,
      'reservationId': data["reservation_id"],
      'address': data["address"],
      'isAutoExtend': data["is_auto_extend"],
      'isBooking': false,
      'paramsCalc': parameters,
      'status': data["status"].toString() == "C" ? "R" : "A",
      'can_cancel': data["status"].toString() == "U"
          ? false
          : int.parse(now.difference(resDate).inMinutes.toString()) <=
              int.parse(data["cancel_minutes"].toString()),
      'cancel_minute':
          data["status"].toString() == "U" ? "" : data["cancel_minutes"],
      // 'qr_code': data["ticket_ref_no"].toString(),
      'qr_code': qrKey.value,
      'onRefresh': () {
        onRefresh();
      }
    };
    Get.back();
    Get.toNamed(Routes.bookingReceipt, arguments: args);
  }

  Future<void> getEncryptQr(int ticketId) async {
    String api = "${ApiKeys.getResQr}$ticketId";
    final response = await HttpRequest(api: api).get().then((response) async {
      if (response == "No Internet") {
        isLoading.value = false;
        hasNet.value = false;
        return;
      }
      if (response == null) {
        isLoading.value = false;
        hasNet.value = true;
        return;
      } else {
        hasNet.value = true;
        isLoading.value = false;
        qrKey.value = response["items"][0]["qr_code"];
      }
    });
  }

  Future<List> calculateCancelTime(objData) async {
    List dataListitem = [];

    DateTime currentTime = await Functions.getTimeNow();
    //compute time remaining
    DateTime timeIn = DateTime.parse(objData["dt_in"].toString());

    DateTime endTime = DateTime.parse(objData["dt_out"]);
    Duration timeLeft = endTime.difference(currentTime);
    Duration remainingTime = timeLeft.isNegative ? Duration.zero : timeLeft;

    Duration newTimeLeft = endTime.difference(DateTime.now());
    if (newTimeLeft.isNegative || newTimeLeft == Duration.zero) {
      remainingTime = Duration.zero; // Set to zero when time runs out
    } else {
      remainingTime = newTimeLeft;
    }
    bool cancelTimeRemaining = currentTime.difference(timeIn).inMinutes > 5 ||
            currentTime.difference(timeIn).inMinutes < 0 ||
            currentPage.value == 1
        ? false
        : true;

    dataListitem = [
      {
        "can_cancel": cancelTimeRemaining,
        "time_remaining": remainingTime,
      }
    ];

    return dataListitem;
  }

  void initializeTimers(data) async {
    List dataItems = data;

    // We need to collect the future results before proceeding
    List futures = dataItems.map((e) async {
      List objData = await calculateCancelTime(e);

      e["can_cancelBooking"] = objData[0]["can_cancel"];
      e["time_remaining"] = objData[0]["time_remaining"];
      return e;
    }).toList();

    // Wait for all the futures to complete
    resData.value = await Future.wait(futures as Iterable<Future>);
  }

  void cancelAdvanceParking(data) async {
    DateTime now = await Functions.getTimeNow();
    DateTime resDate = DateTime.parse(data["dt_in"].toString());

    if (int.parse(now.difference(resDate).inMinutes.toString()) >
        int.parse(data["cancel_minutes"].toString())) {
      CustomDialog().errorDialog(Get.context!, "luvpark",
          "The cancellation period for your booking has expired.", () {
        Get.back();
      });
      return;
    }
    CustomDialog().confirmationDialog(Get.context!, "Cancel Booking",
        "Are you sure you want to cancel your booking? ", "No", "Yes", () {
      Get.back();
    }, () async {
      Get.back();
      CustomDialog().loadingDialog(Get.context!);
      Map<String, dynamic> param = {"reservation_id": data["reservation_id"]};
      dynamic paramRefund = {"reservation_id": data["reservation_id"]};

      final response = await HttpRequest(
              api: ApiKeys.putCancelBooking, parameters: paramRefund)
          .putBody();

      Get.back();
      if (response == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (response == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      }
      if (response["success"] == "Y") {
        CustomDialog().successDialog(
            Get.context!, "Success", "Successfully cancelled booking", "Okay",
            () {
          Get.back();
          onRefresh();
        });
      } else {
        CustomDialog().errorDialog(Get.context!, "luvpark", response["msg"],
            () {
          Get.back();
        });
      }
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));

    if (duration.inSeconds <= 0) {
      return "Expired";
    } else if (hours != "00") {
      return "$hours ${int.parse(hours.toString()) > 1 ? "hrs" : "hr"} $minutes min";
    } else if (minutes != "00") {
      return "$minutes min";
    } else {
      return "Expires soon";
    }
  }
}
