import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/buy_token/validate_account.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
// import 'package:pattern_formatter/numeric_formatter.dart';

class BuyTokenPage extends StatefulWidget {
  final int index;
  const BuyTokenPage({super.key, required this.index});

  @override
  State<BuyTokenPage> createState() => _BuyTokenPageState();
}

class _BuyTokenPageState extends State<BuyTokenPage> {
  Timer? _debounce;
  final TextEditingController tokenAmount = TextEditingController();
  bool isActiveBtn = false;
  bool isLoading = false;
  bool isShowKeyboard = false;
  bool isSelectedPartner = false;
  int? selectedPaymentType;
  int denoInd = 0;
  var nData = <Widget>[];
  var myData = <Widget>[];
  List<String> dataList = [
    "20",
    "30",
    "50",
    "100",
    "200",
    "250",
    "300",
    "500",
    "1000"
  ];

  @override
  void initState() {
    super.initState();
    generateBank();
  }

  void generateBank() {}

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isShowKeyboard = MediaQuery.of(context).viewInsets.bottom == 0;
    return CustomParent1Widget(
      canPop: true,
      appBarheaderText: "Load",
      appBarIconClick: () {
        Navigator.pop(context);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: inputAmountEy(),
      ),
    );
  }

  Widget inputAmountEy() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFffffff),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: TextFormField(
                      controller: tokenAmount,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                        // ThousandsFormatter(allowFraction: true),
                      ],
                      textInputAction: TextInputAction.done,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 5),
                        hintText: "0.00",
                      ),
                      onChanged: (valueee) {
                        if (mounted) {
                          setState(() {
                            selectedPaymentType = null;
                            denoInd = -1;
                          });
                        }

                        if (tokenAmount.text.isEmpty ||
                            double.parse(tokenAmount.text) <= 0) {
                          setState(() {
                            isActiveBtn = false;
                          });
                        } else {
                          setState(() {
                            isActiveBtn = true;
                          });
                        }
                      },
                      style: GoogleFonts.prompt(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomDisplayText(
                    label: '1 token = 1 peso',
                    fontSize: 12,
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w600),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 20,
        ),
        CustomDisplayText(
            label:
                'Enter a desired amount or choose from any denominations below.',
            color: Colors.black87,
            fontWeight: FontWeight.w500),
        const SizedBox(
          height: 20,
        ),
        for (int i = 0; i < dataList.length; i += 3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int j = i; j < i + 3 && j < dataList.length; j++)
                myPads(dataList[j].toString(), j)
            ],
          ),
        Container(
          height: Variables.screenSize.height * .10,
        ),
        if (isShowKeyboard)
          Center(
              child: CustomButton(
                  label: "Proceed",
                  color: !isActiveBtn
                      ? AppColor.primaryColor.withOpacity(.7)
                      : AppColor.primaryColor,
                  onTap: !isActiveBtn
                      ? () {}
                      : () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: ((context) => ValidateNumberPage(
                                    tokenAmount:
                                        tokenAmount.text.replaceAll(",", ""),
                                  )),
                            ),
                          );
                        })),
        const SizedBox(
          height: 50,
        ),
      ],
    );
  }

  Widget myPads(String value, int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: InkWell(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              setState(() {
                denoInd = index;
                selectedPaymentType = index;
                tokenAmount.text = value;
                isActiveBtn = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 17, 23, 17),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),

                border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1), // Color(0xFF2563EB) corresponds to #2563EB
                color: tokenAmount.text.isEmpty
                    ? AppColor.bodyColor
                    : denoInd == index
                        ? AppColor.primaryColor
                        : AppColor.bodyColor, // Background color
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Equivalent to flex-shrink: 0
                children: [
                  CustomDisplayText(
                    label: value,
                    fontWeight: FontWeight.w600,
                    color: tokenAmount.text.isEmpty
                        ? Colors.black
                        : denoInd == index
                            ? Colors.white
                            : Colors.black,
                    fontSize: 20,

                    maxLines: 1, // Limit to a single line if necessary
                  ),
                  CustomDisplayText(
                    label: "Token",
                    fontWeight: FontWeight.w500,
                    color: tokenAmount.text.isEmpty
                        ? Colors.black
                        : denoInd == index
                            ? Colors.white
                            : Colors.black,
                    fontSize: 11,
                    maxLines: 1, // Limit to a single line if necessary
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
