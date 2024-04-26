import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
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
                        ),
                      ),
                    );
                  },
                );
              } else {
                Navigator.of(context).pop();
                showAlertDialog(
                  context,
                  "Error",
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
      children: [
        Divider(
          color: Colors.black,
        ),
        SizedBox(
          height: 15,
        ),
        CustomButton(
          btnHeight: 10,
          color: Colors.red.shade700,
          label: 'Delete Account',
          onTap: () => postDeleteAccount(context),
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomDisplayText(
              label: title,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            )
          ],
        ),
        content: CustomDisplayText(
          label: msg,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          alignment: TextAlign.justify,
        ),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              onPressed: () {
                pressCancel();
              },
              child: CustomDisplayText(
                label: cancelButtonLabel,
                fontSize: 14,
                alignment: TextAlign.center,
                fontWeight: FontWeight.w600,
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
              child: CustomDisplayText(
                color: Colors.red,
                label: continueButtonLabel,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                alignment: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    },
  );
}
