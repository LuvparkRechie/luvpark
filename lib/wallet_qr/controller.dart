// ignore_for_file: unused_import, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../custom_widgets/app_color.dart';
import '../custom_widgets/custom_cutter.dart';
import '../custom_widgets/custom_cutter_top_bottom.dart';
import '../routes/routes.dart';

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

  ///FIrst tab
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
        "+639${userData['mobile_no'].substring(3).toString().replaceAll(RegExp(r'.(?=.{4})'), '●')}";
    mobNum.value = userData['mobile_no'];
    isLoading.value = true;

    HttpRequest(api: "${ApiKeys.gApiSubFolderPayments}${userData["user_id"]}")
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
    HttpRequest(api: ApiKeys.gApiSubFolderPutChangeQR, parameters: param)
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

    final imgFile = File('$directory/screenshot.png');
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

                        // child: QrImageView(
                        //   data: currentPage.value == 1
                        //       ? mobNum.value
                        //       : payKey.value,
                        //   version: QrVersions.auto,
                        //   size: MediaQuery.of(Get.context!).size.width * .50,
                        //   gapless: false,
                        // ),
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
}
