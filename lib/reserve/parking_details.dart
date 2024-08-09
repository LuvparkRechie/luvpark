import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/class/get_user_bal.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/location_controller.dart';
import 'package:luvpark/classess/textstyle.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/reserve/extend_dialog.dart';
import 'package:luvpark/reserve/receiptV2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ParkingDetails extends StatefulWidget {
  String startDate, startTime, endTime;
  final dynamic resData, returnData;
  final Object paramsCalc;
  final String? dtOut, dateIn;
  final Function? onTap;

  ParkingDetails({
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.resData,
    required this.returnData,
    required this.paramsCalc,
    required this.dateIn,
    required this.dtOut,
    required this.onTap,
    super.key,
  });
  @override
  _ParkingDetailsState createState() => _ParkingDetailsState();
}

class _ParkingDetailsState extends State<ParkingDetails>
    with TickerProviderStateMixin {
  DateTime? startTime;
  DateTime? endTime;
  int threshold = 30; // minutes
  late Timer _timer;
  double progress = 0.0;
  Duration? timeLeft;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.parse(widget.dateIn.toString());
    endTime = DateTime.parse(widget.dtOut.toString());
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        DateTime currentTime = DateTime.now();
        Duration timeElapsed = currentTime.difference(startTime!);
        Duration totalTime = endTime!.difference(startTime!);
        progress = timeElapsed.inSeconds / totalTime.inSeconds;
        timeLeft = endTime!.difference(DateTime.now());
        if (progress >= 1) {
          _timer.cancel(); // Stop the timer
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
      canPop: true,
      appBarheaderText: "Parking Details",
      appBarIconClick: () {
        Navigator.of(context).pop();
      },
      hasPadding: false,
      child: Column(
        children: [
          Container(height: 10),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFFf5f5f5),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      children: [
                        Container(
                          width: Variables.screenSize.width,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(color: Colors.grey.shade200)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomTitle(
                                        text: widget.returnData[0]
                                                ["park_area_name"]
                                            .toString(),
                                      ),
                                      Container(height: 10),
                                      CustomParagraph(
                                        text: widget.returnData[0]["address"]
                                            .toString(),
                                        maxlines: 2,
                                      )
                                    ],
                                  ),
                                ),
                                Container(width: 5),
                                InkWell(
                                  onTap: () async {
                                    getCurrentLocation();
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: ShapeDecoration(
                                      color: AppColor.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.directions,
                                      size: 20,
                                      color: AppColor.bodyColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomParagraph(
                                      text:
                                          "${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(widget.startTime))} - ${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(widget.endTime))} ",
                                      fontSize: 12,
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: CustomParagraph(
                                        text: timeLeft == null
                                            ? ""
                                            : "${Variables.formatTimeLeft(timeLeft!)}",
                                        fontSize: 12,
                                        color: Colors.grey,
                                        maxlines: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(height: 10),
                              _buildExpiryIndicator(),
                            ],
                          ),
                        ),
                        Container(height: 10),
                      ],
                    ),
                  ),
                  Container(height: 20),
                  Container(
                    width: Variables.screenSize.width,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: Colors.grey.shade200)
                        // shadows: [
                        //   BoxShadow(
                        //     color: Colors.black.withOpacity(0.1),
                        //     spreadRadius: 0,
                        //     blurRadius: 1,
                        //     offset: Offset(0, 2),
                        //   ),
                        // ],
                        ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReceiptBody(
                            amount: widget.resData["amount"].toString(),
                            plateNo: widget.returnData[0]["vehicle_plate_no"]
                                .toString(),
                            startDate: widget.startDate,
                            startTime: widget.startTime,
                            endTime: widget.endTime,
                            hours: widget.resData["no_hours"].toString(),
                            parkArea: widget.returnData[0]["park_area_name"],
                            refno:
                                widget.resData["reservation_ref_no"].toString(),
                          ),
                          Container(height: 20),
                          Row(
                            children: [
                              QrImageView(
                                data: widget.resData["reservation_ref_no"]
                                    .toString(),
                                version: QrVersions.auto,
                                size: 100,
                                gapless: false,
                                backgroundColor: const Color(0xFFffffff),
                              ),
                              VerticalDivider(),
                              Container(width: 20),
                              InkWell(
                                onTap: () {
                                  _shareQrCode();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey.shade100,
                                        child: const Icon(
                                          Icons.ios_share_outlined,
                                          color: Colors.black,
                                          size: 25,
                                        ),
                                      ),
                                      Container(height: 5),
                                      CustomParagraph(
                                        text: "Share",
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(width: 20),
                              InkWell(
                                onTap: () {
                                  saveToGallery();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey.shade100,
                                        child: const Icon(
                                          Icons.download_outlined,
                                          color: Colors.black,
                                          size: 25,
                                        ),
                                      ),
                                      Container(height: 5),
                                      CustomParagraph(
                                        text: "Save",
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: Variables.screenSize.width,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: "Find Vehicle",
                      onTap: () async {
                        String mapUrl = "";
                        String dest =
                            "${widget.resData["pa_latitude"]},${widget.resData["pa_longitude"]}";
                        if (Platform.isIOS) {
                          mapUrl = 'https://maps.apple.com/?daddr=$dest';
                        } else {
                          mapUrl =
                              'https://www.google.com/maps/search/?api=1&query=${widget.resData["pa_latitude"]},${widget.resData["pa_longitude"]}';
                        }
                        if (await canLaunchUrl(Uri.parse(mapUrl))) {
                          await launchUrl(Uri.parse(mapUrl),
                              mode: LaunchMode.externalApplication);
                        } else {
                          throw 'Something went wrong while opening map. Pleaase report problem';
                        }
                      },
                    ),
                  ),
                  Container(width: 10),
                  Expanded(
                      child: CustomButton(
                          label:
                              widget.resData["is_auto_extend"].toString() == "Y"
                                  ? "Cancel auto extend"
                                  : "Extend Parking",
                          onTap:
                              widget.resData["is_auto_extend"].toString() == "Y"
                                  ? cancelAutoExtend
                                  : extendParking))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildExpiryIndicator() {
    if (progress >= 1) {
      return Text(
        'Time has expired!',
        style: TextStyle(fontSize: 20, color: Colors.red),
      );
    } else {
      return Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white,
            minHeight: 5,
            borderRadius: BorderRadius.circular(10),
            valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1 ? Colors.red : AppColor.mainColor),
          ),
        ],
      );
    }
  }

  Widget printScreen() {
    return Container(
      color: AppColor.bodyColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 20,
            ),
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2, color: Color(0x162563EB)),
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: QrImageView(
                    data: widget.resData["reservation_id"].toString(),
                    version: QrVersions.auto,
                    gapless: false,
                  ),
                ),
              ),
            ),
            Container(
              height: 10,
            ),
            Center(
              child: Text(
                "Scan QR code",
                style: CustomTextStyle(
                  color: const Color(0xFF353536),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 0,
                  letterSpacing: -0.36,
                ),
              ),
            ),
            Container(
              height: 5,
            ),
            Text(
              "Scan this code to check-in",
              style: CustomTextStyle(
                color: const Color(0xFF353536),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 0,
                letterSpacing: -0.28,
              ),
            ),
            Container(
              height: 38,
            ),
            ReceiptBody(
              amount: widget.resData["amount"].toString(),
              plateNo: widget.returnData[0]["vehicle_plate_no"].toString(),
              startDate: widget.startDate,
              startTime: widget.startTime,
              endTime: widget.endTime,
              hours: widget.resData["no_hours"].toString(),
              parkArea: widget.returnData[0]["park_area_name"],
              refno: widget.resData["reservation_ref_no"].toString(),
            ),
            Container(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                widget.returnData[0]["park_area_name"],
                style: CustomTextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                widget.returnData[0]["address"].toString(),
                style: CustomTextStyle(
                  color: const Color(0xFF8D8D8D),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
            )
          ],
        ),
      ),
    );
  }

  _shareQrCode() async {
    File? imgFile;
    CustomModal(context: context).loader();

    final directory = (await getApplicationDocumentsDirectory()).path;
    Uint8List bytes = await ScreenshotController().captureFromWidget(
      printScreen(),
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

  void saveToGallery() async {
    CustomModal(context: context).loader();
    ScreenshotController()
        .captureFromWidget(printScreen(), delay: const Duration(seconds: 3))
        .then((image) async {
      final dir = await getApplicationDocumentsDirectory();
      final imagePath = await File('${dir.path}/captured.png').create();
      await imagePath.writeAsBytes(image);

      GallerySaver.saveImage(imagePath.path).then((result) {
        showAlertDialog(context, "Success", "Successfully saved.", () async {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          //getGalleryPackageName();
        });
      });
    });
  }

  void cancelAutoExtend() {
    FocusManager.instance.primaryFocus!.unfocus();

    // ignore: use_build_context_synchronously
    CustomModal(context: context).loader();
    // ignore: use_build_context_synchronously

    HttpRequest(
            api: ApiKeys.gApiLuvPayPutCancelAutoExtend,
            parameters: {"reservation_id": widget.resData["reservation_id"]})
        .put()
        .then((objData) {
      if (objData == "No Internet") {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.pop(context);
        });
        return;
      }
      if (objData == null) {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      }
      if (objData["success"] == "Y") {
        Navigator.pop(context);
        showAlertDialog(
            context, "Success", "Auto extend successfully cancelled.",
            () async {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          widget.onTap!();
        });
      } else {
        Navigator.pop(context);

        showAlertDialog(context, "LuvPark", objData["msg"], () {
          Navigator.of(context).pop();
        });
      }
    });
  }

  void extendParking() async {
    FocusManager.instance.primaryFocus!.unfocus();
    // ignore: prefer_typing_uninitialized_variables
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var akongP = prefs.getString(
      'userData',
    );

    // ignore: use_build_context_synchronously
    CustomModal(context: context).loader();
    // ignore: use_build_context_synchronously
    UserAccount.getUserBal(context, jsonDecode(akongP!)['user_id'].toString(),
        (userBal) {
      Navigator.pop(context);
      if (double.parse(userBal[0]["amount_bal"].toString()) > 20) {
        showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          backgroundColor: AppColor.bodyColor,
          // This makes the sheet full screen
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15.0), // Adjust the radius as needed
            ),
          ),
          builder: (BuildContext context) {
            return CustomDialog(
              amountBal: double.parse(userBal[0]["amount_bal"].toString()),
              paramsCalc: widget.paramsCalc,
              dtOut: widget.dtOut.toString(),
              referenceNo: widget.resData["reservation_ref_no"].toString(),
              icon: Icons.abc,
              detailContext: context,
            );
          },
        );
      } else {
        showAlertDialog(
            context, "Attention", "You don't have enough balance to proceed",
            () {
          Navigator.of(context).pop();
        });
      }
    });
  }

  getCurrentLocation() async {
    LocationService.grantPermission(context, (isGranted) {
      if (isGranted) {
        Functions.getLocation(context, (location) {
          if (mounted) {
            setState(() async {
              String mapUrl = "";
              String dest =
                  "${widget.returnData[0]["park_space_latitude"].toString()},${widget.returnData[0]["park_space_longitude"]}";

              String origin =
                  "${location.latitude.toString()},${location.longitude.toString()}";

              if (Platform.isIOS) {
                mapUrl =
                    'https://maps.apple.com/?daddr=${widget.returnData[0]["park_space_latitude"].toString()},${widget.returnData[0]["park_space_longitude"].toString()}';
              } else {
                mapUrl =
                    "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$dest&travelmode=driving&dir_action=navigate";
              }

              if (await canLaunchUrl(Uri.parse(mapUrl))) {
                await launchUrl(Uri.parse(mapUrl),
                    mode: LaunchMode.externalApplication);
              } else {
                throw 'Something went wrong while opening map. Pleaase report problem';
              }
            });
          }
        });
      }
    });
  }
}
