// import 'package:flutter/material.dart';
// import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
// import 'package:luvpark/classess/color_component.dart';
// import 'package:luvpark/classess/variables.dart';
// import 'package:luvpark/custom_widget/broken_line.dart';
// import 'package:luvpark/custom_widget/custom_parent_widget.dart';
// import 'package:luvpark/custom_widget/custom_text.dart';

// class TransactionDetails extends StatelessWidget {
//   final List data;
//   final int index;
//   const TransactionDetails(
//       {super.key, required this.data, required this.index});

//   @override
//   Widget build(BuildContext context) {
//     return CustomParent1Widget(
//         canPop: true,
//         appBarheaderText: "Transaction Details",
//         appBarIconClick: () {
//           Navigator.of(context).pop();
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Center(
//               child: Image(
//                 height: 150,
//                 width: 150,
//                 image: AssetImage("assets/images/trans_details.png"),
//               ),
//             ),
//             Container(
//               height: 20,
//             ),
//             Column(
//               children: [
//                 Center(
//                   child: CustomDisplayText(
//                     label: "${data[index]["tran_desc"]}",
//                     color: AppColor.primaryColor,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 20,
//                     alignment: TextAlign.left,
//                     maxLines: 1,
//                   ),
//                 ),
//                 Container(
//                   height: 20,
//                 ),
//                 const MySeparator(),
//                 Container(
//                   height: 20,
//                 ),
//                 rowWidget("Date",
//                     Variables.formatDateLocal(data[index]["tran_date"])),
//                 Container(
//                   height: 10,
//                 ),
//                 rowWidget("Amount",
//                     toCurrencyString(data[index]["amount"].toString())),
//                 Container(
//                   height: 10,
//                 ),
//                 rowWidget("Previous Balance",
//                     toCurrencyString(data[index]["bal_before"].toString())),
//                 Container(
//                   height: 10,
//                 ),
//                 rowWidget("Current Balance",
//                     toCurrencyString(data[index]["bal_after"].toString())),
//                 Container(
//                   height: 50,
//                 ),
//                 CustomDisplayText(
//                     label: data[index]["ref_no"].toString(),
//                     color: AppColor.primaryColor,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600),
//                 CustomDisplayText(
//                   label: "Reference No",
//                   color: Colors.black54,
//                   fontSize: 14,
//                 )
//               ],
//             )
//           ],
//         ));
//   }

//   Row rowWidget(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         CustomDisplayText(label: label, color: Colors.black54, fontSize: 14),
//         Expanded(
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: CustomDisplayText(
//                 label: value,
//                 color: AppColor.primaryColor,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/broken_line.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class TransactionDetails extends StatelessWidget {
  final List data;
  final int index;
  const TransactionDetails(
      {super.key, required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CustomDisplayText(
                  label: 'Transaction Details',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  alignment: TextAlign.left,
                  maxLines: 1,
                ),
                Container(
                  height: 10,
                ),
                Center(
                  child: CustomDisplayText(
                    label: "${data[index]["tran_desc"]}",
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    alignment: TextAlign.left,
                    maxLines: 1,
                  ),
                ),
                Container(
                  height: 10,
                ),
                const MySeparator(),
                Container(
                  height: 20,
                ),
                rowWidget("Date",
                    Variables.formatDateLocal(data[index]["tran_date"])),
                Container(
                  height: 10,
                ),
                rowWidget("Amount",
                    toCurrencyString(data[index]["amount"].toString())),
                Container(
                  height: 10,
                ),
                rowWidget("Previous Balance",
                    toCurrencyString(data[index]["bal_before"].toString())),
                Container(
                  height: 10,
                ),
                rowWidget("Current Balance",
                    toCurrencyString(data[index]["bal_after"].toString())),
                Container(
                  height: 10,
                ),
                const MySeparator(),
                Container(
                  height: 50,
                ),
                CustomDisplayText(
                    label: data[index]["ref_no"].toString(),
                    color: AppColor.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
                CustomDisplayText(
                  label: "Reference No",
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ],
            ),
            Container(
              height: 10,
            ),
            CustomButton(
              label: 'Close',
              onTap: () {
                Navigator.of(context).pop();
              },
              btnHeight: 12,
            ),
          ],
        ),
      ),
    );
  }

  Row rowWidget(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomDisplayText(label: label, color: Colors.black54, fontSize: 14),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: CustomDisplayText(
                label: value,
                color: AppColor.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
