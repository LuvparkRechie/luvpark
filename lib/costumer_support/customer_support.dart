// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:kommunicate_flutter/kommunicate_flutter.dart';
// import 'package:luvpark/classess/color_component.dart';
// import 'package:luvpark/custom_widget/custom_parent_widget.dart';

// class CustomerSupport extends StatefulWidget {
//   const CustomerSupport({super.key});

//   @override
//   State<CustomerSupport> createState() => _CustomerSupportState();
// }

// class _CustomerSupportState extends State<CustomerSupport> {
//   //Variables
//   MethodChannel channel = MethodChannel('kommunicate_flutter');
//   TextEditingController userId = new TextEditingController();
//   TextEditingController password = new TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomParentWidget(
//       appbarColor: AppColor.primaryColor,
//       child: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(36.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               SizedBox(height: 10),
//               new Material(
//                   elevation: 5.0,
//                   borderRadius: BorderRadius.circular(30.0),
//                   color: Color(0xff5c5aa7),
//                   child: new MaterialButton(
//                     onPressed: () async {
//                       try {
//                         dynamic conversationObject = {
//                           'appId': '2792f6be0648bd34f5480da60d7aec7d8'
//                         };
//                         dynamic result =
//                             await KommunicateFlutterPlugin.buildConversation(
//                                 conversationObject);
//                         print("Conversation builder success : " +
//                             result.toString());
//                       } on Exception catch (e) {
//                         print("Conversation builder error occurred : " +
//                             e.toString());
//                       }
//                     },
//                     minWidth: 400,
//                     padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                     child: Text("Login as Visitor",
//                         textAlign: TextAlign.center,
//                         style:
//                             TextStyle(fontFamily: 'Montserrat', fontSize: 20.0)
//                                 .copyWith(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold)),
//                   )),
//               SizedBox(height: 10),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
