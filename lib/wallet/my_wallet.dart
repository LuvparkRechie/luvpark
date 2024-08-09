import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/buy_token/buy_token.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
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
                    CustomTitle(
                      text: "My Wallet",
                      fontSize: 20,
                    ),
                    Container(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: .1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomParagraph(text: "Current Balance"),
                                      SizedBox(height: 5),
                                      CustomTitle(
                                        text: !hasInternetBal
                                            ? "Internet Error"
                                            : toCurrencyString(
                                                userBal.toString().trim()),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 30),
                                GestureDetector(
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: AppColor.primaryColor,
                                      border: Border.all(
                                        color: AppColor.primaryColor
                                            .withOpacity(.2),
                                      ),
                                    ),
                                    child: const CustomParagraph(
                                      text: "Recharge",
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Container(height: 20),
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.gift,
                                  size: 15,
                                  color: Colors.pink,
                                ),
                                Container(width: 5),
                                Flexible(
                                    child: CustomParagraph(
                                  text: !hasInternetBal
                                      ? "Internet Error"
                                      : toCurrencyString(
                                          ptsBal.toString().trim()),
                                  fontSize: 12,
                                  color: Colors.black,
                                )),
                                Container(width: 5),
                                const Flexible(
                                  child: CustomParagraph(
                                    text: "Points",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(height: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: loadingBal
                              ? () {}
                              : () {
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: .1,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.send_2,
                                  color: AppColor.primaryColor,
                                ),
                                Container(width: 5),
                                const CustomParagraph(text: "Send")
                              ],
                            ),
                          ),
                        ),
                        Container(width: 10),
                        GestureDetector(
                          onTap: loadingBal
                              ? () {}
                              : () {
                                  Variables.pageTrans(const QRType(), context);
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: .1,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.qrcode_viewfinder,
                                  color: AppColor.primaryColor,
                                ),
                                Container(width: 5),
                                const CustomParagraph(text: "QR")
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 30),
                    Row(
                      children: [
                        const Expanded(
                          child: CustomTitle(
                            text: "Transaction History",
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        GestureDetector(
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
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: .1,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.filter,
                                  color: AppColor.primaryColor,
                                  size: 18,
                                ),
                                Container(width: 5),
                                const CustomParagraph(text: "Filter")
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(height: 15),
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
                                : StretchingOverscrollIndicator(
                                    axisDirection: AxisDirection.down,
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      itemCount: 5,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          onTap: () {
                                            showModalBottomSheet(
                                              backgroundColor:
                                                  Colors.transparent,
                                              context: context,
                                              builder: (context) =>
                                                  TransactionDetails(
                                                data: histData,
                                                index: index,
                                              ),
                                            );
                                          },
                                          contentPadding: EdgeInsets.zero,
                                          title: CustomTitle(
                                            text: histData[index]["tran_desc"],
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          subtitle: CustomParagraph(
                                            text: Variables.formatDateLocal(
                                                histData[index]["tran_date"]),
                                            fontSize: 12,
                                          ),
                                          trailing: Icon(
                                            CupertinoIcons.chevron_right,
                                            size: 14,
                                            color: AppColor.primaryColor,
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                        endIndent: 1,
                                        height: 1,
                                      ),
                                    ),
                                  ),
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
