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
  String parameter = Get.arguments;
  late TabController tabController;
  TextEditingController searchCtrl = TextEditingController();

  PageController pageController = PageController();
  RxInt currentPage = 0.obs;
  RxList resData = [].obs;
  RxBool hasNet = false.obs;
  RxDouble tabHeight = 0.0.obs;
  bool isAllowToSync = true;
  RxInt tabIndex = 0.obs;
  RxBool tabLoading = true.obs;
  RxBool isLoading = true.obs;
  Timer? _timer;
  ParkingController();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: 2);

    if (parameter == "N") {
      onTabTapped(1);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      onRefresh();
      onTimerRun();
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    pageController.dispose();
    searchCtrl.dispose();
    _timer?.cancel();
    super.onClose();
  }

  void onTimerRun() {
    _timer = Timer.periodic(Duration(seconds: 5), (t) async {
      DateTime now = await Functions.getTimeNow();
      final id = await Authentication().getUserId();
      String api =
          "${currentPage.value == 1 ? ApiKeys.gApiSubFolderGetActiveParking : ApiKeys.gApiSubFolderGetReservations}?luvpay_id=$id";

      final returnData = await HttpRequest(api: api).get();
      resData.value = [];
      resData.value = [];
      List itemData = returnData["items"];
      if (itemData.isNotEmpty) {
        itemData = itemData.where((element) {
          DateTime timeNow = now;
          DateTime timeOut = DateTime.parse(element["dt_out"].toString());
          return timeNow.isBefore(timeOut);
        }).toList();
      }
      resData.value = itemData;

      resData.value = itemData;
    });
  }

  void onTabTapped(int index) {
    currentPage.value = index;
    tabLoading.value = true;

    getReserveData(index == 0 ? "C" : "U");
  }

  Future<void> onRefresh() async {
    isLoading.value = true;
    getReserveData(currentPage.value == 0 ? "C" : "U");
  }

  //Get Reserve Data
  Future<void> getReserveData(String status) async {
    DateTime now = await Functions.getTimeNow();
    final id = await Authentication().getUserId();

    String api =
        "${currentPage.value == 1 ? ApiKeys.gApiSubFolderGetActiveParking : ApiKeys.gApiSubFolderGetReservations}?luvpay_id=$id";

    try {
      final returnData = await HttpRequest(api: api).get();

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
        resData.value = itemData;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // BTN details
  Future<void> getParkingDetails(dynamic data) async {
    CustomDialog().loadingDialog(Get.context!);
    int userId = await Authentication().getUserId();

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

    String api = "${ApiKeys.gApiGetParkingQR}?ticket_id=${data["ticket_id"]}";

    final response = await HttpRequest(api: api).get();
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
      return;
    }
    if (response["items"].isEmpty) {
      CustomDialog().infoDialog("No data", "No data found. Please try again.",
          () {
        Get.back();
      });
      return;
    } else {
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
        'refno': data["ticket_ref_no"].toString().toString(),
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
        'qr_code': response["items"][0]["qr_code"],
        'onRefresh': () {
          onRefresh();
        }
      };
      Get.toNamed(Routes.bookingReceipt, arguments: args);
    }
  }
}
