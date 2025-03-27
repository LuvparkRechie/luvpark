// ignore_for_file: unused_import, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:luvpark/custom_widgets/scanner.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/main.dart';
import 'package:luvpark/wallet_qr/genarateReceive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../custom_widgets/app_color.dart';
import '../custom_widgets/custom_cutter.dart';
import '../custom_widgets/custom_cutter_top_bottom.dart';
import '../routes/routes.dart';
import 'view.dart';

class QrWalletController extends GetxController
    with GetSingleTickerProviderStateMixin {
  QrWalletController();
  final ScreenshotController screenshotController = ScreenshotController();
  RxInt currentPage = 0.obs;
  RxString firstlastCapital = ''.obs;
  RxString fullName = "".obs;
  RxBool isAgree = false.obs;
  RxBool isInternetConn = true.obs;
  RxBool isLoading = true.obs;
  RxString mobNum = "".obs;
  RxString mono = ''.obs;
  RxString payKey = "".obs;
  List optionData = [
    {
      "label": "Pay Using QR",
      "title": "QR Pay",
      "subtitle":
          "Enable QR Pay for fast and secure payment transactions directly from your account.",
      "icon": Icons.qr_code_rounded
    },
    {
      "label": "Scan and Pay through our partnered merchants",
      "title": "Scan Merchant Code",
      "subtitle":
          "Scan with our merchant's QR code for fast and secure payment transactions directly from your account.",
      "icon": Icons.qr_code_scanner_rounded
    },
    {
      "label": "Receive token through QR",
      "title": "QR Receive",
      "subtitle":
          "Receive token quickly and securely by sharing your QR Code with other luvpark accounts.",
      "icon": Icons.qr_code_rounded
    },
  ];

  RxInt denoInd = 0.obs;
  PermissionStatus cameraStatus = PermissionStatus.denied;

  late TabController tabController;
  late final TextEditingController imageSizeEditingController;
  // ignore: prefer_typing_uninitialized_variables
  RxString userImage = "".obs;

  @override
  void onClose() {
    tabController.dispose();

    super.onClose();
  }

  @override
  void onInit() {
    _checkCameraPermission();
    tabController = TabController(vsync: this, length: 2);

    getQrData();
    super.onInit();
  }

  void onTabChanged(int index) async {
    currentPage.value = index;
    if (currentPage.value == 0) {
      getQrData();
    }
    update();
  }

  Future<void> getQrData() async {
    String image = await Authentication().getUserProfilePic();
    userImage.value = image;
    isLoading.value = true;
    isInternetConn.value = true;
    var userData = await Authentication().getUserData2();

    if (userData["first_name"] != null) {
      String middleName =
          userData['middle_name']?.toString().toUpperCase() == null
              ? ""
              : "${userData['middle_name'].toString()[0]}.";
      fullName.value =
          "${userData['first_name'].toString()} $middleName ${userData['last_name'].toString()}";
      firstlastCapital.value =
          "${userData['first_name'].toString()[0]} ${userData['last_name'].toString()[0]}";
    } else {
      fullName.value = "Not specified";
    }
    mono.value =
        "+639${userData['mobile_no'].substring(3).toString().replaceAll(RegExp(r'.(?=.{4})'), '·')}";
    mobNum.value = userData['mobile_no'];
    isLoading.value = true;

    HttpRequest(api: "${ApiKeys.getPaymentKey}${userData["user_id"]}")
        .get()
        .then((paymentKey) {
      if (paymentKey == "No Internet") {
        isInternetConn.value = false;
        isLoading.value = false;

        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (paymentKey == null) {
        isInternetConn.value = true;
        isLoading.value = true;
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      } else {
        isInternetConn.value = true;
        isLoading.value = false;
        payKey.value = paymentKey["items"][0]["payment_hk"];
      }
    });
  }

  Future<void> generateQr() async {
    CustomDialog().loadingDialog(Get.context!);

    int userId = await Authentication().getUserId();
    dynamic param = {"luvpay_id": userId};
    HttpRequest(api: ApiKeys.generatePayKey, parameters: param)
        .put()
        .then((objKey) {
      if (objKey == "No Internet") {
        isInternetConn.value = false;
        isLoading.value = false;

        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (objKey == null) {
        isInternetConn.value = true;
        isLoading.value = true;
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      } else {
        isInternetConn.value = true;
        isLoading.value = false;
        if (objKey["success"] == 'Y') {
          payKey.value = objKey["payment_hk"];
          CustomDialog().successDialog(
              Get.context!, "Success", "Qr successfully changed", "Done", () {
            Get.back();
            Get.back();
          });
        } else {
          CustomDialog()
              .errorDialog(Get.context!, "luvpark", objKey['msg'], () {});
        }
      }
    });
  }

  Future<void> saveQr() async {
    CustomDialog().loadingDialog(Get.context!);
    ScreenshotController()
        .captureFromWidget(myWidget(), delay: const Duration(seconds: 2))
        .then((image) async {
      final dir = await getApplicationDocumentsDirectory();
      final imagePath = await File('${dir.path}/captured.png').create();
      await imagePath.writeAsBytes(image);
      GallerySaver.saveImage(imagePath.path).then((result) {
        CustomDialog().successDialog(Get.context!, "Success",
            "QR code has been saved. Please check your gallery.", "Okay", () {
          Get.back();
          Get.back();
        });
      });
    });
  }

  Future<void> shareQr() async {
    CustomDialog().loadingDialog(Get.context!);
    final directory = (await getApplicationDocumentsDirectory()).path;
    Uint8List bytes = await ScreenshotController().captureFromWidget(
      myWidget(),
    );
    Uint8List pngBytes = bytes.buffer.asUint8List();

    final imgFile = File(
        '$directory/${currentPage.value == 0 ? "payment" : "receive"}_qr.png');
    imgFile.writeAsBytes(pngBytes);
    Get.back();
    await Share.shareFiles([imgFile.path]);
  }

  Widget myWidget() => Container(
        color: Colors.grey.shade300,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColor.bodyColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TopRowDecoration(color: Colors.grey.shade300),
                    Image(
                      height: 60,
                      fit: BoxFit.cover,
                      image: AssetImage("assets/images/login_logo.png"),
                    ),
                    LineCutter(),
                    const SizedBox(height: 10),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 2,
                            color: Color(0x162563EB),
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          height: MediaQuery.of(Get.context!).size.height / 4.5,
                          child: PrettyQrView(
                            decoration: const PrettyQrDecoration(
                                image: PrettyQrDecorationImage(
                                    image:
                                        AssetImage("assets/images/logo.png"))),
                            qrImage: QrImage(QrCode.fromData(
                                data: currentPage.value == 1
                                    ? mobNum.value
                                    : payKey.value,
                                errorCorrectLevel: QrErrorCorrectLevel.H)),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                    Text(
                      currentPage.value == 1
                          ? "Scan QR Code to receive"
                          : "QR Pay",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF787878),
                      ),
                    ),
                    BottomRowDecoration(color: Colors.grey.shade300)
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> _checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    cameraStatus = status;
  }

  Future<void> getpaymentHK(items, mkey, mname) async {
    // CustomDialog().loadingDialog(Get.context!);
    final userID = await Authentication().getUserId();

    HttpRequest(api: "${ApiKeys.getPaymentKey}$userID")
        .get()
        .then((paymentKey) {
      Get.back();

      if (paymentKey == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (paymentKey == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      }
      if (paymentKey["items"].isNotEmpty) {
        Get.back();
        Get.toNamed(Routes.merchantQR, arguments: {
          "data": items,
          'merchant_key': mkey,
          "merchant_name": mname,
          "payment_key": paymentKey["items"][0]["payment_hk"]
        });
      } else {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      }
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
        onchanged: (ScannedData args) async {
          CustomDialog().loadingDialog(Get.context!);
          String mKey = args.scannedHash;
          String api = "${ApiKeys.getMerchantScan}?merchant_key=$mKey";

          final response = await HttpRequest(api: api).get();
          String merchantname = response["items"][0]["merchant_name"];
          if (response == "No Internet") {
            Get.back();
            CustomDialog().errorDialog(Get.context!, "Error",
                "Please check your internet connection and try again.", () {
              Get.back();
            });

            return;
          }
          if (response == null) {
            Get.back();
            CustomDialog().errorDialog(Get.context!, "Error",
                "Error while connecting to server, Please try again.", () {
              Get.back();
            });

            return;
          }

          if (response["items"].isNotEmpty) {
            getpaymentHK(
              response["items"],
              mKey,
              merchantname,
            );
          } else {
            Get.back();
            CustomDialog().errorDialog(Get.context!, "No Merchant Found",
                "Merchant is not registered in our system. Please contact us for more information",
                () {
              Get.back();
            });
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

  void onOptionTap(int index) async {
    switch (index) {
      case 0:
        Get.toNamed(Routes.paywithQR);
        break;
      case 1:
        FocusManager.instance.primaryFocus!.unfocus();
        requestCameraPermission();
        break;
      case 2:
        Get.to(GenerateReceiveQR(), arguments: {
          "mobile_no": mobNum.value,
        });

        break;
    }
  }
}
