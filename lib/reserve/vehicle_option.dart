// import 'package:flutter/material.dart';
// import 'package:luvpark/classess/color_component.dart';
// import 'package:luvpark/custom_widget/custom_button.dart';

// class VehicleOptions extends StatelessWidget {
//   const VehicleOptions({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       child: Container(
//         padding: EdgeInsets.all(20),
//         child: Wrap(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 InkWell(
//                   onTap: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Icon(Icons.arrow_back_ios),
//                 ),
//                 Container(height: 30),
//                 CustomButton(label: "Add another vehicle", onTap: () {}),
//                 Container(height: 10),
//                 CustomButtonCancel(
//                     color: Colors.white,
//                     borderColor: AppColor.primaryColor,
//                     textColor: AppColor.primaryColor,
//                     label: "Select vehicle",
//                     onTap: () {}),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   // Widget button
// }
