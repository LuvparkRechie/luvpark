// ignore_for_file: prefer_const_constructors, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_svg/svg.dart';

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
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 38,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                15,
                30,
                15,
                0,
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
              child: Wrap(
                children: [
                  Center(
                    child: CustomTitle(
                      text: 'Transaction Details',
                      fontSize: 22,
                      maxlines: 1,
                      color: Color(0xFF070707),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  Center(
                    child: CustomParagraph(
                      text: "${data[index]["tran_desc"]}",
                      color: Color(0xFF616161),
                      fontWeight: FontWeight.w400,
                      textAlign: TextAlign.left,
                      fontSize: 16,
                      maxlines: 1,
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  const MySeparator(
                    color: Color(0xFFD9D9D9),
                  ),
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
                          color: Color(0xFF070707),
                          fontSize: 12,
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
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF070707),
                            fontSize: 12,
                          ),
                          data[index]["ref_no"].toString(),
                        ),
                      )
                    ],
                  ),
                  Container(
                    height: 25,
                  ),
                  CustomButton(
                    text: 'Close',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    btnHeight: 12,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 20.5,
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 10,
                color: Colors.white,
              )),
          child: SvgPicture.asset(
            fit: BoxFit.cover, height: 50,
            "assets/images/${data[index]["tran_desc"] == 'Share a token' ? 'wallet_sharetoken' : data[index]["tran_desc"] == 'Received token' ? 'wallet_receivetoken' : 'wallet_payparking'}.svg",
            //if trans_Desc is equal to Share a token svg is wallet_sharetoken else Receive Token svg is wallet_receivetoken else parking transaction is svg wallet_payparking
          ),
        ),
      ],
    );
  }

  Row rowWidget(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomParagraph(
          fontWeight: FontWeight.w400,
          color: Color(0xFF070707),
          text: label,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: CustomParagraph(
              text: value,
              color: Color(0xFF616161),
            ),
          ),
        ),
      ],
    );
  }
}
