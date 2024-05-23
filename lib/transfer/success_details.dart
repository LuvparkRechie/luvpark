import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/bottom_tab/bottom_tab.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/transfer/transfer_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuccessDetails extends StatefulWidget {
  final String amount;
  const SuccessDetails({super.key, required this.amount});

  @override
  State<SuccessDetails> createState() => _SuccessDetailsState();
}

class _SuccessDetailsState extends State<SuccessDetails> {
  bool isLoading = true;
  bool isInternetConnected = true;
  String currentBalance = "";

  @override
  void initState() {
    super.initState();
    getConsumerData();
  }

  void getConsumerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var akongP = prefs.getString(
      'userData',
    );

    // ignore: use_build_context_synchronously
    CustomModal(context: context).loader();

    HttpRequest(
            api:
                "${ApiKeys.gApiSubFolderGetBalance}?user_id=${jsonDecode(akongP!)['user_id'].toString()}")
        .get()
        .then((returnData) {
      if (returnData == "No Internet") {
        setState(() {
          isLoading = false;
          isInternetConnected = false;
        });
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.pop(context);
        });
        return;
      }
      if (returnData == null) {
        setState(() {
          isInternetConnected = true;
          isLoading = false;
        });
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please contact support.", () {
          Navigator.of(context).pop();
        });

        return;
      } else {
        setState(() {
          isInternetConnected = true;
          isLoading = false;
        });
        if (returnData["items"].length == 0) {
          Navigator.of(context).pop();
          showAlertDialog(context, "Error", "No data found.", () {
            Navigator.of(context).pop();
          });
        } else {
          Navigator.pop(context);
          setState(() {
            currentBalance = returnData["items"][0]["amount_bal"].toString();
            isInternetConnected = true;
            isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
      appbarColor: AppColor.bodyColor,
      onPop: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: !isInternetConnected
            ? SizedBox(
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      getConsumerData();
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        height: 70,
                        width: 50,
                        image: AssetImage(
                            "assets/images/no_internet_connection.png"),
                      ),
                      const Text(
                        "Unable to connect to our server,\nPlease check your internet connection.",
                      ),
                      Container(
                        height: 20,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh),
                          Text(" Tap to retry"),
                        ],
                      )
                    ],
                  ),
                ),
              )
            : isLoading
                ? Container()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                      ),
                      Card(
                        // width: MediaQuery.of(context).size.width,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                        ),
                        color: const Color(0xFFffffff),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // const CircleAvatar(
                              //   maxRadius: 30,
                              //   backgroundImage: AssetImage(
                              //       "assets/images/succesfull_transaction.png"),
                              // ),
                              const Image(
                                  height: 100,
                                  width: 150,
                                  image: AssetImage(
                                      "assets/images/succesfull_transaction.png")),
                              Container(
                                height: 20,
                              ),
                              CustomDisplayText(
                                label: "Transaction Successful",
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),

                              Container(
                                height: 20,
                              ),
                              Text(
                                "Your transaction to the recipient \nwas sent successfully.",
                                style: GoogleFonts.varela(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                              Container(
                                height: 30,
                              ),
                              Text(
                                " ${widget.amount.toString()}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 25,
                                ),
                              ),
                              Container(
                                height: 10,
                              ),
                              const Divider(
                                thickness: 1.5,
                              ),
                              Container(
                                height: 20,
                              ),
                              Text(
                                "Remaining Balance: ${toCurrencyString(currentBalance.toString())}",
                                style: GoogleFonts.varela(
                                  color: AppColor.primaryColor,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 20,
                      ),
                      CustomButton(
                        label: "Make another transaction",
                        onTap: () {
                          Navigator.pop(context);
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                          Variables.pageTrans(const TransferOptions(), context);
                        },
                      ),
                      Container(
                        height: 10,
                      ),
                      CustomButtonCancel(
                        color: Colors.grey.shade200,
                        textColor: Colors.black,
                        label: "Done",
                        onTap: () {
                          Navigator.pop(context);
                          Variables.pageTrans(
                              const MainLandingScreen(
                                index: 2,
                              ),
                              context);
                        },
                      ),
                    ],
                  ),
      ),
    );
  }
}
