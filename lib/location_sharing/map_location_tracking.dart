// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:luvpark/classess/color_component.dart';
// import 'package:luvpark/classess/variables.dart';
// import 'package:luvpark/custom_widget/custom_text.dart';
// import 'package:luvpark/custom_widget/custom_textfield.dart';
// import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
// import 'package:luvpark/location_sharing/fire_base_config.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => MapScreenState();
// }

// class MapScreenState extends State<MapScreen> {
//   final TextEditingController mobileNumber = TextEditingController();

//   bool isVisible = true;
//   // ignore: cancel_subscriptions
//   late StreamController<void> _dataController;
//   // ignore: cancel_subscriptions
//   late StreamSubscription<void>? locationSubscription;

//   @override
//   void initState() {
//     _dataController = StreamController<void>();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     locationSubscription!.cancel();
//     _dataController.close();
//   }

//   void streamData() {
//     locationSubscription = _dataController.stream.listen((data) {});
//     fetchDataPeriodically();
//   }

//   void fetchDataPeriodically() async {
//     locationSubscription = Stream.periodic(const Duration(seconds: 5), (count) {
//       fetchData();
//     }).listen((event) {});
//   }

//   Future<void> fetchData() async {
//     await Future.delayed(const Duration(seconds: 3));
//     _startLocationTracking();
//   }

//   Future<void> _startLocationTracking() async {
//     final prefs = await SharedPreferences.getInstance();
//     var firebaseCid = prefs.getString('firebase_cid');
//     CollectionReference users =
//         FirebaseFirestore.instance.collection('live_tracking');

//     try {
//       // Get user's current location
//       var position = await DashboardComponent.getPositionLatLong();

//       // Query the database based on the 'to' field
//       QuerySnapshot<Object?> userSnapshot =
//           await users.where('to', isEqualTo: 2).get();
//       print("userSnapshot $userSnapshot");
//       Map<String, String> insertData = {
//         'from': "1",
//         'to': "2",
//         'lat': position.latitude.toString(),
//         'long': position.longitude.toString(),
//         'is_accepted': userSnapshot.docs.isEmpty ? 'N' : 'Y',
//       };

//       if (userSnapshot.docs.isEmpty) {
//         // If the document doesn't exist, insert data
//         print('Insert process');
//         DocumentReference documentReference = await users.add(insertData);
//         String userId = documentReference.id;
//         prefs.setString('firebase_cid', userId);
//       } else {
//         // If the document exists, update data
//         print('Update process');
//         await FirebaseService.updateDocumentData(firebaseCid!, insertData);
//       }

//       Navigator.pop(context);
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MediaQuery(
//       data: MediaQuery.of(context)
//           .copyWith(textScaler: const TextScaler.linear(1)),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Wrap(
//           children: [
//             Center(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   CustomDisplayText(
//                     label: "Share Location ",
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                   Container(
//                     height: 5,
//                   ),
//                   CustomDisplayText(
//                     label: "Share your location to your jug jug ahh ahh ",
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: AppColor.textSubColor,
//                   ),
//                   Container(
//                     height: 15,
//                   ),
//                   CustomMobileNumber(
//                     labelText: "Mobile No",
//                     controller: mobileNumber,
//                     inputFormatters: [Variables.maskFormatter],
//                   ),
//                   Container(height: 20),
//                   ElevatedButton(
//                       onPressed: () async {
//                         print("inatay");
//                         final prefs = await SharedPreferences.getInstance();
//                         var firebaseCid = prefs.getString('firebase_cid');
//                         print("test id ${firebaseCid == null}");

//                         if (firebaseCid == null) {
//                           prefs.remove("firebase_cid");

//                           streamData();
//                         } else {
//                           print('else');
//                           Navigator.pop(context);
//                           FirebaseFirestore.instance
//                               .collection('live_tracking')
//                               .doc(firebaseCid)
//                               .delete()
//                               .then((_) {
//                             prefs.remove("firebase_cid");
//                             print('Document successfully deleted!');
//                             streamData();
//                           }).catchError((error) {
//                             print('Error deleting document: $error');
//                           });
//                         }
//                       },
//                       child: Text("Click Me"))
//                   // IgnorePointer(
//                   //   child: CustomButton(
//                   //     label: "Share",
//                   //     onTap: () async {
//                   //       WidgetsBinding.instance.addPostFrameCallback((_) async {
//                   // final prefs = await SharedPreferences.getInstance();
//                   // var firebaseCid = prefs.getString('firebase_cid');
//                   // print("test id $firebaseCid");

//                   // // if (firebaseCid == null) {
//                   // //   prefs.remove("firebase_cid");
//                   // //   Navigator.pop(context);
//                   // //   //  streamData();
//                   // // } else {
//                   // //   print('else');
//                   // //   Navigator.pop(context);
//                   // //   FirebaseFirestore.instance
//                   // //       .collection('live_tracking')
//                   // //       .doc(firebaseCid)
//                   // //       .delete()
//                   // //       .then((_) {
//                   // //     prefs.remove("firebase_cid");
//                   // //     print('Document successfully deleted!');
//                   // //     //  streamData();
//                   // //   }).catchError((error) {
//                   // //     print('Error deleting document: $error');
//                   // //   });
//                   // // }
//                   //       });
//                   //     },
//                   //   ),
//                   // ),
//                   ,
//                   Container(height: MediaQuery.of(context).viewInsets.bottom)
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
