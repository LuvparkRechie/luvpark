import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/broken_line.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:luvpark/reserve/parking_details.dart';
import 'package:luvpark/reserve/receiptV2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
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
          child: CustomParent1Widget(
            appBarheaderText: "",
            appBarTabBar: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: AppColor.primaryColor, // Indicator color
              indicatorWeight: 4, // Indicator thickness

              onTap: (value) {
                if (currentTab == value) return;
                setState(() {
                  currentTab = value;
                });
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
              tabs: [
                Tab(
                  child: CustomDisplayText(
                      label: 'Reservations',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 16),
                ),
                Tab(
                    child: CustomDisplayText(
                        label: 'Active Parking',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 16)),
              ],
            ),
            child: SafeArea(
              child: Container(
                //  color: Color.fromARGB(255, 249, 248, 248),
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
                                ? ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    itemCount: 10,
                                    itemBuilder: ((context, index) {
                                      return reserveShimmer();
                                    }),
                                  )
                                : reservedData.isEmpty
                                    ? NoDataFound(
                                        onTap: () {
                                          setState(() {
                                            loadingResData = true;
                                          });

                                          Future.delayed(
                                              const Duration(seconds: 1), () {
                                            getReservation();
                                          });
                                        },
                                      )
                                    : RefreshIndicator(
                                        onRefresh: onRefresh,
                                        child: ListView.separated(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            itemBuilder: (context, index) {
                                              return Container(
                                                width:
                                                    Variables.screenSize.width,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade200,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20.0),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .calendar,
                                                                      color: AppColor
                                                                          .mainColor,
                                                                    ),
                                                                    Container(
                                                                        width:
                                                                            10),
                                                                    Flexible(
                                                                        child:
                                                                            CustomDisplayText(
                                                                      label: Variables.convertDateFormat(
                                                                          reservedData[index]
                                                                              [
                                                                              "dt_in"]),
                                                                      fontSize:
                                                                          14,
                                                                      maxLines:
                                                                          1,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ))
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: reservedData[index]
                                                                              [
                                                                              "status"] ==
                                                                          "U"
                                                                      ? reservedData[index]["is_auto_extend"].toString() ==
                                                                              "Y"
                                                                          ? Colors.purple.withOpacity(
                                                                              .1)
                                                                          : AppColor.mainColor.withOpacity(
                                                                              .1)
                                                                      : const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          243,
                                                                          228,
                                                                          206),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5,
                                                                      vertical:
                                                                          3),
                                                                  child: Center(
                                                                    child:
                                                                        CustomDisplayText(
                                                                      label: reservedData[index]["status"] ==
                                                                              "U"
                                                                          ? "${reservedData[index]["is_auto_extend"].toString() == "Y" ? "EXTENDED" : "ACTIVE"} PARKING"
                                                                          : "CONFIRMED",
                                                                      fontSize:
                                                                          12,
                                                                      color: reservedData[index]["status"] ==
                                                                              "U"
                                                                          ? reservedData[index]["is_auto_extend"].toString() == "Y"
                                                                              ? Colors.purple
                                                                              : AppColor.mainColor
                                                                          : Colors.orange,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      maxLines:
                                                                          1,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(height: 10),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                CupertinoIcons
                                                                    .time,
                                                                color: AppColor
                                                                    .mainColor,
                                                              ),
                                                              Container(
                                                                  width: 10),
                                                              CustomDisplayText(
                                                                label: Variables.convertTime(reservedData[
                                                                            index]
                                                                        [
                                                                        "dt_in"]
                                                                    .toString()
                                                                    .split(
                                                                        " ")[1]),
                                                                fontSize: 14,
                                                                maxLines: 1,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              Container(
                                                                  width: 5),
                                                              CircleAvatar(
                                                                radius: 8,
                                                                backgroundColor:
                                                                    AppColor
                                                                        .mainColor,
                                                              ),
                                                              DynamicDashLine(
                                                                color: AppColor
                                                                    .mainColor,
                                                                height: 1,
                                                                dashWidth: 3,
                                                                dashGap: 2,
                                                              ),
                                                              CircleAvatar(
                                                                radius: 8,
                                                                backgroundColor:
                                                                    AppColor
                                                                        .mainColor,
                                                              ),
                                                              Container(
                                                                  width: 5),
                                                              CustomDisplayText(
                                                                label: Variables.convertTime(reservedData[
                                                                            index]
                                                                        [
                                                                        "dt_out"]
                                                                    .toString()
                                                                    .split(
                                                                        " ")[1]),
                                                                fontSize: 14,
                                                                maxLines: 1,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Divider(
                                                      height: 2,
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        CustomModal(
                                                                context:
                                                                    context)
                                                            .loader();
                                                        var param =
                                                            "${ApiKeys.gApiSubFolderGetDirection}?ref_no=${reservedData[index]["reservation_ref_no"]}";

                                                        HttpRequest(api: param)
                                                            .get()
                                                            .then(
                                                                (returnData) async {
                                                          print(
                                                              "resData ${returnData["items"]}");
                                                          if (returnData ==
                                                              "No Internet") {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            showAlertDialog(
                                                                context,
                                                                "Error",
                                                                "Please check your internet connection and try again.",
                                                                () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            });
                                                          }
                                                          if (returnData ==
                                                              null) {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            showAlertDialog(
                                                                context,
                                                                "Error",
                                                                "Error while connecting to server, Please contact support.",
                                                                () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            });

                                                            return;
                                                          } else {
                                                            if (returnData[
                                                                        "items"]
                                                                    .length ==
                                                                0) {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              showAlertDialog(
                                                                  context,
                                                                  "Error",
                                                                  "No data found, Please change location.",
                                                                  () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              });
                                                            } else {
                                                              Navigator.pop(
                                                                  context);
                                                              var dateInRelated =
                                                                  "";
                                                              var dateOutRelated =
                                                                  "";
                                                              dateInRelated =
                                                                  reservedData[
                                                                          index]
                                                                      ["dt_in"];
                                                              dateOutRelated =
                                                                  reservedData[
                                                                          index]
                                                                      [
                                                                      "dt_out"];
                                                              Map<String,
                                                                      dynamic>
                                                                  parameters = {
                                                                "client_id": jsonDecode(
                                                                            akongP!)[
                                                                        'user_id']
                                                                    .toString(),
                                                                "park_area_id":
                                                                    returnData["items"]
                                                                            [0][
                                                                        "park_area_id"],
                                                                "vehicle_type_id":
                                                                    returnData["items"]
                                                                            [0][
                                                                        "vehicle_type_id"],
                                                                "vehicle_plate_no":
                                                                    returnData["items"][0]
                                                                            [
                                                                            "vehicle_plate_no"]
                                                                        .toString(),
                                                                "dt_in":
                                                                    dateInRelated,
                                                                "dt_out":
                                                                    dateOutRelated,
                                                                "no_hours": int.parse(
                                                                    reservedData[index]
                                                                            [
                                                                            "no_hours"]
                                                                        .toString()),
                                                                "tran_type":
                                                                    "E",
                                                              };
                                                              if (reservedData[
                                                                              index]
                                                                          [
                                                                          "status"]
                                                                      .toString() ==
                                                                  "C") {
                                                                Variables.pageTrans(
                                                                    ReserveReceipt(
                                                                      isVehicleSelected:
                                                                          false,
                                                                      spaceName:
                                                                          returnData["items"][0]["park_space_name"]
                                                                              .toString(),
                                                                      parkArea: returnData["items"][0]
                                                                              [
                                                                              "park_area_name"]
                                                                          .toString(),
                                                                      // startDate: dateInRelated.toString().split(" ")[0].toString() == dateOutRelated.toString().split(" ")[0].toString()
                                                                      //     ? Variables.formatDate(dateInRelated
                                                                      //         .toString()
                                                                      //         .split(" ")[0])
                                                                      //     : "${Variables.formatDate(dateInRelated.toString().split(" ")[0])} - ${Variables.formatDate(dateOutRelated.toString().split(" ")[0])}",

                                                                      startDate: Variables.formatDate(dateInRelated
                                                                          .toString()
                                                                          .split(
                                                                              " ")[0]),
                                                                      endDate: Variables.formatDate(dateOutRelated
                                                                          .toString()
                                                                          .split(
                                                                              " ")[0]),

                                                                      startTime: dateInRelated
                                                                          .toString()
                                                                          .split(
                                                                              " ")[1]
                                                                          .toString(),
                                                                      endTime: dateOutRelated
                                                                          .toString()
                                                                          .split(
                                                                              " ")[1]
                                                                          .toString(),
                                                                      plateNo: returnData["items"][0]
                                                                              [
                                                                              "vehicle_plate_no"]
                                                                          .toString(),
                                                                      hours: reservedData[index]
                                                                              [
                                                                              "no_hours"]
                                                                          .toString(),
                                                                      amount: reservedData[index]
                                                                              [
                                                                              "amount"]
                                                                          .toString(),
                                                                      refno: reservedData[index]
                                                                              [
                                                                              "reservation_ref_no"]
                                                                          .toString()
                                                                          .toString(),
                                                                      lat: double.parse(returnData["items"][0]
                                                                              [
                                                                              "park_space_latitude"]
                                                                          .toString()),
                                                                      long: double.parse(returnData["items"][0]
                                                                              [
                                                                              "park_space_longitude"]
                                                                          .toString()),
                                                                      dtOut:
                                                                          dateOutRelated,
                                                                      dateIn:
                                                                          dateInRelated,
                                                                      isReserved:
                                                                          true,
                                                                      tab:
                                                                          currentTab,
                                                                      canReserved:
                                                                          true,
                                                                      paramsCalc:
                                                                          parameters,
                                                                      address: returnData["items"]
                                                                              [
                                                                              0]
                                                                          [
                                                                          "address"],
                                                                      ticketId: returnData["items"]
                                                                              [
                                                                              0]
                                                                          [
                                                                          "ticket_id"],
                                                                      isAutoExtend:
                                                                          reservedData[index]["is_auto_extend"]
                                                                              .toString(),
                                                                      reservationId:
                                                                          reservedData[index]
                                                                              [
                                                                              "reservation_id"],
                                                                      onTap:
                                                                          () {
                                                                        onRefresh();
                                                                      },
                                                                    ),
                                                                    context);
                                                              } else {
                                                                Variables.pageTrans(
                                                                    ParkingDetails(
                                                                      startDate: dateInRelated.toString().split(" ")[0].toString() == dateOutRelated.toString().split(" ")[0].toString()
                                                                          ? Variables.formatDate(dateInRelated
                                                                              .toString()
                                                                              .split(" ")[0])
                                                                          : "${Variables.formatDate(dateInRelated.toString().split(" ")[0])} - ${Variables.formatDate(dateOutRelated.toString().split(" ")[0])}",
                                                                      startTime: dateInRelated
                                                                          .toString()
                                                                          .split(
                                                                              " ")[1]
                                                                          .toString(),
                                                                      endTime: dateOutRelated
                                                                          .toString()
                                                                          .split(
                                                                              " ")[1]
                                                                          .toString(),
                                                                      resData:
                                                                          reservedData,
                                                                      returnData:
                                                                          returnData[
                                                                              "items"],
                                                                      dtOut:
                                                                          dateOutRelated,
                                                                      dateIn:
                                                                          dateInRelated,
                                                                      paramsCalc:
                                                                          parameters,
                                                                      onTap:
                                                                          () {
                                                                        onRefresh();
                                                                      },
                                                                    ),
                                                                    context);
                                                              }
                                                            }
                                                          }
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 20,
                                                                vertical: 15),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  CustomDisplayText(
                                                                    label:
                                                                        '${reservedData[index]["notes"]}',
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    maxLines: 1,
                                                                    color: Color(
                                                                        0xFF232323),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  CustomDisplayText(
                                                                    label: reservedData[
                                                                            index]
                                                                        [
                                                                        "reservation_ref_no"],
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    maxLines: 1,
                                                                    color: Color(
                                                                        0xFF444242),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_ios_outlined,
                                                              size: 20,
                                                              color: AppColor
                                                                  .mainColor,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Divider(
                                                      height: 2,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20.0,
                                                          vertical: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          CustomDisplayText(
                                                            label: "Total",
                                                            fontSize: 14,
                                                            maxLines: 1,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          CustomDisplayText(
                                                            label: reservedData[
                                                                    index]
                                                                ["amount"],
                                                            fontSize: 14,
                                                            maxLines: 1,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                            itemCount: reservedData.length),
                                      ),
                          ),
                          Container()
                        ],
                      ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget reserveShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: const Color(0xFFe6faff),
        child: Container(
          height: 50.0,
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
