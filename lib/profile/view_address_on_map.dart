// // ignore: must_be_immutable
// import 'dart:convert';

// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:luvpay/core/theme/app_color.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:luvpay/custom/header_title&subtitle.dart';
// import 'package:luvpay/http_request/http_request_model.dart';
// import 'package:luvpay/map_components/map_components.dart';
// import 'package:luvpay/map_components/search_places.dart';
// import 'package:luvpay/variables.dart';
// import 'package:luvpay/widgets/custom_loader.dart';
// import 'package:luvpay/widgets/snackbar_dialog.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // ignore: must_be_immutable
// class UpdateProfStep2 extends StatefulWidget {
//   // final TextEditingController address1, address2, zipCode;

//   // int regionId, provinceId, cityId, brgyId;

//   // final GlobalKey<FormState> formKey;
//   final VoidCallback onNextPage;
//   final VoidCallback onPreviousPage;

//   UpdateProfStep2(
//       {super.key, required this.onPreviousPage, required this.onNextPage
//       // required this.address1,
//       // required this.address2,
//       // required this.zipCode,
//       // required this.regionId,
//       // required this.provinceId,
//       // required this.cityId,
//       // required this.brgyId,
//       // required this.formKey
//       });

//   @override
//   State<UpdateProfStep2> createState() => _RegistrationPage1State();
// }

// class _RegistrationPage1State extends State<UpdateProfStep2> {
//   bool loading = true;
//   var akongP;
//   TextEditingController searchPlaceController = TextEditingController();
//   LatLng? startLocation;
//   late GoogleMapController mapController;
//   late CameraPosition? cameraPositions;
//   String myAddress = "";
//   List<Marker> markers = <Marker>[];
//   Set<Circle> _circles = {};
//   List<String> images = [
//     'assets/images/marker.png',
//     'assets/images/red_marker.png'
//   ];
//   @override
//   void initState() {
//     super.initState();
//     getAccountData();
//   }

//   void getAccountData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     akongP = prefs.getString(
//       'userData',
//     );
//     akongP = jsonDecode(akongP!);

//     getCurrentLocation();
//   }

//   Future<Uint8List> getImages(String path, int width) async {
//     ByteData data = await rootBundle.load(path);
//     ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
//         targetHeight: width);
//     ui.FrameInfo fi = await codec.getNextFrame();
//     return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
//         .buffer
//         .asUint8List();
//   }

//   void getCurrentLocation() async {
//     CustomModal(context: context).loader();
//     bool servicestatus = await Geolocator.isLocationServiceEnabled();

//     if (!servicestatus) {
//       // ignore: use_build_context_synchronously
//       showAlertDialog(context, "Location Disabled",
//           "To continue, turn on device location, which uses Google's location service.",
//           () {
//         Navigator.of(context).pop();
//         if (Navigator.canPop(context)) {
//           Navigator.of(context).pop();
//         }
//       });
//       return;
//     }
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     // ignore: use_build_context_synchronously

//     displayMapData(position.latitude, position.longitude);
//   }

//   displayMapData(lat, lng) async {
//     setState(() {
//       markers = [];
//       cameraPositions = null;
//     });

//     final Uint8List availabeMarkIcons = await getImages(images[0], 150);
//     int ctr = 0;
//     BitmapDescriptor bitMap;

//     bitMap = BitmapDescriptor.fromBytes(availabeMarkIcons);
//     markers.add(
//       Marker(
//           markerId: MarkerId(ctr.toString()),
//           position: LatLng(
//               double.parse(lat.toString()), double.parse(lng.toString())),
//           visible: true,
//           onTap: () async {}),
//     );

//     setState(() {
//       startLocation =
//           LatLng(double.parse(lat.toString()), double.parse(lng.toString()));
//       cameraPositions = CameraPosition(
//         target: startLocation!,
//         zoom: 16,
//         tilt: 0,
//         bearing: 0,
//       );

//       loading = false;
//     });
//     // ignore: use_build_context_synchronously
//     Navigator.of(context).pop();
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     setState(() {
//       mapController = controller;
//     });
//     _addCircle();
//   }

//   _addCircle() {
//     // Create a Circle with specified properties
//     _circles.add(
//       Circle(
//         circleId: const CircleId("myCircle"), // Unique ID for the circle
//         center: LatLng(
//             startLocation!.latitude, startLocation!.longitude), // Circle center
//         radius: 80, // Radius in meters (adjust as needed)
//         fillColor:
//             AppColor.primaryColor.withOpacity(0.1), // Fill color of the circle
//         strokeColor: AppColor.primaryColor, // Border color of the circle
//         strokeWidth: 1, // Border width
//       ),
//     );
//   }

// //Get Address
//   void getAddress(lat, long, searchVal) {
//     MapComponents.getAddress(lat, long).then((address) async {
//       // String locality = address!.locality.toString();
//       // String subLocality = address.subLocality.toString();
//       // String street = address.street
//       //     .toString(); // or use placemark.toString() for a detailed address
//       // String subAdministrativeArea = address.subAdministrativeArea.toString();
//       // String myAddress =
//       //     "$street,$subLocality,$locality,$subAdministrativeArea.";
 
//       MapComponents().getCoordinates(searchVal).then((returnAdd) {
//        
//       });
 
//     });

//     // MapComponents()
//     //     .fetchSuggestions(
//     //         searchVal,
//     //         double.parse(startLocation!.latitude.toString()),
//     //         double.parse(startLocation!.longitude.toString()),
//     //         "5000")
//     //     .then((adddress) {
 
//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 20,
//           ),
//           child: HeaderLabel(
//             title: "What is your location?",
//             subTitle:
//                 "Drag and zoom the map on the exact spot to get your adress.",
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 20,
//           ),
//           child: Column(
//             children: [
//               Container(
//                 width: MediaQuery.of(context)
//                     .size
//                     .width, // Adjust the width as needed
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(
//                       25.0), // Adjust the radius as needed
//                   color: Colors.grey[200], // Background color
//                 ),
//                 child: TextField(
//                   readOnly: true,
//                   decoration: InputDecoration(
//                     prefixIcon: const Icon(Icons.search),
//                     hintText: 'Enter address',
//                     hintStyle: GoogleFonts.prompt(
//                       fontSize: 15.0,
//                       color: Colors.black.withOpacity(0.5),
//                     ),
//                     border: InputBorder.none, // Remove the default input border
//                   ),
//                   onTap: () async {
//                     await showDialog(
//                       context: context,
//                       builder: (context) {
//                         return SearchPlaces(
//                             helpText: searchPlaceController.text,
//                             lat: startLocation!.latitude.toString(),
//                             long: startLocation!.longitude.toString(),
//                             radius: "500",
//                             callBack: (data) {
//                               var newlatlang = LatLng(
//                                   double.parse(data[0]["lat"].toString()),
//                                   double.parse(data[0]["long"].toString()));

//                               setState(() {
//                                 searchPlaceController.text =
//                                     data[0]["place"].toString();
//                                 startLocation = newlatlang;
//                               });

//                               getAddress(
//                                   startLocation!.latitude,
//                                   startLocation!.longitude,
//                                   searchPlaceController.text);
//                               if (Navigator.canPop(context)) {
//                                 Navigator.of(context).pop();
//                               }
//                             });
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           height: 20,
//         ),
//         Expanded(
//           child: loading
//               ? Container()
//               : Stack(
//                   children: [
//                     GestureDetector(
//                       behavior: HitTestBehavior.opaque,
//                       child: GoogleMap(
//                         mapType: MapType.normal,
//                         onMapCreated: _onMapCreated,
//                         initialCameraPosition: cameraPositions!,
//                         mapToolbarEnabled: true,
//                         zoomControlsEnabled: false,
//                         myLocationEnabled: true,
//                         myLocationButtonEnabled: false,
//                         compassEnabled: false,
//                         buildingsEnabled: true,
//                         scrollGesturesEnabled: true,
//                         markers: Set<Marker>.of(markers),
//                         onTap: (LatLng latLng) {
//                           // Handle the map tap here
//                           CustomModal(context: context).loader();
//                           setState(() {
//                             loading = true;
//                             _circles = {};
//                           });
//                           displayMapData(latLng.latitude, latLng.longitude);
//                         },
//                         circles: _circles,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ],
//     );
//   }

// //   void getRegionData() {
// //     FocusManager.instance.primaryFocus!.unfocus();
// //     CustomModal(context: context).loader();
// //     hasInternetConnection((hasInternet) async {
// //       if (!hasInternet) {
// //         Navigator.pop(context);
// //         showAlertDialog(context, "Error",
// //             'Please check your internet connection and try again.', () {
// //           Navigator.pop(context);
// //           if (Navigator.canPop(context)) {
// //             Navigator.pop(context);
// //           }
// //         });

// //         return;
// //       }

// //       const HttpRequest(api: gApiSubFolderGetRegion)
// //           .get()
// //           .then((returnData) async {
// //         if (returnData == "No Internet") {
// //           Navigator.pop(context);
// //           showAlertDialog(context, "Error",
// //               'Please check your internet connection and try again.', () {
// //             Navigator.pop(context);
// //             if (Navigator.canPop(context)) {
// //               Navigator.pop(context);
// //             }
// //           });

// //           return;
// //         }
// //         if (returnData == null) {
// //           showAlertDialog(context, "Error",
// //               "Error while connecting to server, Please contact support.", () {
// //             Navigator.of(context).pop();
// //           });

// //           return;
// //         } else {
// //           if (returnData["items"].length == 0) {
// //             Navigator.pop(context);
// //             showAlertDialog(
// //                 context, "Error", 'No data found, Please contact admin.', () {
// //               Navigator.pop(context);
// //             });
// //           } else {
// //             Navigator.pop(context);
// //             for (var regionRows in returnData["items"]) {
// //               regionDatas.add({
// //                 'value': regionRows["region_id"],
// //                 "region": regionRows["region_name"]
// //               });
// //             }
// //             setState(() {
// //               loading = false;
// //             });
// //           }
// //         }
// //       });
// //     });
// //   }

// // //GetLoadData
// //   void getLoadAddress(id, folder, Function cb) {
// //     // ignore: prefer_typing_uninitialized_variables
// //     String subApi = "";

// //     if (folder == gApiSubFolderGetProvince) {
// //       setState(() {
// //         provinceData = [];
// //         subApi = "$folder?p_region_id=$id";
// //       });
// //     } else if (folder == gApiSubFolderGetCity) {
// //       setState(() {
// //         cityData = [];
// //         subApi = "$folder?p_province_id=$id";
// //       });
// //     } else {
// //       setState(() {
// //         baranggayData = [];
// //         subApi = "$folder?p_city_id=$id";
// //       });
// //     }
// //     // ignore: prefer_typing_uninitialized_variables

// //     FocusManager.instance.primaryFocus!.unfocus();
// //     //  CustomModal(context: context).loader();
// //     hasInternetConnection((hasInternet) async {
// //       if (!hasInternet) {
// //         //  Navigator.of(context).pop();
// //         showAlertDialog(context, "Error",
// //             'Please check your internet connection and try again.', () {
// //           Navigator.pop(context);
// //           if (Navigator.canPop(context)) {
// //             Navigator.pop(context);
// //           }
// //         });
// //         setState(() {
// //           cb(0);
// //         });
// //         return;
// //       }
// //       HttpRequest(api: subApi).get().then((returnData) async {
// //         if (folder == gApiSubFolderGetProvince) {
// //           setState(() {
// //             provinceData = [];
// //           });
// //         } else if (folder == gApiSubFolderGetCity) {
// //           setState(() {
// //             cityData = [];
// //           });
// //         } else {
// //           setState(() {
// //             brgyData = [];
// //           });
// //         }

// //         if (returnData == "No Internet") {
// //           showAlertDialog(context, "Error",
// //               'Please check your internet connection and try again.', () {
// //             Navigator.pop(context);
// //             if (Navigator.canPop(context)) {
// //               Navigator.pop(context);
// //             }
// //           });

// //           return;
// //         }
// //         if (returnData == null) {
// //           showAlertDialog(context, "Error",
// //               "Error while connecting to server, Please contact support.", () {
// //             Navigator.of(context).pop();
// //           });
// //           setState(() {
// //             cb(0);
// //           });
// //           return;
// //         } else {
// //           if (returnData["items"].length == 0) {
// //             //   Navigator.pop(context);
// //             showAlertDialog(
// //                 context, "Error", 'No data found, Please contact admin.', () {
// //               Navigator.pop(context);
// //             });
// //             setState(() {
// //               cb(0);
// //             });
// //           } else {
// //             for (var provRow in returnData["items"]) {
// //               if (folder == gApiSubFolderGetProvince) {
// //                 provinceData.add(
// //                     {'value': provRow["value"], 'province': provRow["text"]});
// //               } else if (folder == gApiSubFolderGetCity) {
// //                 cityData
// //                     .add({'value': provRow["value"], 'city': provRow["text"]});
// //               } else {
// //                 brgyData
// //                     .add({'value': provRow["value"], 'brgy': provRow["text"]});
// //               }
// //             }

// //             setState(() {
// //               cb(1);
// //             });
// //             //  Navigator.of(context).pop();
// //           }
// //         }
// //       });
// //     });
// //   }

// // //ONCHANGE FUNCTION
// //   void getProvinceData(id, folder) {
// //     // ignore: prefer_typing_uninitialized_variables
// //     String subApi = "";

// //     if (folder == gApiSubFolderGetProvince) {
// //       setState(() {
// //         provinceData = [];
// //         subApi = "$folder?p_region_id=$id";
// //       });
// //     } else if (folder == gApiSubFolderGetCity) {
// //       setState(() {
// //         cityData = [];
// //         subApi = "$folder?p_province_id=$id";
// //       });
// //     } else {
// //       setState(() {
// //         baranggayData = [];
// //         subApi = "$folder?p_city_id=$id";
// //       });
// //     }
// //     // ignore: prefer_typing_uninitialized_variables

// //     FocusManager.instance.primaryFocus!.unfocus();
// //     CustomModal(context: context).loader();
// //     hasInternetConnection((hasInternet) async {
// //       if (!hasInternet) {
// //         Navigator.of(context).pop();
// //         showAlertDialog(context, "Error",
// //             'Please check your internet connection and try again.', () {
// //           Navigator.of(context).pop();
// //         });
// //         return;
// //       }
// //       HttpRequest(api: subApi).get().then((returnData) async {
// //         if (folder == gApiSubFolderGetProvince) {
// //           setState(() {
// //             provinceData = [];
// //           });
// //         } else if (folder == gApiSubFolderGetCity) {
// //           setState(() {
// //             cityData = [];
// //           });
// //         } else {
// //           setState(() {
// //             brgyData = [];
// //           });
// //         }
// //         if (returnData == "No Internet") {
// //           Navigator.pop(context);
// //           showAlertDialog(context, "Error",
// //               "Please check your internet connection and try again", () {
// //             Navigator.pop(context);
// //           });
// //           return;
// //         }
// //         if (returnData == null) {
// //           Navigator.pop(context);
// //           showAlertDialog(context, "Error",
// //               "Error while connecting to server, Please contact support.", () {
// //             Navigator.of(context).pop();
// //           });

// //           return;
// //         } else {
// //           if (returnData["items"].length == 0) {
// //             Navigator.pop(context);
// //             showAlertDialog(
// //                 context, "Error", 'No data found, Please contact admin.', () {
// //               Navigator.pop(context);
// //             });
// //           } else {
// //             for (var provRow in returnData["items"]) {
// //               if (folder == gApiSubFolderGetProvince) {
// //                 provinceData.add(
// //                     {'value': provRow["value"], 'province': provRow["text"]});
// //               } else if (folder == gApiSubFolderGetCity) {
// //                 cityData
// //                     .add({'value': provRow["value"], 'city': provRow["text"]});
// //               } else {
// //                 brgyData
// //                     .add({'value': provRow["value"], 'brgy': provRow["text"]});
// //               }
// //             }

// //             setState(() {});
// //             Navigator.of(context).pop();
// //           }
// //         }
// //       });
// //     });
// //   }
// }
