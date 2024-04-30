// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
// import 'package:luvpark/buy_token/buy_token.dart';
// import 'package:luvpark/classess/api_keys.dart';
// import 'package:luvpark/classess/color_component.dart';
// import 'package:luvpark/classess/http_request.dart';
// import 'package:luvpark/classess/variables.dart';
// import 'package:luvpark/custom_widget/custom_button.dart';
// import 'package:luvpark/custom_widget/custom_parent_widget.dart';
// import 'package:luvpark/custom_widget/custom_text.dart';
// import 'package:luvpark/custom_widget/snackbar_dialog.dart';
// import 'package:luvpark/no_internet/no_internet_connected.dart';
// import 'package:luvpark/qr_payment/qr_type.dart';
// import 'package:luvpark/transfer/transfer_screen.dart';
// import 'package:luvpark/wallet/filter_transaction.dart';
// import 'package:luvpark/wallet/transaction_details.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';

// class MyWallet extends StatefulWidget {
//   const MyWallet({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _MyWalletState createState() => _MyWalletState();
// }

// class _MyWalletState extends State<MyWallet>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool hasInternetBal = true;
//   bool loadingBal = true;
//   double userBal = 0.0;
//   String fromDate = "";
//   String toDate = "";

//   //History Trans param
//   bool hasInternetHist = true;
//   bool isLoadingHist = true;
//   List histData = [];
//   final today = DateTime.now();
//   // ignore: prefer_typing_uninitialized_variables
//   var myProfilePic;

//   // ignore: prefer_typing_uninitialized_variables
//   var akongP;

//   @override
//   void initState() {
//     _tabController = TabController(
//       length: 2, // Number of tabs
//       vsync: this,
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       getPreferences();
//     });

//     super.initState();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> getPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     toDate = today.toString().split(" ")[0];
//     fromDate =
//         today.subtract(const Duration(days: 29)).toString().split(" ")[0];
//     akongP = prefs.getString(
//       'userData',
//     );
//     var myPicData = prefs.getString(
//       'myProfilePic',
//     );
//     if (mounted) {
//       setState(() {
//         myProfilePic = jsonDecode(myPicData!).toString();
//         hasInternetBal = true;
//         loadingBal = true;
//         hasInternetHist = true;
//         isLoadingHist = true;
//       });
//     }

//     _getData(jsonDecode(akongP!)['user_id'].toString());
//     getPaymentAllData(jsonDecode(akongP!)['user_id'].toString());
//   }

//   void getPaymentAllData(apiFolder) async {
//     Future.delayed(const Duration(seconds: 3), () {
//       String subApi =
//           "${ApiKeys.gApiSubFolderGetTransactionLogs}?user_id=${jsonDecode(akongP!)['user_id'].toString()}&tran_date_from=$fromDate&tran_date_to=$toDate";

//       HttpRequest(api: subApi).get().then((returnData) async {
//         if (returnData == "No Internet") {
//           if (mounted) {
//             setState(() {
//               hasInternetHist = false;
//               isLoadingHist = false;
//               histData = [];
//             });
//           }

//           return;
//         }
//         if (returnData == null) {
//           if (mounted) {
//             setState(() {
//               hasInternetHist = true;
//               isLoadingHist = false;
//               histData = [];
//             });
//           }
//           showAlertDialog(context, "Error",
//               "Error while connecting to server, Please try again later.", () {
//             Navigator.of(context).pop();
//           });
//         }

//         if (returnData["items"].length > 0) {
//           if (mounted) {
//             setState(() {
//               histData = [];
//             });
//           }

//           for (var itemData in returnData["items"]) {
//             histData.add({
//               "user_id": itemData["user_id"],
//               "tran_desc": itemData["tran_desc"],
//               "amount": double.parse(itemData["amount"].toString()),
//               "bal_before": double.parse(itemData["bal_before"].toString()),
//               "bal_after": double.parse(itemData["bal_after"].toString()),
//               "tran_date": itemData["tran_date"],
//               "ref_no": itemData["ref_no"]
//             });
//           }
//           if (mounted) {
//             setState(() {
//               isLoadingHist = false;
//               hasInternetHist = true;
//             });
//           }
//         } else {
//           if (mounted) {
//             setState(() {
//               isLoadingHist = false;
//               hasInternetHist = true;
//               histData = [];
//             });
//           }
//         }
//       });
//     });
//   }

//   void _getData(id) {
//     String subApi =
//         "${ApiKeys.gApiSubFolderGetBalance}?user_id=${jsonDecode(akongP!)['user_id'].toString()}";

//     HttpRequest(api: subApi).get().then((returnBalance) async {
//       if (returnBalance == "No Internet") {
//         if (mounted) {
//           setState(() {
//             hasInternetBal = false;
//             loadingBal = false;
//           });
//         }

//         return;
//       }
//       if (returnBalance == null) {
//         showAlertDialog(context, "Error",
//             "Error while connecting to server, Please try again.", () {
//           Navigator.of(context).pop();
//           if (mounted) {
//             setState(() {
//               hasInternetBal = true;
//               loadingBal = false;
//             });
//           }
//         });
//       }
//       if (mounted) {
//         setState(() {
//           userBal =
//               double.parse(returnBalance["items"][0]["amount_bal"].toString());
//           hasInternetBal = true;
//           loadingBal = false;
//         });
//       }
//     });
//   }

//   getFilterDate(data) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     akongP = prefs.getString(
//       'userData',
//     );
//     if (mounted) {
//       setState(() {
//         fromDate = data["date_from"];
//         toDate = data["date_to"];
//         hasInternetHist = true;
//         isLoadingHist = true;
//       });
//     }

//     getPaymentAllData(jsonDecode(akongP!)['user_id'].toString());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomParentWidget(
//         appbarColor: AppColor.primaryColor,
//         child: RefreshIndicator(
//           onRefresh: getPreferences,
//           child: Stack(
//             children: [
//               ListView(
//                 padding: EdgeInsets.zero,
//                 shrinkWrap: true,
//                 children: [
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height,
//                   )
//                 ],
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     loadingBal
//                         ? Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: const Color(0xFFe6faff),
//                             child: const SizedBox(
//                               width: 30,
//                               height: 10,
//                             ))
//                         : CustomDisplayText(
//                             label: !hasInternetBal
//                                 ? "Internet Error"
//                                 : toCurrencyString(userBal.toString().trim()),
//                             fontWeight: FontWeight.w700,
//                             height: 0,
//                             letterSpacing: -0.64,
//                             fontSize: 32,
//                             maxLines: 4,
//                           ),
//                     CustomDisplayText(
//                       label: "Your wallet balance",
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       height: 0,
//                       letterSpacing: -0.28,
//                     ),
//                     Container(
//                       height: 20,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         actionButton("load", "Load", () {
//                           if (jsonDecode(akongP!)['first_name'].toString() ==
//                               'null') {
//                             showAlertDialog(context, "Attention",
//                                 "Complete your account information to access the requested service.\nGo to profile and update your account. ",
//                                 () {
//                               Navigator.of(context).pop();
//                             });
//                             return;
//                           }
//                           Variables.pageTrans(const BuyTokenPage(
//                             index: 1,
//                           ));
//                         }),
//                         Container(
//                           width: 10,
//                         ),
//                         actionButton("share", "Share", () {
//                           if (jsonDecode(akongP!)['first_name'].toString() ==
//                               'null') {
//                             showAlertDialog(context, "Attention",
//                                 "Complete your account information to access the requested service.\nGo to profile and update your account. ",
//                                 () {
//                               Navigator.of(context).pop();
//                             });
//                             return;
//                           }
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: ((context) => const TransferOptions()),
//                             ),
//                           );
//                         }),
//                         Container(
//                           width: 10,
//                         ),
//                         actionButton("qr_pay", "QR Pay", () {
//                           Variables.pageTrans(const QRType(
//                             index: 0,
//                           ));
//                         }),
//                         Container(
//                           width: 10,
//                         ),
//                         actionButton("qr_pay", "Receive", () {
//                           Variables.pageTrans(const QRType(
//                             index: 1,
//                           ));
//                         }),
//                       ],
//                     ),
//                     Container(
//                       height: 10,
//                     ),
//                     Container(
//                       height: 62,
//                       padding: const EdgeInsets.only(right: 10),
//                       clipBehavior: Clip.antiAlias,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border(
//                           bottom: BorderSide(
//                             width: 1,
//                             color:
//                                 Colors.black.withOpacity(0.10000000149011612),
//                           ),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: CustomDisplayText(
//                               label: 'Recent Transaction',
//                               color: Colors.black,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           InkWell(
//                             onTap: () {
//                               Variables.pageTrans(FilterTrans(
//                                 callback: (data) {
//                                   getFilterDate(data);
//                                 },
//                               ));
//                             },
//                             child: const Icon(
//                               Icons.tune_outlined,
//                               color: Color(0xFF9C9C9C),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         child: isLoadingHist
//                             ? Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//                                 highlightColor: const Color(0xFFe6faff),
//                                 child: StretchingOverscrollIndicator(
//                                   axisDirection: AxisDirection.down,
//                                   child: ListView.builder(
//                                     itemCount: 10,
//                                     itemBuilder: ((context, index) =>
//                                         const Card(
//                                           child: ListTile(),
//                                         )),
//                                   ),
//                                 ),
//                               )
//                             : histData.isEmpty
//                                 ? Center(
//                                     child: NoDataFound(
//                                       size: 50,
//                                       onTap: getPreferences,
//                                     ),
//                                   )
//                                 : ListView.builder(
//                                     itemCount: histData.length,
//                                     itemBuilder: ((context, index) {
//                                       return InkWell(
//                                         onTap: () {
//                                           Variables.pageTrans(
//                                             TransactionDetails(
//                                               data: histData,
//                                               index: index,
//                                             ),
//                                           );
//                                         },
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 10),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Expanded(
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: [
//                                                     CustomDisplayText(
//                                                       label: histData[index]
//                                                           ["tran_desc"],
//                                                       fontWeight:
//                                                           FontWeight.w700,
//                                                       height: 0,
//                                                       color: Colors.black,
//                                                       fontSize: 14,
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                     Container(
//                                                       height: 3,
//                                                     ),
//                                                     CustomDisplayText(
//                                                       label: Variables
//                                                           .formatDateLocal(
//                                                               histData[index][
//                                                                   "tran_date"]),
//                                                       color: AppColor
//                                                           .textSecondaryColor,
//                                                       fontSize: 14,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               CustomDisplayText(
//                                                 label:
//                                                     "${histData[index]["amount"]}",
//                                                 color: AppColor.primaryColor,
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 16,
//                                               ),
//                                               Container(
//                                                 width: 4,
//                                               ),
//                                               Icon(
//                                                 Icons.more_vert_outlined,
//                                                 color: AppColor.primaryColor,
//                                                 size: 20,
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     })),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ));
//   }

// // Card buttons
//   Widget actionButton(String image, String buttonName, Function onTap) {
//     return Expanded(
//         child: loadingBal
//             ? Shimmer.fromColors(
//                 baseColor: Colors.grey.shade300,
//                 highlightColor: const Color(0xFFe6faff),
//                 child: CustomButton(
//                   label: "",
//                   onTap: () {},
//                 ),
//               )
//             : InkWell(
//                 onTap: () {
//                   onTap();
//                 },
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image(
//                         height: 35,
//                         width: 35,
//                         image: AssetImage("assets/images/$image.png")),
//                     Container(
//                       height: 5,
//                     ),
//                     CustomDisplayText(
//                         label: buttonName,
//                         color: AppColor.primaryColor,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14),
//                   ],
//                 ),
//               ));
//   }
// }

import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  final CarouselController _carouselController = CarouselController();

  //History Trans param
  bool hasInternetHist = true;
  bool isLoadingHist = true;
  List histData = [];
  final today = DateTime.now();
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

    _getData(jsonDecode(akongP!)['user_id'].toString());
    getPaymentAllData(jsonDecode(akongP!)['user_id'].toString());
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

  void _getData(id) {
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
          userBal =
              double.parse(returnBalance["items"][0]["amount_bal"].toString());
          ptsBal =
              double.parse(returnBalance["items"][0]["points_bal"].toString());
          hasInternetBal = true;
          loadingBal = false;
        });
      }
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
        appbarColor: AppColor.primaryColor,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomDisplayText(
                            label: 'Cash',
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          CustomDisplayText(
                            label: 'Reward Points',
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 61,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF01b9c5),
                                  const Color(0xFF3863c2),
                                  const Color(0xFF0078FF),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: [0.0, 0.5, 1.0],
                                tileMode: TileMode.clamp,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                loadingBal
                                    ? Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: const Color(0xFFe6faff),
                                        child: const SizedBox(
                                          width: 30,
                                          height: 10,
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                            ),
                                            child: CustomDisplayTextkanit(
                                              color: Colors.white,
                                              label: !hasInternetBal
                                                  ? "Internet Error"
                                                  : toCurrencyString(userBal
                                                      .toString()
                                                      .trim()),
                                              fontWeight: FontWeight.w500,
                                              height: 0,
                                              fontSize: 30,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 10),
                        Expanded(
                          child: Container(
                            height: 61,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF0078FF), // primaryColor
                                  const Color(0xFF3863c2), // secondaryColor
                                  const Color(0xFF01b9c5), // mainColor
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: [0.0, 0.5, 1.0],
                                tileMode: TileMode.clamp,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                loadingBal
                                    ? Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: const Color(0xFFe6faff),
                                        child: const SizedBox(
                                          width: 30,
                                          height: 10,
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          CustomDisplayTextkanit(
                                            color: Colors.white,
                                            label: !hasInternetBal
                                                ? "Internet Error"
                                                : toCurrencyString(
                                                    ptsBal.toString().trim()),
                                            fontWeight: FontWeight.w500,
                                            height: 0,
                                            fontSize: 30,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        actionButton("load_wallet", "Load", () {
                          if (jsonDecode(akongP!)['first_name'].toString() ==
                              'null') {
                            showAlertDialog(context, "Attention",
                                "Complete your account information to access the requested service.\nGo to profile and update your account. ",
                                () {
                              Navigator.of(context).pop();
                            });
                            return;
                          }
                          Variables.pageTrans(const BuyTokenPage(
                            index: 1,
                          ));
                        }),
                        Container(
                          width: 10,
                        ),
                        actionButton("share", "Share", () {
                          if (jsonDecode(akongP!)['first_name'].toString() ==
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
                              builder: ((context) => const TransferOptions()),
                            ),
                          );
                        }),
                        Container(
                          width: 10,
                        ),
                        actionButton("QR-CODE", "QR Pay", () {
                          Variables.pageTrans(const QRType(
                            index: 0,
                          ));
                        }),
                        Container(
                          width: 10,
                        ),
                        actionButton("Receive", "Receive", () {
                          Variables.pageTrans(const QRType(
                            index: 1,
                          ));
                        }),
                      ],
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      height: 62,
                      padding: const EdgeInsets.only(right: 10),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color:
                                Colors.black.withOpacity(0.10000000149011612),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomDisplayText(
                              label: 'Recent Transaction',
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // InkWell(
                          //   onTap: () {
                          //     Variables.pageTrans(FilterTrans(
                          //       callback: (data) {
                          //         getFilterDate(data);
                          //       },
                          //     ));
                          //   },
                          //   child: const Icon(
                          //     Icons.tune_outlined,
                          //     color: Color(0xFF9C9C9C),
                          //   ),
                          // ),
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
                            child: const Icon(
                              Icons.tune_outlined,
                              color: Color(0xFF9C9C9C),
                            ),
                          ),
                        ],
                      ),
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
                                      return InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) => Container(
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
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
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 3),
                                                    CustomDisplayText(
                                                      label: Variables
                                                          .formatDateLocal(
                                                              histData[index][
                                                                  "tran_date"]),
                                                      color: AppColor
                                                          .textSecondaryColor,
                                                      fontSize: 14,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              CustomDisplayText(
                                                label:
                                                    "${histData[index]["amount"]}",
                                                color: AppColor.primaryColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.more_vert_outlined,
                                                color: AppColor.primaryColor,
                                                size: 20,
                                              ),
                                            ],
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

// Card buttons
  Widget actionButton(String image, String buttonName, Function onTap) {
    return Expanded(
        child: loadingBal
            ? Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: const Color(0xFFe6faff),
                child: CustomButton(
                  label: "",
                  onTap: () {},
                ),
              )
            : InkWell(
                onTap: () {
                  onTap();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                        height: 35,
                        width: 35,
                        image: AssetImage("assets/images/$image.png")),
                    Container(
                      height: 5,
                    ),
                    CustomDisplayText(
                        label: buttonName,
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ],
                ),
              ));
  }
}
