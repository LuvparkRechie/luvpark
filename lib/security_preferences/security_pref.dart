// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:luvpay/core/theme/app_color.dart';
// import 'package:luvpay/custom/custom_textfield.dart';
// import 'package:luvpay/phone_type/appbar_widget.dart';
// import 'package:luvpay/widgets/custom_parent_widget.dart';

// import '../class/DbProvider.dart';
// import '../class/biometric_login.dart';
// import '../widgets/snackbar_dialog.dart';

// enum _SupportState {
//   unknown,
//   supported,
//   unsupported,
// }

// class SecurityPreferences extends StatefulWidget {
//   const SecurityPreferences({
//     super.key,
//   });

//   @override
//   State<SecurityPreferences> createState() => _SecurityPreferencesState();
// }

// class _SecurityPreferencesState extends State<SecurityPreferences> {
//   bool secured = false;
//   bool enableBioTrans = false;
//   bool isAuth = false;
//   final LocalAuthentication auth = LocalAuthentication();
//   _SupportState supportState = _SupportState.unknown;
//   @override
//   void initState() {
//     super.initState();
//     auth.isDeviceSupported().then(
//           (bool isSupported) => setState(() => supportState = isSupported
//               ? _SupportState.supported
//               : _SupportState.unsupported),
//         );

//     DbProvider().getAuthState().then((value) {
//       setState(() {
//         secured = value;
//       });
//     });
//     DbProvider().getAuthTransaction().then((value) async {
//       setState(() {
//         enableBioTrans = value;
//       });
//     });
//   }

//   void _authenticateWithBiometrics(isTransaction) async {
//     // ignore: unused_local_variable
//     setState(() {
//       isAuth = true;
//     });

//     final LocalAuthentication auth = LocalAuthentication();
//     // ignore: unused_local_variable
//     bool canCheckBiometrics = false;

//     try {
//       canCheckBiometrics = await auth.canCheckBiometrics;
//     } catch (e) {
//       debugPrint("$e");
//     }

//     bool authenticated = false;

//     try {
//       authenticated = await auth.authenticate(
//         localizedReason: 'Touch your finger on the sensor to login',
//         options: const AuthenticationOptions(
//           stickyAuth: true,
//           sensitiveTransaction: false,
//           biometricOnly: true,
//         ),
//       );
//     } catch (e) {
//       debugPrint("$e");
//     }

//     setState(() {
//       isAuth = authenticated ? true : false;
//     });

//     if (isAuth) {
//       if (isTransaction) {
//         setState(() {
//           enableBioTrans = false;
//         });
//         DbProvider().saveAuthTransaction(false);
//       } else {
//         setState(() {
//           secured = false;
//         });
//         DbProvider().saveAuthState(false);
//       }
//     } else {
//       if (isTransaction) {
//         setState(() {
//           enableBioTrans = true;
//         });
//         DbProvider().saveAuthTransaction(true);
//       } else {
//         setState(() {
//           secured = true;
//         });
//         DbProvider().saveAuthState(true);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomParent1Widget(
//         appBarheaderText: "Security Preferences",
//         appBarIconClick: () {
//           Navigator.of(context).pop();
//         },
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Login Security",
//                 style: CustomTextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black,
//                 ),
//               ),
//               Container(
//                 height: 10,
//               ),
//               Text(
//                 "Our robust and multi-layered security measures ensure that only authorized users can access your accounts.",
//                 style: GoogleFonts.varela(
//                   fontWeight: FontWeight.normal,
//                   color: Colors.black.withOpacity(.8),
//                 ),
//               ),
//               Container(
//                 height: 20,
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   color: const Color(0xFFffffff),
//                 ),
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             //  crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Icon(
//                                 Icons.fingerprint,
//                                 color: AppColor.primaryColor,
//                               ),
//                               Container(
//                                 width: 10,
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Mobile App Login",
//                                     style: CustomTextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: AppColor.primaryColor,
//                                     ),
//                                   ),
//                                   Container(
//                                     height: 5,
//                                   ),
//                                   Text(
//                                     "Enable biometric login.",
//                                     style: GoogleFonts.varela(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.normal,
//                                       color: Colors.black.withOpacity(.7),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Switch(
//                             value: secured,
//                             onChanged: (bool value) async {
//                               setState(() {
//                                 secured = value;
//                               });
//                               final localAuth = LocalAuthentication();

//                               if (secured) {
//                                 BiometricLogin()
//                                     .checkBiometrics()
//                                     .then((canCheckBiometrics) async {
//                                   if (canCheckBiometrics) {
//                                     List<BiometricType> availableBiometrics =
//                                         await localAuth
//                                             .getAvailableBiometrics();

//                                     if (availableBiometrics.isNotEmpty) {
//                                       DbProvider().saveAuthState(value);
//                                     } else {
//                                       // ignore: use_build_context_synchronously
//                                       showAlertDialog(
//                                           context,
//                                           "Fingerprint required",
//                                           "Fingerprint is not set up on your device. Go to 'Settings > Security' to add your fingerprint.",
//                                           () async {
//                                         Navigator.of(context).pop();
//                                       });
//                                       DbProvider().saveAuthState(false);
//                                       setState(() {
//                                         secured = false;
//                                       });
//                                     }
//                                   } else {
//                                     showAlertDialog(context, "Error",
//                                         "Fingerprint is not available on this device.",
//                                         () {
//                                       Navigator.of(context).pop();
//                                     });
//                                     DbProvider().saveAuthState(false);
//                                     setState(() {
//                                       secured = false;
//                                     });
//                                   }
//                                 });
//                               } else {
//                                 // DbProvider().saveAuthState(false);
//                                 _authenticateWithBiometrics(false);
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Container(
//                 height: 30,
//               ),
//               Text(
//                 "Transaction Security",
//                 style: CustomTextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black,
//                 ),
//               ),
//               Container(
//                 height: 10,
//               ),
//               Text(
//                 "Whether you're making online purchases, transferring funds, or conducting any financial transaction,"
//                 " our multi-layered security protocols are constantly vigilant to keep your money safe.",
//                 style: GoogleFonts.varela(
//                   fontWeight: FontWeight.normal,
//                   color: Colors.black.withOpacity(.8),
//                 ),
//               ),
//               Container(
//                 height: 20,
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   color: const Color(0xFFffffff),
//                 ),
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             //  crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Icon(
//                                 Icons.fingerprint,
//                                 color: AppColor.primaryColor,
//                               ),
//                               Container(
//                                 width: 10,
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Mobile App Transactions",
//                                     style: CustomTextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: AppColor.primaryColor,
//                                     ),
//                                   ),
//                                   Container(
//                                     height: 5,
//                                   ),
//                                   Text(
//                                     "Enable biometric transaction.",
//                                     style: GoogleFonts.varela(
//                                       fontWeight: FontWeight.normal,
//                                       color: Colors.black.withOpacity(.7),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Switch(
//                             value: enableBioTrans,
//                             onChanged: (bool value) async {
//                               setState(() {
//                                 enableBioTrans = value;
//                               });
//                               final localAuth = LocalAuthentication();

//                               if (enableBioTrans) {
//                                 BiometricLogin()
//                                     .checkBiometrics()
//                                     .then((canCheckBiometrics) async {
//                                   if (canCheckBiometrics) {
//                                     List<BiometricType> availableBiometrics =
//                                         await localAuth
//                                             .getAvailableBiometrics();

//                                     if (availableBiometrics.isNotEmpty) {
//                                       DbProvider().saveAuthTransaction(value);
//                                     } else {
//                                       // ignore: use_build_context_synchronously
//                                       showAlertDialog(
//                                           context,
//                                           "Fingerprint required",
//                                           "Fingerprint is not set up on your device. Go to 'Settings > Security' to add your fingerprint.",
//                                           () async {
//                                         Navigator.of(context).pop();
//                                       });
//                                       DbProvider().saveAuthTransaction(false);
//                                       setState(() {
//                                         enableBioTrans = false;
//                                       });
//                                     }
//                                   } else {
//                                     showAlertDialog(context, "Error",
//                                         "Fingerprint is not available on this device.",
//                                         () {
//                                       Navigator.of(context).pop();
//                                     });
//                                     DbProvider().saveAuthTransaction(false);
//                                     setState(() {
//                                       enableBioTrans = false;
//                                     });
//                                   }
//                                 });
//                               } else {
//                                 _authenticateWithBiometrics(true);
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ));
//   }

//   Widget detailsProf(String label, String value) {
//     return Row(
//       children: [
//         Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: TextStyle(color: Colors.black.withOpacity(.7)),
//             )),
//         Container(
//           width: 5,
//         ),
//         Expanded(
//             flex: 4,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   " $value",
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.normal,
//                     fontFamily: "Open Sans",
//                   ),
//                 ),
//                 Container(
//                   height: 5,
//                 ),
//                 const Divider(
//                   thickness: 1.5,
//                 ),
//               ],
//             ))
//       ],
//     );
//   }
// }
