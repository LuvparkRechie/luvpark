// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:luvpark/classess/color_component.dart';
// import 'package:luvpark/classess/variables.dart';
// import 'package:luvpark/custom_widget/custom_button.dart';
// import 'package:luvpark/custom_widget/custom_text.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class ParkDetailsV2 extends StatefulWidget {
//   const ParkDetailsV2({super.key});

//   @override
//   State<ParkDetailsV2> createState() => _ParkDetailsV2State();
// }

// class _ParkDetailsV2State extends State<ParkDetailsV2> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 0,
//         elevation: 0,
//         backgroundColor: AppColor.primaryColor,
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: AppColor.primaryColor,
//           statusBarBrightness: Brightness.dark,
//           statusBarIconBrightness: Brightness.light,
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             Expanded(
//               child: Stack(
//                 fit: StackFit.loose,
//                 children: [
//                   Container(
//                     color: AppColor.primaryColor,
//                     height: Variables.screenSize.height * 0.20,
//                   ),
//                   Positioned(
//                     left: 15,
//                     right: 15,
//                     top: 10,
//                     bottom: 20, // Space for the buttons at the bottom
//                     child: ClipPath(
//                       clipper: TicketClipper(),
//                       child: SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildQrSection(),
//                             _buildAddressSection(),
//                             _buildDetailsSection(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(15),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: CustomButton(
//                       color: Colors.white,
//                       textColor: AppColor.primaryColor,
//                       bordercolor: AppColor.primaryColor,
//                       label: "Find vehicle",
//                       onTap: () {},
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: CustomButton(
//                       label: "Extend parking",
//                       onTap: () {},
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       color: AppColor.primaryColor,
//       padding: EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: [
//           Flexible(
//             flex: 1,
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.chevron_left, color: Colors.white),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//                 CustomParagraph(
//                   text: "Back",
//                   fontSize: 14,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ],
//             ),
//           ),
//           Flexible(
//             flex: 2,
//             child: CustomTitle(
//               text: "Parking Details",
//               color: Colors.white,
//               letterSpacing: -0.41,
//               fontWeight: FontWeight.w700,
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQrSection() {
//     return Container(
//       padding: EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildIconButton(Icons.download),
//           SizedBox(width: 20),
//           Expanded(
//             child: QrImageView(
//               data: "hi",
//               version: QrVersions.auto,
//               gapless: false,
//             ),
//           ),
//           SizedBox(width: 20),
//           _buildIconButton(Icons.share),
//         ],
//       ),
//     );
//   }

//   Widget _buildIconButton(IconData icon) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Color(0xFFF2F2F4),
//         shape: BoxShape.circle,
//       ),
//       child: IconButton(
//         icon: Icon(icon),
//         onPressed: () {},
//         padding: EdgeInsets.all(10),
//       ),
//     );
//   }

//   Widget _buildAddressSection() {
//     return Container(
//       padding: EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//         border: Border(
//           top: BorderSide(color: Colors.grey.shade200),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: CustomTitle(
//                   text: "SM SOUTH LEFT",
//                   fontSize: 20,
//                   maxlines: 1,
//                   letterSpacing: 0,
//                 ),
//               ),
//               IconButton(
//                 onPressed: () {},
//                 icon: Image.asset("assets/dashboard_icon/direct_map.png"),
//               ),
//             ],
//           ),
//           CustomParagraph(
//             text:
//                 "SM SOUTH MWCV+3HRT Farther M. Ferrs St. Bacolod, 6100 Negros Occidental",
//             maxlines: 2,
//           ),
//           SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: CustomTitle(
//                   text: "4:00PM - 5:00PM",
//                   fontSize: 14,
//                   letterSpacing: -0.41,
//                 ),
//               ),
//               CustomParagraph(
//                 text: "45 mins left",
//                 fontSize: 14,
//                 letterSpacing: -0.41,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailsSection() {
//     return Container(
//       padding: EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
//         border: Border(
//           top: BorderSide(color: Colors.grey.shade200),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ticketDetailsWidget('Total Token', '20.00', 'Duration', '1 hour'),
//           SizedBox(height: 10),
//           ticketDetailsWidget(
//             'Date In-Out',
//             '2024/06/26 - 2024/06/26',
//             'Time In-Out',
//             '4:00PM - 5:00PM',
//           ),
//           SizedBox(height: 10),
//           ticketDetailsWidget(
//             'Vehicle',
//             'YTX-1245',
//             'Reference no.',
//             'BCD-234555L',
//           ),
//         ],
//       ),
//     );
//   }
// }

// Widget ticketDetailsWidget(String firstTitle, String firstDesc,
//     String secondTitle, String secondDesc) {
//   return Row(
//     children: [
//       Expanded(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CustomParagraph(text: firstTitle),
//             CustomParagraph(
//               text: firstDesc,
//               color: Colors.black,
//             ),
//           ],
//         ),
//       ),
//       Expanded(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CustomParagraph(text: secondTitle),
//             CustomParagraph(
//               text: secondDesc,
//               color: Colors.black,
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

// class TicketClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();

//     path.lineTo(0.0, size.height);
//     path.lineTo(size.width, size.height);
//     path.lineTo(size.width, 0.0);

//     // Add rounded corners
//     path.addRRect(RRect.fromLTRBR(
//       0.0,
//       0.0,
//       size.width,
//       size.height,
//       Radius.circular(20),
//     ));

//     // Add the ticket-style notches (optional)
//     path.addOval(
//         Rect.fromCircle(center: Offset(0.0, size.height / 2), radius: 20.0));
//     path.addOval(Rect.fromCircle(
//         center: Offset(size.width, size.height / 2), radius: 20.0));

//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_tciket_style.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ParkDetailsV2 extends StatefulWidget {
  const ParkDetailsV2({super.key});

  @override
  State<ParkDetailsV2> createState() => _ParkDetailsV2State();
}

class _ParkDetailsV2State extends State<ParkDetailsV2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                fit: StackFit.loose,
                children: [
                  Container(
                    color: AppColor.primaryColor,
                    height: Variables.screenSize.height * 0.20,
                  ),
                  Positioned(
                    left: 15,
                    right: 15,
                    top: 5,
                    bottom: 10, // Space for the buttons at the bottom
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQrSection(),
                            _buildAddressSection(),
                            _buildDetailsSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      color: Colors.white,
                      textColor: AppColor.primaryColor,
                      bordercolor: AppColor.primaryColor,
                      label: "Find vehicle",
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      label: "Extend parking",
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColor.primaryColor,
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CustomParagraph(
                  text: "Back",
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: CustomTitle(
              text: "Parking Details",
              color: Colors.white,
              letterSpacing: -0.41,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconButton(Icons.download),
              SizedBox(width: 20),
              Expanded(
                child: QrImageView(
                  data: "hi",
                  version: QrVersions.auto,
                  gapless: false,
                ),
              ),
              SizedBox(width: 20),
              _buildIconButton(Icons.share_outlined),
            ],
          ),
        ),
        TicketStyle()
      ],
    );
  }

  Widget _buildIconButton(IconData icon) {
    return IconButton(
      icon: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Icon(
            icon,
            color: Colors.black,
          ),
        ),
      ),
      onPressed: () {},
      padding: EdgeInsets.all(10),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTitle(
                      text: "SM SOUTH LEFT",
                      fontSize: 20,
                      maxlines: 1,
                      letterSpacing: 0,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset("assets/dashboard_icon/direct_map.png"),
                  ),
                ],
              ),
              CustomParagraph(
                text:
                    "SM SOUTH MWCV+3HRT Farther M. Ferrs St. Bacolod, 6100 Negros Occidental",
                maxlines: 2,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTitle(
                      text: "4:00PM - 5:00PM",
                      fontSize: 14,
                      letterSpacing: -0.41,
                    ),
                  ),
                  CustomParagraph(
                    text: "45 mins left",
                    fontSize: 14,
                    letterSpacing: -0.41,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
        TicketStyle()
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ticketDetailsWidget('Total Token', '20.00', 'Duration', '1 hour'),
          SizedBox(height: 10),
          ticketDetailsWidget(
            'Date In-Out',
            '2024/06/26 - 2024/06/26',
            'Time In-Out',
            '4:00PM - 5:00PM',
          ),
          SizedBox(height: 10),
          ticketDetailsWidget(
            'Vehicle',
            'YTX-1245',
            'Reference no.',
            'BCD-234555L',
          ),
        ],
      ),
    );
  }
}

Widget ticketDetailsWidget(String firstTitle, String firstDesc,
    String secondTitle, String secondDesc) {
  return Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomParagraph(text: firstTitle),
            CustomParagraph(
              text: firstDesc,
              color: Colors.black,
            ),
          ],
        ),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomParagraph(text: secondTitle),
            CustomParagraph(
              text: secondDesc,
              color: Colors.black,
            ),
          ],
        ),
      ),
    ],
  );
}
