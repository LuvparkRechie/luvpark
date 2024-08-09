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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(7))),
      child: Wrap(
        children: [
          Center(
            child: CustomTitle(
              text: 'Transaction Details',
              fontSize: 20,
              maxlines: 1,
            ),
          ),
          Container(
            height: 10,
          ),
          Center(
            child: CustomParagraph(
              text: "${data[index]["tran_desc"]}",
              color: AppColor.primaryColor,
              textAlign: TextAlign.left,
              fontSize: 16,
              maxlines: 1,
            ),
          ),
          Container(
            height: 10,
          ),
          const MySeparator(),
          Container(
            height: 20,
          ),
          rowWidget(
              "Date", Variables.formatDateLocal(data[index]["tran_date"])),
          Container(
            height: 10,
          ),
          rowWidget(
              "Amount", toCurrencyString(data[index]["amount"].toString())),
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
            height: 20,
          ),
          const MySeparator(),
          Container(
            height: 50,
          ),
          Center(
            child: CustomTitle(
              text: data[index]["ref_no"].toString(),
              color: AppColor.primaryColor,
            ),
          ),
          Center(
            child: CustomParagraph(
              text: "Reference No",
            ),
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
    );
  }

  Row rowWidget(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomParagraph(
          text: label,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: CustomParagraph(
              text: value,
              color: AppColor.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
