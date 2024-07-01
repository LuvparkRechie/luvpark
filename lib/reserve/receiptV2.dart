import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/bottom_tab/bottom_tab.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/textstyle.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/rating/rate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

// ignore: must_be_immutable
class ReserveReceipt extends StatefulWidget {
  String spaceName,
      parkArea,
      plateNo,
      startDate,
      endDate,
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
    required this.endDate,
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

class _ReserveReceiptState extends State<ReserveReceipt> {
  bool loadingScreen = true;
  bool isLoadingChkIn = false;
  String myAddress = "";
  BuildContext? mainContext;
  List<Marker> markers = <Marker>[];
  late GoogleMapController mapController;
  List<String> images = [
    'assets/images/marker.png',
    'assets/images/red_marker.png'
  ];

  @override
  void initState() {
    super.initState();
    createMarker();
    showRate();
  }

  @override
  dispose() {
    super.dispose();
  }

  void createMarker() async {
    List<Marker> newMarkers = []; // Create a new list to hold the markers
    Uint8List bytessss = await Variables.capturePng(
        context, printIconMarker("my_marker", Colors.white), 30, false);

    newMarkers.add(
      Marker(
        markerId: MarkerId(widget.parkArea), // Use unique marker ids

        position: LatLng(widget.lat, widget.long),
        icon: BitmapDescriptor.fromBytes(bytessss),
      ),
    );
    setState(() {
      markers.addAll(newMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
      appbarColor: Colors.white,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Variables.pageTrans(
                            const MainLandingScreen(
                              index: 1,
                            ),
                            context);
                      },
                      icon: Icon(
                        Icons.arrow_back_outlined,
                        color: AppColor.textSubColor,
                      ),
                    ),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        saveToGallery();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image(
                            image: AssetImage("assets/images/download.png"),
                            width: 20,
                            height: 20,
                          ),
                          Container(width: 5),
                          CustomDisplayText(
                            label: "Receipt",
                            alignment: TextAlign.center,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7d7e75),
                            fontSize: 14,
                          )
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 100,

                              child: AutoSizeText(
                                "Parking\nreceipt\ndetails",
                                style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1e1c2e),
                                    fontSize: 25,
                                    letterSpacing: .48),
                                textAlign: TextAlign.left,
                              ),

                              //  CustomDisplayText(
                              //   label: "Parking\nreceipt\ndetails",
                              //   alignment: TextAlign.left,
                              //   fontWeight: FontWeight.w600,
                              //   color: Color(0xFF1e1c2e),
                              //   fontSize: 25,
                              // ),
                            ),
                          ),
                          Expanded(
                              child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              height: 100,
                              width: 130,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: GoogleMap(
                                  mapType: MapType.normal,
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    if (mounted) {
                                      setState(() {
                                        mapController = controller;
                                        DefaultAssetBundle.of(context)
                                            .loadString(
                                                'assets/custom_map_style/map_style.json')
                                            .then((String style) {
                                          controller.setMapStyle(style);
                                        });
                                      });
                                    }
                                  },
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(widget.lat, widget.long),
                                    zoom: 15.0,
                                  ),
                                  zoomGesturesEnabled: false,
                                  mapToolbarEnabled: false,
                                  zoomControlsEnabled: false,
                                  myLocationEnabled: false,
                                  myLocationButtonEnabled: false,
                                  compassEnabled: false,
                                  buildingsEnabled: false,
                                  tiltGesturesEnabled: false,
                                  rotateGesturesEnabled: false,
                                  scrollGesturesEnabled: false,
                                  markers: Set<Marker>.of(markers),
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),
                      Container(height: 30),
                      Container(
                        width: Variables.screenSize.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColor.primaryColor,
                                child: CustomDisplayText(
                                  label: "P",
                                  alignment: TextAlign.center,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Container(width: 20),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomDisplayText(
                                    label: widget.parkArea,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  Container(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Iconsax.car,
                                        color: Color(0xFF7d7e75),
                                        size: 16,
                                      ),
                                      Container(width: 10),
                                      CustomDisplayText(
                                        label: widget.plateNo,
                                        alignment: TextAlign.left,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ],
                                  ),
                                  Container(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Iconsax.clock,
                                        color: Color(0xFF7d7e75),
                                        size: 16,
                                      ),
                                      Container(width: 10),
                                      CustomDisplayText(
                                        label:
                                            "${widget.hours} ${int.parse(widget.hours.toString()) > 1 ? "Hours" : "Hour"}",
                                        alignment: TextAlign.left,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ],
                                  )
                                ],
                              )),
                            ],
                          ),
                        ),
                      ),
                      Container(height: 25),
                      CustomDisplayText(
                        label: "Booking Date",
                        alignment: TextAlign.left,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: .4,
                        color: Color(0xFF1e1c2e),
                      ),
                      Container(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: Variables.screenSize.width,
                            child: Row(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: AppColor.primaryColor,
                                      radius: 5,
                                    ),
                                    Dash(
                                        direction: Axis.vertical,
                                        length: 30,
                                        dashLength: 5,
                                        dashThickness: 2.0,
                                        dashColor: AppColor.primaryColor),
                                    CircleAvatar(
                                      backgroundColor: AppColor.primaryColor,
                                      radius: 5,
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          CustomDisplayText(
                                            label: widget.startTime,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Container(width: 10),
                                          CustomDisplayText(
                                            label: convertDateFormat(
                                                widget.startDate),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            overflow: TextOverflow.ellipsis,
                                            color: Color(0xFF7d7e75),
                                          ),
                                        ],
                                      ),
                                      Container(height: 10),
                                      Row(
                                        children: [
                                          CustomDisplayText(
                                            label: widget.endTime,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Container(width: 10),
                                          CustomDisplayText(
                                            label: convertDateFormat(
                                                widget.endDate),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            overflow: TextOverflow.ellipsis,
                                            color: Color(0xFF7d7e75),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(height: 25),
                      Divider(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          QrImageView(
                            data: widget.refno,
                            version: QrVersions.auto,
                            gapless: false,
                            size: 100,
                          ),
                          Container(width: 10),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(height: 30),
                              CustomDisplayText(
                                label: widget.refno,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              Container(height: 5),
                              CustomDisplayText(
                                label: "Reference No",
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF7d7e75),
                              ),
                            ],
                          ))
                        ],
                      ),
                      Container(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            _shareQrCode();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.share,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                Container(width: 5),
                                Text("Share",
                                    style: Platform.isAndroid
                                        ? GoogleFonts.dmSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1,
                                            fontSize: 14)
                                        : TextStyle(
                                            color: Colors.white,
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
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomDisplayText(
                          label: "Total",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        CustomDisplayText(
                          label: toCurrencyString(widget.amount),
                          fontWeight: FontWeight.w600,
                          alignment: TextAlign.left,
                          fontSize: 16,
                        ),
                      ],
                    ),
                    if (Platform.isIOS) Container(height: 20)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget printIconMarker(String imgName, Color color) {
    return Container(
      width: 120, // Set the width to adjust the size of the marker image
      height: 120,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Image(
          fit: BoxFit.contain,
          image: AssetImage(
            "assets/images/$imgName.png",
          ),
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

  String convertDateFormat(String inputDate) {
    // Split the inputDate string by '/'
    List<String> parts = inputDate.split('/');

    // Reformat to desired format: June 29, 2024
    String year = parts[0];
    String month = _getMonthName(int.parse(parts[1]));
    String day = parts[2];

    String formattedDate = '$month $day, $year';
    return formattedDate;
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
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
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
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
            confirmDetails("Vehicle", plateNo.toUpperCase()),
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
