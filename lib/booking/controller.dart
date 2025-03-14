import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/booking/utils/success_dialog.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/routes/routes.dart';

import '../notification_controller.dart';

class BookingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  BookingController();
  final parameters = Get.arguments;

  RxBool isLoadingPage = true.obs;
  RxBool isInternetConn = true.obs;
  RxList myVehiclesData = [].obs;
  RxList ddVehiclesData = [].obs;
  RxList noticeData = [].obs;
  //Booking param

  //Rewards param
  RxString usedRewards = "0".obs;
  RxString tokenRewards = "0".obs;
  RxDouble displayRewards = 0.0.obs;
  RxBool isUseRewards = false.obs;
  List dataLastBooking = [];
  RegExp regExp = RegExp(r'[^a-zA-Z0-9]');

//new param new coding
  RxInt pageInd = 0.obs;
  Timer? _activeTmr;
  RxString stBookTime = "".obs;
  RxString endBookTime = "".obs;
  RxBool is24Hrs = false.obs;
  RxInt noOfHours = 0.obs;
  Map<String, dynamic> postBookParam = {};
  RxString vhTypeDisp = "".obs;

  @override
  void onInit() {
    super.onInit();

    displayRewards.value =
        double.parse(parameters["userData"][0]["points_bal"].toString());

    getNotice();
  }

  Future<void> getNotice() async {
    String subApi = "${ApiKeys.getParkingNotice}?msg_code=PREBOOKMSG";

    HttpRequest(api: subApi).get().then((retDataNotice) async {
      if (retDataNotice == "No Internet") {
        isLoadingPage.value = false;
        isInternetConn.value = false;
        noticeData.value = [];

        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (retDataNotice == null) {
        isInternetConn.value = true;
        isLoadingPage.value = true;
        noticeData.value = [];

        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      }
      if (retDataNotice["items"].length > 0) {
        isInternetConn.value = true;
        isLoadingPage.value = true;
        noticeData.value = retDataNotice["items"];
        Timer(Duration(milliseconds: 500), () {
          CustomDialog().bookingNotice(
              noticeData[0]["msg_title"], noticeData[0]["msg"], () {
            Get.back();
            Get.back();
          }, () {
            Get.back();
            getDropdownVehicles();
          });
        });
      } else {
        isInternetConn.value = true;
        isLoadingPage.value = false;
        noticeData.value = [];

        CustomDialog().errorDialog(Get.context!, "luvpark", "No data found",
            () {
          Get.back();
        });
      }
    });
  }

  //GET drodown vehicles per area
  Future<void> getDropdownVehicles() async {
    HttpRequest(
            api:
                "${ApiKeys.getDropdownVhTypesArea}?park_area_id=${parameters["areaData"]["park_area_id"]}")
        .get()
        .then((returnData) async {
      if (returnData == "No Internet") {
        isInternetConn.value = false;
        isLoadingPage.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });

        return;
      }
      if (returnData == null) {
        isInternetConn.value = true;
        isLoadingPage.value = true;

        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      ddVehiclesData.value = [];

      if (returnData["items"].length > 0) {
        dynamic items = returnData["items"];

        ddVehiclesData.value = items.map((item) {
          return {
            "text": item["vehicle_type_desc"],
            "value": item["vehicle_type_id"],
            "base_hours": item["base_hours"],
            "base_rate": item["base_rate"],
            "succeeding_rate": item["succeeding_rate"],
            "vehicle_type": item["vehicle_type_desc"],
          };
        }).toList();

        getMyVehicle();
        return;
      } else {
        getMyVehicle();
        return;
      }
    });
  }

  //GET my registered vehicle
  Future<void> getMyVehicle() async {
    int? userId = await Authentication().getUserId();
    String api =
        "${ApiKeys.getRegisteredVehicle}?user_id=$userId&vehicle_types_id_list=${parameters["areaData"]["vehicle_types_id_list"]}";

    HttpRequest(api: api).get().then((myVehicles) async {
      if (myVehicles == "No Internet") {
        isInternetConn.value = false;
        isLoadingPage.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (myVehicles == null) {
        isInternetConn.value = true;
        isLoadingPage.value = true;
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      myVehiclesData.value = [];
      isInternetConn.value = true;
      isLoadingPage.value = true;

      if (myVehicles["items"].length > 0) {
        for (var row in myVehicles["items"]) {
          List dataVBrand = await Functions.getBranding(
              row["vehicle_type_id"], row["vehicle_brand_id"]);
          List fData = ddVehiclesData.where((obj) {
            return obj["value"] == row["vehicle_type_id"];
          }).toList();

          if (fData.isNotEmpty) {
            myVehiclesData.add({
              "vehicle_type_id": row["vehicle_type_id"],
              "vehicle_brand_id": row["vehicle_brand_id"],
              "vehicle_brand_name": dataVBrand[0]["vehicle_brand_name"],
              "vehicle_plate_no": row["vehicle_plate_no"],
              "image": dataVBrand[0]["imageb64"],
              "vehicle_type": fData[0]["vehicle_type"],
            });
          }
        }
      } else {
        myVehiclesData.value = [];
      }
      isInternetConn.value = true;
      isLoadingPage.value = false;
      initializeBookingDate();
    });
  }

  // sample for motor

  void onToggleRewards(bool isUse) async {
    isUseRewards.value = isUse;

    if (!isUse) {
      usedRewards.value = "0";
      return;
    }
    CustomDialog().loadingDialog(Get.context!);

    double rewards = double.parse(displayRewards.value.toString());
    double paidAmt = double.parse(postBookParam["amount"].toString());
    double totalRewardsDeducted = 0.0;

    if (paidAmt < rewards) {
      totalRewardsDeducted = rewards - paidAmt;
      usedRewards.value = (rewards - totalRewardsDeducted).toString();
    } else if (paidAmt == rewards || paidAmt > rewards) {
      usedRewards.value = rewards.toString();
    }
    postBookParam["points_used"] = double.parse(usedRewards.value.toString());

    await Future.delayed(Duration(milliseconds: 500));
    Get.back();
  }

  /// New code for payment based on consumed hours ///

  void initializedBookParam(data) async {
    data["dt_in"] = stBookTime.value.split(".")[0];
    data["dt_out"] = endBookTime.value.split(".")[0];
    data["park_area_id"] = parameters["areaData"]["park_area_id"];
    postBookParam = data;

    vhTypeDisp.value = ddVehiclesData.where((element) {
      return element["value"] == data["vehicle_type_id"];
    }).toList()[0]["text"];
  }

  Future execActiveTmr() async {
    _activeTmr = Timer.periodic(Duration(seconds: 10), (timer) {
      initializeBookingDate();
    });
  }

  Future<void> initializeBookingDate() async {
    DateTime now = await Functions.getTimeNow();
    is24Hrs.value = parameters["areaData"]["is_24_hrs"].toString() == "Y";
    stBookTime.value = now.toString();
    if (is24Hrs.value) {
      DateTime nextDay = now.add(Duration(days: 1));
      endBookTime.value = nextDay.toString();
    } else {
      endBookTime.value =
          "${now.toString().split(" ")[0].toString()} ${parameters["areaData"]["closed_time"].toString().trim()}";
    }
    int diff = DateTime.parse(endBookTime.value)
        .difference(DateTime.parse(stBookTime.value))
        .inHours;
    int diffinmin = DateTime.parse(endBookTime.value)
        .difference(DateTime.parse(stBookTime.value))
        .inMinutes;
    int minutes = diffinmin % 60;
    noOfHours.value = is24Hrs.value
        ? 24
        : minutes > 5
            ? diff + 1
            : diff;
    if (_activeTmr?.isActive ?? false) return;
    execActiveTmr();
  }

  void confirmBooking() {
    double myBal = isUseRewards.value
        ? double.parse(parameters["userData"][0]["amount_bal"].toString()) +
            double.parse(displayRewards.toString())
        : double.parse(parameters["userData"][0]["amount_bal"].toString());

    if (myBal >= double.parse(postBookParam["amount"].toString())) {
      CustomDialog().confirmationDialog(Get.context!, "Booking",
          "Are you sure you want to proceed?", "No", "Yes", () {
        Get.back();
      }, () {
        Get.back();
        submitBooking();
      });
    } else {
      CustomDialog().infoDialog(
          "Insuficient Funds", "Insuficient funds please top-up", () {
        Get.back();
      });
    }
  }

  Future<void> submitBooking() async {
    CustomDialog().loadingDialog(Get.context!);
    DateTime now = await Functions.getTimeNow();

    final position = await Functions.getCurrentPosition();
    LatLng current = LatLng(position[0]["lat"], position[0]["long"]);
    LatLng destinaion = LatLng(parameters["areaData"]["pa_latitude"],
        parameters["areaData"]["pa_longitude"]);
    final etaData = await Functions.fetchETA(current, destinaion);

    if (etaData.isEmpty) {
      CustomDialog().errorDialog(Get.context!, "Error",
          "We couldn't calculate the distance. Please check your connection and try again.",
          () {
        Get.back();
      });
      return;
    }

    if (etaData[0]["error"] == "No Internet") {
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }

    int etaTime =
        int.parse(etaData[0]["time"].toString().split(" ")[0].toString());
    int areaEtaTime = etaTime +
        int.parse(
            parameters["areaData"]["book_grace_period_in_mins"].toString());
    postBookParam["eta_in_mins"] = areaEtaTime;
    Get.back();
    DateTime eet = now.add(Duration(minutes: areaEtaTime));
    DateTime ddEet = eet.subtract(Duration(minutes: 4));
    var ddd = Variables.timeFormatter("${eet.hour}:${eet.minute}");
    String schedEtaTime = ddEet.toString().split(".")[0];
    DateTime ina = DateTime.parse(schedEtaTime);
    // String abc = DateFormat("HH:mm a").format(DateTime.parse(schedEtaTime));
    String scehdTime = Variables.timeFormatter("${ina.hour}:${ina.minute}");

    CustomDialog().confirmationDialog(
        Get.context!,
        "Confirm Booking",
        "Please ensure that you arrive at the destination by $ddd, or your advance booking will be forfeited.",
        "Cancel",
        "Proceed", () {
      Get.back();
    }, () {
      Get.back();
      CustomDialog().loadingDialog(Get.context!);

      HttpRequest(api: ApiKeys.bookParking, parameters: postBookParam)
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
          return;
        }
        if (objData["success"] == "Y") {
          List paramArgs = [];
          paramArgs.add({
            'parkArea': parameters["areaData"]["park_area_name"], //
            'hours': postBookParam["no_hours"].toString(), //
            'amount': postBookParam["amount"].toString(), //
            'refno': objData["lp_ref_no"].toString(), //
            'address': parameters["areaData"]["address"], //
            'referno': objData["ticket_ref_no"].toString(),
          });

          Authentication().setLastBooking(jsonEncode(postBookParam));

          NotificationController.scheduleNewNotification(
            objData["ticket_id"],
            "luvpark",
            "Please check in by $scehdTime to secure your booking.",
            schedEtaTime,
            "parking",
          );
          Get.back();

          Get.to(BookingDialog(), arguments: paramArgs);

          return;
        }
        if (objData["success"] == "Q") {
          Get.back();
          CustomDialog().confirmationDialog(
              Get.context!, "Queue Booking", objData["msg"], "No", "Yes", () {
            Get.back();
          }, () {
            Map<String, dynamic> queueParam = {
              'luvpay_id': postBookParam["user_id"],
              'park_area_id': postBookParam["park_area_id"],
              'vehicle_type_id': postBookParam["vehicle_type_id"].toString(),
              'vehicle_plate_no': postBookParam["vehicle_plate_no"]
            };

            HttpRequest(api: ApiKeys.postQueueBooking, parameters: queueParam)
                .post()
                .then((queParamData) {
              if (queParamData == "No Internet") {
                CustomDialog().internetErrorDialog(Get.context!, () {
                  Get.back();
                });
                return;
              }
              if (queParamData == null) {
                CustomDialog().serverErrorDialog(Get.context!, () {
                  Get.back();
                });
                return;
              } else {
                if (queParamData["success"] == 'Y') {
                  CustomDialog().successDialog(Get.context!, "Success",
                      queParamData["msg"], "Go to dashboad", () {
                    Get.offAllNamed(Routes.map);
                  });
                } else {
                  CustomDialog().errorDialog(
                      Get.context!, 'luvpark', queParamData["msg"], () {
                    Get.back();
                  });
                }
              }
            });
          });
          return;
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

  @override
  void onClose() {
    super.onClose();

    _activeTmr?.cancel();
  }
}
