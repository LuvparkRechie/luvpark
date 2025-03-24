import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/scanner.dart';
import '../custom_widgets/variables.dart';
import '../notification_controller.dart';
import 'view.dart';

class WalletSendController extends GetxController {
  WalletSendController();
  final GlobalKey<FormState> formKeySend = GlobalKey<FormState>();
  final TextEditingController tokenAmount = TextEditingController();
  final TextEditingController message = TextEditingController();
  TextEditingController myPass = TextEditingController();
  final GlobalKey contentKey = GlobalKey();
  RxBool isLpAccount = false.obs;
  RxBool isLoading = true.obs;
  RxBool isPage2 = false.obs;
  PermissionStatus cameraStatus = PermissionStatus.denied;
  RxBool isNetConn = true.obs;
  RxList userData = [].obs;
  RxList recipientData = [].obs;
  String mobileNumber = '';
  RxString userName = "".obs;
  RxString userImage = "".obs;
  List<SimCard> simCard = <SimCard>[];
  final FlutterContactPicker contactPicker = FlutterContactPicker();
  Rx<Contact?> contact = Rx<Contact?>(null);
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
    checkAndRequestPermissions();
    refreshUserData();
    showBottomSheet();
    padData.value = dataList;
  }

  @override
  void onClose() {
    if (formKeySend.currentState != null) {
      formKeySend.currentState!.reset();
    }
    super.onClose();
  }

  Future<void> checkAndRequestPermissions() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
    } else if (status.isDenied) {
      var result = await Permission.contacts.request();
      if (result.isGranted) {
      } else if (result.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
      }
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Please enable contacts permission in settings.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    cameraStatus = status;
  }

  Future<void> showBottomSheet() async {
    await Future.delayed(Duration(seconds: 1), () {
      Get.bottomSheet(
          UsersBottomsheet(
            index: 1,
            cb: (index) {
              Functions.popPage(index);
            },
          ),
          enableDrag: false,
          isDismissible: false);
    });
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
            CustomDialog().errorDialog(
              Get.context!,
              "Invalid QR Code",
              "The scanned QR code is invalid. Please try again.",
              () {
                Get.back();
              },
            );
          } else {
            getRecipient(formattedNumber);
            Get.back();
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

//naa
  Future<void> getVerifiedAcc() async {
    CustomDialog().loadingDialog(Get.context!);
    var params =
        "${ApiKeys.verifyUserAccount}?mobile_no=${recipientData[0]["mobile_no"]}";

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
        return;
      }

      if (returnData["is_valid"] == "Y") {
        Get.back();
        isPage2.value = true;

        return;
      } else {
        Get.back();
        CustomDialog().errorDialog(
            Get.context!, "luvpark", returnData["items"][0]["msg"], () {
          Get.back();
        });
        return;
      }
    });
  }

  Future<void> pads(String value) async {
    int textValue = int.parse(value.toString());
    tokenAmount.text = textValue.toString();
    indexbtn.value = textValue;
    padData.value = dataList.map((obj) {
      obj["is_active"] = (obj["value"] == value);
      return obj;
    }).toList();
  }

//naa
  Future<void> refreshUserData() async {
    isLoading.value = true;
    final userId = await Authentication().getUserId();
    String subApi = "${ApiKeys.getUserBalance}$userId";

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

//Share token
  Future<void> shareToken() async {
    final userData = await Authentication().getUserData2();
    int userId = await Authentication().getUserId();

    CustomDialog().loadingDialog(Get.context!);
    Map<String, dynamic> parameters = {
      "user_id": userId.toString(),
      "to_mobile_no": recipientData[0]["mobile_no"],
      "amount": tokenAmount.text,
      "to_msg": message.text,
      "session_id": userData["session_id"].toString(),
      "pwd": myPass.text,
    };
    HttpRequest(api: ApiKeys.postShareToken, parameters: parameters)
        .postBody()
        .then(
      (retvalue) {
        if (retvalue == "No Internet") {
          Get.back();
          CustomDialog().errorDialog(Get.context!, "Error",
              "Please check your internet connection and try again.", () {
            Get.back();
          });
          return;
        }
        if (retvalue == null) {
          Get.back();
          CustomDialog().errorDialog(Get.context!, "Error",
              "Error while connecting to server, Please try again.", () {
            if (Navigator.canPop(Get.context!)) {
              Get.back();
            }
          });
        } else {
          if (retvalue["success"] == "Y") {
            NotificationController.shareTokenNotification(
                0, 0, 'Transfer Token', "${retvalue["msg"]}.", "walletScreen");

            Get.back();

            CustomDialog().successDialog(
                Get.context!, "Success", "Transaction complete", "Okay", () {
              Get.back();
              onPageSnap();
              refreshUserData();
              Future.delayed(Duration(milliseconds: 500), () {
                Get.back();
              });
            });
            return;
          } else {
            Get.back();
            CustomDialog().errorDialog(
              Get.context!,
              "Error",
              retvalue["msg"],
              () {
                Get.back();
              },
            );
            return;
          }
        }
      },
    );
  }
//get user data

  Future<void> getRecipient(String mobileNo) async {
    CustomDialog().loadingDialog(Get.context!);
    String api =
        "${ApiKeys.getRecipient}?mobile_no=63${mobileNo.toString().replaceAll(" ", '')}";

    HttpRequest(api: api).get().then((objData) {
      print("objData $objData");
      // FocusScope.of(Get.context!).unfocus();
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
      if (objData["user_id"] == 0) {
        Get.back();
        CustomDialog().errorDialog(
            Get.context!, "Error", "Sorry, we're unable to find your account.",
            () {
          Get.back();
        });
        return;
      } else {
        Get.back();

        recipientData.value = [objData];
        String fname = objData["first_name"] ?? "";
        userImage.value = objData["image_base64"] ?? "";

        if (fname.isNotEmpty) {
          String transformedFullName = Variables.transformFullName(
              fname.replaceAll(RegExp(r'\..*'), ''));
          String transformedLname = Variables.transformFullName(
              objData["last_name"]
                      ?.toString()
                      .replaceAll(RegExp(r'\..*'), '') ??
                  "");

          String middleName = objData["middle_name"]?.toString()[0] ?? "";

          userName.value =
              '$transformedFullName $middleName${middleName.isNotEmpty ? "." : ""} $transformedLname';
        } else {
          userName.value = "Not Verified";
        }
        Get.back();
      }
    });
  }

  void onPageSnap() {
    isPage2.value = !isPage2.value;
  }
}
