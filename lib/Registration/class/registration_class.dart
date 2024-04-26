import 'package:flutter/material.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/biometric_login.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/otp/otp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubmitData {
  void submitRegistration(context, param) {
    Map<String, dynamic> parameters = {
      "mobile_no": param["mobile_no"],
    };

    CustomModal(context: context).loader();

    HttpRequest(api: ApiKeys.gApiLuvParkPostReg, parameters: param)
        .post()
        .then((returnPost) async {
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
      } else {
        if (returnPost["success"] == "Y") {
          Navigator.of(context).pop();
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', false);
          BiometricLogin().setPasswordBiometric(param["pwd"]);
          parameters["is_active"] = "N";

          showAlertDialog(context, "LuvPark",
              "We have sent an activation code\nto your mobile number.", () {
            Navigator.of(context).pop();
            // if (Navigator.of(context).canPop()) {
            //   Navigator.of(context).pop();
            // }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: ((context) => OTPScreen(
                      otp: int.parse(returnPost["otp"]),
                      mobileNo: param["mobile_no"],
                      reqType: "VERIFY",
                      seqId: 0,
                      seca: "",
                      seqNo: 1,
                      newPass: "",
                    )),
              ),
            );
          });
        } else {
          Navigator.of(context).pop();
          showAlertDialog(context, "Attention", returnPost["msg"], () {
            Navigator.of(context).pop();
          });

          return;
        }
      }
    });
  }
}
