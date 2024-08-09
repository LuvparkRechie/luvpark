import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_shimmer.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:luvpark/reserve/parking_details.dart';
import 'package:luvpark/reserve/receiptV2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class ParkingActivity extends StatefulWidget {
  final int tabIndex;
  const ParkingActivity({
    super.key,
    required this.tabIndex,
  });

  @override
  State<ParkingActivity> createState() => _ParkingActivityState();
}

class _ParkingActivityState extends State<ParkingActivity>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentTab = 0;
  bool clicked = false;
  bool hasInternetResData = true;
  bool loadingResData = false;

  List reservedData = [];
  List reservedsubData = [];
  var akongP;
  BuildContext? myContext;
  String paramStatus = "C";
  bool isAllowToSync = true;
  // final _dataController = StreamController<void>();
  // late StreamSubscription<void> _dataSubscription;

  late StreamController<void> _dataController;
  late StreamSubscription<void> _dataSubscription;

  @override
  void initState() {
    clicked = false;
    _dataController = StreamController<void>();
    _tabController = TabController(
      length: 2, // Number of tabs
      vsync: this,
    );
    _tabController.index = widget.tabIndex;
    currentTab = widget.tabIndex;
    _tabController.addListener(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      onRefresh();
    });
    streamData();

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dataSubscription.cancel();
    _dataController.close();

    super.dispose();
  }

  void streamData() {
    _dataSubscription = _dataController.stream.listen((data) {});
    fetchDataPeriodically();
  }

  void fetchDataPeriodically() async {
    _dataSubscription = Stream.periodic(const Duration(seconds: 20), (count) {
      fetchData();
    }).listen((event) {});
  }

  Future<void> fetchData() async {
    await Future.delayed(const Duration(seconds: 5));
    if (isAllowToSync) {
      onRefresh();
    }
  }

  void getReservation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    akongP = prefs.getString(
      'userData',
    );
    HttpRequest(
            api:
                "${ApiKeys.gApiSubFolderGetReservations}?user_id=${jsonDecode(akongP!)['user_id'].toString()}")
        .get()
        .then((returnData) async {
      if (mounted) {
        setState(() {
          isAllowToSync = true;
        });
      }
      if (returnData == "No Internet") {
        if (mounted) {
          setState(() {
            hasInternetResData = false;
            loadingResData = false;
            reservedData = [];
            reservedsubData = [];
          });
        }
        return;
      }
      if (returnData == null) {
        if (mounted) {
          setState(() {
            hasInternetResData = true;
            loadingResData = false;
            reservedData = [];
            reservedsubData = [];
          });
        }

        return;
      } else {
        if (returnData["items"].length == 0) {
          if (mounted) {
            setState(() {
              reservedData = [];
              hasInternetResData = true;
              loadingResData = false;
              reservedsubData = [];
            });
          }
        } else {
          if (mounted) {
            if (currentTab == 0) {
              setState(() {
                reservedData = returnData["items"].where((element) {
                  return element["is_active"] == "Y" &&
                      element["status"] == "C";
                }).toList();
                hasInternetResData = true;
                loadingResData = false;
              });
            } else {
              setState(() {
                reservedData = returnData["items"].where((element) {
                  return element["is_active"] == "Y" &&
                      element["status"] == "U";
                }).toList();
                hasInternetResData = true;
                loadingResData = false;
              });
            }
          }
        }
      }
    });
  }

  List formattedDate(String date) {
    List dataD = [];
    String formattedDate =
        DateFormat.yMMMEd().format(DateTime.parse(date.toString()));
    String time = DateFormat('kk:mm:a').format(DateTime.parse(date.toString()));

    var splittedDate = formattedDate.split(",");
    dataD.add({
      "day_name": splittedDate[0].toString().trim(),
      "day_value": splittedDate[1].split(" ")[2].toString().trim(),
      "complete_date": "${splittedDate[1].trim()}, ${splittedDate[2].trim()}",
      "time": time.trim()
    });
    return dataD;
  }

  Future<void> onRefresh() async {
    if (mounted) {
      setState(() {
        loadingResData = true;
        hasInternetResData = true;
        isAllowToSync = false;
        reservedData = [];
        reservedsubData = [];
      });

      getReservation();
    }
  }

  @override
  Widget build(BuildContext context) {
    myContext = context;

    return Sizer(builder: (context, orientation, deviceType) {
      return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1)),
        child: PopScope(
          canPop: false,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: CustomTitle(
                text: "My Parking",
                color: Colors.white,
                letterSpacing: -0.41,
                fontSize: 20,
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColor.primaryColor,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: AppColor.primaryColor,
                statusBarBrightness: Brightness.dark,
                statusBarIconBrightness: Brightness.light,
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                          color: Color(0xFF0D62C3),
                        ),
                        child: TabBar(
                          onTap: (value) {
                            if (currentTab == value) return;
                            setState(() {
                              currentTab = value;
                            });
                            print("currentTab $currentTab");
                            if (currentTab == 0) {
                              setState(() {
                                paramStatus = "C";
                              });
                            } else {
                              setState(() {
                                paramStatus = "U";
                              });
                            }
                            onRefresh();
                          },
                          controller: _tabController,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                            color: Color(0xFF269DF1),
                          ),
                          tabs: [
                            Tab(
                              child: CustomParagraph(
                                text: 'Reservations',
                                color: currentTab == 0
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                            Tab(
                              child: CustomParagraph(
                                text: 'Active Parking',
                                color: currentTab == 1
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: !hasInternetResData
                          ? NoInternetConnected(onTap: () {
                              setState(() {
                                loadingResData = true;
                                hasInternetResData = true;
                              });
                              Future.delayed(const Duration(seconds: 1), () {
                                getReservation();
                              });
                            })
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: loadingResData
                                      ? ListView.separated(
                                          padding: EdgeInsets.only(top: 10),
                                          itemBuilder: (context, index) {
                                            return CustomShimmer();
                                          },
                                          separatorBuilder: (context, index) {
                                            return SizedBox(
                                              height: 5,
                                            );
                                          },
                                          itemCount: 5)
                                      : reservedData.isEmpty
                                          ? NoDataFound(
                                              onTap: () {
                                                setState(() {
                                                  loadingResData = true;
                                                });

                                                Future.delayed(
                                                    const Duration(seconds: 1),
                                                    () {
                                                  getReservation();
                                                });
                                              },
                                            )
                                          : RefreshIndicator(
                                              onRefresh: onRefresh,
                                              child: ListView.separated(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  itemBuilder:
                                                      (context, index) {
                                                    String title =
                                                        reservedData[index]
                                                            ["notes"];
                                                    String subTitle =
                                                        reservedData[index][
                                                            "reservation_ref_no"];
                                                    String date = Variables
                                                        .convertDateFormat(
                                                            reservedData[index]
                                                                ["dt_in"]);
                                                    String time =
                                                        "${Variables.convertTime(reservedData[index]["dt_in"].toString().split(" ")[1])} - ${Variables.convertTime(reservedData[index]["dt_out"].toString().split(" ")[1])}";
                                                    String totalAmt =
                                                        toCurrencyString(
                                                            reservedData[index]
                                                                    ["amount"]
                                                                .toString());
                                                    String status = reservedData[
                                                                    index]
                                                                ["status"] ==
                                                            "U"
                                                        ? "${reservedData[index]["is_auto_extend"].toString() == "Y" ? "EXTENDED" : "ACTIVE"} PARKING"
                                                        : "CONFIRMED";
                                                    String userId = jsonDecode(
                                                            akongP!)['user_id']
                                                        .toString();

                                                    return ListCard(
                                                      title: title,
                                                      subTitle: subTitle,
                                                      date: date,
                                                      time: time,
                                                      totalAmt: totalAmt,
                                                      status: status,
                                                      data: reservedData[index],
                                                      userId: userId,
                                                      currentTab: currentTab,
                                                      onRefresh: onRefresh,
                                                    );
                                                  },
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          const SizedBox(
                                                            height: 15,
                                                          ),
                                                  itemCount:
                                                      reservedData.length),
                                            ),
                                ),
                                Container()
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class ListCard extends StatelessWidget {
  final String title, subTitle, date, time, totalAmt, status, userId;
  final int currentTab;
  final dynamic data;
  final Function onRefresh;
  const ListCard(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.date,
      required this.time,
      required this.totalAmt,
      required this.status,
      required this.data,
      required this.userId,
      required this.currentTab,
      required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                "client_id": userId,
                "park_area_id": returnData["items"][0]["park_area_id"],
                "vehicle_type_id": returnData["items"][0]["vehicle_type_id"],
                "vehicle_plate_no":
                    returnData["items"][0]["vehicle_plate_no"].toString(),
                "dt_in": dateInRelated,
                "dt_out": dateOutRelated,
                "no_hours": int.parse(data["no_hours"].toString()),
                "tran_type": "E",
              };
              if (data["status"].toString() == "C") {
                Variables.pageTrans(
                    ReserveReceipt(
                      isVehicleSelected: false,
                      spaceName:
                          returnData["items"][0]["park_space_name"].toString(),
                      parkArea:
                          returnData["items"][0]["park_area_name"].toString(),
                      startDate: Variables.formatDate(
                          dateInRelated.toString().split(" ")[0]),
                      endDate: Variables.formatDate(
                          dateOutRelated.toString().split(" ")[0]),
                      startTime:
                          dateInRelated.toString().split(" ")[1].toString(),
                      endTime:
                          dateOutRelated.toString().split(" ")[1].toString(),
                      plateNo:
                          returnData["items"][0]["vehicle_plate_no"].toString(),
                      hours: data["no_hours"].toString(),
                      amount: data["amount"].toString(),
                      refno: data["reservation_ref_no"].toString().toString(),
                      lat: double.parse(returnData["items"][0]
                              ["park_space_latitude"]
                          .toString()),
                      long: double.parse(returnData["items"][0]
                              ["park_space_longitude"]
                          .toString()),
                      dtOut: dateOutRelated,
                      dateIn: dateInRelated,
                      isReserved: true,
                      tab: currentTab,
                      canReserved: true,
                      paramsCalc: parameters,
                      address: returnData["items"][0]["address"],
                      ticketId: returnData["items"][0]["ticket_id"],
                      isAutoExtend: data["is_auto_extend"].toString(),
                      reservationId: data["reservation_id"],
                      onTap: () {
                        onRefresh();
                      },
                    ),
                    context);
              } else {
                Variables.pageTrans(
                    ParkingDetails(
                      startDate: dateInRelated
                                  .toString()
                                  .split(" ")[0]
                                  .toString() ==
                              dateOutRelated.toString().split(" ")[0].toString()
                          ? Variables.formatDate(
                              dateInRelated.toString().split(" ")[0])
                          : "${Variables.formatDate(dateInRelated.toString().split(" ")[0])} - ${Variables.formatDate(dateOutRelated.toString().split(" ")[0])}",
                      startTime:
                          dateInRelated.toString().split(" ")[1].toString(),
                      endTime:
                          dateOutRelated.toString().split(" ")[1].toString(),
                      resData: data,
                      returnData: returnData["items"],
                      dtOut: dateOutRelated,
                      dateIn: dateInRelated,
                      paramsCalc: parameters,
                      onTap: () {
                        onRefresh();
                      },
                    ),
                    context);
              }
            }
          }
        });
      },
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Color(0xFFE8E6E6)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Image(
                      image: AssetImage(
                        "assets/dashboard_icon/res_confirm.png",
                      ),
                      fit: BoxFit.contain,
                      width: 34,
                      height: 34,
                    ),
                    title: CustomTitle(
                      text: title,
                      color: AppColor.primaryColor,
                      letterSpacing: -0.41,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    subtitle: CustomParagraph(
                      text: subTitle,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.41,
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 30,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 35.50,
                        height: 35.50,
                        child: Image(
                          image:
                              AssetImage("assets/dashboard_icon/calendar.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                      Container(width: 8),
                      CustomParagraph(
                        text: date,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.41,
                      ),
                      Container(width: 15),
                      Flexible(
                        child: Row(
                          children: [
                            Container(
                              width: 35.50,
                              height: 35.50,
                              child: Image(
                                image: AssetImage(
                                    "assets/dashboard_icon/clock.png"),
                                fit: BoxFit.contain,
                              ),
                            ),
                            Container(width: 8),
                            Flexible(
                              child: CustomParagraph(
                                text: time,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.41,
                                maxlines: 1,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                  color: Color(0xFF2495eb),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(10))),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTitle(
                      text: "Total Paid",
                      color: Colors.white,
                      letterSpacing: -0.41,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  CustomTitle(
                    text: totalAmt,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.41,
                    fontSize: 14,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DottedMiddlePath extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 3;
    double dashSpace = 4;
    double startY = 10;
    final paint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;

    while (startY < size.height - 10) {
      canvas.drawCircle(Offset(size.width / 5, startY), 2, paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class DottedInitialPath extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 3;
    double dashSpace = 4;
    double startY = 10;
    final paint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;

    while (startY < size.height - 10) {
      canvas.drawCircle(Offset(0, startY), 2, paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class SideCutsDesign extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var h = size.height;
    var w = size.width;

    canvas.drawArc(
        Rect.fromCircle(center: Offset(0, h / 2), radius: 18),
        0,
        10,
        false,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.grey.shade100);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(w, h / 2), radius: 18),
        0,
        10,
        false,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.grey.shade100);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(w / 5, h), radius: 7),
        0,
        10,
        false,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.grey.shade100);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(w / 5, 0), radius: 7),
        0,
        10,
        false,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.grey.shade100);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(0, h), radius: 7),
        0,
        10,
        false,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.grey.shade100);
    canvas.drawArc(
        Rect.fromCircle(center: const Offset(0, 0), radius: 7),
        0,
        10,
        false,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.grey.shade100);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
