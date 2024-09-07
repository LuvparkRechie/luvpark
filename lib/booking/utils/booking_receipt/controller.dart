import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luvpark_get/booking/utils/extend.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';

class BookingReceiptController extends GetxController
    with GetTickerProviderStateMixin {
  final parameters = Get.arguments;
  late Timer _timer;
  RxDouble progress = 0.0.obs;
  RxInt noHours = 1.obs;
  Rx<Duration?> timeLeft = Rx<Duration?>(null);
  RxBool isSubmit = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (parameters["status"] == "A") {
      startTimer();
    }
  }

  void startTimer() {
    DateTime startTime =
        DateTime.parse(parameters["paramsCalc"]["dt_in"].toString());
    DateTime endTime =
        DateTime.parse(parameters["paramsCalc"]["dt_out"].toString());

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      DateTime currentTime = DateTime.now();
      Duration timeElapsed = currentTime.difference(startTime);
      Duration totalTime = endTime.difference(startTime);
      progress.value = timeElapsed.inSeconds / totalTime.inSeconds;

      Duration remainingTime = endTime.difference(currentTime);
      if (remainingTime.isNegative) {
        remainingTime = Duration.zero;
      }
      timeLeft.value = remainingTime;

      if (progress.value >= 1) {
        _timer.cancel();
        progress.value = 1.0;
        CustomDialog().loadingDialog(Get.context!);
        Future.delayed(const Duration(seconds: 2), () {
          Get.back();
          Get.back();
        });
      }
    });
  }

  String formatDateTime(DateTime dtIn, DateTime dtOut) {
    final DateFormat dateFormat = DateFormat('MMM d');
    final DateFormat fullDateFormat = DateFormat('MMM d, yyyy');

    // Check if the dates are on the same day
    if (dtIn.toLocal().year == dtOut.toLocal().year &&
        dtIn.toLocal().month == dtOut.toLocal().month &&
        dtIn.toLocal().day == dtOut.toLocal().day) {
      return fullDateFormat.format(dtIn);
    } else {
      final startDate = dateFormat.format(dtIn);
      final endDate = dateFormat.format(dtOut);
      final endYear = fullDateFormat.format(dtOut).split(', ')[1];

      return '$startDate - ${endDate.split(" ")[1]}, $endYear';
    }
  }

  String formatTimeRange(String dtIn, String dtOut) {
    final DateFormat timeFormat = DateFormat('h:mm a');
    return '${timeFormat.format(DateTime.parse(dtIn))} - ${timeFormat.format(DateTime.parse(dtOut))}';
  }

//EXTEND FUNCTION
  void onExtend() {
    Get.bottomSheet(const ExtendParking(),
        isDismissible: true, isScrollControlled: true);
  }

  void onAdd() {
    noHours.value++;
    update();
  }

  void onMinus() {
    if (noHours.value == 1) return;
    noHours.value--;
    update();
  }

  void cancelAdvanceParking() {
    DateTime now = DateTime.now();
    DateTime resDate = DateTime.parse(parameters["startDate"].toString());

    if (int.parse(now.difference(resDate).inMinutes.toString()) >
        int.parse(parameters["cancel_minute"].toString())) {
      CustomDialog().errorDialog(Get.context!, "luvpark",
          "The cancellation period for your booking has expired.", () {
        Get.back();
      });
      return;
    }
    CustomDialog().confirmationDialog(Get.context!, "Cancel Booking",
        "Are you sure you want to cancel your booking? ", "No", "Yes", () {
      Get.back();
    }, () {
      Get.back();
      CustomDialog().loadingDialog(Get.context!);
      Map<String, dynamic> param = {
        "reservation_id": parameters["reservationId"]
      };

      HttpRequest(api: ApiKeys.gApiPostCancelParking, parameters: param)
          .postBody()
          .then((objData) async {
        Get.back();

        if (objData == "No Internet") {
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (objData == null) {
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        }
        if (objData["success"] == "Y") {
          CustomDialog().successDialog(
              Get.context!, "Success", "Successfully cancelled booking", "Okay",
              () {
            Get.back();
            Get.back();
            parameters["onRefresh"]();
          });
        } else {
          CustomDialog().errorDialog(Get.context!, "luvpark", objData["msg"],
              () {
            Get.back();
          });
          return;
        }
      });
    });
  }

  void cancelAutoExtend() {
    CustomDialog().errorDialog(
        Get.context!, "Sorry", "We're currently working on it", () {
      Get.back();
    });
  }

  //EXTend parking
  void extendParking() {
    CustomDialog().confirmationDialog(Get.context!, "Extend Parking",
        "Are you sure you want to extend your parking? ", "No", "Yes", () {
      Get.back();
    }, () {
      Get.back();
      CustomDialog().loadingDialog(Get.context!);
      Map<String, dynamic> param = {
        "reservation_id": parameters["reservationId"],
        "no_hours": parameters["hours"]
      };
      HttpRequest(api: ApiKeys.gApiCancelAutoExtend, parameters: param)
          .postBody()
          .then((objData) async {
        Get.back();

        if (objData == "No Internet") {
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (objData == null) {
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        }
        if (objData["success"] == "Y") {
          CustomDialog().successDialog(
              Get.context!, "Success", objData["msg"], "Okay", () {
            Get.back();
            Get.back();
            Get.back();
            parameters["onRefresh"]();
          });
        } else {
          CustomDialog().errorDialog(Get.context!, "luvpark", objData["msg"],
              () {
            Get.back();
          });
          return;
        }
      });
    });
  }

  @override
  void onClose() {
    if (parameters["status"] == "A") {
      _timer.cancel();
    }
    super.onClose();
  }
}
