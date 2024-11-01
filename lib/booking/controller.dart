import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/booking/utils/success_dialog.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/functions/functions.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'view.dart';

class BookingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  BookingController();
  final parameters = Get.arguments;

  TextEditingController timeInParam = TextEditingController();
  TextEditingController plateNo = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();

  TextEditingController noHours = TextEditingController();
  TextEditingController inpDisplay = TextEditingController();
  TextEditingController rewardsCon = TextEditingController();

  RxString hintTextLabel = "Plate No.".obs;
  RxString vehicleText = "Tap to add vehicle".obs;
  RxString inputTimeLabel = '1 Hour'.obs;
  RxBool isBtnLoading = false.obs;
  RxBool isHideBottom = true.obs;
  RxString startTime = "".obs;
  RxString endTime = "".obs;
  RxString paramEndTime = "".obs;
  RxBool hasInternetBal = true.obs;
  RxBool isRewardchecked = false.obs;
  RxBool isExtendchecked = false.obs;
  RxBool isLoadingPage = true.obs;
  RxBool isInternetConn = true.obs;
  MaskTextInputFormatter? maskFormatter;
  final Map<String, RegExp> _filter = {
    'A': RegExp(r'[A-Za-z0-9]'),
    '#': RegExp(r'[A-Za-z0-9]')
  };
  int numberOfhours = 1;
  RxList numbersList = [].obs;
  RxList selectedVh = [].obs;
  RxList vehicleTypeData = [].obs;
  RxInt selectedNumber = RxInt(1);
  RxString totalAmount = "0.0".obs;
  RxString vehicleTypeValue = "".obs;

  //VH OPTION PARAm
  final GlobalKey<FormState> bookKey = GlobalKey<FormState>();
  RxBool isFirstScreen = true.obs;
  RxBool isLoadingVehicles = true.obs;
  RxBool isNetConnVehicles = true.obs;
  RxBool isShowNotice = false.obs;
  RxList myVehiclesData = [].obs;
  RxList ddVehiclesData = [].obs;
  String? dropdownValue;

  RxList noticeData = [].obs;
  //Booking param
  RxBool isSubmitBooking = false.obs;

  Timer? inactivityTimer;
  Timer? debounce;
  final int timeoutDuration = 180; //3 mins

  //Rewards param
  RxString usedRewards = "0".obs;
  RxString tokenRewards = "0".obs;
  RxDouble displayRewards = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    selectedNumber.value = 1;
    _startInactivityTimer();
    _updateMaskFormatter("");
    int endNumber =
        int.parse(parameters["areaData"]["res_max_hours"].toString());
    numbersList.value = List.generate(
        endNumber - numberOfhours + 1, (index) => numberOfhours + index);

    displayRewards.value =
        double.parse(parameters["userData"][0]["points_bal"].toString());
    timeInParam = TextEditingController();
    plateNo = TextEditingController();
    startDate = TextEditingController();
    endDate = TextEditingController();
    noHours = TextEditingController();
    inpDisplay = TextEditingController();
    noHours.text = selectedNumber.value.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAvailabeAreaVh();
    });
  }

  void _startInactivityTimer() {
    inactivityTimer?.cancel();
    inactivityTimer =
        Timer(Duration(seconds: timeoutDuration), _handleInactivity);
  }

  void _handleInactivity() {
    inactivityTimer?.cancel();
    if (isShowNotice.value) {
      Get.back();
    }
    CustomDialog().errorDialog(Get.context!, "Screen Idle",
        "No Gestures were detected in the last minute. Reloading the page.",
        () {
      Get.back();
      _reloadPage();
    });
  }

  void _reloadPage() async {
    DateTime now = await Functions.getTimeNow();

    startDate.text = now.toString().split(" ")[0].toString();
    startTime.value = DateFormat('h:mm a').format(now).toString();
    DateTime parsedTime = DateFormat('hh:mm a').parse(startTime.value);
    timeInParam.text = DateFormat('HH:mm').format(parsedTime);

    endTime.value = DateFormat('h:mm a')
        .format(parsedTime.add(Duration(hours: selectedNumber.value)))
        .toString();
    paramEndTime.value = DateFormat('HH:mm')
        .format(parsedTime.add(Duration(hours: selectedNumber.value)))
        .toString();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   getAvailabeAreaVh();
    // });
  }

  void onUserInteraction() {
    _startInactivityTimer();
  }

  void _updateMaskFormatter(mask) {
    if (mask != null) {
      hintTextLabel.value = mask.toString();
    } else {
      hintTextLabel.value = "Plate No.";
    }
    maskFormatter = MaskTextInputFormatter(
      mask: mask,
      filter: _filter,
    );
  }

  String convertStandardToMilitary(String standardTime) {
    // Parse the standard time into a DateTime object
    DateTime dateTime = DateFormat.jm().parse(standardTime);

    // Format the DateTime object to a 24-hour format
    String militaryTime = DateFormat("HH:mm").format(dateTime);

    return militaryTime;
  }

  void timeComputation() async {
    DateTime now = await Functions.getTimeNow();

    startDate.text = now.toString().split(" ")[0].toString();
    startTime.value = DateFormat('h:mm a').format(now).toString();
    DateTime parsedTime = DateFormat('hh:mm a').parse(startTime.value);
    timeInParam.text = DateFormat('HH:mm').format(parsedTime);

    endTime.value = DateFormat('h:mm a')
        .format(parsedTime.add(Duration(hours: selectedNumber.value)))
        .toString();
    paramEndTime.value = DateFormat('HH:mm')
        .format(parsedTime.add(Duration(hours: selectedNumber.value)))
        .toString();

    DateTime sTime = DateFormat('yyyy-MM-dd HH:mm')
        .parse("${startDate.text} ${timeInParam.text}");

    DateTime pTime = sTime.add(Duration(hours: selectedNumber.value));

    DateTime cTime = DateFormat('yyyy-MM-dd HH:mm').parse(
        "${now.toString().split(" ")[0]} ${parameters["areaData"]["closed_time"].toString().trim()}");

    print("cTime $selectedVh");

    if (parameters["areaData"]["is_24_hrs"] == "N") {
      if (pTime.isAfter(cTime)) {
        int deductTime = pTime.difference(cTime).inHours > 0
            ? pTime.difference(cTime).inHours
            : 1;

        CustomDialog().confirmationDialog(
            Get.context!,
            "Booking Time Exceeded",
            "Booking time must not exceed operating hours. You'll be charged the ${selectedVh[0]["base_hours"]}-hour${selectedVh[0]["base_hours"] > 1 ? "s" : ""} rate,"
                "even for shorter stays, as the parking closes at ${DateFormat('h:mm').format(cTime).toString()} PM. Thank you for understanding!",
            "No",
            "Okay", () {
          Get.back();
          selectedNumber -= deductTime;

          timeComputation();
          routeToComputation();
          isExtendchecked.value = false;
        }, () {
          Get.back();
          selectedNumber -= deductTime;
          if (selectedNumber.value == 0) {
            selectedNumber.value = 1;
          }
          endTime.value = DateFormat('h:mm a').format(cTime).toString();
          paramEndTime.value = DateFormat('HH:mm').format(cTime).toString();
        });
      }
      update();
    }
  }

  void onTapChanged(bool isIncrement) {
    int inatay = selectedVh.isEmpty ? 1 : selectedVh[0]["base_hours"];
    if (isIncrement) {
      if (selectedNumber.value == numbersList.length) return;
      selectedNumber.value++;
      timeComputation();
    } else {
      if (selectedNumber.value == inatay) return;
      selectedNumber--;
      timeComputation();
    }
    if (selectedVh.isEmpty) return;
    if (debounce?.isActive ?? false) debounce?.cancel();

    Duration duration = const Duration(seconds: 1);
    debounce = Timer(duration, () {
      CustomDialog().loadingDialog(Get.context!);
      Future.delayed(Duration(milliseconds: 500), () {
        routeToComputation();
        Get.back();
      });
      update();
    });

    update();
  }

  void displaySelVh() {
    Get.bottomSheet(
      isScrollControlled: true,
      VehicleOption(
        callback: (data) {
          List objData = data;

          List filterData = ddVehiclesData.where((obj) {
            return obj["value"] == data[0]["vehicle_type_id"];
          }).toList();
          if (filterData.isEmpty) {
            selectedVh.value = objData;
          } else {
            objData = objData.map((e) {
              e["vehicle_type"] = filterData[0]["text"];
              return e;
            }).toList();
            selectedVh.value = objData;
          }

          selectedNumber.value = selectedVh[0]["base_hours"];
          timeComputation();
          routeToComputation();
        },
      ),
    );
  }

//Compute booking payment
  Future<void> routeToComputation() async {
    isBtnLoading.value = true;
    int selNoHours = int.parse(selectedNumber.value.toString());
    int selBaseHours = int.parse(selectedVh[0]["base_hours"].toString());
    int selSucceedRate = int.parse(selectedVh[0]["succeeding_rate"].toString());
    int amount = int.parse(selectedVh[0]["base_rate"].toString());
    int finalData = 0;

    if (selNoHours > selBaseHours) {
      finalData = amount + (selNoHours - selBaseHours) * selSucceedRate;
    } else {
      finalData = amount;
    }

    isBtnLoading.value = false;
    totalAmount.value = "$finalData";
    tokenRewards.value = totalAmount.value;
  }

  void toggleRewardChecked(bool value) {
    isRewardchecked.value = value;

    usedRewards.value = "0.0";
    tokenRewards.value = "0.0";
  }

  void toggleExtendChecked(bool value) async {
    DateTime now = await Functions.getTimeNow();
    var dateIn = DateTime.parse("${startDate.text} ${timeInParam.text}");

    DateTime dateOut = dateIn.add(
      Duration(
        hours: selectedNumber.value,
      ),
    );

    DateTime cTime = DateFormat('yyyy-MM-dd HH:mm').parse(
        "${now.toString().split(" ")[0]} ${parameters["areaData"]["closed_time"].toString().trim()}");
    String dtOut =
        "${DateFormat('yyyy-MM-dd').format(DateTime.parse(dateOut.toString()))} ${paramEndTime.value}";
    DateTime finalDateOut = DateTime.parse(dtOut);
    isExtendchecked.value = value;
    if (finalDateOut.isAfter(cTime) || finalDateOut.isAtSameMomentAs(cTime)) {
      CustomDialog().infoDialog("Auto Extend",
          "Unfortunately, auto-extend is not available at this time. Please be aware that the parking area is about to close soon.",
          () {
        Get.back();
        isExtendchecked.value = false;
      });
      return;
    }
  }

  //Get Vehicle Formatter or if there is vehicle in this area
  Future<void> getAvailabeAreaVh() async {
    isLoadingPage.value = true;
    final dataVehicle = [];
    HttpRequest(
            api:
                "${ApiKeys.gApiSubFolderGetVehicleType}?park_area_id=${parameters["areaData"]["park_area_id"]}")
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
        isLoadingPage.value = false;
        isInternetConn.value = true;
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      isInternetConn.value = true;
      if (returnData["items"].length > 0) {
        isLoadingPage.value = false;

        for (var items in returnData["items"]) {
          dataVehicle.add({
            "vehicle_id": items["vehicle_type_id"],
            "vehicle_desc": items["vehicle_type_desc"],
            "format": items["input_format"],
          });
        }
        vehicleTypeData.value = dataVehicle;
        _updateMaskFormatter(vehicleTypeData[0]["format"]);
      }
      getNotice();
    });
  }

  //Vehicle
  void onScreenChanged(bool value) {
    isFirstScreen.value = value;
  }

  //GET my registered vehicle
  Future<void> getMyVehicle() async {
    final item = await Authentication().getUserData();
    CustomDialog().loadingDialog(Get.context!);
    if (selectedVh.isEmpty) {
      isBtnLoading.value = true;
    }
    isFirstScreen.value = true;
    plateNo.text = "";
    int userId = jsonDecode(item!)["user_id"];
    String api =
        "${ApiKeys.gApiLuvParkPostGetVehicleReg}?user_id=$userId&vehicle_types_id_list=${parameters["areaData"]["vehicle_types_id_list"]}";

    HttpRequest(api: api).get().then((myVehicles) async {
      if (myVehicles == "No Internet") {
        isNetConnVehicles.value = false;
        isLoadingVehicles.value = false;
        Get.back();
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });

        return;
      }
      if (myVehicles == null) {
        isNetConnVehicles.value = true;
        isLoadingVehicles.value = true;
        Get.back();
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      myVehiclesData.value = [];
      if (myVehicles["items"].length > 0) {
        for (var row in myVehicles["items"]) {
          String brandName = await Functions.getBrandName(
              row["vehicle_type_id"], row["vehicle_brand_id"]);

          myVehiclesData.add({
            "vehicle_type_id": row["vehicle_type_id"],
            "vehicle_brand_id": row["vehicle_brand_id"],
            "vehicle_brand_name": brandName,
            "vehicle_plate_no": row["vehicle_plate_no"],
          });
        }
        getDropdownVehicles();
      } else {
        getDropdownVehicles();
      }
    });
  }

  //GET drodown vehicles per area
  Future<void> getDropdownVehicles() async {
    HttpRequest(
            api:
                "${ApiKeys.gApiLuvParkDDVehicleTypes2}?park_area_id=${parameters["areaData"]["park_area_id"]}")
        .get()
        .then((returnData) async {
      isBtnLoading.value = false;
      if (returnData == "No Internet") {
        isNetConnVehicles.value = false;
        isLoadingVehicles.value = true;
        Get.back();
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });

        return;
      }
      if (returnData == null) {
        isNetConnVehicles.value = true;
        isLoadingVehicles.value = true;
        Get.back();
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      isNetConnVehicles.value = true;
      isLoadingVehicles.value = false;
      ddVehiclesData.value = [];
      Get.back();
      if (returnData["items"].length > 0) {
        dynamic items = returnData["items"];
        ddVehiclesData.value = items.map((item) {
          return {
            "text": item["vehicle_type_desc"],
            "value": item["vehicle_type_id"],
            "base_hours": item["base_hours"],
            "base_rate": item["base_rate"],
            "succeeding_rate": item["succeeding_rate"],
          };
        }).toList();
      }
      displaySelVh();
    });
  }

  //Reservation Submit
  void submitReservation(params) async {
    List bookingParams = [params];

    int userId = await Authentication().getUserId();
    isSubmitBooking.value = true;
    final position = await Functions.getCurrentPosition();
    LatLng current = LatLng(position[0]["lat"], position[0]["long"]);
    LatLng destinaion = LatLng(parameters["areaData"]["pa_latitude"],
        parameters["areaData"]["pa_longitude"]);
    final etaData = await Functions.fetchETA(current, destinaion);

    if (etaData.isEmpty) {
      isSubmitBooking.value = false;
      CustomDialog().errorDialog(Get.context!, "Error",
          "We couldn't calculate the distance. Please check your connection and try again.",
          () {
        Get.back();
      });
      return;
    }

    if (etaData[0]["error"] == "No Internet") {
      isSubmitBooking.value = false;
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

    Map<String, dynamic> dynamicBookParam = {
      "user_id": userId,
      "amount": totalAmount.value,
      "no_hours": selectedNumber.value.toString(),
      "dt_in": params["dt_in"].toString(),
      "dt_out": params["dt_out"].toString(),
      "eta_in_mins": areaEtaTime,
      "vehicle_type_id": params["vehicle_type_id"].toString(),
      "vehicle_plate_no": params["vehicle_plate_no"],
      "park_area_id": params["park_area_id"].toString(),
      "points_used": double.parse(usedRewards.toString()),
      "auto_extend": isExtendchecked.value ? "Y" : "N"
    };

    CustomDialog().confirmationDialog(
        Get.context!,
        "Confirm Booking",
        "Please ensure that you arrive at the destination by $areaEtaTime mins, or your advance booking will be forfeited.",
        "Cancel",
        "Proceed", () {
      isSubmitBooking.value = false;
      isBtnLoading.value = false;
      Get.back();
    }, () {
      Get.back();

      HttpRequest(api: ApiKeys.gApiBooking, parameters: dynamicBookParam)
          .postBody()
          .then((objData) async {
        if (objData == "No Internet") {
          isSubmitBooking.value = false;
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (objData == null) {
          isSubmitBooking.value = false;
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        }
        if (objData["success"] == "Y") {
          dynamic paramArgs = {
            'parkArea': parameters["areaData"]["park_area_name"],
            'startDate': Variables.formatDate(
                bookingParams[0]["dt_in"].toString().split(" ")[0]),
            'endDate': Variables.formatDate(
                bookingParams[0]["dt_out"].toString().split(" ")[0]),
            'startTime':
                bookingParams[0]["dt_in"].toString().split(" ")[1].toString(),
            'endTime':
                bookingParams[0]["dt_out"].toString().split(" ")[1].toString(),
            'plateNo': bookingParams[0]["vehicle_plate_no"].toString(),
            'hours': bookingParams[0]["no_hours"].toString(),
            'amount': totalAmount.value.toString(),
            'refno': objData["lp_ref_no"].toString(),
            'lat':
                double.parse(parameters["areaData"]['pa_latitude'].toString()),
            'long':
                double.parse(parameters["areaData"]['pa_longitude'].toString()),
            'canReserved': false,
            'isReserved': false,
            'isShowRate': true,
            'reservationId': objData["reservation_id"],
            'address': parameters["areaData"]["address"],
            'area_data': parameters["areaData"],
            'isAutoExtend': false,
            'isBooking': true,
            'status': "B",
            'paramsCalc': bookingParams[0]
          };
          Map<String, dynamic> lastBookingData = {
            "plate_no": selectedVh[0]["vehicle_plate_no"].toString(),
            "brand_name": selectedVh[0]["vehicle_brand_name"].toString(),
            "park_area_id": parameters["areaData"]["park_area_id"].toString(),
          };

          Authentication().setLastBooking(jsonEncode(lastBookingData));
          if (parameters["canCheckIn"]) {
            checkIn(objData["reservation_id"], userId, paramArgs);
            return;
          } else {
            isSubmitBooking.value = false;
            inactivityTimer?.cancel();
            Get.back();
            Get.back();
            Get.to(BookingDialog(data: [paramArgs]));
            return;
          }
        }
        if (objData["success"] == "Q") {
          CustomDialog().confirmationDialog(
              Get.context!, "Queue Booking", objData["msg"], "No", "Yes", () {
            Get.back();
          }, () {
            Map<String, dynamic> queueParam = {
              'luvpay_id': userId,
              'park_area_id': params["park_area_id"],
              'vehicle_type_id': params["vehicle_type_id"].toString(),
              'vehicle_plate_no': params["vehicle_plate_no"]
            };

            HttpRequest(
                    api: ApiKeys.gApiLuvParkResQueue, parameters: queueParam)
                .post()
                .then((queParamData) {
              if (queParamData == "No Internet") {
                isSubmitBooking.value = false;
                CustomDialog().internetErrorDialog(Get.context!, () {
                  Get.back();
                });
                return;
              }
              if (queParamData == null) {
                isSubmitBooking.value = false;
                CustomDialog().serverErrorDialog(Get.context!, () {
                  Get.back();
                });
                return;
              } else {
                isSubmitBooking.value = false;
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
          isSubmitBooking.value = false;
          CustomDialog().errorDialog(Get.context!, "luvpark", objData["msg"],
              () {
            Get.back();
          });
          return;
        }
      });
    });
  }

  //Self checkin
  Future<void> checkIn(ticketId, lpId, args) async {
    dynamic chkInParam = {
      "ticket_id": ticketId,
      "luvpay_id": lpId,
    };

    HttpRequest(api: ApiKeys.gApiPostSelfCheckIn, parameters: chkInParam)
        .postBody()
        .then((returnData) async {
      if (returnData == "No Internet") {
        isSubmitBooking.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (returnData == null) {
        isSubmitBooking.value = false;
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });

        return;
      }
      isSubmitBooking.value = false;
      if (returnData["success"] == 'Y') {
        Get.back();
        CustomDialog().successDialog(
            Get.context!, "Check-In", "Successfully checked-in", "Okay", () {
          Get.back();
        });
      } else {
        CustomDialog().errorDialog(Get.context!, "luvpark", returnData["msg"],
            () {
          Get.back();
        });
      }
    });
  }

  //Compute rewards
  void computeRewards(dynamic data) {
    final int parsedData = int.parse(data.toString());

    // Set initial token rewards
    tokenRewards.value = totalAmount.value;

    // Check if input data is valid
    final int totalAmountParsed = int.parse(totalAmount.value.toString());

    if (parsedData > totalAmountParsed) {
      CustomDialog().errorDialog(Get.context!, "luvpark",
          "Amount must be less than or equal to the total amount", () {
        Get.back();
        usedRewards.value = parsedData.toString();
        usedRewards.value = "0.0";
      });
      return;
    }

    isLoadingPage.value = true;

    usedRewards.value = parsedData.toString();

    final int currentTokenRewards = int.parse(tokenRewards.value.toString());
    if (parsedData < currentTokenRewards) {
      tokenRewards.value = (currentTokenRewards - parsedData).toString();
    } else {
      tokenRewards.value = "0.0";
    }

    isLoadingPage.value = false;
  }

  Future<void> getNotice() async {
    isInternetConn.value = true;
    isLoadingPage.value = true;
    isShowNotice.value = true;
    String subApi = "${ApiKeys.gApiLuvParkGetNotice}?msg_code=PREBOOKMSG";

    HttpRequest(api: subApi).get().then((retDataNotice) async {
      if (retDataNotice == "No Internet") {
        isLoadingPage.value = false;
        isInternetConn.value = false;
        noticeData.value = [];
        isShowNotice.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (retDataNotice == null) {
        isInternetConn.value = true;
        isLoadingPage.value = true;
        noticeData.value = [];
        isShowNotice.value = false;
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      }
      if (retDataNotice["items"].length > 0) {
        isInternetConn.value = true;
        isLoadingPage.value = false;
        noticeData.value = retDataNotice["items"];
        Timer(Duration(milliseconds: 500), () {
          CustomDialog().bookingNotice(
              noticeData[0]["msg_title"], noticeData[0]["msg"], () {
            Get.back();
            Get.back();
          }, () {
            isShowNotice.value = false;
            Get.back();
          });
        });
      } else {
        isInternetConn.value = true;
        isLoadingPage.value = false;
        noticeData.value = [];
        isShowNotice.value = false;
        CustomDialog().errorDialog(Get.context!, "luvpark", "No data found",
            () {
          Get.back();
        });
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    bookKey.currentState?.reset();
    inactivityTimer?.cancel();
    debounce?.cancel();
  }
}
