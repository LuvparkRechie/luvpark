import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scan/scan.dart';

class ScannedData {
  final BuildContext context;
  final String scannedHash;

  const ScannedData({required this.context, required this.scannedHash});
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key, required this.onchanged, this.isBack = true})
      : super(key: key);

  final Function(ScannedData args) onchanged;
  final bool isBack;

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  ScanController controller = ScanController();
  final ImagePicker _picker = ImagePicker();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkCameraPermission();
      load();
    });
  }

  void checkCameraPermission() async {
    final permissionStatus = await Permission.camera.status;
  }

  @override
  void dispose() {
    super.dispose();
  }

  load() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("QR Code"),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Iconsax.arrow_left,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
            )
          : Stack(
              children: [
                ScanView(
                  controller: controller,
                  scanAreaScale: .6,
                  scanLineColor: Colors.red.shade400,
                  onCapture: (data) {
                    ScannedData args =
                        new ScannedData(context: context, scannedHash: data);
                    Navigator.of(context).pop();
                    widget.onchanged(args);
                  },
                ),
                Positioned(
                    child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Text(
                      'Make sure the QR code is within the frame.',
                      style: GoogleFonts.openSans(color: Colors.white),
                    ),
                  ),
                )),
                Positioned(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () => takePhoto(ImageSource.gallery),
                      child: Container(
                        width: 150,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        margin: const EdgeInsets.only(bottom: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: Theme.of(context).primaryColor,
                              size: 30,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomParagraph(
                              maxlines: 1,
                              minFontSize: 8,
                              textAlign: TextAlign.center,
                              text: 'Upload QR Code',
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void takePhoto(ImageSource source) async {
    CameraDevice preferredCameraDevice = CameraDevice.rear;
    XFile? pickedFile = await _picker.pickImage(
        maxWidth: 939,
        source: source,
        imageQuality: 50,
        preferredCameraDevice: preferredCameraDevice);
    File? imageFile;

    imageFile = pickedFile != null ? File(pickedFile.path) : null;
    if (imageFile != null) {
      String? str = await Scan.parse(pickedFile!.path);
      if (str != null) {
        ScannedData args = ScannedData(context: context, scannedHash: str);
        Navigator.of(context).pop();
        widget.onchanged(args);
      } else {
        CustomDialog().errorDialog(context, "luvpark",
            "Invalid QR code image, please select valid QR code image.", () {
          Get.back();
        });
      }
    }
  }
}
