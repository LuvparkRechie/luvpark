import 'dart:async';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:luvpark_get/booking/utils/extend.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/functions/functions.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';

import '../../../auth/authentication.dart';

class BookingReceiptController extends GetxController
    with GetTickerProviderStateMixin {
  final parameters = Get.arguments;
  late Timer _timer;
  late Timer _timerEta;
  RxDouble progress = 0.0.obs;
  RxInt noHours = 1.obs;
  Rx<Duration?> timeLeft = Rx<Duration?>(null);
  RxBool isSubmit = false.obs;
  RxBool btnDisabled = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (parameters["status"] == "A") {
      startTimer();
    } else {
      checkEta();
    }
  }

  void checkEta() {
    _timerEta = Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
      List ltlng = await Functions.getCurrentPosition();
      LatLng coordinates = LatLng(ltlng[0]["lat"], ltlng[0]["long"]);
      LatLng dest = LatLng(double.parse(parameters["lat"].toString()),
          double.parse(parameters["long"].toString()));
      final etaData = await Functions.fetchETA(coordinates, dest);

      if (etaData[0]["distance"]
          .toString()
          .toLowerCase()
          .trim()
          .contains("km")) {
        if (btnDisabled.value) return;
        btnDisabled.value = true;
      } else {
        if (int.parse(etaData[0]["distance"].toString().trim().split(" ")[0]) <=
            5) {
          if (!btnDisabled.value) return;
          btnDisabled.value = false;
        } else {
          if (btnDisabled.value) return;
          btnDisabled.value = true;
        }
      }
    });
  }

  void startTimer() {
    DateTime startTime =
        DateTime.parse(parameters["paramsCalc"]["dt_in"].toString());
    DateTime endTime =
        DateTime.parse(parameters["paramsCalc"]["dt_out"].toString());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      DateTime timeNow = await Functions.getTimeNow();
      DateTime currentTime = timeNow;
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

  void cancelAdvanceParking() async {
    DateTime now = await Functions.getTimeNow();
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

  Future<void> checkIn() async {
    int userId = await Authentication().getUserId();
    dynamic chkInParam = {
      "ticket_id": parameters["ticketId"],
      "luvpay_id": userId,
    };
    CustomDialog().loadingDialog(Get.context!);
    List ltlng = await Functions.getCurrentPosition();
    LatLng coordinates = LatLng(ltlng[0]["lat"], ltlng[0]["long"]);
    LatLng dest = LatLng(double.parse(parameters["lat"].toString()),
        double.parse(parameters["long"].toString()));
    final etaData = await Functions.fetchETA(coordinates, dest);

    if (etaData.isEmpty) {
      Get.back();
      CustomDialog().errorDialog(Get.context!, "Error",
          "We couldn't calculate the distance. Please check your connection and try again.",
          () {
        Get.back();
      });
      return;
    }

    if (etaData[0]["error"] == "No Internet") {
      Get.back();
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }

    btnDisabled.value = true;
    if (etaData[0]["distance"].toString().toLowerCase().trim().contains("km")) {
      Get.back();
      CustomDialog().infoDialog("Check-In",
          "You should be within 5 meters of the parking zone to check-in.", () {
        btnDisabled.value = true;
        Get.back();
      });
    } else {
      if (int.parse(etaData[0]["distance"].toString().trim().split(" ")[0]) <=
          5) {
        btnDisabled.value = false;
        HttpRequest(api: ApiKeys.gApiPostSelfCheckIn, parameters: chkInParam)
            .postBody()
            .then((returnData) async {
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

          if (returnData["success"] == 'Y') {
            Get.back();
            CustomDialog().successDialog(
                Get.context!, "Check-In", "Successfully checked-in", "Okay",
                () {
              Get.back();
            });
          } else {
            CustomDialog()
                .errorDialog(Get.context!, "luvpark", returnData["msg"], () {
              Get.back();
            });
          }
        });
      } else {
        Get.back();
        CustomDialog().infoDialog(
            "Check-In", "You are 5 meters away from the parking area.", () {
          btnDisabled.value = true;
          Get.back();
        });
      }
    }
  }

  void cancelAutoExtend() {
    CustomDialog().confirmationDialog(
        Get.context!,
        "Cancel auto extend",
        "Are you sure you want to cancel auto extend parking? ",
        "No",
        "Yes", () {
      Get.back();
    }, () {
      Get.back();
      CustomDialog().loadingDialog(Get.context!);
      Map<String, dynamic> param = {
        "reservation_id": parameters["reservationId"]
      };
      HttpRequest(api: ApiKeys.gApiCancelAutoExtend, parameters: param)
          .postBody()
          .then((objData) async {
        if (objData == "No Internet") {
          Get.back();
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (objData == null) {
          Get.back();
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        }
        if (objData["success"] == "Y") {
          Get.back();
          CustomDialog().successDialog(
              Get.context!, "Success", objData["msg"], "Okay", () {
            Get.back();
            Get.back();
            parameters["onRefresh"]();
          });
        } else {
          Get.back();
          CustomDialog().errorDialog(Get.context!, "luvpark", objData["msg"],
              () {
            Get.back();
          });
          return;
        }
      });
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
      HttpRequest(api: ApiKeys.gApiExtendParking, parameters: param)
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
    } else {
      _timerEta.cancel();
    }
    super.onClose();
  }
}
