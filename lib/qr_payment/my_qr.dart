import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class MyQrPage extends StatefulWidget {
  const MyQrPage({
    super.key,
  });

  @override
  State<MyQrPage> createState() => _MyQrPageState();
}

class _MyQrPageState extends State<MyQrPage> {
  ScreenshotController screenshotController = ScreenshotController();
  // ignore: prefer_typing_uninitialized_variables
  var akongP;
  bool loading = true;
  String myImage = "";
  String fullName = "";
  String myProfilePic = "";
  @override
  void initState() {
    super.initState();
    loading = true;
    getPreferences();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    akongP = prefs.getString(
      'userData',
    );
    var myPicData = prefs.getString(
      'myProfilePic',
    );

    setState(() {
      myProfilePic = jsonDecode(myPicData!).toString();
      String middleName =
          jsonDecode(akongP!)['middle_name'].toString().toUpperCase() == "NA"
              ? ""
              : "${jsonDecode(akongP!)['middle_name'].toString()[0]}.";
      fullName =
          "${jsonDecode(akongP!)['first_name'].toString()} $middleName ${jsonDecode(akongP!)['last_name'].toString()}";

      loading = false;
    });
    Timer(const Duration(milliseconds: 200), () {
      setState(() {
        loading = false;
      });
    });
  }

  Future<Image>? image;

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1)),
        child: bodyniya2(),
      );
    });
  }

  Widget bodyniya2() {
    return Padding(
      padding: const EdgeInsets.only(top: 52.0),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * .60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                loading
                    ? Center(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: const Color(0xFFe6faff),
                          child: Container(),
                        ),
                      )
                    : Column(
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
                                data: jsonDecode(akongP!)['user_qr'].toString(),
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
                              label: loading ? "" : 'Scan QR code to receive',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF787878),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomDisplayText(
                                      label: jsonDecode(akongP!)['first_name']
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
                                      label: loading
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
                          Container(
                            height: 16,
                          ),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 1,
                                                    fontSize: 14)
                                                : TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 1,
                                                    fontSize: 14,
                                                    fontFamily: "SFProTextReg",
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  color: const Color.fromRGBO(30, 33, 41, 0.08),
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
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 1,
                                                    fontSize: 14)
                                                : TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 1,
                                                    fontSize: 14,
                                                    fontFamily: "SFProTextReg",
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
                data: loading ? '' : jsonDecode(akongP!)['user_qr'].toString(),
                version: QrVersions.auto,
                size: MediaQuery.of(context).size.width * .50,
                gapless: false,
                backgroundColor: const Color(0xFFffffff),
              ),
              Container(
                height: 20,
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'Scan QR Code to receive',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black54,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

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
        openAppResult;
        break;
      }
    }
  }

  void saveToGallery() async {
    CustomModal(context: context).loader();
    ScreenshotController()
        .captureFromWidget(myWidget(), delay: const Duration(seconds: 1))
        .then((image) async {
      final dir = await getApplicationDocumentsDirectory();
      final imagePath = await File('${dir.path}/captured.png').create();
      await imagePath.writeAsBytes(image);
      GallerySaver.saveImage(imagePath.path).then((result) {
        Navigator.of(context).pop();
        showAlertDialog(context, "Success",
            "QR code has been saved. Please check your gallery.", () async {
          Navigator.of(context).pop();
          getGalleryPackageName();
        });
      });
    });
  }

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

  // void _onShareXFileFromAssets(BuildContext context) async {
  //   final box = context.findRenderObject() as RenderBox?;
  //   final scaffoldMessenger = ScaffoldMessenger.of(context);
  //   final data = await rootBundle.load('assets/flutter_logo.png');
  //   final buffer = data.buffer;
  //   final shareResult = await Share.shareXFiles(
  //     [
  //       XFile.fromData(
  //         buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  //         name: 'flutter_logo.png',
  //         mimeType: 'image/png',
  //       ),
  //     ],
  //     sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  //   );

  //   scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
  // }
}
