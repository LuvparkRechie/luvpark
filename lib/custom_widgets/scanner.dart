import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        title: 'QR Code',
      ),
      body: Stack(
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
                      Text(
                        'Upload QR Code',
                        style: GoogleFonts.openSans(color: Colors.black),
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
