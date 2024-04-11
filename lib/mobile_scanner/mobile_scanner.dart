// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:luvpay/variables.dart';
// import 'package:luvpay/widgets/qr_scanner_overlay.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:auto_size_text/auto_size_text.dart';

// class ZMobileScanner extends StatefulWidget {
//   final Function(String) callback;
//   final bool isFrontCam;
//   final String title;
//   const ZMobileScanner(
//       {Key? key,
//       required this.callback,
//       required this.isFrontCam,
//       required this.title})
//       : super(key: key);

//   @override
//   State<ZMobileScanner> createState() =>
//       // ignore: no_logic_in_create_state
//       _ZMobileScannerState(callback, isFrontCam);
// }

// class _ZMobileScannerState extends State<ZMobileScanner> {
//   bool? isFrontCam;
//   MobileScannerController cameraController = MobileScannerController();

//   late Function(String) callback;

//   _ZMobileScannerState(this.callback, bool this.isFrontCam);

//   @override
//   void initState() {
//     if (isFrontCam!) cameraController.facing = CameraFacing.front;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         callback('');

//         return true;
//       },
//       child: Stack(
//         children: <Widget>[
//           MobileScanner(
//               allowDuplicates: false,
//               controller: cameraController,
//               onDetect: (barcode, args) {
//                 if (barcode.rawValue == null) {
//                   callback('');
//                 } else {
//                   final String code = barcode.rawValue!;
//                   callback(code);
//                 }
//               }),
//           QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.5)),
//           SizedBox(
//               height: 200,
//               width: MediaQuery.of(context).size.width,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 30),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width,
//                       child: AutoSizeText(
//                         widget.title,
//                         maxLines: 2,
//                         textAlign: TextAlign.left,
//                         style: Variable.gfont.override(
//                             color: const Color(0xFFffffff),
//                             fontSize: 14,
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.normal,
//                             letterSpacing: 0),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Text(
//                           'Note : ',
//                           style: Variable.gfont.override(
//                               color: Colors.red,
//                               fontSize: 16,
//                               fontFamily: 'Poppins',
//                               fontWeight: FontWeight.normal,
//                               letterSpacing: 0),
//                         ),
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * 0.65,
//                           child: AutoSizeText(
//                             'Please make sure that the QR code is at the center area of a scanner.',
//                             maxLines: 2,
//                             textAlign: TextAlign.left,
//                             style: Variable.gfont.override(
//                                 color: const Color(0xFFffffff),
//                                 fontSize: 14,
//                                 fontFamily: 'Poppins',
//                                 fontWeight: FontWeight.normal,
//                                 letterSpacing: 0),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               )),
//           Positioned(
//             child: Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 color: Colors.transparent,
//                 height: 80,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: <Widget>[
//                     IconButton(
//                       color: Color(0xFFffffff),
//                       icon: ValueListenableBuilder(
//                         valueListenable: cameraController.torchState,
//                         builder: (context, state, child) {
//                           switch (state) {
//                             case TorchState.off:
//                               return const Icon(Icons.flash_off,
//                                   color: Colors.grey);
//                             case TorchState.on:
//                               return const Icon(Icons.flash_on,
//                                   color: Colors.blue);
//                           }
//                         },
//                       ),
//                       iconSize: 32.0,
//                       onPressed: () => cameraController.toggleTorch(),
//                     ),
//                     InkWell(
//                       onTap: () async {
//                         callback('');
//                       },
//                       child: const Icon(
//                         Icons.cancel,
//                         color: Colors.red,
//                         size: 50,
//                       ),
//                     ),
//                     IconButton(
//                       color: Color(0xFFffffff),
//                       icon: ValueListenableBuilder(
//                         valueListenable: cameraController.cameraFacingState,
//                         builder: (context, state, child) {
//                           return const Icon(
//                             Icons.cameraswitch_outlined,
//                             color: Colors.blue,
//                           );
//                         },
//                       ),
//                       iconSize: 32.0,
//                       onPressed: () => cameraController.switchCamera(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// mobileScanQrCode(BuildContext prmContext, String title,
//     Function(String, BuildContext) callback, bool isFrontCam) {
//   showModalBottomSheet(
//       context: prmContext,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return AnnotatedRegion<SystemUiOverlayStyle>(
//           value: const SystemUiOverlayStyle(
//             statusBarColor: Color(0xFF000000),
//             systemNavigationBarColor: Color(0xFF000000),
//             statusBarIconBrightness: Brightness.light,
//             systemNavigationBarIconBrightness: Brightness.light,
//           ),
//           child: SafeArea(
//             child: Scaffold(
//               backgroundColor: Colors.transparent,
//               body: MediaQuery(
//                 data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
//                 child: Container(
//                   height: MediaQuery.of(context).size.height,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFffffff),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: ZMobileScanner(
//                     callback: (String res) {
//                       callback(res, context);
//                     },
//                     title: title,
//                     isFrontCam: isFrontCam,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       });
// }
