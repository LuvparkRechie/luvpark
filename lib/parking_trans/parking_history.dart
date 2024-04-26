import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/textstyle.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/http_request/http_request_model.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ParkingHistory extends StatefulWidget {
  final List parkingData;
  const ParkingHistory({super.key, required this.parkingData});

  @override
  State<ParkingHistory> createState() => _ParkingHistoryState();
}

class _ParkingHistoryState extends State<ParkingHistory> {
  var histParent = <Widget>[];
  List parkingHistoryData = [];
  bool isLoading = true;
  bool hasInternet = true;
  @override
  void initState() {
    super.initState();
    refresh();
  }

  void displayData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var akongP = prefs.getString(
      'userData',
    );

    String subApi =
        "${ApiKeys.gApiSubFolderGetReservationHistory}?user_id=${jsonDecode(akongP!)['user_id'].toString()}";

    HttpRequest(api: subApi).get().then((parkHistory) async {
      if (parkHistory == "No Internet") {
        setState(() {
          parkingHistoryData = [];
          hasInternet = false;
        });
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });

        return;
      }
      if (parkHistory == null) {
        setState(() {
          parkingHistoryData = [];
          hasInternet = true;
        });
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      }
      if (parkHistory["items"].isNotEmpty) {
        setState(() {
          parkingHistoryData = parkHistory["items"];
          hasInternet = true;
        });
        for (var i = 0; i < parkingHistoryData.length; i++) {
          var items = parkingHistoryData[i];

          setState(() {
            histParent.add(
              historyWidget(items),
            );
          });

          if ((i + 1) == parkingHistoryData.length) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          isLoading = false;
          parkingHistoryData = [];
          hasInternet = true;
        });
      }
    });
  }

  Future<void> refresh() async {
    setState(() {
      isLoading = true;
      hasInternet = true;
      histParent = <Widget>[];
      parkingHistoryData = [];
    });
    displayData();
  }

  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
      canPop: true,
      bodyColor: Colors.grey.shade100,
      appBarheaderText: "Parking History",
      appBarIconClick: () {
        Navigator.pop(context);
      },
      child: !hasInternet
          ? NoInternetConnected(onTap: refresh)
          : Column(
              children: [
                Expanded(
                  child: isLoading
                      ? ListView.builder(
                          itemCount: 10,
                          itemBuilder: ((context, index) {
                            return reserveShimmer();
                          }),
                        )
                      : parkingHistoryData.isEmpty
                          ? Center(
                              child: NoDataFound(
                                onTap: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  displayData();
                                },
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: refresh,
                              child: ListView(
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                children: histParent,
                              ),
                            ),
                ),
              ],
            ),
    );
  }

  Widget reserveShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: const Color(0xFFe6faff),
        child: Container(
          height: 100.0,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: const Color(0xFFffffff),
            border: Border.all(
                style: BorderStyle.solid, color: Colors.grey.shade100),
            borderRadius: const BorderRadius.all(
              Radius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  String convertDateFormat(String dateString) {
    // Parse the original date string
    DateTime originalDate = DateTime.parse(dateString);

    // Format the date to "thu 23 jan" format
    DateFormat newDateFormat = DateFormat('E dd MMM');
    String formattedDate = newDateFormat.format(originalDate);

    return formattedDate;
  }

  Widget historyWidget(data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () {
          CustomModal(context: context).loader();
          var param =
              "${ApiKeys.gApiSubFolderGetDirection}?ref_no=${data["reservation_ref_no"]}";

          HttpRequest(api: param).get().then((returnData) async {
            if (returnData == "No Internet") {
              Navigator.of(context).pop();
              showAlertDialog(context, "Error",
                  "Please check your internet connection and try again.", () {
                Navigator.of(context).pop();
              });
            }
            if (returnData == null) {
              Navigator.of(context).pop();
              showAlertDialog(context, "Error",
                  "Error while connecting to server, Please contact support.",
                  () {
                Navigator.of(context).pop();
              });

              return;
            } else {
              if (returnData["items"].length == 0) {
                Navigator.of(context).pop();
                showAlertDialog(
                    context, "Error", "No data found, Please change location.",
                    () {
                  Navigator.of(context).pop();
                });
              } else {
                Navigator.pop(context);
                var dateInRelated = "";
                var dateOutRelated = "";
                dateInRelated = data["dt_in"];
                dateOutRelated = data["dt_out"];
                Map<String, dynamic> parameters = {
                  "plate_no":
                      returnData["items"][0]["vehicle_plate_no"].toString(),
                  "dt_in": dateInRelated.toString().split(" ")[0].toString() ==
                          dateOutRelated.toString().split(" ")[0].toString()
                      ? Variables.formatDate(
                          dateInRelated.toString().split(" ")[0])
                      : "${Variables.formatDate(dateInRelated.toString().split(" ")[0])} - ${Variables.formatDate(dateOutRelated.toString().split(" ")[0])}",
                  'startTime':
                      dateInRelated.toString().split(" ")[1].toString(),
                  'endTime': dateOutRelated.toString().split(" ")[1].toString(),
                  "duration": int.parse(data["no_hours"].toString()),
                  "ref_no": data["reservation_ref_no"].toString().toString(),
                  "park_area":
                      returnData["items"][0]["park_area_name"].toString(),
                  "amount": data["amount"].toString()
                };

                showModalBottomSheet(
                  context: context,
                  isDismissible: true,
                  enableDrag: true,
                  isScrollControlled: true,
                  // This makes the sheet full screen
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15.0), // Adjust the radius as needed
                    ),
                  ),
                  builder: (BuildContext context) {
                    return ParkingDetails(
                        param: parameters, amount: data["amount"].toString());
                  },
                );
              }
            }
          });
        },
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 68.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                bottom: 10.0, left: 10, right: 10, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomDisplayText(
                        label: data["reservation_ref_no"].toString(),
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        maxLines: 1,
                      ),

                      //  AutoSizeText(
                      //   "Parking Completed",
                      //   style: CustomTextStyle(
                      //       fontSize: 14,
                      //       color: AppColor.mainColor,
                      //       fontWeight: FontWeight.bold),
                      //   maxLines: 1,
                      // ),
                    ),
                    CustomDisplayText(
                      label: toCurrencyString(data["amount"].toString()),
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      maxLines: 1,
                    ),
                  ],
                ),
                Container(height: 22),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      color: Colors.grey.shade400,
                      size: 28,
                    ),
                    Container(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDisplayText(
                          label: convertDateFormat(data["dt_in"]),
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          maxLines: 1,
                        ),
                        CustomDisplayText(
                          label: Variables.convertTime(
                              data["dt_in"].toString().split(" ")[1]),
                          fontSize: 14,
                          color: const Color.fromARGB(255, 137, 140, 148),
                          fontWeight: FontWeight.w500,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    Container(
                      width: 10,
                    ),
                    const Icon(
                      Icons.arrow_right_alt_outlined,
                      color: Color.fromARGB(255, 22, 22, 22),
                      size: 28,
                    ),
                    Container(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDisplayText(
                          label: convertDateFormat(data["dt_out"]),
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          maxLines: 1,
                        ),
                        CustomDisplayText(
                          label: Variables.convertTime(
                              data["dt_out"].toString().split(" ")[1]),
                          fontSize: 14,
                          color: const Color.fromARGB(255, 137, 140, 148),
                          fontWeight: FontWeight.w500,
                          maxLines: 1,
                        ),
                      ],
                    )
                  ],
                ),
                Container(height: 11),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ParkingDetails extends StatefulWidget {
  final Map<String, dynamic> param;
  final String amount;
  const ParkingDetails({super.key, required this.param, required this.amount});

  @override
  State<ParkingDetails> createState() => _ParkingDetailsState();
}

class _ParkingDetailsState extends State<ParkingDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: Wrap(
        children: [
          Center(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          width: 64,
                          height: 7,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFD9D9D9),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)),
                          ),
                        ),
                      ),
                      Container(height: 10),
                      const Align(
                        alignment: Alignment.bottomLeft,
                        child: Image(
                            width: 50,
                            height: 50,
                            image: AssetImage(
                                "assets/images/luvpark_transparent.png")),
                      ),
                      Container(height: 15),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CustomDisplayText(
                          label: widget.param["park_area"].toString(),
                          color: const Color(0xFF353536),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 0,
                          letterSpacing: -0.32,
                        ),
                      ),
                      Container(
                        height: 5,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CustomDisplayText(
                          label: "Parking Area",
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        height: 15,
                      ),
                      backup(),
                      Container(
                        height: 30,
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
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
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
                    toCurrencyString(widget.amount.toString()),
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
            confirmDetails("Vehicle", widget.param["plate_no"].toString()),
            Container(
              height: 10,
            ),
            confirmDetails("Date In-Out", widget.param["dt_in"].toString()),
            Container(
              height: 10,
            ),
            confirmDetails("Time In-Out",
                "${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(widget.param["startTime"].toString()))} - ${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(widget.param["endTime"].toString()))}"),
            Container(
              height: 10,
            ),
            // confirmDetails("Duration",
            //     "${widget.hours} ${int.parse(widget.hours) > 1 ? "hrs" : "hr"}"),
            // Container(
            //   height: 10,
            // ),
            confirmDetails("Reference", widget.param["ref_no"].toString()),
            Container(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _myWidget() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 50),
            Align(
              alignment: Alignment.centerLeft,
              child: CustomDisplayText(
                label: widget.param["park_area"].toString(),
                color: const Color(0xFF353536),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 0,
                letterSpacing: -0.32,
              ),
            ),
            Container(
              height: 5,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: CustomDisplayText(
                  label: "Parking Area",
                  fontSize: 12,
                  color: const Color.fromARGB(255, 137, 140, 148),
                  fontWeight: FontWeight.w600),
            ),
            Container(
              height: 30,
            ),
            // confirmDetails(
            //     "Date In/Out",
            //     DateFormat('dd-MM-yyyy hh:mm a')
            //         .format(DateTime.parse(widget.param["dt_in"].toString()))
            //         .toString()),
            // confirmDetails("Time In/Out",
            //     "${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(widget.param["startTime"].toString()))} - ${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(widget.param["endTime"].toString()))}"),
            // confirmDetails("Reference No", widget.param["ref_no"].toString()),
            confirmDetails("Vehicle", widget.param["plate_no"].toString()),
            Container(
              height: 10,
            ),
            confirmDetails("Date In-Out", widget.param["dt_in"].toString()),
            Container(
              height: 10,
            ),
            confirmDetails("Time In-Out",
                "${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(widget.param["startTime"].toString()))} - ${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(widget.param["endTime"].toString()))}"),
            Container(
              height: 10,
            ),
            // confirmDetails("Duration",
            //     "${widget.hours} ${int.parse(widget.hours) > 1 ? "hrs" : "hr"}"),
            // Container(
            //   height: 10,
            // ),
            confirmDetails("Reference", widget.param["ref_no"].toString()),
            Container(
              height: 18,
            ),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color.fromARGB(255, 245, 250, 254),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    const Image(
                      width: 25,
                      height: 25,
                      image:
                          AssetImage("assets/images/luvpark_transparent.png"),
                    ),
                    Container(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomDisplayText(
                        label: "Total Paid",
                        color: const Color(0xFF353536),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: -0.32,
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      width: 20,
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: CustomDisplayText(
                                label: toCurrencyString(
                                    widget.param["amount"].toString()),
                                color: const Color(0xFF353536),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.32,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: CustomDisplayText(
                                label: "Token",
                                color: const Color.fromARGB(255, 137, 140, 148),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                height: 0,
                                letterSpacing: -0.20,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget confirmDetails(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: CustomDisplayText(
              label: label,
              fontWeight: FontWeight.normal,
              color: Colors.black54,
              maxLines: 1,
              alignment: TextAlign.left,
            ),
          ),
          Expanded(
            child: CustomDisplayText(
              label: value,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  _shareQrCode() async {
    File? imgFile;
    CustomModal(context: context).loader();

    final directory = (await getApplicationDocumentsDirectory()).path;
    Uint8List bytes = await ScreenshotController().captureFromWidget(
      _myWidget(),
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
        .captureFromWidget(_myWidget(), delay: const Duration(seconds: 3))
        .then((image) async {
      final dir = await getApplicationDocumentsDirectory();
      final imagePath = await File('${dir.path}/captured.png').create();
      await imagePath.writeAsBytes(image);

      GallerySaver.saveImage(imagePath.path).then((result) {
        showAlertDialog(context, "Success", "Successfully saved", () async {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          //getGalleryPackageName();
        });
      });
    });
  }
}
