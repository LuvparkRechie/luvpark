import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/bottom_tab/bottom_tab.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayParkingConfirmation extends StatefulWidget {
  final Function? onTap;
  final String amountFee;
  final List paramDetails;
  final List? paramExtend;
  final String myBalance;

  const PayParkingConfirmation({
    super.key,
    this.onTap,
    this.paramExtend,
    required this.amountFee,
    required this.paramDetails,
    required this.myBalance,
  });

  @override
  State<PayParkingConfirmation> createState() => _PayParkingConfirmationState();
}

class _PayParkingConfirmationState extends State<PayParkingConfirmation> {
  //variables
  // ignore: prefer_typing_uninitialized_variables
  var akongP;
  // ignore: prefer_typing_uninitialized_variables
  var myProfilePic;
  String personName = "";
  String fullName = "";
  bool isLoadingPage = true;
  bool isClickedPayment = false;

  @override
  void initState() {
    getPreferences();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    akongP = prefs.getString(
      'userData',
    );
    var myPicData = prefs.getString(
      'myProfilePic',
    );
    setState(() {
      myProfilePic = jsonDecode(myPicData!).toString();
    });
    setState(() {
      fullName =
          "${jsonDecode(akongP!)['first_name'].toString()} ${jsonDecode(akongP!)['last_name'].toString()}";
      personName =
          " ${jsonDecode(akongP!)['first_name'].toString()} ${jsonDecode(akongP!)['last_name'].toString()[0]}. ";
      isLoadingPage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: Wrap(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: isLoadingPage
                  ? Container()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                        ),
                        Center(
                          child: Container(
                            width: 64,
                            height: 7,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFD9D9D9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7)),
                            ),
                          ),
                        ),
                        Container(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomDisplayText(
                              label: "Confirm Payment",
                              color: const Color(0xFF353536),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: -0.32,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black45),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 17,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        Container(
                          height: 20,
                        ),
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF8F8F8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(13),
                            child: Row(
                              children: [
                                isLoadingPage
                                    ? const CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Color(0xFF9A9A9A),
                                      )
                                    : CircleAvatar(
                                        radius: 25,
                                        backgroundColor: AppColor.primaryColor,
                                        child: Center(
                                          child: CustomDisplayText(
                                            label: jsonDecode(akongP!)[
                                                            'last_name']
                                                        .toString() ==
                                                    'null'
                                                ? "N/A"
                                                : "${jsonDecode(akongP!)['first_name'].toString()[0]}${jsonDecode(akongP!)['last_name'].toString()[0]}",
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            height: 0,
                                            letterSpacing: -0.32,
                                          ),
                                        ),
                                      ),
                                Container(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomDisplayText(
                                        label: jsonDecode(akongP!)['last_name']
                                                    .toString() ==
                                                'null'
                                            ? "Not Verified"
                                            : fullName,
                                        color: const Color(0xFF353536),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        height: 0,
                                        letterSpacing: -0.32,
                                        maxLines: 1,
                                      ),
                                      CustomDisplayText(
                                        label:
                                            "+63${Variables.displayLastFourDigitsWithAsterisks(int.parse(jsonDecode(akongP!)['mobile_no'].toString().substring(2)))}",
                                        color: const Color(0xFF9A9A9A),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        height: 0,
                                        letterSpacing: -0.32,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: CustomDisplayText(
                                            label: toCurrencyString(
                                                widget.myBalance.toString()),
                                            color: const Color(0xFF353536),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.32,
                                            maxLines: 1,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: CustomDisplayText(
                                            label: "My Balance",
                                            color: const Color(0xFF353536),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            height: 0,
                                            letterSpacing: -0.20,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 18,
                        ),
                        CustomDisplayText(
                          label: "Amount to Pay",
                          color: const Color(0xFF353536),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: -0.32,
                        ),
                        Container(
                          height: 14,
                        ),
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF8F8F8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CustomDisplayText(
                                      label: 'Total Token',
                                      color: const Color(0xFF353536),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 0,
                                      letterSpacing: -0.32,
                                    ),
                                    Expanded(
                                      child: CustomDisplayText(
                                        label:
                                            toCurrencyString(widget.amountFee),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        height: 0,
                                        letterSpacing: -0.32,
                                        alignment: TextAlign.right,
                                      ),
                                    )
                                  ],
                                ),
                                const Divider(),
                                Container(
                                  height: 10,
                                ),
                                confirmDetails(
                                    "Date In",
                                    DateFormat('dd-MM-yyyy hh:mm a')
                                        .format(DateTime.parse(
                                            widget.paramDetails[0]["dt_in"]))
                                        .toString()),
                                Container(
                                  height: 5,
                                ),
                                confirmDetails(
                                    "Date Out",
                                    DateFormat('dd-MM-yyyy hh:mm a')
                                        .format(DateTime.parse(
                                            widget.paramDetails[0]["dt_out"]))
                                        .toString()),
                                Container(
                                  height: 5,
                                ),
                                confirmDetails("Hours",
                                    "${widget.paramDetails[0]["no_hours"].toString()} ${int.parse(widget.paramDetails[0]["no_hours"].toString()) > 1 ? "hrs" : "hr"}"),
                                Container(
                                  height: 5,
                                ),
                                confirmDetails(
                                    "Vehicle",
                                    widget.paramDetails[0]["vehicle_plate_no"]
                                        .toString()),
                                Container(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 20,
                        ),
                        isClickedPayment
                            ? const Center(
                                child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator()),
                              )
                            : CustomButton(
                                label:
                                    "Proceed to pay - ${toCurrencyString(widget.amountFee)}",
                                onTap: () {
                                  if (isClickedPayment) return;
                                  if (widget.onTap != null) {
                                    widget.onTap!();
                                  } else {
                                    submitExtend();
                                  }
                                }),
                        Container(
                          height: 20,
                        ),
                      ],
                    ),
            ),
          )
        ],
      ),
    );
  }

  Widget confirmDetails(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: CustomDisplayText(
            label: label,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            fontSize: 14,
            alignment: TextAlign.left,
          ),
        ),
        Expanded(
            child: CustomDisplayText(
          label: value,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontSize: 14,
          maxLines: 1,
        )),
      ],
    );
  }

  void submitExtend() async {
    CustomModal(context: context).loader();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var akongP = prefs.getString(
      'userData',
    );

    HttpRequest(
            api: ApiKeys.gApiSubFolderPutExtend,
            parameters: widget.paramExtend![0])
        .put()
        .then((returnPost) {
      print("return posting $returnPost");
      if (returnPost == "No Internet") {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.pop(context);
        });
        return;
      }
      if (returnPost == null) {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      }

      if (returnPost["success"] == "Y") {
        var param = {
          "payment_date": DateTime.now().toString().split(".")[0],
          "amount": returnPost["amount"].toString(),
          "dt_out": returnPost["dt_out"].toString(),
          "reservation_ref_no": widget.paramExtend![0]["ps_ref_no"].toString(),
          "user_id": jsonDecode(akongP!)['user_id'].toString(),
          "no_hours": widget.paramDetails[0]["no_hours"].toString(),
        };

        HttpRequest(api: ApiKeys.gApiSubFolderPutExtendPay, parameters: param)
            .put()
            .then((returnPut) {
          print("return putting $returnPut");
          if (returnPut == "No Internet") {
            Navigator.pop(context);
            showAlertDialog(context, "Error",
                "Please check your internet connection and try again.", () {
              Navigator.pop(context);
            });
            return;
          }
          if (returnPut == null) {
            Navigator.pop(context);
            showAlertDialog(context, "Error",
                "Error while connecting to server, Please try again.", () {
              Navigator.of(context).pop();
            });
          }
          if (returnPut["success"] == "Y") {
            Navigator.pop(context);

            showAlertDialog(context, "Success", returnPut["msg"].toString(),
                () async {
              Navigator.pop(context);
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                Navigator.pop(context);
                Variables.pageTrans(
                    const MainLandingScreen(
                      parkingIndex: 1,
                      index: 1,
                    ),
                    context);
              }
            });
          } else {
            Navigator.pop(context);

            showAlertDialog(context, "Error", returnPut["msg"], () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              Navigator.of(context).pop();
            });
          }
        });
      } else {
        Navigator.pop(context);
        showAlertDialog(context, "Error", returnPost["msg"], () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          Navigator.of(context).pop();
        });
      }
    });
  }
}
