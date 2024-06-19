import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:luvpark/buy_token/buy_token.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:luvpark/qr_payment/qr_type.dart';
import 'package:luvpark/transfer/transfer_screen.dart';
import 'package:luvpark/wallet/filter_transaction.dart';
import 'package:luvpark/wallet/transaction_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class MyWallet extends StatefulWidget {
  const MyWallet({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyWalletState createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool hasInternetBal = true;
  bool loadingBal = true;
  double userBal = 0.0;
  double ptsBal = 0.0;
  String fromDate = "";
  String toDate = "";

  //History Trans param
  bool hasInternetHist = true;
  bool isLoadingHist = true;
  List histData = [];
  final today = DateTime.now();
  Timer? timer1;
  // ignore: prefer_typing_uninitialized_variables
  var myProfilePic;

  // ignore: prefer_typing_uninitialized_variables
  var akongP;

  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getPreferences();
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    timer1!.cancel();
    super.dispose();
  }

  Future<void> getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    toDate = today.toString().split(" ")[0];
    fromDate =
        today.subtract(const Duration(days: 29)).toString().split(" ")[0];
    akongP = prefs.getString(
      'userData',
    );
    var myPicData = prefs.getString(
      'myProfilePic',
    );
    if (mounted) {
      setState(() {
        myProfilePic = jsonDecode(myPicData!).toString();
        hasInternetBal = true;
        loadingBal = true;
        hasInternetHist = true;
        isLoadingHist = true;
      });
    }

    _getData();
  }

  void getPaymentAllData(apiFolder) async {
    Future.delayed(const Duration(seconds: 3), () {
      String subApi =
          "${ApiKeys.gApiSubFolderGetTransactionLogs}?user_id=${jsonDecode(akongP!)['user_id'].toString()}&tran_date_from=$fromDate&tran_date_to=$toDate";

      HttpRequest(api: subApi).get().then((returnData) async {
        if (returnData == "No Internet") {
          if (mounted) {
            setState(() {
              hasInternetHist = false;
              isLoadingHist = false;
              histData = [];
            });
          }

          return;
        }
        if (returnData == null) {
          if (mounted) {
            setState(() {
              hasInternetHist = true;
              isLoadingHist = false;
              histData = [];
            });
          }
          showAlertDialog(context, "Error",
              "Error while connecting to server, Please try again later.", () {
            Navigator.of(context).pop();
          });
        }

        if (returnData["items"].length > 0) {
          if (mounted) {
            setState(() {
              histData = [];
            });
          }

          for (var itemData in returnData["items"]) {
            histData.add({
              "user_id": itemData["user_id"],
              "tran_desc": itemData["tran_desc"],
              "amount": double.parse(itemData["amount"].toString()),
              "bal_before": double.parse(itemData["bal_before"].toString()),
              "bal_after": double.parse(itemData["bal_after"].toString()),
              "tran_date": itemData["tran_date"],
              "ref_no": itemData["ref_no"]
            });
          }
          if (mounted) {
            setState(() {
              isLoadingHist = false;
              hasInternetHist = true;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              isLoadingHist = false;
              hasInternetHist = true;
              histData = [];
            });
          }
        }
      });
    });
  }

  void _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    akongP = prefs.getString(
      'userData',
    );
    timer1 = Timer.periodic(Duration(seconds: 3), (timer) {
      String subApi =
          "${ApiKeys.gApiSubFolderGetBalance}?user_id=${jsonDecode(akongP!)['user_id'].toString()}";

      HttpRequest(api: subApi).get().then((returnBalance) async {
        if (returnBalance == "No Internet") {
          if (mounted) {
            setState(() {
              hasInternetBal = false;
              loadingBal = false;
            });
          }

          return;
        }
        if (returnBalance == null) {
          showAlertDialog(context, "Error",
              "Error while connecting to server, Please try again.", () {
            Navigator.of(context).pop();
            if (mounted) {
              setState(() {
                hasInternetBal = true;
                loadingBal = false;
              });
            }
          });
        }
        if (mounted) {
          setState(() {
            userBal = double.parse(
                returnBalance["items"][0]["amount_bal"].toString());
            ptsBal = double.parse(
                returnBalance["items"][0]["points_bal"].toString());
            hasInternetBal = true;
            loadingBal = false;
          });
        }
        getPaymentAllData(jsonDecode(akongP!)['user_id'].toString());
      });
    });
  }

  getFilterDate(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    akongP = prefs.getString(
      'userData',
    );
    if (mounted) {
      setState(() {
        fromDate = data["date_from"];
        toDate = data["date_to"];
        hasInternetHist = true;
        isLoadingHist = true;
      });
    }

    getPaymentAllData(jsonDecode(akongP!)['user_id'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
        appbarColor: Colors.white,
        bodyColor: Color.fromARGB(255, 249, 248, 248),
        child: RefreshIndicator(
          onRefresh: getPreferences,
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDisplayText(
                      label: 'My Wallet',
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                    Container(height: 20),
                    Container(
                      height: 102,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5.0,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomDisplayText(
                                      label: 'My Balance',
                                      fontSize: 14,
                                      alignment: TextAlign.center,
                                      maxLines: 1,
                                      color: Colors.grey,
                                    ),
                                    Container(height: 5),
                                    loadingBal
                                        ? Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                const Color(0xFFe6faff),
                                            child: const SizedBox(
                                              width: 30,
                                              height: 10,
                                            ),
                                          )
                                        : CustomDisplayTextkanit(
                                            color: Colors.black,
                                            label: !hasInternetBal
                                                ? "Internet Error"
                                                : toCurrencyString(
                                                    userBal.toString().trim()),
                                            fontWeight: FontWeight.w500,
                                            height: 0,
                                            fontSize: 25,
                                            maxLines: 1,
                                          )
                                  ],
                                ),
                              ),
                            ),
                            VerticalDivider(
                              color: Colors.grey,
                              indent: 20,
                              endIndent: 20,
                            ),
                            Expanded(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomDisplayText(
                                      label: 'Rewards Points',
                                      fontSize: 14,
                                      alignment: TextAlign.center,
                                      maxLines: 1,
                                      color: Colors.grey,
                                    ),
                                    Container(height: 5),
                                    loadingBal
                                        ? Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                const Color(0xFFe6faff),
                                            child: const SizedBox(
                                              width: 30,
                                              height: 10,
                                            ),
                                          )
                                        : CustomDisplayTextkanit(
                                            color: Colors.black,
                                            label: !hasInternetBal
                                                ? "Internet Error"
                                                : toCurrencyString(
                                                    ptsBal.toString().trim()),
                                            fontWeight: FontWeight.w500,
                                            height: 0,
                                            fontSize: 25,
                                            maxLines: 1,
                                          )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        loadingBal
                            ? Expanded(
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: const Color(0xFFe6faff),
                                  child: CustomButton(
                                    label: "",
                                    onTap: () {},
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  if (jsonDecode(akongP!)['first_name']
                                          .toString() ==
                                      'null') {
                                    showAlertDialog(context, "Attention",
                                        "Complete your account information to access the requested service.\nGo to profile and update your account. ",
                                        () {
                                      Navigator.of(context).pop();
                                    });
                                    return;
                                  }
                                  Variables.pageTrans(
                                      const BuyTokenPage(
                                        index: 1,
                                      ),
                                      context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryColor,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.download_outlined,
                                        color: Colors.white,
                                      ),
                                      Container(width: 5),
                                      CustomDisplayText(
                                        label: "Load",
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                        if (loadingBal) Container(width: 10),
                        loadingBal
                            ? Expanded(
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: const Color(0xFFe6faff),
                                  child: CustomButton(
                                    label: "",
                                    onTap: () {},
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  if (jsonDecode(akongP!)['first_name']
                                          .toString() ==
                                      'null') {
                                    showAlertDialog(context, "Attention",
                                        "Complete your account information to access the requested service.\nGo to profile and update your account. ",
                                        () {
                                      Navigator.of(context).pop();
                                    });
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: ((context) =>
                                          const TransferOptions()),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryColor,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Center(
                                        child: Transform.rotate(
                                          angle: 50 *
                                              (3.14159265359 /
                                                  180), // Convert degrees to radians
                                          child: Center(
                                            child: Icon(
                                              Icons.navigation_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(width: 5),
                                      CustomDisplayText(
                                        label: "Share",
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                        if (loadingBal) Container(width: 10),
                        loadingBal
                            ? Expanded(
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: const Color(0xFFe6faff),
                                  child: CustomButton(
                                    label: "",
                                    onTap: () {},
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  Variables.pageTrans(const QRType(), context);
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 10,
                                    ),
                                    child: Icon(
                                      Icons.qr_code,
                                      color: Colors.white,
                                    )),
                              ),
                      ],
                    ),
                    Container(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDisplayText(
                            label: 'Recent Activity',
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              barrierColor: Colors.black.withOpacity(0.5),
                              builder: (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    child: Stack(
                                      children: [
                                        FilterTrans(
                                          callback: (data) {
                                            getFilterDate(data);
                                          },
                                        ),
                                        Positioned(
                                          top: 12,
                                          right: 10,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Icon(
                            Icons.tune_outlined,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: isLoadingHist
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: const Color(0xFFe6faff),
                                child: StretchingOverscrollIndicator(
                                  axisDirection: AxisDirection.down,
                                  child: ListView.builder(
                                    itemCount: 10,
                                    itemBuilder: ((context, index) =>
                                        const Card(
                                          child: ListTile(),
                                        )),
                                  ),
                                ),
                              )
                            : histData.isEmpty
                                ? Center(
                                    child: NoDataFound(
                                      size: 50,
                                      onTap: getPreferences,
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: histData.length,
                                    itemBuilder: ((context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 1),
                                        child: InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                              backgroundColor:
                                                  Colors.transparent,
                                              context: context,
                                              builder: (context) => Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                  ),
                                                ),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.5, // Adjust the height as needed
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(20),
                                                      topRight:
                                                          Radius.circular(20),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(20),
                                                    child: TransactionDetails(
                                                      data: histData,
                                                      index: index,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              color: Color(0xFFFFFFFF),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                              ),
                                              shadows: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  spreadRadius: 0,
                                                  blurRadius: 1,
                                                  offset: Offset(1, 2),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20,
                                                      horizontal: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        CustomDisplayText(
                                                          label: histData[index]
                                                              ["tran_desc"],
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          height: 0,
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        SizedBox(height: 3),
                                                        CustomDisplayText(
                                                          label: Variables
                                                              .formatDateLocal(
                                                                  histData[
                                                                          index]
                                                                      [
                                                                      "tran_date"]),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.grey,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  CustomDisplayText(
                                                    label:
                                                        "${histData[index]["amount"]}",
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    })),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
