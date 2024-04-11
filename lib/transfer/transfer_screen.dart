import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:luvpark/classess/DbProvider.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/textstyle.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/notification_controller/notification_controller.dart';
import 'package:luvpark/otp/otp_update.dart';
import 'package:luvpark/transfer/success_details.dart';
// import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransferOptions extends StatefulWidget {
  const TransferOptions({super.key});

  @override
  State<TransferOptions> createState() => _TransferOptionsState();
}

class _TransferOptionsState extends State<TransferOptions> {
  TextEditingController recepient = TextEditingController();
  TextEditingController tokenAmount = TextEditingController();
  TextEditingController message = TextEditingController();
  TextEditingController sub = TextEditingController();
  final GlobalKey contentKey = GlobalKey();
  bool isLpAccount = false;
  bool isLoading = true;
  bool isBtnDisabled = true;
  bool isInternetConnected = true;
  String myBalance = "";
  dynamic akongP;
  int denoInd = 0;
  List<String> padNumbers = ["10", "20", "30", "40", "50", "100", "200", "250"];
  bool isValidNumber = false;
  double amountBal = 0.0;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getConsumerData();
    });
  }

  void getConsumerData() async {
    setState(() {
      myBalance = "";
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    akongP = prefs.getString(
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
          myBalance = "";
          isLoading = true;
          isInternetConnected = false;
        });
        Navigator.of(context).pop();
        return;
      }
      if (returnData == null) {
        setState(() {
          myBalance = "";
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
          myBalance = "";
        });
        if (returnData["items"].length == 0) {
          myBalance = "";
          Navigator.of(context).pop();
          showAlertDialog(context, "Error", "No data found.", () {
            Navigator.of(context).pop();
          });
        } else {
          setState(() {
            myBalance = returnData["items"][0]["amount_bal"].toString();
            amountBal =
                double.parse(returnData["items"][0]["amount_bal"].toString());
            isInternetConnected = true;
            isLoading = false;
          });
          Navigator.pop(context);
        }
      }
    });
  }

  biometricTransaction() async {
    // ignore: unused_local_variable

    final LocalAuthentication auth = LocalAuthentication();
    // ignore: unused_local_variable
    bool canCheckBiometrics = false;

    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      debugPrint("$e");
    }

    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Confirm using fingerprint',
        options: const AuthenticationOptions(
          stickyAuth: true,
          sensitiveTransaction: false,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint("$e");
    }
    if (authenticated) {
      transferFunc();
    } else {}
  }

  transferFunc() {
    CustomModal(context: context).loader();

    Map<String, dynamic> parameters = {
      "user_id": jsonDecode(akongP!)['user_id'].toString(),
      "to_mobile_no": "63${recepient.text.replaceAll(" ", "")}",
      "amount": tokenAmount.text.toString().replaceAll(",", ""),
      "to_msg": message.text,
    };

    HttpRequest(api: ApiKeys.gApiSubFolderPutShareLuv, parameters: parameters)
        .put()
        .then(
      (retvalue) {
        if (retvalue == "No Internet") {
          Navigator.pop(context);
          showAlertDialog(context, "Error",
              "Please check your internet connection and try again.", () {
            Navigator.pop(context);
          });
          return;
        }
        if (retvalue == null) {
          Navigator.pop(context);
          showAlertDialog(context, "Error",
              "Error while connecting to server, Please try again.", () {
            Navigator.of(context).pop();
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          });
        } else {
          if (retvalue["success"] == "Y") {
            NotificationController.shareTokenNotification(
                0, 0, 'Transfer Token', "${retvalue["msg"]}.", "walletScreen");

            Navigator.of(context).pop();

            Variables.pageTrans(SuccessDetails(
                amount: tokenAmount.text.toString().replaceAll(",", "")));
          } else {
            Navigator.of(context).pop();
            showAlertDialog(context, "Error", retvalue["msg"], () {
              Navigator.of(context).pop();
            });
          }
        }
      },
    );
  }

  sendOtp() {
    CustomModal(context: context).loader();

    Map<String, dynamic> parameters = {
      "mobile_no": jsonDecode(akongP!)['mobile_no'].toString(),
    };

    HttpRequest(
            api: ApiKeys.gApiSubFolderPostReqOtpShare, parameters: parameters)
        .post()
        .then(
      (retvalue) {
        if (retvalue == "No Internet") {
          Navigator.pop(context);
          showAlertDialog(context, "Error",
              "Please check your internet connection and try again.", () {
            Navigator.pop(context);
          });
          return;
        }
        if (retvalue == null) {
          Navigator.pop(context);
          showAlertDialog(context, "Error",
              "Error while connecting to server, Please try again.", () {
            Navigator.of(context).pop();
          });
        } else {
          if (retvalue["success"] == "Y") {
            Navigator.of(context).pop();
            Variables.pageTrans(OtpTransferScreen(
              otp: int.parse(retvalue["otp"].toString()),
              mobileNo: jsonDecode(akongP!)['mobile_no'].toString(),
              onCallbackTap: () {
                transferFunc();
              },
            ));
          } else {
            Navigator.of(context).pop();
            showAlertDialog(context, "Error", retvalue["msg"], () {
              Navigator.of(context).pop();
            });
          }
        }
      },
    );
  }

  onTextChange() {
    setState(() {
      denoInd = -1;
    });
    if (recepient.text.isEmpty ||
        tokenAmount.text.isEmpty ||
        double.parse(
                tokenAmount.text.replaceAll(",", "").replaceAll(".", "")) <=
            0) {
      setState(() {
        isBtnDisabled = true;
      });
    } else {
      setState(() {
        isBtnDisabled = false;
      });
    }
  }

  onTapChange(String value, index) {
    setState(() {
      denoInd = index;
      tokenAmount.text = value.toString();
    });

    if (recepient.text.isEmpty ||
        tokenAmount.text.isEmpty ||
        double.parse(tokenAmount.text) <= 0) {
      setState(() {
        isBtnDisabled = true;
      });
    } else {
      setState(() {
        isBtnDisabled = false;
      });
    }
  }

  getVerifyAccount() {
    CustomModal(context: context).loader();
    var params =
        "${ApiKeys.gApiSubFolderVerifyNumber}?mobile_no=63${recepient.text.toString().replaceAll(" ", "")}";
    HttpRequest(
      api: params,
    ).get().then((returnData) async {
      if (returnData == "No Internet") {
        Navigator.pop(context);
        setState(() {
          isLpAccount = false;
        });
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again", () {
          Navigator.pop(context);
        });

        return;
      }

      if (returnData == null) {
        Navigator.pop(context);
        setState(() {
          isLpAccount = false;
        });
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please contact support.", () {
          Navigator.pop(context);
        });
      }

      if (returnData["items"][0]["is_valid"] == "Y") {
        Navigator.of(context).pop();
        DbProvider().getAuthTransaction().then((enableBioTrans) async {
          if (enableBioTrans) {
            biometricTransaction();
          } else {
            sendOtp();
          }
        });
      } else {
        Navigator.pop(context);
        setState(() {
          isLpAccount = false;
        });
        showAlertDialog(context, "Error", returnData["items"][0]["msg"], () {
          Navigator.pop(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
        canPop: true,
        appBarheaderText: "Share",
        appBarIconClick: () {
          Navigator.of(context).pop();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 15,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            7,
                          ),
                        ),
                        child: Icon(
                          Icons.wallet_rounded,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      Container(
                        width: 10,
                      ),
                      CustomDisplayText(
                        label: "Available Balance",
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 12,
                        alignment: TextAlign.center,
                      ),
                      Expanded(
                        child: CustomDisplayText(
                          label: toCurrencyString(myBalance.toString()),
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          alignment: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 20,
              ),
              LabelText(text: "Recipient"),
              CustomMobileNumber(
                labelText: "Mobile No",
                inputFormatters: [Variables.maskFormatter],
                keyboardType: TextInputType.number,
                controller: recepient,
                onChange: (text) {
                  onTextChange();
                },
              ),
              LabelText(text: "Amount"),
              CustomTextField(
                labelText: "0.00",
                controller: tokenAmount,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),
                  //  ThousandsFormatter(allowFraction: true),
                ],
                onChange: (text) {
                  onTextChange();
                },
              ),
              LabelText(text: "Note"),
              CustomTextField(labelText: "Optional", controller: message),
              Container(
                height: 5,
              ),
              for (int i = 0; i < padNumbers.length; i += 4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int j = i; j < i + 4 && j < padNumbers.length; j++)
                      myPads(int.parse(padNumbers[j]), j),
                  ],
                ),
              Container(
                height: 20,
              ),
              CustomButton(
                  label: "Continue",
                  color: AppColor.primaryColor,
                  onTap: () {
                    FocusManager.instance.primaryFocus!.unfocus();
                    if (isBtnDisabled) {
                      showAlertDialog(context, "Attention",
                          "Please ensure that you have filled out the provided form before we can proceed.",
                          () {
                        Navigator.of(context).pop();
                      });
                      return;
                    }

                    if (double.parse(
                            tokenAmount.text.toString().replaceAll(",", "")) >
                        double.parse(amountBal.toString())) {
                      showAlertDialog(context, "Attention",
                          "You don't have enough balance to proceed", () {
                        Navigator.of(context).pop();
                      });
                      return;
                    }
                    if (jsonDecode(akongP!)['mobile_no'].toString() ==
                        "63${recepient.text.replaceAll(" ", "")}") {
                      showAlertDialog(
                          context, "Attention", "Please use another number.",
                          () {
                        Navigator.of(context).pop();
                      });
                      return;
                    }
                    showModalConfirmation(context, "Confirmation",
                        "Are you sure you want to proceed?", "Cancel", () {
                      Navigator.of(context).pop();
                    }, () async {
                      Navigator.of(context).pop();
                      getVerifyAccount();
                    });
                  }),
              Container(
                height: 20,
              ),
            ],
          ),
        ));
  }

  Widget myPads(int value, int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: InkWell(
            onTap: () => onTapChange("$value", index),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 17, 20, 17),
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
                  // CustomDisplayText(
                  //   label: "$value",
                  //   fontWeight: FontWeight.w600,
                  //   color: tokenAmount.text.isEmpty
                  //       ? Colors.black
                  //       : tokenAmount.text.isEmpty
                  //           ? AppColor.bodyColor
                  //           : denoInd == index
                  //               ? Colors.white
                  //               : Colors.black,
                  //   fontSize: 20,
                  // ),
                  AutoSizeText(
                    "$value",
                    style: CustomTextStyle(
                      fontWeight: FontWeight.w600,
                      color: tokenAmount.text.isEmpty
                          ? Colors.black
                          : tokenAmount.text.isEmpty
                              ? AppColor.bodyColor
                              : denoInd == index
                                  ? Colors.white
                                  : Colors.black,
                      fontSize: 20,
                    ),
                    // minFontSize: 12, // Adjust as needed
                    // maxFontSize: 20, // Adjust as needed
                    maxLines: 1, // Limit to a single line if necessary
                    softWrap:
                        false, // Disable soft wrap if you don't want text to wrap
                  ),
                  CustomDisplayText(
                    label: "Token",
                    fontWeight: FontWeight.w500,
                    color: tokenAmount.text.isEmpty
                        ? Colors.black
                        : denoInd == index
                            ? Colors.white
                            : Colors.black,
                    fontSize: 12,
                    minFontsize: 12, // Adjust as needed
                    maxFontsize: 12, //
                    maxLines: 1,
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  CurrencyInputFormatter({this.maxDigits = 10});
  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    if (newValue.selection.baseOffset > maxDigits) {
      return oldValue;
    }

    final oldValueText = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String newValueText = newValue.text;

    // We manually remove the value we want to remove
    // If oldValueText == newValue.text it means we deleted a non digit number.
    if (oldValueText == newValue.text) {
      newValueText = newValueText.substring(0, newValue.selection.end - 1) +
          newValueText.substring(newValue.selection.end, newValueText.length);
    }

    double value = double.parse(newValueText);
    final formatter = NumberFormat.currency(locale: 'eu', symbol: '€');
    String newText = formatter.format(value / 100);

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}
