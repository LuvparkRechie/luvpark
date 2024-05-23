import 'dart:convert';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:app_settings/app_settings.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/bottom_tab/bottom_tab.dart';
import 'package:luvpark/class/get_user_bal.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/textstyle.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/rating/rate.dart';
import 'package:luvpark/reserve/extend_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ReserveReceipt extends StatefulWidget {
  String spaceName,
      parkArea,
      plateNo,
      startDate,
      startTime,
      endTime,
      hours,
      amount,
      refno;
  final Function? onTap;
  final bool isReserved;
  final String? dtOut, dateIn;
  final String isAutoExtend;
  final String address;
  final double lat, long;
  final bool canReserved;
  final int tab;
  final Object paramsCalc;
  bool isVehicleSelected;
  final bool? isShowRate;
  final int? reservationId;
  final int? ticketId;

  ReserveReceipt({
    required this.spaceName,
    required this.parkArea,
    required this.plateNo,
    required this.isReserved,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.hours,
    required this.amount,
    required this.refno,
    required this.lat,
    required this.long,
    required this.isVehicleSelected,
    required this.canReserved,
    required this.paramsCalc,
    required this.tab,
    required this.address,
    required this.isAutoExtend,
    this.onTap,
    this.isShowRate = false,
    this.reservationId = 0,
    this.ticketId = 0,
    this.dtOut,
    this.dateIn,
    super.key,
  });

  @override
  State<ReserveReceipt> createState() => _ReserveReceiptState();
}

class _ReserveReceiptState extends State<ReserveReceipt>
    with SingleTickerProviderStateMixin {
  OverlayEntry? overlayEntry;
  late Animation<Color?> animation;
  late GoogleMapController mapController;
  // ignore: prefer_typing_uninitialized_variables
  var startLocation;
  bool loadingScreen = true;
  bool isLoadingChkIn = false;
  String myAddress = "";
  BuildContext? mainContext;
  List<Marker> markers = <Marker>[];
  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  List<String> images = [
    'assets/images/marker.png',
    'assets/images/red_marker.png'
  ];

  @override
  void initState() {
    super.initState();
    showRate();
  }

  @override
  dispose() {
    super.dispose();
  }

  getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() async {
        String mapUrl = "";
        String dest = "${widget.lat},${widget.long}";
        String origin =
            "${position.latitude.toString()},${position.longitude.toString()}";

        if (Platform.isIOS) {
          mapUrl = 'https://maps.apple.com/?daddr=${widget.lat},${widget.long}';
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
      // Use the position data
    } catch (e) {
      // ignore: use_build_context_synchronously
    }
  }

  Future<Position> locatePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      showPlatformDialog(
        context: context,
        builder: (_) => BasicDialogAlert(
          title: const Text("Current Location Not Available"),
          content: const Text(
              "Your current location cannot be determined at this time."),
          actions: <Widget>[
            BasicDialogAction(
              title: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
      return Future.error('Location services are disabled.');
    } else if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      // ignore: use_build_context_synchronously
      showPlatformDialog(
        context: context,
        builder: (_) => BasicDialogAlert(
          title: const Text("Permission Status"),
          content: const Text(
              "Location permissions are denied.\nWe need to request your permission to use google map"),
          actions: <Widget>[
            BasicDialogAction(
              title: const Text("OK"),
              onPressed: () {
                AppSettings.openAppSettings();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
      return Future.error('Location permissions are denied');
    }
    return await Geolocator.getCurrentPosition();
  }

  void showRate() {
    if (widget.isShowRate!) {
      Future.delayed(const Duration(milliseconds: 500), () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                content: FadeIn(
                    duration: const Duration(seconds: 1),
                    child: RateUs(
                        reservationId: widget.reservationId, callBack: () {})),
              ),
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    mainContext = context;
    return CustomParent1Widget(
      canPop: true,
      appBarheaderText: "Parking Ticket",
      appBarIconClick: () {
        Variables.pageTrans(
            const MainLandingScreen(
              index: 1,
            ),
            context);
      },
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 20,
            ),
            widget.tab == 1
                ? Container()
                : Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 2, color: Color(0x162563EB)),
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: QrImageView(
                          data: widget.refno,
                          version: QrVersions.auto,
                          gapless: false,
                        ),
                      ),
                    ),
                  ),
            widget.tab == 1
                ? Container()
                : Container(
                    height: 10,
                  ),
            widget.tab == 1
                ? Container()
                : Center(
                    child: CustomDisplayText(
                      label: "Scan QR code",
                      color: const Color(0xFF353536),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 0,
                      letterSpacing: -0.36,
                    ),
                  ),
            widget.tab == 1
                ? Container()
                : Container(
                    height: 5,
                  ),
            widget.tab == 1
                ? Container()
                : CustomDisplayText(
                    label: "Scan this code to check-in",
                    color: const Color(0xFF353536),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 0,
                    letterSpacing: -0.28,
                  ),
            widget.tab == 1
                ? Container()
                : Container(
                    height: 38,
                  ),
            ReceiptBody(
              amount: widget.amount,
              plateNo: widget.plateNo,
              startDate: widget.startDate,
              startTime: widget.startTime,
              endTime: widget.endTime,
              hours: widget.hours,
              parkArea: widget.parkArea,
              refno: widget.refno,
            ),
            Container(
              height: 10,
            ),
            // Padding(
            //   padding:
            //       const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             CustomDisplayText(
            //               label: widget.parkArea,
            //               color: Colors.black,
            //               fontSize: 16,
            //               fontWeight: FontWeight.bold,
            //               maxLines: 1,
            //             ),
            //             Container(height: 5),
            //             CustomDisplayText(
            //               label: widget.address,
            //               color: const Color(0xFF8D8D8D),
            //               fontSize: 14,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ],
            //         ),
            //       ),
            //       Container(
            //         width: 10,
            //       ),
            //       InkWell(
            //         onTap: () async {
            //           var permissionStatus = await Geolocator.checkPermission();

            //           if ((permissionStatus == LocationPermission.whileInUse ||
            //                   permissionStatus == LocationPermission.always) &&
            //               await Geolocator.isLocationServiceEnabled()) {
            //             getCurrentLocation();
            //           } else {
            //             locatePosition();
            //           }
            //         },
            //         child: Container(
            //           width: 30,
            //           height: 30,
            //           decoration: ShapeDecoration(
            //             color: const Color(0x160078FF),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(
            //                 12,
            //               ),
            //             ),
            //           ),
            //           child: Icon(
            //             Icons.directions,
            //             size: 20,
            //             color: AppColor.primaryColor,
            //           ),
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            // Container(
            //   height: 20,
            // ),
            if (widget.isReserved && int.parse(widget.tab.toString()) == 0)
              CustomButton(
                  label: "Check-in",
                  onTap: () async {
                    CustomModal(context: context).loader();
                    Functions.getUserBalance((data) async {
                      if (data != "null" || data != "No Internet") {
                        Functions.computeDistanceResorChckIN(
                            context, LatLng(widget.lat, widget.long),
                            (success) {
                          if (success["success"]) {
                            if (success["can_checkIn"]) {
                              Functions.checkIn(
                                  widget.ticketId, widget.lat, widget.long,
                                  (cbData) {
                                Navigator.pop(context);
                                if (cbData == "Success") {
                                  showAlertDialog(context, "Success",
                                      "Successfully checked-in.", () {
                                    Navigator.of(context).pop();
                                    Variables.pageTrans(
                                        const MainLandingScreen(
                                          index: 1,
                                        ),
                                        context);
                                  });
                                }
                              });
                            } else {
                              Navigator.pop(context);
                              showAlertDialog(
                                  context, "LuvPark", success["message"], () {
                                Navigator.of(context).pop();
                              });
                            }
                          } else {
                            Navigator.pop(context);
                          }
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    });
                  }),
            if (widget.isReserved &&
                int.parse(widget.tab.toString()) == 1 &&
                widget.isAutoExtend == "N")
              CustomButton(
                label: "Extend Parking",
                onTap: () async {
                  FocusManager.instance.primaryFocus!.unfocus();
                  // ignore: prefer_typing_uninitialized_variables
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  var akongP = prefs.getString(
                    'userData',
                  );

                  // ignore: use_build_context_synchronously
                  CustomModal(context: context).loader();
                  // ignore: use_build_context_synchronously
                  UserAccount.getUserBal(
                      context, jsonDecode(akongP!)['user_id'].toString(),
                      (userBal) {
                    Navigator.pop(context);
                    if (double.parse(userBal[0]["amount_bal"].toString()) >
                        20) {
                      showModalBottomSheet(
                        context: context,
                        isDismissible: false,
                        enableDrag: false,
                        isScrollControlled: true,
                        backgroundColor: AppColor.bodyColor,
                        // This makes the sheet full screen
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(
                                15.0), // Adjust the radius as needed
                          ),
                        ),
                        builder: (BuildContext context) {
                          return CustomDialog(
                            amountBal: double.parse(
                                userBal[0]["amount_bal"].toString()),
                            paramsCalc: widget.paramsCalc,
                            dtOut: widget.dtOut.toString(),
                            referenceNo: widget.refno,
                            icon: Icons.abc,
                            detailContext: context,
                          );
                        },
                      );
                    } else {
                      showAlertDialog(context, "Attention",
                          "You don't have enough balance to proceed", () {
                        Navigator.of(context).pop();
                      });
                    }
                  });
                },
              ),
            if (widget.isReserved &&
                int.parse(widget.tab.toString()) == 1 &&
                widget.isAutoExtend == "Y")
              CustomButton(
                label: "Cancel Auto Extend",
                onTap: () async {
                  FocusManager.instance.primaryFocus!.unfocus();

                  // ignore: use_build_context_synchronously
                  CustomModal(context: context).loader();
                  // ignore: use_build_context_synchronously
                  HttpRequest(
                          api: ApiKeys.gApiLuvPayPutCancelAutoExtend,
                          parameters: {"reservation_id": widget.reservationId})
                      .put()
                      .then((objData) {
                    if (objData == "No Internet") {
                      Navigator.pop(context);
                      showAlertDialog(context, "Error",
                          "Please check your internet connection and try again.",
                          () {
                        Navigator.pop(context);
                      });
                      return;
                    }
                    if (objData == null) {
                      Navigator.pop(context);
                      showAlertDialog(context, "Error",
                          "Error while connecting to server, Please try again.",
                          () {
                        Navigator.of(context).pop();
                      });
                    }
                    if (objData["success"] == "Y") {
                      Navigator.pop(context);
                      showAlertDialog(context, "Success",
                          "Auto extend successfully cancelled.", () async {
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
                },
              ),
            Container(
              height: 20,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.ios_share_outlined,
                              color: Colors.black,
                              size: 25,
                            ),
                            Text("Share",
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
                                      )),
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
                          mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
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
            widget.tab == 1
                ? Container()
                : Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 2, color: Color(0x162563EB)),
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: QrImageView(
                          data: widget.refno,
                          version: QrVersions.auto,
                          gapless: false,
                        ),
                      ),
                    ),
                  ),
            widget.tab == 1
                ? Container()
                : Container(
                    height: 10,
                  ),
            widget.tab == 1
                ? Container()
                : Center(
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
            widget.tab == 1
                ? Container()
                : Container(
                    height: 5,
                  ),
            widget.tab == 1
                ? Container()
                : Text(
                    "Scan this code to check-in",
                    style: CustomTextStyle(
                      color: const Color(0xFF353536),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 0,
                      letterSpacing: -0.28,
                    ),
                  ),
            widget.tab == 1
                ? Container()
                : Container(
                    height: 38,
                  ),
            ReceiptBody(
              amount: widget.amount,
              plateNo: widget.plateNo,
              startDate: widget.startDate,
              startTime: widget.startTime,
              endTime: widget.endTime,
              hours: widget.hours,
              parkArea: widget.parkArea,
              refno: widget.refno,
            ),
            Container(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                widget.parkArea,
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
                myAddress,
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
}

class ReceiptBody extends StatelessWidget {
  final String amount,
      plateNo,
      startDate,
      startTime,
      endTime,
      hours,
      refno,
      parkArea;
  const ReceiptBody(
      {super.key,
      required this.amount,
      required this.plateNo,
      required this.startDate,
      required this.startTime,
      required this.endTime,
      required this.hours,
      required this.parkArea,
      required this.refno});

  @override
  Widget build(BuildContext context) {
    return backup();
  }

  Widget backup() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF8F8F8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Total Token',
                  style: CustomTextStyle(
                    color: const Color(0xFF353536),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 0,
                    letterSpacing: -0.32,
                  ),
                ),
                Expanded(
                  child: Text(
                    toCurrencyString(amount),
                    style: CustomTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 0,
                      letterSpacing: -0.32,
                    ),
                    textAlign: TextAlign.right,
                    softWrap: true,
                  ),
                )
              ],
            ),
            const Divider(),
            Container(
              height: 10,
            ),
            confirmDetails("Vehicle", plateNo),
            Container(
              height: 10,
            ),
            confirmDetails("Date In-Out", startDate),
            Container(
              height: 10,
            ),
            confirmDetails("Time In-Out",
                "${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(startTime))} - ${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(endTime))}"),
            Container(
              height: 10,
            ),
            confirmDetails(
                "Duration", "$hours ${int.parse(hours) > 1 ? "hrs" : "hr"}"),
            Container(
              height: 10,
            ),
            confirmDetails("Reference", refno.toString()),
            Container(
              height: 10,
            ),
            confirmDetails("Parking Zone", parkArea.toString()),
            Container(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget confirmDetails(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: AutoSizeText(
            label,
            style: CustomTextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
            textAlign: TextAlign.left,
            softWrap: true,
            maxLines: 1,
            minFontSize: 1,
          ),
        ),
        Expanded(
          child: AutoSizeText(
            value,
            style: CustomTextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            softWrap: true,
            maxLines: 1,
            minFontSize: 1,
          ),
        ),
      ],
    );
  }
}
