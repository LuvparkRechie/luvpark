// import 'dart:async';
// import 'dart:convert';

// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:luvpark/buy_token/buy_token.dart';
// import 'package:luvpark/classess/api_keys.dart';
// import 'package:luvpark/classess/color_component.dart';
// import 'package:luvpark/classess/http_request.dart';
// import 'package:luvpark/classess/variables.dart';
// import 'package:luvpark/custom_widget/custom_parent_widget.dart';
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
//         appbarColor: AppColor.bodyColor,
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
//                             child: Container(
//                               height: MediaQuery.of(context).size.height * .20,
//                               width: MediaQuery.of(context).size.width,
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFffffff),
//                                 border: Border.all(
//                                     style: BorderStyle.solid,
//                                     color: Colors.grey.shade100),
//                                 borderRadius: const BorderRadius.all(
//                                   Radius.circular(15),
//                                 ),
//                               ),
//                             ),
//                           )
//                         : Text(
//                             loadingBal
//                                 ? ""
//                                 : !hasInternetBal
//                                     ? "Internet Error"
//                                     : toCurrencyString(
//                                         userBal.toString().trim()),
//                             style: CustomTextStyle(
//                               fontWeight: FontWeight.w700,
//                               height: 0,
//                               letterSpacing: -0.64,
//                               fontSize: 32,
//                             ),
//                             softWrap: true,
//                           ),
//                     Text(
//                       "Your wallet balance",
//                       style: CustomTextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         height: 0,
//                         letterSpacing: -0.28,
//                       ),
//                       softWrap: true,
//                     ),
//                     //  Container(
//                     //     width: MediaQuery.of(context).size.width,
//                     //     decoration: const BoxDecoration(
//                     //       image: DecorationImage(
//                     //           fit: BoxFit.cover,
//                     //           image: AssetImage(
//                     //               "assets/images/luvpayCard.png")),
//                     //       borderRadius: BorderRadius.all(
//                     //         Radius.circular(
//                     //           20,
//                     //         ),
//                     //       ),
//                     //     ),
//                     //     child: Padding(
//                     //       padding: const EdgeInsets.symmetric(
//                     //           horizontal: 20, vertical: 22),
//                     //       child: Column(
//                     //         crossAxisAlignment: CrossAxisAlignment.start,
//                     //         children: [
//                     //           Row(
//                     //             children: [
//                     //               Container(
//                     //                 width: 50,
//                     //                 height: 50,
//                     //                 clipBehavior: Clip.antiAlias,
//                     //                 decoration: BoxDecoration(
//                     //                   color: Colors.grey[300],
//                     //                   shape: BoxShape.circle,
//                     //                 ),
//                     //                 child: Center(
//                     //                     child: ClipRRect(
//                     //                   borderRadius:
//                     //                       BorderRadius.circular(80 / 2),
//                     //                   child: myProfilePic == 'null'
//                     //                       ? const Image(
//                     //                           image: AssetImage(
//                     //                               "assets/images/no_image.png"))
//                     //                       : Image.memory(
//                     //                           const Base64Decoder().convert(
//                     //                               myProfilePic.toString()),
//                     //                           fit: BoxFit.cover,
//                     //                           height: 50,
//                     //                           width: 50,
//                     //                           gaplessPlayback: true,
//                     //                         ),
//                     //                 )),
//                     //               ),
//                     //               Container(
//                     //                 width: 10,
//                     //               ),
//                     //               Expanded(
//                     //                 child: Column(
//                     //                   crossAxisAlignment:
//                     //                       CrossAxisAlignment.start,
//                     //                   children: [
//                     //                     AutoSizeText(
//                     //                       loadingBal
//                     //                           ? ''
//                     //                           : jsonDecode(akongP!)[
//                     //                                           'first_name']
//                     //                                       .toString() ==
//                     //                                   "null"
//                     //                               ? "Not Specified"
//                     //                               : '${jsonDecode(akongP!)['first_name'].toString().toUpperCase()} ${jsonDecode(akongP!)['last_name'].toString().toUpperCase()} ',
//                     //                       style: CustomTextStyle(
//                     //                         color: Colors.white.withOpacity(
//                     //                             0.8899999856948853),
//                     //                         fontSize: 14,
//                     //                         fontWeight: FontWeight.w700,
//                     //                         height: 0,
//                     //                         letterSpacing: -0.28,
//                     //                       ),
//                     //                       overflow: TextOverflow.ellipsis,
//                     //                       maxLines: 1,
//                     //                     ),
//                     //                     Container(
//                     //                       height: 5,
//                     //                     ),
//                     //                     AutoSizeText(
//                     //                       loadingBal
//                     //                           ? ""
//                     //                           : "+639${jsonDecode(akongP!)['mobile_no'].substring(3).toString().replaceAll(RegExp(r'.(?=.{4})'), '●')}",
//                     //                       style: const TextStyle(
//                     //                         fontWeight: FontWeight.w600,
//                     //                         color: Colors.white70,
//                     //                         letterSpacing: 1,
//                     //                       ),
//                     //                     ),
//                     //                   ],
//                     //                 ),
//                     //               ),
//                     //             ],
//                     //           ),
//                     //           Container(
//                     //             height: 19,
//                     //           ),
//                     //           Row(
//                     //             children: [
//                     //               Text(
//                     //                 " ${Variables.formatDateLocal(today.toString().split(".")[0].toString())}",
//                     //                 style: GoogleFonts.lato(
//                     //                   fontWeight: FontWeight.bold,
//                     //                   color: Colors.white60,
//                     //                   fontSize: 10,
//                     //                   // letterSpacing: 1,
//                     //                 ),
//                     //                 softWrap: true,
//                     //                 textAlign: TextAlign.center,
//                     //               ),
//                     //               Expanded(
//                     //                 child: Column(
//                     //                   children: [
//                     //                     Align(
//                     //                       alignment: Alignment.centerRight,
//                     //                       child: AutoSizeText(
//                     //                         "Available Balance",
//                     //                         style: CustomTextStyle(
//                     //                           fontWeight: FontWeight.bold,
//                     //                           color: Colors.white,
//                     //                           fontSize: 12,
//                     //                           // letterSpacing: 1,
//                     //                         ),
//                     //                         softWrap: true,
//                     //                         maxLines: 1,
//                     //                       ),
//                     //                     ),
//                     //                     Align(
//                     //                       alignment: Alignment.centerRight,
//                     //                       child: AutoSizeText(
//                     //                         loadingBal
//                     //                             ? ""
//                     //                             : !hasInternetBal
//                     //                                 ? "Internet Error"
//                     //                                 : toCurrencyString(
//                     //                                     userBal
//                     //                                         .toString()
//                     //                                         .trim()),
//                     //                         style: CustomTextStyle(
//                     //                           color: Colors.white,
//                     //                           fontSize: 24,
//                     //                           fontWeight: FontWeight.w600,
//                     //                           height: 0,
//                     //                           letterSpacing: -0.48,
//                     //                         ),
//                     //                         maxLines: 1,
//                     //                       ),
//                     //                     ),
//                     //                   ],
//                     //                 ),
//                     //               ),
//                     //             ],
//                     //           ),
//                     //         ],
//                     //       ),
//                     //     ),
//                     //   ),

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
//                         actionButton("qr_pay", "QR Pay", () {
//                           Variables.pageTrans(const QRType());
//                         }),
//                       ],
//                     ),
//                     Container(
//                       height: 30,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         AutoSizeText(
//                           "Recent Transaction",
//                           style: GoogleFonts.varela(
//                             fontSize: 16,
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                             height: 0,
//                             letterSpacing: -0.28,
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () {
//                             Variables.pageTrans(FilterTrans(
//                               callback: (data) {
//                                 getFilterDate(data);
//                               },
//                             ));
//                           },
//                           child: const Padding(
//                             padding: EdgeInsets.only(right: 8.0),
//                             child: Icon(
//                               Icons.tune_outlined,
//                               color: Color(0xFF9C9C9C),
//                             ),
//                           ),
//                         ),
//                       ],
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
//                                                     AutoSizeText(
//                                                       histData[index]
//                                                           ["tran_desc"],
//                                                       style: CustomTextStyle(
//                                                         fontWeight:
//                                                             FontWeight.w600,
//                                                         fontSize: 14,
//                                                         letterSpacing: -0.28,
//                                                         color: AppColor
//                                                             .primaryColor,
//                                                       ),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                     Container(
//                                                       height: 3,
//                                                     ),
//                                                     Text(
//                                                       Variables.formatDateLocal(
//                                                           histData[index]
//                                                               ["tran_date"]),
//                                                       style: CustomTextStyle(
//                                                         color: AppColor
//                                                             .textSecondaryColor,
//                                                         fontSize: 13,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               Text(
//                                                 "${histData[index]["amount"]}",
//                                                 style: CustomTextStyle(
//                                                   color: Colors.black,
//                                                   fontWeight: FontWeight.w600,
//                                                   fontSize: 16,
//                                                 ),
//                                               ),
//                                               Container(
//                                                 width: 4,
//                                               ),
//                                               const Icon(
//                                                 Icons.more_vert_outlined,
//                                                 color: Color.fromRGBO(
//                                                     37, 99, 235, 0.8),
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
//       child: GestureDetector(
//         onTap: () {
//           onTap();
//         },
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             loadingBal
//                 ? Shimmer.fromColors(
//                     baseColor: Colors.grey.shade300,
//                     highlightColor: const Color(0xFFe6faff),
//                     child: Container(
//                       height: 40,
//                       width: 40,
//                       decoration: BoxDecoration(
//                           color: const Color(0xFFffffff),
//                           border: Border.all(
//                               style: BorderStyle.solid,
//                               color: Colors.grey.shade100),
//                           shape: BoxShape.circle),
//                     ),
//                   )
//                 : Container(
//                     height: 50,
//                     width: 50,
//                     decoration: const BoxDecoration(
//                       color: Color.fromRGBO(14, 142, 253, 0.05),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Image(
//                         image: AssetImage("assets/images/$image.png"),
//                       ),
//                     ),
//                   ),
//             Container(
//               height: 10,
//             ),
//             loadingBal
//                 ? Shimmer.fromColors(
//                     baseColor: Colors.grey.shade300,
//                     highlightColor: const Color(0xFFe6faff),
//                     child: Container(
//                       width: 70,
//                       height: 20,
//                       decoration: BoxDecoration(
//                           color: const Color(0xFFffffff),
//                           border: Border.all(
//                               style: BorderStyle.solid,
//                               color: Colors.grey.shade100),
//                           borderRadius: BorderRadius.circular(15)),
//                     ),
//                   )
//                 : AutoSizeText(
//                     buttonName,
//                     style: CustomTextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: const Color(0xFF108FFD), //s.black.withOpacity(.8),
//                       fontSize: 14,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     softWrap: true,
//                     textAlign: TextAlign.center,
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
