// ignore_for_file: unnecessary_null_comparison, unnecessary_string_interpolations, prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:screenshot/screenshot.dart';

import '../auth/authentication.dart';
import '../custom_widgets/alert_dialog.dart';
import '../functions/functions.dart';
import '../http/api_keys.dart';
import 'utils/receipt_billing.dart';

class BillersController extends GetxController {
  BillersController();

  final TextEditingController billAccNo = TextEditingController();
  final TextEditingController billerAccountName = TextEditingController();
  final TextEditingController billNo = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final ScreenshotController screenshotController = ScreenshotController();
  RxBool isNetConn = true.obs;
  RxList billers = [].obs;
  RxList favBillers = [].obs;
  RxString payKey = "".obs;
  RxBool isLoading = true.obs;
  var fav = <int, bool>{}.obs;
  RxList filteredBillers = [].obs;

//for sorting
  RxString selectedSortOption = "Biller Name".obs;
  RxBool isAscending = true.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadFavoritesAndBillers();
    });

    super.onInit();
  }

  void clearFields() {
    billAccNo.clear();
    billerAccountName.clear();
    billNo.clear();
    amount.clear();
  }

  Future<void> loadFavoritesAndBillers() async {
    isLoading.value = true;
    await getFavorites();
    await getBillers();
  }

  Future<void> getBillers() async {
    String subApi = "${ApiKeys.gApiGetBiller}";
    HttpRequest(api: subApi).get().then((response) async {
      if (response == "No Internet") {
        isLoading.value = false;
        isNetConn.value = false;
        return;
      }
      if (response == null) {
        isLoading.value = false;
        isNetConn.value = true;
        return;
      }
      if (response["items"].isNotEmpty) {
        billers.assignAll(response["items"]);
        filteredBillers.assignAll(billers);
      }
      isNetConn.value = true;
    });
  }

  void filterBillers(String query) {
    if (query.isEmpty) {
      filteredBillers.assignAll(billers);
    } else {
      filteredBillers.assignAll(billers.where((biller) {
        return biller['biller_name']
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList());
    }
  }

  Future<void> sortFavorites() async {
    if (selectedSortOption.value == selectedSortOption.value) {
      isAscending.value = !isAscending.value;
    }
    if (selectedSortOption.value == 'Account Name') {
      favBillers.sort((a, b) {
        String nameA = a['account_name'] ?? '';
        String nameB = b['account_name'] ?? '';
        return isAscending.value
            ? nameA.compareTo(nameB)
            : nameB.compareTo(nameA);
      });
    } else if (selectedSortOption.value == "Biller Name") {
      favBillers.sort((a, b) {
        String nameA = a["biller_name"] ?? '';
        String nameB = b["biller_name"] ?? '';
        return isAscending.value
            ? nameA.compareTo(nameB)
            : nameB.compareTo(nameA);
      });
    } else if (selectedSortOption.value == "Biller Address") {
      favBillers.sort((a, b) {
        String addressA = a["biller_address"] ?? '';
        String addressB = b["biller_address"] ?? '';
        return isAscending.value
            ? addressA.compareTo(addressB)
            : addressB.compareTo(addressA);
      });
    }
    update();
  }

  Future<void> addFavorites(params) async {
    int userId = await Authentication().getUserId();
    bool isButtonEnabled = true;
    CustomDialog().confirmationDialog(Get.context!, "Add to Favorites",
        "Do you want to add this biller to your favorites?", "No", "Add", () {
      Get.back();
    }, () {
      Get.back();
      if (!isButtonEnabled) return;
      isButtonEnabled = false;
      CustomDialog().loadingDialog(Get.context!);
      var parameter = {
        "user_id": userId,
        "biller_id": params["biller_id"],
        "account_no": billAccNo.text,
        "account_name": billerAccountName.text
      };
      HttpRequest(api: ApiKeys.gApiPostFavBiller, parameters: parameter)
          .postBody()
          .then((returnPost) async {
        Get.back();
        if (returnPost == "No Internet") {
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return {"response": returnPost, "data": []};
        }
        if (returnPost == null) {
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
          return {"response": returnPost, "data": []};
        }
        if (returnPost["success"] == 'Y') {
          CustomDialog().successDialog(Get.context!, "Success",
              "Successfully added to favorites.", "Okay", () {
            if (params["source"] == "fav") {
              Functions.popPage(3);
              getFavorites();
            } else {
              Get.back();
              getFavorites();
            }
          });
        } else {
          CustomDialog().errorDialog(Get.context!, "luvpark", returnPost["msg"],
              () {
            if (params["source"] == "fav") {
              Functions.popPage(2);
            } else {
              Get.back();
              getFavorites();
            }
          });
        }
      }).whenComplete(() {
        Future.delayed(const Duration(seconds: 2), () {
          isButtonEnabled = true;
        });
      });
    });
  }

  Future<void> onPay(args) async {
    FocusManager.instance.primaryFocus?.unfocus();

    CustomDialog().loadingDialog(Get.context!);
    final response = await Functions.generateQr();

    if (response["response"] == "Success") {
      double serviceFee =
          double.tryParse(args['service_fee'].toString()) ?? 0.0;
      double userAmount = double.tryParse(amount.text) ?? 0.0;
      double addedAmount = serviceFee + userAmount;
      String totalAmount = addedAmount.toStringAsFixed(2);
      int userId = await Authentication().getUserId();
      CustomDialog().confirmationDialog(Get.context!, "Pay Bills",
          "Are you sure you want to continue?", "No", "Okay", () {
        Get.back();
      }, () async {
        Get.back();
        var parameter = {
          "luvpay_id": userId.toString(),
          "biller_id": args["biller_id"].toString(),
          "bill_acct_no": billAccNo.text,
          "amount": totalAmount,
          "payment_hk": response["data"],
          "bill_no": billNo.text,
          "account_name": billerAccountName.text,
          'original_amount': amount.text
        };

        CustomDialog().loadingDialog(Get.context!);

        HttpRequest(api: ApiKeys.gApiPostPayBills, parameters: parameter)
            .postBody()
            .then((returnPost) async {
          Get.back();
          if (returnPost == "No Internet") {
            isLoading.value = false;
            isNetConn.value = false;
            CustomDialog().internetErrorDialog(Get.context!, () {
              Get.back();
            });
          } else if (returnPost == null) {
            isLoading.value = false;
            isNetConn.value = true;
            CustomDialog().serverErrorDialog(Get.context!, () {
              Get.back();
            });
          } else {
            if (returnPost["success"] == 'Y') {
              var params = {
                "user_id": userId,
                "biller_id": args["biller_id"].toString(),
                "account_no": billAccNo.text,
                "biller_name": args["biller_name"],
                "biller_address": args["biller_address"],
                'user_biller_id': args['user_biller_id'],
                'amount': totalAmount.toString(),
                "account_name": billerAccountName.text,
                "service_fee": args['service_fee'].toString(),
                "original_amount": amount.text
              };
              Get.to(TicketUI(), arguments: params);
            } else {
              CustomDialog()
                  .errorDialog(Get.context!, "Error", returnPost["msg"], () {
                Get.back();
              });
            }
          }
          isNetConn.value = true;
        });
      });
    }
  }

  Future<void> getFavorites() async {
    final item = await Authentication().getUserData();
    String userId = jsonDecode(item!)['user_id'].toString();
    String subApi = "${ApiKeys.gApiGetFavBiller}?user_id=$userId";
    HttpRequest(api: subApi).get().then((response) async {
      if (response == "No Internet") {
        isLoading.value = false;
        isNetConn.value = false;
        return;
      }
      if (response == null) {
        isLoading.value = false;
        isNetConn.value = true;
        favBillers.value = [];
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      favBillers.value = response["items"];
      isNetConn.value = true;
      isLoading.value = false;
    });
  }

  Future<void> generateQr() async {
    CustomDialog().loadingDialog(Get.context!);
    final response = await Functions.generateQr();

    Get.back();
    if (response["response"] == "No Internet") {
      isNetConn.value = false;
      return;
    }
    if (response["response"] == "Success") {
      isNetConn.value = true;
      payKey.value = response["data"];
      CustomDialog().successDialog(
          Get.context!, "Success", "Qr successfully changed", "Done", () {
        Get.back();
      });
      return;
    } else {
      isNetConn.value = true;
    }
  }

  void deleteFavoriteBiller(int billerId) async {
    final userId = await Authentication().getUserId();
    var params = {
      "user_id": userId,
      "u_biller_id": billerId,
    };

    CustomDialog().confirmationDialog(Get.context!, "Delete Biller",
        "Are you sure you want to delete this biller?", "No", "Yes", () {
      Get.back();
    }, () {
      Get.back();
      CustomDialog().loadingDialog(Get.context!);
      HttpRequest(api: ApiKeys.gApiLuvParkDeleteVehicle, parameters: params)
          .deleteData()
          .then((retDelete) {
        Get.back();
        if (retDelete == "No Internet") {
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
        } else if (retDelete == "Success") {
          CustomDialog().successDialog(
              Get.context!, "Success", "Successfully deleted", "Okay", () {
            Get.back();
            loadFavoritesAndBillers();
          });
        } else {
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        }
      });
    });
  }
}
