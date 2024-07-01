// import 'dart:io';

// import 'package:animate_do/animate_do.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
// import 'package:gallery_saver/gallery_saver.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:intl/intl.dart';
// import 'package:luvpark/bottom_tab/bottom_tab.dart';
// import 'package:luvpark/classess/color_component.dart';
// import 'package:luvpark/classess/textstyle.dart';
// import 'package:luvpark/classess/variables.dart';
// import 'package:luvpark/custom_widget/custom_loader.dart';
// import 'package:luvpark/custom_widget/custom_parent_widget.dart';
// import 'package:luvpark/custom_widget/custom_text.dart';
// import 'package:luvpark/custom_widget/snackbar_dialog.dart';
// import 'package:luvpark/rating/rate.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:share_plus/share_plus.dart';

// // ignore: must_be_immutable
// class ReserveReceipt extends StatefulWidget {
//   String spaceName,
//       parkArea,
//       plateNo,
//       startDate,
//       startTime,
//       endTime,
//       hours,
//       amount,
//       refno;
//   final Function? onTap;
//   final bool isReserved;
//   final String? dtOut, dateIn;
//   final String isAutoExtend;
//   final String address;
//   final double lat, long;
//   final bool canReserved;
//   final int tab;
//   final Object paramsCalc;
//   bool isVehicleSelected;
//   final bool? isShowRate;
//   final int? reservationId;
//   final int? ticketId;

//   ReserveReceipt({
//     required this.spaceName,
//     required this.parkArea,
//     required this.plateNo,
//     required this.isReserved,
//     required this.startDate,
//     required this.startTime,
//     required this.endTime,
//     required this.hours,
//     required this.amount,
//     required this.refno,
//     required this.lat,
//     required this.long,
//     required this.isVehicleSelected,
//     required this.canReserved,
//     required this.paramsCalc,
//     required this.tab,
//     required this.address,
//     required this.isAutoExtend,
//     this.onTap,
//     this.isShowRate = false,
//     this.reservationId = 0,
//     this.ticketId = 0,
//     this.dtOut,
//     this.dateIn,
//     super.key,
//   });

//   @override
//   State<ReserveReceipt> createState() => _ReserveReceiptState();
// }

// class _ReserveReceiptState extends State<ReserveReceipt>
//     with SingleTickerProviderStateMixin {
//   // ignore: prefer_typing_uninitialized_variables

//   bool loadingScreen = true;
//   bool isLoadingChkIn = false;
//   String myAddress = "";
//   BuildContext? mainContext;
//   List<Marker> markers = <Marker>[];

//   List<String> images = [
//     'assets/images/marker.png',
//     'assets/images/red_marker.png'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     showRate();
//   }

//   @override
//   dispose() {
//     super.dispose();
//   }

//   void showRate() {
//     if (widget.isShowRate!) {
//       Future.delayed(const Duration(milliseconds: 500), () {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return PopScope(
//               canPop: false,
//               child: AlertDialog(
//                 backgroundColor: Colors.white,
//                 surfaceTintColor: Colors.white,
//                 content: FadeIn(
//                     duration: const Duration(seconds: 1),
//                     child: RateUs(
//                         reservationId: widget.reservationId, callBack: () {})),
//               ),
//             );
//           },
//         );
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     mainContext = context;
//     return CustomParent1Widget(
//       canPop: true,
//       appBarheaderText: "Parking Ticket",
//       hasPadding: false,
//       appBarIconClick: () {
//         Variables.pageTrans(
//             const MainLandingScreen(
//               index: 1,
//             ),
//             context);
//       },
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(
//               top: 10.0,
//               left: 10.0,
//               right: 10,
//             ),
//             child: Container(
//               height: 76,
//               decoration: BoxDecoration(
//                 color: AppColor.primaryColor,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     spreadRadius: 1,
//                     blurRadius: 4,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Stack(
//                 alignment: Alignment.centerRight,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(right: 20),
//                     child: Icon(
//                       Icons.check_circle_outline_rounded,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(left: 20),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CustomDisplayText(
//                               label: 'Your booking is now confirmed!',
//                               fontWeight: FontWeight.bold,
//                               fontSize: 15,
//                               color: Colors.white,
//                             ),
//                             CustomDisplayText(
//                               label: 'Scan QR code below to check-in',
//                               fontWeight: FontWeight.w400,
//                               fontSize: 12,
//                               color: Colors.white,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(
//                 horizontal: 20,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     height: 50,
//                   ),
//                   widget.tab == 1
//                       ? Container()
//                       : Center(
//                           child: Container(
//                             width: 150,
//                             height: 150,
//                             decoration: ShapeDecoration(
//                               color: Colors.white,
//                               shadows: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.2),
//                                   spreadRadius: 1,
//                                   blurRadius: 4,
//                                   offset: Offset(0, 2),
//                                 ),
//                               ],
//                               shape: RoundedRectangleBorder(
//                                 side: const BorderSide(
//                                     width: 2, color: Color(0x162563EB)),
//                                 borderRadius: BorderRadius.circular(28),
//                               ),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(15.0),
//                               child: QrImageView(
//                                 data: widget.refno,
//                                 version: QrVersions.auto,
//                                 gapless: false,
//                               ),
//                             ),
//                           ),
//                         ),
//                   Container(height: 50),
//                   widget.tab == 1
//                       ? Container()
//                       : Container(
//                           height: 10,
//                         ),
//                   widget.tab == 1
//                       ? Container()
//                       : Container(
//                           height: 10,
//                         ),
//                   ReceiptBody(
//                     amount: widget.amount,
//                     plateNo: widget.plateNo,
//                     startDate: widget.startDate,
//                     startTime: widget.startTime,
//                     endTime: widget.endTime,
//                     hours: widget.hours,
//                     parkArea: widget.parkArea,
//                     refno: widget.refno,
//                   ),
//                   Container(
//                     height: 20,
//                   ),
//                   IntrinsicHeight(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Expanded(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: AppColor.primaryColor,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: InkWell(
//                               onTap: () {
//                                 _shareQrCode();
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     // const Icon(
//                                     //   Icons.ios_share_outlined,
//                                     //   color: Colors.white,
//                                     //   size: 24,
//                                     // ),
//                                     Icon(
//                                       Iconsax.share,
//                                       size: 20,
//                                       color: Colors.white,
//                                     ),
//                                     Container(width: 5),
//                                     Text("Share",
//                                         style: Platform.isAndroid
//                                             ? GoogleFonts.dmSans(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.w600,
//                                                 letterSpacing: 1,
//                                                 fontSize: 14)
//                                             : TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.w600,
//                                                 letterSpacing: 1,
//                                                 fontSize: 14,
//                                                 fontFamily: "SFProTextReg",
//                                               )),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Container(width: 20),
//                         Expanded(
//                           child: Container(
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: AppColor.primaryColor,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: InkWell(
//                               onTap: () {
//                                 saveToGallery();
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     // const Icon(
//                                     //   Icons.download_outlined,
//                                     //   color: Colors.white,
//                                     //   size: 24,
//                                     // ),
//                                     Icon(
//                                       Iconsax.save_2,
//                                       color: Colors.white,
//                                       size: 20,
//                                     ),
//                                     Container(width: 5),
//                                     Text(
//                                       "Save",
//                                       style: Platform.isAndroid
//                                           ? GoogleFonts.dmSans(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.w600,
//                                               letterSpacing: 1,
//                                               fontSize: 14)
//                                           : TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.w600,
//                                               letterSpacing: 1,
//                                               fontSize: 14,
//                                               fontFamily: "SFProTextReg",
//                                             ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // if (widget.isReserved && int.parse(widget.tab.toString()) == 0)
//           //   Container(
//           //     decoration: BoxDecoration(
//           //       borderRadius: BorderRadius.vertical(
//           //         top: Radius.circular(20),
//           //       ),
//           //       color: Colors.white,
//           //     ),
//           //     width: Variables.screenSize.width,
//           //     child: Padding(
//           //       padding:
//           //           const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//           //       child: CustomButton(
//           //           label: "Check-in",
//           //           onTap: () async {
//           //             CustomModal(context: context).loader();
//           //             Functions.getUserBalance((data) async {
//           //               if (data["user_bal"] < data["min_wal_bal"]) {
//           //                 Navigator.of(context).pop();
//           //                 showAlertDialog(
//           //                     context,
//           //                     "Attention",
//           //                     "Your balance is below the required minimum for this feature. "
//           //                         "Please ensure a minimum balance of ${data["min_wal_bal"]} tokens to access the requested service.",
//           //                     () {
//           //                   Navigator.of(context).pop();
//           //                 });
//           //                 return;
//           //               }
//           //               if (data != "null" || data != "No Internet") {
//           //                 Functions.computeDistanceResorChckIN(
//           //                     context, LatLng(widget.lat, widget.long),
//           //                     (success) {
//           //                   if (success["success"]) {
//           //                     if (success["can_checkIn"]) {
//           //                       Functions.checkIn(
//           //                           widget.ticketId, widget.lat, widget.long,
//           //                           (cbData) {
//           //                         Navigator.pop(context);
//           //                         if (cbData == "Success") {
//           //                           showAlertDialog(context, "Success",
//           //                               "Successfully checked-in.", () {
//           //                             Navigator.of(context).pop();
//           //                             Variables.pageTrans(
//           //                                 const MainLandingScreen(
//           //                                   index: 1,
//           //                                 ),
//           //                                 context);
//           //                           });
//           //                         }
//           //                       });
//           //                     } else {
//           //                       Navigator.pop(context);
//           //                       showAlertDialog(
//           //                           context, "LuvPark", success["message"], () {
//           //                         Navigator.of(context).pop();
//           //                       });
//           //                     }
//           //                   } else {
//           //                     Navigator.pop(context);
//           //                   }
//           //                 });
//           //               } else {
//           //                 Navigator.pop(context);
//           //               }
//           //             });
//           //           }),
//           //     ),
//           //   ),
//         ],
//       ),
//     );
//   }

//   Widget printScreen() {
//     return Container(
//       color: AppColor.bodyColor,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               height: 20,
//             ),
//             widget.tab == 1
//                 ? Container()
//                 : Center(
//                     child: Container(
//                       width: 150,
//                       height: 150,
//                       decoration: ShapeDecoration(
//                         shape: RoundedRectangleBorder(
//                           side: const BorderSide(
//                               width: 2, color: Color(0x162563EB)),
//                           borderRadius: BorderRadius.circular(28),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(15.0),
//                         child: QrImageView(
//                           data: widget.refno,
//                           version: QrVersions.auto,
//                           gapless: false,
//                         ),
//                       ),
//                     ),
//                   ),
//             widget.tab == 1
//                 ? Container()
//                 : Container(
//                     height: 10,
//                   ),
//             widget.tab == 1
//                 ? Container()
//                 : Center(
//                     child: Text(
//                       "Scan QR code",
//                       style: CustomTextStyle(
//                         color: const Color(0xFF353536),
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         height: 0,
//                         letterSpacing: -0.36,
//                       ),
//                     ),
//                   ),
//             widget.tab == 1
//                 ? Container()
//                 : Container(
//                     height: 5,
//                   ),
//             widget.tab == 1
//                 ? Container()
//                 : Text(
//                     "Scan this code to check-in",
//                     style: CustomTextStyle(
//                       color: const Color(0xFF353536),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       height: 0,
//                       letterSpacing: -0.28,
//                     ),
//                   ),
//             widget.tab == 1
//                 ? Container()
//                 : Container(
//                     height: 38,
//                   ),
//             ReceiptBody(
//               amount: widget.amount,
//               plateNo: widget.plateNo,
//               startDate: widget.startDate,
//               startTime: widget.startTime,
//               endTime: widget.endTime,
//               hours: widget.hours,
//               parkArea: widget.parkArea,
//               refno: widget.refno,
//             ),
//             Container(
//               height: 10,
//             ),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: AutoSizeText(
//                 widget.parkArea,
//                 style: CustomTextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 maxLines: 1,
//               ),
//             ),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: AutoSizeText(
//                 myAddress,
//                 style: CustomTextStyle(
//                   color: const Color(0xFF8D8D8D),
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 maxLines: 1,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   _shareQrCode() async {
//     File? imgFile;
//     CustomModal(context: context).loader();

//     final directory = (await getApplicationDocumentsDirectory()).path;
//     Uint8List bytes = await ScreenshotController().captureFromWidget(
//       printScreen(),
//     );
//     Uint8List pngBytes = bytes.buffer.asUint8List();

//     setState(() {
//       imgFile = File('$directory/screenshot.png');
//       imgFile!.writeAsBytes(pngBytes);
//     });
//     // ignore: use_build_context_synchronously
//     Navigator.of(context).pop();
//     // ignore: deprecated_member_use
//     await Share.shareFiles([imgFile!.path]);
//   }

//   void saveToGallery() async {
//     CustomModal(context: context).loader();
//     ScreenshotController()
//         .captureFromWidget(printScreen(), delay: const Duration(seconds: 3))
//         .then((image) async {
//       final dir = await getApplicationDocumentsDirectory();
//       final imagePath = await File('${dir.path}/captured.png').create();
//       await imagePath.writeAsBytes(image);

//       GallerySaver.saveImage(imagePath.path).then((result) {
//         showAlertDialog(context, "Success", "Successfully saved.", () async {
//           Navigator.of(context).pop();
//           Navigator.of(context).pop();
//           //getGalleryPackageName();
//         });
//       });
//     });
//   }
// }

// class ReceiptBody extends StatelessWidget {
//   final String amount,
//       plateNo,
//       startDate,
//       startTime,
//       endTime,
//       hours,
//       refno,
//       parkArea;
//   const ReceiptBody(
//       {super.key,
//       required this.amount,
//       required this.plateNo,
//       required this.startDate,
//       required this.startTime,
//       required this.endTime,
//       required this.hours,
//       required this.parkArea,
//       required this.refno});

//   @override
//   Widget build(BuildContext context) {
//     return backup();
//   }

//   Widget backup() {
//     return Container(
//       clipBehavior: Clip.antiAlias,
//       decoration: ShapeDecoration(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
//         shadows: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(18),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'Total Token',
//                   style: CustomTextStyle(
//                     color: const Color(0xFF353536),
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     height: 0,
//                     letterSpacing: -0.32,
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     toCurrencyString(amount),
//                     style: CustomTextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       height: 0,
//                       letterSpacing: -0.32,
//                     ),
//                     textAlign: TextAlign.right,
//                     softWrap: true,
//                   ),
//                 )
//               ],
//             ),
//             const Divider(),
//             Container(
//               height: 10,
//             ),
//             confirmDetails("Vehicle", plateNo.toUpperCase()),
//             Container(
//               height: 10,
//             ),
//             confirmDetails("Date In-Out", startDate),
//             Container(
//               height: 10,
//             ),
//             confirmDetails("Time In-Out",
//                 "${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(startTime))} - ${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(endTime))}"),
//             Container(
//               height: 10,
//             ),
//             confirmDetails(
//                 "Duration", "$hours ${int.parse(hours) > 1 ? "hrs" : "hr"}"),
//             Container(
//               height: 10,
//             ),
//             confirmDetails("Reference", refno.toString()),
//             Container(
//               height: 10,
//             ),
//             confirmDetails("Parking Zone", parkArea.toString()),
//             Container(
//               height: 10,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget confirmDetails(String label, String value) {
//     return Row(
//       children: [
//         Expanded(
//           child: AutoSizeText(
//             label,
//             style: CustomTextStyle(
//               fontWeight: FontWeight.w500,
//               color: Colors.black54,
//             ),
//             textAlign: TextAlign.left,
//             softWrap: true,
//             maxLines: 1,
//             minFontSize: 1,
//           ),
//         ),
//         Expanded(
//           child: AutoSizeText(
//             value,
//             style: CustomTextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//             softWrap: true,
//             maxLines: 1,
//             minFontSize: 1,
//           ),
//         ),
//       ],
//     );
//   }
// }
