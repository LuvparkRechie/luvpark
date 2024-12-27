import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/scanner.dart';

class WalletSendController extends GetxController {
  WalletSendController();
  final GlobalKey<FormState> formKeySend = GlobalKey<FormState>();
  final TextEditingController recipient = TextEditingController();
  final TextEditingController tokenAmount = TextEditingController();
  final TextEditingController message = TextEditingController();
  final GlobalKey contentKey = GlobalKey();
  RxBool isLpAccount = false.obs;
  RxBool isLoading = true.obs;
  PermissionStatus cameraStatus = PermissionStatus.denied;
  RxBool isNetConn = true.obs;
  RxList userData = [].obs;
  String mobileNumber = '';
  List<SimCard> simCard = <SimCard>[];

  RxInt denoInd = 0.obs;

  RxInt indexbtn = 0.obs;
  RxList padData = [].obs;
  List dataList = [
    {"value": 20, "is_active": false},
    {"value": 30, "is_active": false},
    {"value": 50, "is_active": false},
    {"value": 100, "is_active": false},
    {"value": 200, "is_active": false},
    {"value": 250, "is_active": false},
    {"value": 300, "is_active": false},
    {"value": 500, "is_active": false},
    {"value": 1000, "is_active": false},
  ].obs;
  @override
  void onInit() {
    super.onInit();
    _checkCameraPermission();
    MobileNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        initMobileNumberState();
      } else {}
    });

    refreshUserData();
    padData.value = dataList;

    initMobileNumberState();
  }

  @override
  void onClose() {
    if (formKeySend.currentState != null) {
      formKeySend.currentState!.reset();
    }
    super.onClose();
  }

  Future<void> _checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    cameraStatus = status;
  }

  Future<void> requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();

    cameraStatus = status;

    if (status.isGranted) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text('Camera permission granted')),
      );
      Get.to(ScannerScreen(
        onchanged: (ScannedData args) {
          String scannedMobileNumber = args.scannedHash;
          String formattedNumber =
              scannedMobileNumber.replaceAll(RegExp(r'\D'), '');

          if (formattedNumber.length >= 12) {
            formattedNumber = formattedNumber.substring(2);
          }

          if (formattedNumber.isEmpty ||
              formattedNumber.length != 10 ||
              formattedNumber[0] == '0') {
            recipient.text = "";
            CustomDialog().errorDialog(
              Get.context!,
              "Invalid QR Code",
              "The scanned QR code is invalid. Please try again.",
              () {
                Get.back();
              },
            );
          } else {
            recipient.text = formattedNumber;
            onTextChange();
          }
        },
      ));
    } else if (status.isDenied) {
      // Permission denied
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text('Camera permission denied')),
      );
    } else if (status.isPermanentlyDenied) {
      AppSettings.openAppSettings();
    }
  }

// //naa
  Future<void> onTextChange() async {
    denoInd.value = -1;
  }

//naa
  Future<void> getVerifiedAcc() async {
    CustomDialog().loadingDialog(Get.context!);
    final userData = await Authentication().getUserData2();

    print("userData $userData");

    var params =
        "${ApiKeys.gApiSubFolderVerifyNumber}?mobile_no=63${recipient.text.toString().replaceAll(" ", "")}";
    HttpRequest(
      api: params,
    ).get().then((returnData) async {
      if (returnData == "No Internet") {
        Get.back();
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData == null) {
        Get.back();
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      }

      if (returnData["items"][0]["is_valid"] == "Y") {
        sendOtp();
        // if (mobileNumber.isNotEmpty) {
        //   String myMobile = mobileNumber.toString().split("+")[1];

        //   if (myMobile.toString() == userData["mobile_no"].toString()) {
        //     final responseOb =
        //         await Functions.getObtainOtp(userData["mobile_no"]);
        //     print("responseOb $responseOb");
        //   } else {
        //     sendOtp();
        //   }
        // } else {
        //   sendOtp();
        // }

        // return;
      } else {
        Get.back();
        CustomDialog().errorDialog(
            Get.context!, "luvpark", returnData["items"][0]["msg"], () {
          Get.back();
        });
      }
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      mobileNumber = (await MobileNumber.mobileNumber)!;
      simCard = (await MobileNumber.getSimCards)!;
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
  }

//naa
  Future<void> sendOtp() async {
    final item = await Authentication().getUserLogin();
    Map<String, dynamic> paramSend = {
      "mobile_no": item["mobile_no"],
    };

    HttpRequest(
            api: ApiKeys.gApiSubFolderPostReqOtpShare, parameters: paramSend)
        .post()
        .then(
      (retvalue) {
        if (retvalue == "No Internet") {
          Get.back();
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (retvalue == null) {
          Get.back();
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        } else {
          if (retvalue["success"] == "Y") {
            Get.back();
            List otpData = [
              {
                "amount": tokenAmount.text.toString().replaceAll(",", ""),
                "to_msg": message.text,
                "mobile_no": item["mobile_no"],
                "otp": int.parse(retvalue["otp"].toString()),
                "to_mobile_no": "63${recipient.text.replaceAll(" ", "")}"
              }
            ];

            Get.toNamed(
              Routes.sendOtp,
              arguments: {
                "otpData": otpData,
                "cb": () {
                  Get.back();
                  refreshUserData();
                }
              },
            );
          } else {
            Get.back();
            CustomDialog().errorDialog(Get.context!, "Error", retvalue["msg"],
                () {
              Get.back();
            });
          }
        }
      },
    );
  }

  Future<void> pads(int value) async {
    tokenAmount.text = value.toString();
    indexbtn.value = value;
    padData.value = dataList.map((obj) {
      obj["is_active"] = (obj["value"] == value);
      return obj;
    }).toList();
  }

//naa
  Future<void> refreshUserData() async {
    isLoading.value = true;
    final userId = await Authentication().getUserId();
    String subApi = "${ApiKeys.gApiSubFolderGetBalance}?user_id=$userId";

    HttpRequest(
      api: subApi,
    ).get().then((returnBalance) async {
      if (returnBalance == "No Internet") {
        isLoading.value = false;
        isNetConn.value = false;
        return;
      }
      if (returnBalance == null) {
        isLoading.value = false;
        isNetConn.value = false;
        return;
      }
      isLoading.value = false;
      isNetConn.value = true;
      if (returnBalance["items"].isNotEmpty) {
        userData.value = returnBalance["items"];
      }
    });
  }
}
