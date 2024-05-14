import 'dart:convert';
import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../custom_widget/custom_loader.dart';

// ignore: must_be_immutable
class QRPay extends StatefulWidget {
  const QRPay({super.key, required});

  @override
  State<QRPay> createState() => _QRPayState();
}

class _QRPayState extends State<QRPay> {
  final GlobalKey qrKey = GlobalKey();
  String paymentHashKey = "";
  String myProfilePic = "";
  bool isLoading = true;
  bool hasInternet = true;
  var akongP;
  bool loading = true;
  String myImage = "";
  String fullName = "";

  @override
  void initState() {
    super.initState();

    getUserData();
  }

  void getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    akongP = prefs.getString(
      'userData',
    );
    var myPicData = prefs.getString(
      'myProfilePic',
    );

    setState(() {
      isLoading = true;
      myProfilePic = jsonDecode(myPicData!).toString();
      String middleName =
          jsonDecode(akongP!)['middle_name'].toString().toUpperCase() == "NA"
              ? ""
              : "${jsonDecode(akongP!)['middle_name'].toString()[0]}.";
      fullName =
          "${jsonDecode(akongP!)['first_name'].toString()} $middleName ${jsonDecode(akongP!)['last_name'].toString()}";
    });
    getluvparkHashKey();
  }

  void getluvparkHashKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var akongP = prefs.getString(
      'userData',
    );

    HttpRequest(
            api:
                "${ApiKeys.gApiSubFolderPayments}${jsonDecode(akongP!)['user_id'].toString()}")
        .get()
        .then((paymentKey) {
      print("paymentKey $paymentKey");
      if (paymentKey == "No Internet") {
        setState(() {
          hasInternet = false;
          isLoading = false;
        });

        return;
      }
      if (paymentKey == null) {
        setState(() {
          hasInternet = true;
          isLoading = false;
        });

        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });

        return;
      } else {
        setState(() {
          hasInternet = true;
          isLoading = false;
          paymentHashKey = paymentKey["items"][0]["payment_hk"];
        });
      }
    });
  }

  void changeQr() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var akongP = prefs.getString(
      'userData',
    );
    // ignore: prefer_typing_uninitialized_variables

    // ignore: use_build_context_synchronously
    CustomModal(context: context).loader();
    HttpRequest(api: ApiKeys.gApiSubFolderPutChangeQR, parameters: {
      "luvpay_id": jsonDecode(akongP!)['user_id'].toString()
    }).put().then((returnPost) {
      if (returnPost == "No Internet") {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again", () {
          Navigator.pop(context);
        });
        return;
      }
      if (returnPost == null) {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      } else {
        if (returnPost["success"] == 'Y') {
          setState(() {
            paymentHashKey = returnPost["payment_hk"];
            isLoading = false;
            Navigator.of(context).pop();
            showAlertDialog(context, "Success", "QR successfully changed.",
                () async {
              Navigator.of(context).pop();
            });
          });
        } else {
          Navigator.pop(context);
          showAlertDialog(context, "Error", returnPost['msg'], () {
            Navigator.of(context).pop();
          });
        }
      }
    });
  }

  Future<void> getGalleryPackageName() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );

    for (Application app in apps) {
      if (app.packageName.contains('gallery')) {
        String galleryPackageName = app.packageName;

        var openAppResult = await LaunchApp.openApp(
            androidPackageName: galleryPackageName, openStore: true);
        // ignore: unnecessary_statements
        openAppResult;
        break;
      }
    }
  }

  void saveToGallery() async {
    CustomModal(context: context).loader();
    ScreenshotController()
        .captureFromWidget(myWidget(), delay: const Duration(seconds: 3))
        .then((image) async {
      final dir = await getApplicationDocumentsDirectory();
      final imagePath = await File('${dir.path}/captured.png').create();
      await imagePath.writeAsBytes(image);

      GallerySaver.saveImage(imagePath.path).then((result) {
        showAlertDialog(context, "Success",
            "QR code has been saved. Please check your gallery.", () async {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          //getGalleryPackageName();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: PopScope(canPop: true, child: bodyniya()),
    );
  }

  Widget bodyniya() {
    return Padding(
      padding: const EdgeInsets.only(top: 52.0),
      child: isLoading
          ? Center(
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: const Color(0xFFe6faff),
                child: Container(),
              ),
            )
          : !hasInternet
              ? NoInternetConnected(onTap: getUserData)
              : Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                        width: 2,
                                        color: const Color.fromRGBO(
                                            37, 99, 235, 0.09))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: QrImageView(
                                    data: paymentHashKey,
                                    version: QrVersions.auto,
                                    gapless: false,
                                    backgroundColor: AppColor.bodyColor,
                                  ),
                                ),
                              ),
                              Container(
                                height: 27,
                              ),
                              Center(
                                child: CustomDisplayText(
                                  label: isLoading ? "" : 'Scan QR Code to pay',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                  alignment: TextAlign.center,
                                ),
                              ),
                              Container(
                                height: 37,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColor.primaryColor),
                                    child: Center(
                                      child: CustomDisplayText(
                                        label: jsonDecode(akongP!)['first_name']
                                                    .toString() ==
                                                'null'
                                            ? "N/A"
                                            : "${jsonDecode(akongP!)['first_name'].toString()[0]}${jsonDecode(akongP!)['last_name'].toString()[0]}",
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontSize: 16,
                                        alignment: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomDisplayText(
                                          label:
                                              jsonDecode(akongP!)['first_name']
                                                          .toString() ==
                                                      'null'
                                                  ? "Not Specified"
                                                  : fullName.toUpperCase(),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF353636),
                                          letterSpacing: -0.32,
                                        ),
                                        CustomDisplayText(
                                          label: isLoading
                                              ? ""
                                              : "+639${jsonDecode(akongP!)['mobile_no'].substring(3).toString().replaceAll(RegExp(r'.(?=.{4})'), '●')}",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF9A9A9A),
                                          letterSpacing: -0.32,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 33,
                              ),
                              InkWell(
                                onTap: () {
                                  changeQr();
                                },
                                child: Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .60,
                                    padding: const EdgeInsets.fromLTRB(
                                        12, 12, 12, 12), // Padding values
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromRGBO(0, 0, 0,
                                            0.08), // Color with rgba values
                                        width: 1.0, // 1-pixel width
                                      ),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons
                                              .sync_outlined, // Replace with your desired icon
                                          size:
                                              28.0, // Adjust the icon size as needed
                                        ),
                                        const SizedBox(
                                            width:
                                                5), // Gap between the icon and other content
                                        CustomDisplayText(
                                          label: 'Generate QR code',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 16,
                              ),
                              IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          _shareQrCode();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.ios_share_outlined,
                                                color: Colors.black,
                                                size: 25,
                                              ),
                                              Text(
                                                "Share",
                                                style: Platform.isAndroid
                                                    ? GoogleFonts.dmSans(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: 1,
                                                        fontSize: 14)
                                                    : TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: 1,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            "SFProTextReg",
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      color: const Color.fromRGBO(
                                          30, 33, 41, 0.08),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          saveToGallery();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.download_outlined,
                                                color: Colors.black,
                                                size: 25,
                                              ),
                                              Text(
                                                "Save",
                                                style: Platform.isAndroid
                                                    ? GoogleFonts.dmSans(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: 1,
                                                        fontSize: 14)
                                                    : TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: 1,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            "SFProTextReg",
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget myWidget() => Container(
        color: const Color(0xFFffffff),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                  width: 100,
                  height: 100,
                  image: AssetImage("assets/images/luvpark_transparent.png")),
              Container(
                height: 20,
              ),
              QrImageView(
                data: paymentHashKey,
                version: QrVersions.auto,
                size: MediaQuery.of(context).size.width * .50,
                gapless: false,
                backgroundColor: const Color(0xFFffffff),
              ),
              Container(
                height: 20,
              ),
              Text(
                "QR Pay",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF787878),
                ),
              )
            ],
          ),
        ),
      );

  _shareQrCode() async {
    File? imgFile;
    CustomModal(context: context).loader();

    final directory = (await getApplicationDocumentsDirectory()).path;
    Uint8List bytes = await ScreenshotController().captureFromWidget(
      myWidget(),
    );
    Uint8List pngBytes = bytes.buffer.asUint8List();

    setState(() {
      imgFile = File('$directory/screenshot.png');
      imgFile!.writeAsBytes(pngBytes);
    });
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
    // ignore: deprecated_member_use
    await Share.shareFiles([imgFile!.path]);
  }
}
