// import 'dart:convert';

// import 'package:animate_do/animate_do.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:luvpark/classess/color_component.dart';
// import 'package:luvpark/custom_widget/custom_parent_widget.dart';
// import 'package:luvpark/custom_widget/custom_text.dart';
// import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class SearchPlaces extends StatefulWidget {
//   final Function callBack;
//   final String helpText, lat, long, radius;
//   const SearchPlaces(
//       {super.key,
//       required this.callBack,
//       required this.helpText,
//       required this.lat,
//       required this.radius,
//       required this.long});

//   @override
//   State<SearchPlaces> createState() => _SearchPlacesState();
// }

// class _SearchPlacesState extends State<SearchPlaces> {
//   TextEditingController searchController = TextEditingController();
//   TextEditingController hoursController = TextEditingController();
//   List<String> suggestions = [];
//   bool isLoading = true;
//   int searchData = 0;

//   // ignore: prefer_typing_uninitialized_variables
//   var myProfilePic, akongP;
//   BuildContext? mainContext;
//   bool _speechEnabled = false;
//   String _lastWords = '';
//   //new param
//   stt.SpeechToText _speechToText = stt.SpeechToText();

//   @override
//   void initState() {
//     super.initState();
//     searchController.text = widget.helpText;
//     searchController.addListener(() {});
//     _initSpeech();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       getPreferences();
//     });
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   /// This has to happen only once per app
//   void _initSpeech() async {
//     _speechEnabled = await _speechToText.initialize();
//   }

//   /// Each time to start a speech recognition session
//   void _startListening() async {
//     await _speechToText.listen(onResult: _onSpeechResult);
//   }

//   /// Manually stop the active speech recognition session
//   /// Note that there are also timeouts that each platform enforces
//   /// and the SpeechToText plugin supports setting timeouts on the
//   /// listen method.
//   void _stopListening() async {
//     await _speechToText.stop();
//     setState(() {});
//   }

//   /// This is the callback that the SpeechToText plugin calls when
//   /// the platform returns recognized words.
//   void _onSpeechResult(SpeechRecognitionResult result) {
//     setState(() {
//       _lastWords = result.recognizedWords;
//       searchController.text = _lastWords;
//     });
//     onChangeTrigger(_lastWords);
//   }

//   void getPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     akongP = prefs.getString(
//       'userData',
//     );
//     var myPicData = prefs.getString(
//       'myProfilePic',
//     );
//     setState(() {
//       myProfilePic = jsonDecode(myPicData!).toString();
//       isLoading = false;
//       onChangeTrigger(searchController.text);
//     });
//   }

//   void onChangeTrigger(textSuggest) async {
//     await DashboardComponent()
//         .fetchSuggestions(textSuggest, double.parse(widget.lat),
//             double.parse(widget.long), widget.radius)
//         .then((suggestions) {
//       setState(() {
//         _speechEnabled = false;
//         this.suggestions = suggestions;
//         searchData = suggestions.length;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     mainContext = context;
//     return CustomParentWidget(
//       appbarColor: AppColor.primaryColor,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                       widget.callBack([]);
//                     },
//                     child: Container(
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Color(0xFFf5f5fa),
//                       ),
//                       child: const Padding(
//                         padding: EdgeInsets.all(5.0),
//                         child: Icon(
//                           Icons.arrow_back_ios_outlined,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Center(
//                       child: CustomDisplayText(
//                     label: "Find Parking",
//                     color: Colors.black,
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   )),
//                   Container(width: 45),
//                 ],
//               ),
//             ),
//             Container(
//               height: 10,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: FadeInRight(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       height: 2,
//                     ),
//                     Center(
//                       child: TextField(
//                         controller: searchController,
//                         readOnly: false,
//                         enabled: true,
//                         decoration: InputDecoration(
//                           hintText: 'Where are you going?',
//                           enabled: false,
//                           border: InputBorder.none,
//                           prefixIcon: const Icon(
//                             Icons.search,
//                             color: Color(0xFF9C9C9C),
//                           ),
//                           suffixIcon: InkWell(
//                             onTap: () {
//                               setState(() {
//                                 _speechEnabled = !_speechEnabled;
//                               });
//                               if (_speechToText.isNotListening) {
//                                 _startListening();
//                               } else {
//                                 _stopListening();
//                               }
//                             },
//                             child: Icon(
//                               Icons.mic,
//                               color: _speechEnabled
//                                   ? Colors.green
//                                   : Color(0xFF9C9C9C),
//                             ),
//                           ),
//                           hintStyle: GoogleFonts.dmSans(
//                             color: const Color.fromARGB(255, 82, 82, 82),
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         onChanged: (query) async {
//                           onChangeTrigger(query);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Container(
//               height: 5,
//             ),
//             const Divider(),
//             Visibility(
//               visible: searchData > 0,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: CustomDisplayText(
//                   label: "Result",
//                   color: Colors.black,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             Container(
//               height: 10,
//             ),
//             Expanded(
//               child: FadeInUp(
//                 child: Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.height,
//                   color: Colors.white,
//                   child: FutureBuilder<List<String>>(
//                     future: DashboardComponent().fetchSuggestions(
//                         searchController.text,
//                         double.parse(widget.lat),
//                         double.parse(widget.long),
//                         widget.radius),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       } else if (snapshot.hasError) {
//                         return Text('Error: ${snapshot.error}');
//                       } else if (snapshot.data!.isEmpty) {
//                         return const Center(
//                           child: Text("No result"),
//                         );
//                       } else {
//                         return ListView.builder(
//                           itemCount: suggestions.length,
//                           itemBuilder: (context, index) {
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 InkWell(
//                                     onTap: () async {
//                                       await DashboardComponent.searchPlaces(
//                                           suggestions[index]
//                                               .split("=Rechie=")[0],
//                                           (searchedPlace) {
//                                         List data = [
//                                           {
//                                             "lat": searchedPlace[0].toString(),
//                                             "long": searchedPlace[1].toString(),
//                                             "place": suggestions[index]
//                                                 .toString()
//                                                 .split("=Rechie=")[0],
//                                             "radius": 10000,
//                                             "hours":
//                                                 hoursController.text.isEmpty
//                                                     ? "1"
//                                                     : hoursController.text,
//                                           }
//                                         ];
//                                         Navigator.of(context).pop();
//                                         widget.callBack(data);
//                                       });
//                                     },
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(10.0),
//                                       child: Row(
//                                         children: [
//                                           Container(
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               color: AppColor.primaryColor,
//                                             ),
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(3.0),
//                                               child: Icon(
//                                                 Icons.location_pin,
//                                                 size: 20,
//                                                 color: AppColor.bodyColor,
//                                               ),
//                                             ),
//                                           ),
//                                           Container(
//                                             width: 10,
//                                           ),
//                                           Expanded(
//                                               child: CustomDisplayText(
//                                             label: suggestions[index]
//                                                 .split("=Rechie=")[0],
//                                             fontWeight: FontWeight.normal,
//                                             color: Colors.black,
//                                             maxLines: 2,
//                                           ))
//                                         ],
//                                       ),
//                                     )),
//                                 const Divider()
//                               ],
//                             );
//                           },
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
