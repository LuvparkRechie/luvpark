import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/webview/webview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDelete extends StatefulWidget {
  const ProfileDelete({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileDelete> createState() => _ProfileDeleteState();
}

class _ProfileDeleteState extends State<ProfileDelete> {
  void postDeleteAccount(BuildContext context) async {
    showModalConfirmation(
      context,
      "Delete your account?",
      "Deleting your account will result in the loss of all your data. You'll be redirected to the account deletion page where you'll receive an SMS containing an OTP code. Our support team will then reach out to you promptly.",
      "No, I've changed my mind",
      "Delete my account",
      () {
        Navigator.of(context).pop();
      },
      () async {
        Navigator.of(context).pop();
        CustomModal(context: context).loader();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        var userData = prefs.getString('userData');

        if (userData == null) {
          // Handle error
          return;
        }
        Map<String, dynamic> param = {
          'mobile_no': jsonDecode(userData)['mobile_no'].toString(),
        };

        HttpRequest(api: ApiKeys.gApiLuvPayPostDeleteAccount, parameters: param)
            .post()
            .then(
          (returnData) async {
            if (returnData == "No Internet") {
              Navigator.pop(context);
              showAlertDialog(
                context,
                "Error",
                "Please check your internet connection and try again.",
                () {
                  Navigator.of(context).pop();
                },
              );
              return;
            }
            if (returnData == null) {
              Navigator.pop(context);
              showAlertDialog(
                context,
                "Error",
                "Error while connecting to server. Please contact support.",
                () {
                  Navigator.pop(context);
                },
              );
            } else {
              if (returnData["success"] == "Y") {
                Navigator.of(context).pop();
                showAlertDialog(
                  context,
                  "Success",
                  "You will be directed to delete account page. Wait for customer support",
                  () {
                    Navigator.of(context).pop();
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebviewPage(
                          urlDirect: "https://luvpark.ph/account-deletion/",
                          label: "Account Deletion ",
                          isBuyToken: false,
                          callback: () {
                            CustomModal(context: context).loader();
                            Navigator.of(context).pushNamed('/');
                          },
                        ),
                      ),
                    );
                  },
                );
              } else {
                Navigator.of(context).pop();
                showAlertDialog(
                  context,
                  "LuvPark",
                  returnData["msg"],
                  () {
                    Navigator.of(context).pop();
                  },
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 15,
        ),
        GestureDetector(
          onTap: () => postDeleteAccount(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
            ),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                ),
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.red,
                    ),
                    Container(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomParagraph(
                        text: 'Delete My Account',
                        color: Colors.red,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void showModalConfirmation(
  BuildContext context,
  String title,
  String msg,
  String cancelButtonLabel,
  String continueButtonLabel,
  Function pressCancel,
  Function pressContinue,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: CustomTitle(
          text: "Delete your account?",
        ),
        content: CustomParagraph(
          text: "$msg",
        ),
        // CustomDisplayText(
        //   label: msg,
        //   fontSize: 14,
        //   fontWeight: FontWeight.normal,
        //   alignment: TextAlign.justify,
        // ),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              onPressed: () {
                pressCancel();
              },
              child: Text(
                cancelButtonLabel,
                style: paragraphStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColor.primaryColor,
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                pressContinue();
              },
              child: Text(
                continueButtonLabel,
                style: paragraphStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    },
  );
}
