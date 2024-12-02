import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'utils/success_dialog.dart';
import 'view.dart';

class BookingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  BookingController();
  final parameters = Get.arguments;

  TextEditingController timeInParam = TextEditingController();
  TextEditingController plateNo = TextEditingController();
  TextEditingController noHours = TextEditingController(text: "1");
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();

  TextEditingController inpDisplay = TextEditingController();
  TextEditingController rewardsCon = TextEditingController();

  RxString hintTextLabel = "Plate No.".obs;
  RxString vehicleText = "Tap to add vehicle".obs;
  RxString inputTimeLabel = '1 Hour'.obs;
  RxBool isBtnLoading = false.obs;
  RxBool isHideBottom = true.obs;
  RxBool isSubscribed = false.obs;
  RxString startTime = "".obs;
  RxString endTime = "".obs;
  RxString paramEndTime = "".obs;
  RxBool hasInternetBal = true.obs;
  RxBool isRewardchecked = false.obs;
  RxBool isExtendchecked = false.obs;
  RxBool isLoadingPage = true.obs;
  RxBool isInternetConn = true.obs;
  RxBool isDisabledBtn = true.obs;
  MaskTextInputFormatter? maskFormatter;
  final Map<String, RegExp> _filter = {
    'A': RegExp(r'[A-Za-z0-9]'),
    '#': RegExp(r'[A-Za-z0-9]')
  };
  int numberOfhours = 1;
  RxList selectedVh = [].obs;
  RxList vehicleTypeData = [].obs;
  RxBool isExpandedPansion = false.obs;
  RxList pointsData = [
    {"name": "Token", "value": 100},
    {"name": "Points", "value": 100},
    {"name": "Total", "value": 100}
  ].obs;
  RxInt selectedNumber = RxInt(1);
  RxString totalAmount = "0.0".obs;
  RxString vehicleTypeValue = "".obs;

  //VH OPTION PARAm
  final GlobalKey<FormState> bookKey = GlobalKey<FormState>();
  RxBool isFirstScreen = true.obs;
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
  RxInt endNumber = 0.obs;

  //Rewards param
  RxString usedRewards = "0".obs;
  RxString tokenRewards = "0".obs;
  RxDouble displayRewards = 0.0.obs;
  RxBool isUseRewards = false.obs;
  List dataLastBooking = [];

  @override
  void onInit() {
    super.onInit();
    selectedNumber.value = 1;
    noHours.text = 1.toString();
    endNumber.value =
        int.parse(parameters["areaData"]["res_max_hours"].toString());

    displayRewards.value =
        double.parse(parameters["userData"][0]["points_bal"].toString());
    timeInParam = TextEditingController();
    plateNo = TextEditingController();
    startDate = TextEditingController();
    endDate = TextEditingController();
    noHours = TextEditingController();
    inpDisplay = TextEditingController();
    noHours.text = selectedNumber.value.toString();

    getNotice();
    _startInactivityTimer();
    _updateMaskFormatter("");
  }

  Future<void> getNotice() async {
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
        isLoadingPage.value = true;
        noticeData.value = retDataNotice["items"];
        Timer(Duration(milliseconds: 500), () {
          CustomDialog().bookingNotice(
              noticeData[0]["msg_title"], noticeData[0]["msg"], () {
            Get.back();
            Get.back();
          }, () {
            isShowNotice.value = false;
            Get.back();
            getDropdownVehicles();
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

  //GET drodown vehicles per area
  Future<void> getDropdownVehicles() async {
    HttpRequest(
            api:
                "${ApiKeys.gApiLuvParkDDVehicleTypes2}?park_area_id=${parameters["areaData"]["park_area_id"]}")
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
      } else {
        getMyVehicle();
      }
    });
  }

  //GET my registered vehicle
  Future<void> getMyVehicle() async {
    final item = await Authentication().getUserData();

    int userId = jsonDecode(item!)["user_id"];

    String api =
        "${ApiKeys.gApiLuvParkPostGetVehicleReg}?user_id=$userId&vehicle_types_id_list=${parameters["areaData"]["vehicle_types_id_list"]}";

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
      List filterLastBooking(String vhId) {
        List retData = ddVehiclesData.where((obj) {
          return int.parse(obj["value"].toString()) ==
              int.parse(vhId.toString());
        }).toList();
        return retData;
      }

      if (myVehicles["items"].length > 0) {
        for (var row in myVehicles["items"]) {
          List dataVBrand = await Functions.getBranding(
              row["vehicle_type_id"], row["vehicle_brand_id"]);
          List fData = ddVehiclesData.where((obj) {
            return obj["value"] == row["vehicle_type_id"];
          }).toList();

          myVehiclesData.add({
            "vehicle_type_id": row["vehicle_type_id"],
            "vehicle_brand_id": row["vehicle_brand_id"],
            "vehicle_brand_name": dataVBrand[0]["vehicle_brand_name"],
            "vehicle_plate_no": row["vehicle_plate_no"],
            "image": dataVBrand[0]["imageb64"],
            "vehicle_type": fData[0]["vehicle_type"],
          });
        }

        dataLastBooking = await Authentication().getLastBooking();

        if (dataLastBooking.isNotEmpty) {
          List dataHabibi = await filterSubscriotion(
              dataLastBooking[0]["vehicle_plate_no"],
              dataLastBooking[0]["vehicle_type_id"]);

          if (dataHabibi.isNotEmpty) {
            checkIfSubscribed(dataHabibi);
          } else {
            CustomDialog().loadingDialog(Get.context!);

            List flb = filterLastBooking(
                dataLastBooking[0]["vehicle_type_id"].toString());

            if (flb.isEmpty) {
              Get.back();
              selectedVh.clear();
            } else {
              selectedVh.value = dataLastBooking.map((e) {
                e["base_hours"] = flb[0]["base_hours"];
                e["succeeding_rate"] = flb[0]["succeeding_rate"];
                e["base_rate"] = flb[0]["base_rate"];
                return e;
              }).toList();
              krowkrow();
            }
          }
        } else {
          List vhDatas = [myVehiclesData[0]];
          List dataHabibi = await filterSubscriotion(
              vhDatas[0]["vehicle_plate_no"], vhDatas[0]["vehicle_type_id"]);

          if (dataHabibi.isNotEmpty) {
            checkIfSubscribed(dataHabibi);
          } else {
            CustomDialog().loadingDialog(Get.context!);
            dynamic recData = ddVehiclesData;
            Map<int, Map<String, dynamic>> recDataMap = {
              for (var item in recData) item['value']: item
            };
            for (var vh in vhDatas) {
              int typeId = vh['vehicle_type_id'];
              if (recDataMap.containsKey(typeId)) {
                var rec = recDataMap[typeId];
                vh['base_hours'] = rec?['base_hours'];
                vh['base_rate'] = rec?['base_rate'];
                vh['succeeding_rate'] = rec?['succeeding_rate'];
                vh['vehicle_type'] = rec?['vehicle_type'];
              }
            }

            selectedVh.value = vhDatas;

            krowkrow();
          }
        }
      } else {
        dataLastBooking = await Authentication().getLastBooking();
        if (dataLastBooking.isNotEmpty) {
          CustomDialog().loadingDialog(Get.context!);
          List flb = filterLastBooking(
              dataLastBooking[0]["vehicle_type_id"].toString());
          selectedVh.value = dataLastBooking.map((e) {
            e["base_hours"] = flb[0]["base_hours"];
            e["succeeding_rate"] = flb[0]["succeeding_rate"];
            e["base_rate"] = flb[0]["base_rate"];
            return e;
          }).toList();

          krowkrow();
        }
      }
      isInternetConn.value = true;
      isLoadingPage.value = false;

      if (selectedVh.isEmpty) {
        vehicleSelection(1);
      }
    });
  }

  ///end

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
    if (Get.isBottomSheetOpen!) {
      Get.back();
    }
    CustomDialog().infoDialog("Screen Idle",
        "No Gestures were detected in the last minute. Reloading the page.",
        () {
      Get.back();
      _reloadPage();
    });
  }

  void _reloadPage() async {
    DateTime now = await Functions.getTimeNow();

    inatay() {
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
    }

    if (dataLastBooking.isNotEmpty) {
      List dataHabibi = await filterSubscriotion(
          dataLastBooking[0]["vehicle_plate_no"],
          dataLastBooking[0]["vehicle_type_id"]);

      if (dataHabibi.isNotEmpty) {
        checkIfSubscribed(dataHabibi);
      } else {
        inatay();
      }
    } else {
      inatay();
    }
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

    if (parameters["areaData"]["is_24_hrs"] == "N") {
      if (pTime.isAfter(cTime)) {
        int deductTime = pTime.difference(cTime).inHours > 0
            ? pTime.difference(cTime).inHours
            : 1;

        CustomDialog().confirmationDialog(
            Get.context!,
            "Booking Time Exceeded",
            "Booking time must not exceed operating hours. You'll be charged the ${selectedVh[0]["base_hours"]}-hour${selectedVh[0]["base_hours"] > 1 ? "s" : ""} rate,"
                "even for shorter stays, as the parking closes at ${DateFormat('h:mm').format(cTime).toString()} PM.\nContinue parking?",
            "No",
            "Okay", () {
          Get.back();
          selectedNumber -= deductTime;
          noHours.text = selectedNumber.value.toString();

          timeComputation();
          routeToComputation();
          isExtendchecked.value = false;
          if (selectedNumber.value == 0) {
            Get.back();
          }
        }, () {
          Get.back();
          selectedNumber -= deductTime;
          noHours.text = selectedNumber.value.toString();
          if (selectedNumber.value == 0) {
            selectedNumber.value = 1;
            noHours.text = selectedNumber.value.toString();
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
      if (selectedNumber.value == endNumber.value) return;
      selectedNumber.value++;
      noHours.text = selectedNumber.value.toString();
      timeComputation();
    } else {
      if (selectedNumber.value == inatay) return;
      selectedNumber--;
      noHours.text = selectedNumber.value.toString();
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

  void krowkrow() {
    isSubscribed.value = false;

    Future.delayed(Duration(seconds: 2), () async {
      selectedNumber.value = selectedVh[0]["base_hours"];
      plateNo.text = selectedVh[0]["vehicle_plate_no"];
      dropdownValue = selectedVh[0]["vehicle_type_id"].toString();
      noHours.text = selectedNumber.value.toString();

      timeComputation();
      routeToComputation();
      onFieldChanged();
      Get.back();
    });
  }

  //dynamic on change vehicle changed selected vh data
  void onChangedVtype(ddvalue) {
    CustomDialog().loadingDialog(Get.context!);
    dynamic selVh = ddVehiclesData.where((element) {
      return element["value"] == int.parse(ddvalue!.toString());
    }).toList()[0];

    selectedVh.value = [
      {
        'vehicle_type_id': dropdownValue!.toString(),
        'vehicle_brand_id': 0,
        'vehicle_brand_name': selVh["text"],
        'vehicle_plate_no': plateNo.text,
        'base_hours': selVh["base_hours"],
        'base_rate': selVh["base_rate"],
        'succeeding_rate': selVh["succeeding_rate"],
        'vehicle_type': selVh["text"]
      }
    ];

    krowkrow();
  }
  //display

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
    if (int.parse(noHours.text.toString()) >= endNumber.value) {
      CustomDialog().infoDialog("Booking Hours",
          "You have maximum ${endNumber.value} hours of booking.", () {
        Get.back();
        noHours.text = "${endNumber.value}";
        selectedNumber.value = endNumber.value;
        isExtendchecked.value = false;
      });
    }
  }

  //Vehicle
  void onScreenChanged(bool value) {
    isFirstScreen.value = value;
  }

  //Reservation Submit
  void submitReservation(params, bool allowChkin) async {
    CustomDialog().loadingDialog(Get.context!);
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
    Get.back();

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
      CustomDialog().loadingDialog(Get.context!);
      HttpRequest(api: ApiKeys.gApiBooking, parameters: dynamicBookParam)
          .postBody()
          .then((objData) async {
        if (objData == "No Internet") {
          isSubmitBooking.value = false;
          Get.back();
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (objData == null) {
          Get.back();
          isSubmitBooking.value = false;
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        }

        if (objData["success"] == "Y") {
          issueTicket(objData, params, areaEtaTime, bookingParams, allowChkin);
          return;
        }
        if (objData["success"] == "Q") {
          Get.back();
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

  Future<void> issueTicket(
      pobjData, params, areaEtaTime, bookingParams, bool allowChkin) async {
    int? userId = await Authentication().getUserId();
    final userData = await Authentication().getUserData2();

    dynamic param = {
      "ticket_category": "AP",
      "amount": totalAmount.value.toString(),
      "points_used": double.parse(usedRewards.toString()),
      "no_hours": selectedNumber.value.toString(),
      "luvpay_id": userId,
      "lp_ref_no": pobjData["lp_ref_no"].toString(),
      "vehicle_type_id": params["vehicle_type_id"].toString(),
      "vehicle_plate_no": params["vehicle_plate_no"],
      "park_area_id": params["park_area_id"].toString(),
      "eta_in_mins": areaEtaTime,
      "dt_in": params["dt_in"].toString(),
      "dt_out": params["dt_out"].toString(),
      "is_auto_extend": isExtendchecked.value ? "Y" : "N",
      'base_rate': selectedVh[0]["base_rate"],
      "base_hours": selectedVh[0]["base_hours"],
      "succeeding_rate": selectedVh[0]["succeeding_rate"],
      'disc_rate': '0',
      "mobile_no": userData["mobile_no"],
      'payment_hk': pobjData["payment_hk"]
    };
    HttpRequest(api: ApiKeys.gApiIssueTicket, parameters: param)
        .postBody()
        .then((returnData) async {
      if (returnData == "No Internet") {
        isSubmitBooking.value = false;
        Get.back();
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (returnData == null) {
        Get.back();
        isSubmitBooking.value = false;
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      }
      if (returnData["success"] == "Y") {
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
          'refno': returnData["ticket_ref_no"].toString(),
          'lat': double.parse(parameters["areaData"]['pa_latitude'].toString()),
          'long':
              double.parse(parameters["areaData"]['pa_longitude'].toString()),
          'canReserved': false,
          'isReserved': false,
          'isShowRate': true,
          'reservationId': returnData["ticket_id"],
          'address': parameters["areaData"]["address"],
          'area_data': parameters["areaData"],
          'isAutoExtend': false,
          'isBooking': true,
          'status': "B",
          'paramsCalc': bookingParams[0]
        };

        Authentication().setLastBooking(jsonEncode(selectedVh));
        if (allowChkin) {
          checkIn(returnData["ticket_id"], userId, paramArgs);
          return;
        } else {
          Get.back();
          isSubmitBooking.value = false;
          inactivityTimer?.cancel();

          Get.back();
          Get.offAll(BookingDialog(data: [paramArgs]));
          return;
        }
      } else {
        Get.back();
        CustomDialog().errorDialog(Get.context!, "luvpark", returnData["msg"],
            () {
          Get.back();
        });
      }
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
        Get.back();
        isSubmitBooking.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (returnData == null) {
        Get.back();
        isSubmitBooking.value = false;
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });

        return;
      }
      isSubmitBooking.value = false;
      Get.back();
      if (returnData["success"] == 'Y') {
        CustomDialog().successDialog(
            Get.context!, "Check-In", "Successfully checked-in", "Okay", () {
          inactivityTimer?.cancel();
          Get.back();
          Get.offAllNamed(Routes.parking, arguments: "B");
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

  String validateText(String inputText, TextEditingController txtController) {
    // Check if the first character is a space or special character
    if (inputText.isNotEmpty && !RegExp(r'^[a-zA-Z0-9]').hasMatch(inputText)) {
      return 'Text must not start with a space or special character';
    }

    // Replace multiple spaces with a single space
    String formattedText = inputText.replaceAll(RegExp(r'\s+'), ' ');

    // Update error message if input is not valid
    if (formattedText != inputText) {
      txtController.text = formattedText;

      txtController.selection = TextSelection.fromPosition(
        TextPosition(offset: formattedText.length),
      );
    }

    return ''; // Return an empty string if valid
  }

  void confirmBooking() {
    Get.bottomSheet(
      ConfirmBooking(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  void onFieldChanged() {
    if (plateNo.text.isEmpty ||
        dropdownValue.toString().isEmpty ||
        noHours.text.isEmpty) {
      isDisabledBtn.value = true;
    } else {
      isDisabledBtn.value = false;
    }
  }

  Future<List> filterSubscriotion(String plNo, int id) async {
    //check if subscribed
    List data = Variables.subsVhList.where((obj) {
      return obj["vehicle_type_id"] == id && obj["vehicle_plate_no"] == plNo;
    }).toList();
    return data;
  }

  void checkIfSubscribed(data) async {
    DateTime now = await Functions.getTimeNow();
    DateTime cTime = DateFormat('yyyy-MM-dd HH:mm').parse(
        "${now.toString().split(" ")[0]} ${parameters["areaData"]["closed_time"].toString().trim()}");

    int diff = cTime.difference(now).inMinutes;
    double totalHours = diff / 60;
    int roundedHours = totalHours.round();
    isSubscribed.value = true;
    selectedVh.value = [
      {
        'vehicle_type_id': data[0]["vehicle_type_id"],
        'vehicle_brand_id': data[0]["vehicle_brand_id"],
        'vehicle_brand_name': data[0]["vehicle_brand_name"],
        'vehicle_plate_no': data[0]["vehicle_plate_no"],
        'base_hours': roundedHours,
        'succeeding_rate': "0",
        'base_rate': data[0]["subscription_rate"],
        'vehicle_type': data[0]["vehicle_type"],
      }
    ];
    selectedNumber.value = selectedVh[0]["base_hours"];
    plateNo.text = selectedVh[0]["vehicle_plate_no"];
    dropdownValue = selectedVh[0]["vehicle_type_id"].toString();
    noHours.text = roundedHours.toString();
    totalAmount.value = selectedVh[0]["base_rate"].toString();
    tokenRewards.value = totalAmount.value;

    startDate.text = now.toString().split(" ")[0].toString();
    startTime.value = DateFormat('h:mm a').format(now).toString();
    DateTime parsedTime = DateFormat('hh:mm a').parse(startTime.value);
    timeInParam.text = DateFormat('HH:mm').format(parsedTime);

    // endTime.value = DateFormat('h:mm a')
    //     .format(parsedTime.add(Duration(hours: selectedNumber.value)))
    //     .toString();
    // paramEndTime.value = DateFormat('HH:mm')
    //     .format(parsedTime.add(Duration(hours: selectedNumber.value)))
    //     .toString();

    //afdsafa
    DateTime sTime = DateFormat('yyyy-MM-dd HH:mm')
        .parse("${startDate.text} ${timeInParam.text}");

    DateTime pTime = sTime.add(Duration(hours: selectedNumber.value));

    int deductTime = pTime.difference(cTime).inHours > 0
        ? pTime.difference(cTime).inHours
        : 1;

    selectedNumber -= deductTime;
    noHours.text = selectedNumber.value.toString();

    endTime.value = DateFormat('h:mm a').format(cTime).toString();
    paramEndTime.value = DateFormat('HH:mm').format(cTime).toString();

    //afasfd

    onFieldChanged();
  }

  void onToggleRewards(bool isUse) {
    isUseRewards.value = isUse;
  }

  void vehicleSelection(int index) {
    Get.bottomSheet(
      VehicleTypes(
          pageIndex: index,
          cb: (data) async {
            FocusManager.instance.primaryFocus!.unfocus();
            CustomDialog().loadingDialog(Get.context!);
            await Future.delayed(Duration(milliseconds: 500), () async {
              List objData = data;

              List dataHabibi = await filterSubscriotion(
                  objData[0]["vehicle_plate_no"],
                  objData[0]["vehicle_type_id"]);

              if (dataHabibi.isNotEmpty) {
                Get.back();
                checkIfSubscribed(dataHabibi);
              } else {
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

                krowkrow();
              }
            });
          }),
      ignoreSafeArea: true,
      isScrollControlled: false,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  @override
  void onClose() {
    super.onClose();
    bookKey.currentState?.reset();
    inactivityTimer?.cancel();
    debounce?.cancel();
  }
}
