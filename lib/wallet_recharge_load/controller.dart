import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/web_view/webview.dart';

import '../auth/authentication.dart';
import '../custom_widgets/variables.dart';
import '../http/api_keys.dart';

class WalletRechargeLoadController extends GetxController
    with GetSingleTickerProviderStateMixin {
  WalletRechargeLoadController();

  RxString aesKeys = "".obs;
  TextEditingController amountController = TextEditingController();
  final List<dynamic> bankPartner = [
    {
      "name": "U-Bank",
      "value": "UB",
      "img_url": "assets/images/ubank.png",
    },
  ];
  List dataList = [
    {"value": 100, "is_active": false},
    {"value": 150, "is_active": false},
    {"value": 200, "is_active": false},
    {"value": 300, "is_active": false},
    {"value": 400, "is_active": false},
    {"value": 500, "is_active": false},
    {"value": 750, "is_active": false},
    {"value": 1000, "is_active": false},
    {"value": 1500, "is_active": false},
  ].obs;
  RxList padData = [].obs;
  RxString email = "".obs;
  RxString fullName = "".obs;
  RxString hash = "".obs;
  RxBool isActiveBtn = false.obs;
  RxBool isLoadingPage = true.obs;
  RxBool isSelectedPartner = false.obs;
  RxBool isValidNumber = false.obs;
  final TextEditingController mobNum = TextEditingController();
  final GlobalKey<FormState> topUpKey = GlobalKey<FormState>();
  RxString pageUrl = "".obs;
  TextEditingController rname = TextEditingController();

// Nullable integer uniform code
  Rxn<int> selectedBankTracker = Rxn<int>(null);
  Rxn<int> selectedBankType = Rxn<int>(null);
  var denoInd = (-1).obs;
  var userDataInfo;
  final TextEditingController userName = TextEditingController();

  Timer? _debounce;

  @override
  void onClose() {
    _debounce?.cancel();
    topUpKey.currentState?.reset();
    super.onClose();
  }

  @override
  void onInit() {
    padData.value = dataList;
    rname = TextEditingController();
    amountController = TextEditingController();
    fullName.value = "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getBankUrl();
    });
    super.onInit();
  }

  Future<void> getData() async {
    var userData = await Authentication().getUserData();
    var item = jsonDecode(userData!);
    mobNum.text = item['mobile_no'].toString().substring(2);
    onSearchChanged(mobNum.text, true);
  }

  Future<void> getBankUrl() async {
    CustomDialog().loadingDialog(Get.context!);
    String subApi = "${ApiKeys.getBankDetails}?code=UB";

    try {
      var objData = await HttpRequest(api: subApi).get();

      if (objData == "No Internet") {
        handleNoInternet();
        return;
      }

      if (objData == null || objData["items"].isEmpty) {
        handleServerError();
        return;
      }

      await getBankData(
          objData["items"][0]["app_id"], objData["items"][0]["page_url"], 0);
    } catch (e) {
      handleServerError();
    }
  }

  void handleNoInternet() {
    isSelectedPartner.value = false;
    selectedBankType.value = null;
    selectedBankTracker.value = null;
    Get.back();
    CustomDialog().internetErrorDialog(Get.context!, () {
      Get.back();
    });
  }

  void handleServerError() {
    isSelectedPartner.value = false;
    isLoadingPage.value = false;
    selectedBankType.value = null;
    selectedBankTracker.value = null;
    Get.back();
    CustomDialog().serverErrorDialog(Get.context!, () {
      Get.back();
    });
  }

  getBankData(appId, url, ind) {
    String bankParamApi = "${ApiKeys.getBankParam}?app_id=$appId";

    HttpRequest(api: bankParamApi).get().then((objData) {
      if (objData == "No Internet") {
        Get.back();
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (objData == null || objData["items"].length == 0) {
        Get.back();

        isSelectedPartner.value = false;
        isLoadingPage.value = false;
        selectedBankType.value = null;
        selectedBankTracker.value = null;

        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });

        return;
      } else {
        Get.back();
        var dataObj = {};

        for (int i = 0; i < objData["items"].length; i++) {
          dataObj[objData["items"][i]["param_key"]] =
              objData["items"][i]["param_value"];
        }

        isLoadingPage.value = false;

        selectedBankType.value = ind;
        selectedBankTracker.value = ind;
        isSelectedPartner.value = true;
        aesKeys.value = dataObj["AES_KEY"];
        pageUrl.value = Uri.decodeFull(url);
        getData();
        if (!isValidNumber.value) {
          isActiveBtn.value = false;
        } else {
          isActiveBtn.value = true;
        }
      }
    });
  }

  Future<void> testUBUriPage(plainText, secretKeyHex) async {
    final secretKey = Variables.hexStringToArrayBuffer(secretKeyHex);
    final nonce = Variables.generateRandomNonce();

    // Encrypt
    final encrypted = await Variables.encryptData(secretKey, nonce, plainText);
    final concatenatedArray = Variables.concatBuffers(nonce, encrypted);
    final output = Variables.arrayBufferToBase64(concatenatedArray);

    hash.value = Uri.encodeComponent(output);

    Get.to(
      () => WebviewPage(
        urlDirect: "${pageUrl.value}${hash.value}",
        label: "Bank Payment",
      ),
      transition: Transition.zoom,
      duration: const Duration(milliseconds: 200),
    );
  }

  Future<void> onPay() async {
    final item = await Authentication().getUserData2();

    if (topUpKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus!.unfocus();
      if (!isActiveBtn.value) {
        return;
      }
      if (!isSelectedPartner.value) {
        CustomDialog().errorDialog(
            Get.context!, "Attention", "Please Select payment method", () {
          Get.back();
        });
        return;
      }

      var dataParam = {
        "amount": amountController.text.toString().split(".")[0],
        "user_id": userDataInfo[0]["user_id"],
        "to_mobile_no": "63${mobNum.text.replaceAll(" ", "")}",
      };

      CustomDialog().loadingDialog(Get.context!);
      HttpRequest(api: ApiKeys.postThirdPartyPayment, parameters: dataParam)
          .postBody()
          .then((returnPost) {
        if (returnPost == "No Internet") {
          Get.back();
          CustomDialog().errorDialog(Get.context!, "Error",
              "Please check your internet connection and try again.", () {
            Get.back();
          });
          return;
        }
        if (returnPost == null) {
          Get.back();
          CustomDialog().errorDialog(Get.context!, "Error",
              "Error while connecting to server, Please try again.", () {
            Get.back();
          });
        } else {
          if (returnPost["success"] == 'Y') {
            var plainText = {
              "Amt": amountController.text,
              "Email": item['email'].toString(),
              "Mobile": mobNum.text.replaceAll(" ", ""),
              "Redir": "https://www.example.com",
              "References": [
                {
                  "Id": "1",
                  "Name": "RECIPIENT_MOBILE_NO",
                  "Val": "63${mobNum.text.replaceAll(" ", "")}"
                },
                {
                  "Id": "2",
                  "Name": "RECIPIENT_FULL_NAME",
                  "Val": userName.text.replaceAll(RegExp(' +'), ' ')
                },
                {"Id": "3", "Name": "TNX_HK", "Val": returnPost["hash-key"]}
              ]
            };

            // Get.back();

            testUBUriPage(json.encode(plainText),
                aesKeys.value); // Use .value for aesKeys

            if (Navigator.canPop(Get.context!)) {
              Get.back();
            }
          } else {
            Get.back();
            CustomDialog().errorDialog(Get.context!, "Error", returnPost['msg'],
                () {
              Get.back();
            });
          }
        }
      });
    }
  }

  Future<void> onSearchChanged(mobile, isFirst) async {
    isActiveBtn.value = false;

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (mobile.toString().length < 10) {
      return;
    }
    Duration duration = const Duration(milliseconds: 200);
    if (isFirst) {
      duration = const Duration(milliseconds: 200);
    } else {
      duration = const Duration(seconds: 2);
    }

    _debounce = Timer(duration, () {
      CustomDialog().loadingDialog(Get.context!);
      String api =
          "${ApiKeys.getRecipient}?mobile_no=63${mobile.toString().replaceAll(" ", '')}";
      HttpRequest(api: api).get().then((objData) {
        FocusScope.of(Get.context!).unfocus();
        if (objData == "No Internet") {
          isValidNumber.value = false;
          rname.text = "";
          fullName.value = "";
          userName.text = "";

          Get.back();
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (objData == null) {
          Get.back();

          isValidNumber.value = false;
          rname.text = "";
          fullName.value = "";
          userName.text = "";

          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (objData["user_id"] == 0) {
          Get.back();

          userDataInfo = null;
          rname.text = "";
          userName.text = "";
          fullName.value = "";
          isValidNumber.value = false;

          CustomDialog().errorDialog(Get.context!, "Error",
              "Sorry, we're unable to find your account.", () {
            Get.back();
          });
          return;
        } else {
          Get.back();

          if (!isSelectedPartner.value) {
            isActiveBtn.value = false;
          } else {
            isActiveBtn.value = true;
          }
          userDataInfo = [objData];
          isValidNumber.value = true;
          String originalFullName = userDataInfo[0]["first_name"].toString();
          String transformedFullName = Variables.transformFullName(
              originalFullName.replaceAll(RegExp(r'\..*'), ''));
          String transformedLname = Variables.transformFullName(userDataInfo[0]
                  ["last_name"]
              .toString()
              .replaceAll(RegExp(r'\..*'), ''));

          String middelName = "";
          if (userDataInfo[0]["middle_name"] != null) {
            middelName = userDataInfo[0]["middle_name"].toString()[0];
          } else {
            middelName = "";
          }
          userName.text =
              "$originalFullName $middelName ${userDataInfo[0]["last_name"].toString()}";
          fullName.value =
              '$transformedFullName $middelName${middelName.isNotEmpty ? "." : ""} $transformedLname';
          if (originalFullName == 'null') {
            rname.text = "Not verified user";
          } else {
            rname.text = fullName.value;
          }
        }
      });
    });
  }

  //function for my pads
  Future<void> pads(int value) async {
    amountController.text = value.toString();
    padData.value = dataList.map((obj) {
      obj["is_active"] = (obj["value"] == value);
      return obj;
    }).toList();

    isActiveBtn.value = true;
  }

  Future<void> onTextChange() async {
    denoInd.value = -1;

    final double? value = double.parse(amountController.text);
    padData.value = padData.map((e) {
      if (double.parse(e["value"].toString()) ==
          double.parse(value.toString())) {
        e["is_active"] = true;
        return e;
      } else {
        e["is_active"] = false;
        return e;
      }
    }).toList();

    if (value == null || value < 20) {
      isActiveBtn.value = false;
    } else {
      isActiveBtn.value = true;
    }
  }
}
