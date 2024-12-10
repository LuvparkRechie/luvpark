// ignore_for_file: prefer_const_constructors, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_svg/svg.dart';

import '../../custom_widgets/app_color.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_separator.dart';
import '../../custom_widgets/custom_text.dart';
import '../../custom_widgets/variables.dart';

class TransactionDetails extends StatelessWidget {
  final List data;
  final int index;
  const TransactionDetails(
      {super.key, required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    String trans = data[index]["tran_desc"].toString().toLowerCase();
    String img = "";
    if (trans.contains("share")) {
      img = "wallet_sharetoken";
    } else if (trans.contains("received")) {
      img = "wallet_receivetoken";
    } else {
      img = "wallet_payparking";
    }

    // String fromValue =
    //     data[index]["category"] == "SENDER" ? data[index]["mobile_no"] : "";
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            fit: StackFit.loose,
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(height: 30),
                    Center(
                      child: CustomParagraph(
                        minFontSize: 8,
                        text: 'Transaction Details',
                        fontSize: 20,
                        maxlines: 1,
                        color: Color(0xFF070707),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Center(
                      child: CustomParagraph(
                        text: "${data[index]["tran_desc"]}",
                        color: Color(0xFF616161),
                        textAlign: TextAlign.left,
                        minFontSize: 8,
                        maxlines: 1,
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                    const MySeparator(
                      color: Color(0xFFD9D9D9),
                    ),
                    Container(
                      height: 20,
                    ),
                    rowWidget("Date & Time",
                        Variables.formatDateLocal(data[index]["tran_date"])),
                    Container(
                      height: 5,
                    ),
                    // if (fromValue.isNotEmpty) ...[
                    //   rowWidget("From", fromValue),
                    //   Container(height: 5),
                    // ],
                    rowWidget("Amount",
                        toCurrencyString(data[index]["amount"].toString())),
                    Container(
                      height: 5,
                    ),
                    rowWidget("Previous Balance",
                        toCurrencyString(data[index]["bal_before"].toString())),
                    Container(
                      height: 5,
                    ),
                    rowWidget("Current Balance",
                        toCurrencyString(data[index]["bal_after"].toString())),
                    Container(
                      height: 20,
                    ),
                    const MySeparator(
                      color: Color(0xFFD9D9D9),
                    ),
                    Container(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: CustomParagraph(
                            maxlines: 1,
                            minFontSize: 8,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            text: "Reference No: ",
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (details) async {
                            await Clipboard.setData(ClipboardData(
                              text: data[index]["ref_no"].toString(),
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Text copied to clipboard')),
                            );
                          },
                          child: SelectableText(
                            toolbarOptions: ToolbarOptions(copy: true),
                            style: paragraphStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColor.headerColor,
                            ),
                            data[index]["ref_no"].toString(),
                          ),
                        )
                      ],
                    ),
                    Container(
                      height: 15,
                    ),
                    CustomButton(
                      text: 'Close',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 10,
                          color: Colors.white,
                        )),
                    child: SvgPicture.asset(
                      fit: BoxFit.cover,
                      height: 50,
                      "assets/images/$img.svg",
                    ),
                  ),
                ),
              ),
            ],
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
          maxlines: 1,
          minFontSize: 8,
          color: Color(0xFF616161),
          text: label,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: CustomParagraph(
              text: value,
              maxlines: 1,
              fontWeight: FontWeight.w600,
              color: AppColor.headerColor,
              fontSize: 13,
              minFontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
