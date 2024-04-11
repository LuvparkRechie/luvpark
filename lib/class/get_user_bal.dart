import 'package:flutter/material.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';

class UserAccount {
  static getUserBal(context, userId, Function callBack) async {
    //  CustomModal(context: context).loader();

    var params = "${ApiKeys.gApiSubFolderGetBalance}?user_id=$userId";

    try {
      var returnData = await HttpRequest(api: params).get();

      if (returnData == "No Internet") {
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();

          callBack([]);
        });

        return;
      }

      if (returnData == null) {
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please contact support.", () {
          Navigator.of(context).pop();

          callBack([]);
        });

        return;
      } else {
        if (returnData["items"].length == 0) {
          callBack([]);
          return;
        } else {
          callBack(returnData["items"]);
          return;
        }
      }
    } catch (e) {
      return;
    }
  }
}
