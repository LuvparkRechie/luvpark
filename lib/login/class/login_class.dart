import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
//import 'package:flutter_background_service/flutter_background_service.dart';
//import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:luvpark/bottom_tab/bottom_tab.dart';
import 'package:luvpark/classess/DbProvider.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/biometric_login.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/notification_controller/notification_controller.dart';
import 'package:luvpark/sqlite/pa_message_table.dart';
import 'package:luvpark/sqlite/reserve_notification_table.dart';
import 'package:luvpark/sqlite/share_location_table.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

class LoginComponent {
  void loginFunc(pass, mobile, context, Function cb) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> postParam = {
      "mobile_no": mobile,
      "pwd": pass,
    };
    HttpRequest(api: ApiKeys.gApiSubFolderPostLogin, parameters: postParam)
        .post()
        .then((returnPost) {
      if (returnPost == "No Internet") {
        showAlertDialog(context, "Error",
            "please check your internet connection and try again.", () {
          Navigator.pop(context);
          cb([false, "No Internet"]);
        });
        return;
      }

      if (returnPost == null) {
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
          cb([false, null]);
        });
      } else {
        if (returnPost["success"] == "N") {
          showAlertDialog(context, "Error", returnPost["msg"], () {
            Navigator.pop(context);
            cb([false, "Error"]);
          });
          return;
        }
        if (returnPost["success"] == 'Y') {
          var getApi =
              "${ApiKeys.gApiSubFolderLogin}?mobile_no=$mobile&auth_key=${returnPost["auth_key"].toString()}";
          HttpRequest(api: getApi).get().then((objData) async {
            if (objData == "No Internet") {
              //   Navigator.pop(context);
              showAlertDialog(context, "Error",
                  "Please check your internet connection and try again.", () {
                Navigator.pop(context);
                cb([false, "No Internet"]);
              });
              return;
            }

            if (objData == null) {
              //   Navigator.of(context).pop();
              showAlertDialog(context, "Error",
                  "Error while connecting to server, Please contact support.",
                  () {
                Navigator.of(context).pop();
                cb([false, null]);
              });

              return;
            } else {
              if (objData["items"].length == 0) {
                Navigator.pop(context);
                showAlertDialog(context, "Error", objData["items"]["msg"], () {
                  Navigator.pop(context);
                });
                return;
              } else {
                if (objData["items"][0]["msg"] == 'Y') {
                  //    final service = FlutterBackgroundService();
                  prefs.remove('loginData');
                  prefs.remove('userData');
                  prefs.remove('geo_connect_id');
                  var items = objData["items"][0];
                  Variables.timerSec = int.parse(items["timeout"].toString());
                  var logData = prefs.getString(
                    'loginData',
                  );
                  var myId = prefs.getString(
                    'myId',
                  );
                  prefs.setBool('isLoggedIn', true);

                  //   service.invoke("stopService");
                  tz.initializeTimeZones();

                  if (logData == null) {
                    Map<String, dynamic> parameters = {
                      "mobile_no": mobile,
                      "is_active": "Y",
                    };
                    await prefs.setString('loginData', jsonEncode(parameters));
                    BiometricLogin().setPasswordBiometric(pass);
                  } else {
                    var logData2 = prefs.getString(
                      'loginData',
                    );

                    var mappedLogData = [jsonDecode(logData2!)];
                    mappedLogData[0]["is_active"] = "Y";
                    await prefs.setString(
                        'loginData', jsonEncode(mappedLogData[0]));

                    BiometricLogin().setPasswordBiometric(pass);
                  }

                  // ignore: use_build_context_synchronously
                  if (myId != null) {
                    if (int.parse(myId.toString()) !=
                        int.parse(items['user_id'].toString())) {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      await NotificationDatabase.instance.deleteAll();
                      NotificationController.cancelNotifications();
                      NotificationDatabase.instance.deleteAll();
                      PaMessageDatabase.instance.deleteAll();
                      ShareLocationDatabase.instance.deleteAll();
                      pref.remove('myId');
                      pref.clear();
                      var mPinParams = {
                        "user_id": items['user_id'].toString(),
                        "is_on": "N"
                      };
                      DbProvider().saveAuthTransaction(false);
                      DbProvider().saveAuthState(false);
                      HttpRequest(
                              api: ApiKeys.gApiSubFolderPutSwitch,
                              parameters: mPinParams)
                          .put();
                    }
                  }

                  await prefs.setString('myId', items['user_id'].toString());
                  await prefs.setString('userData', jsonEncode(items));
                  await prefs.setString(
                      'myProfilePic', jsonEncode(items["image_base64"]));

                  cb([true, "Success"]);
                  // if (await service.isRunning()) {
                  //   service.invoke("stopService");
                  // }
                  // service.startService();
                  // AndroidBackgroundProcess.initilizeBackgroundService();
                  prefs.remove(
                    'provinceData',
                  );
                  prefs.remove(
                    'cityData',
                  );
                  prefs.remove(
                    'brgyData',
                  );

                  Variables.pageTrans(const MainLandingScreen());
                } else {
                  if (objData["items"][0]["msg"] == 'Not Yet Registered') {
                    showModalConfirmation(
                        context,
                        "Inactive Account",
                        "Your account is currently inactive. Would you like to activate it now?",
                        "",
                        "Not now", () {
                      Navigator.of(context).pop();
                      cb([false, "No"]);
                    }, () async {
                      Navigator.pop(context);
                      cb([false, "No"]);
                    });

                    return;
                  } else {
                    showAlertDialog(
                        context, "Error", objData["items"][0]["msg"], () {
                      Navigator.pop(context);
                      cb([false, "No"]);
                    });

                    return;
                  }
                }
              }
            }
          });
        }
      }
    });
  }

  void getAccountStatus(context, mobile, pass, Function cb) {
    HttpRequest(
            api:
                "${ApiKeys.gApiSubFolderGetLoginAttemptRecord}?mobile_no=$mobile")
        .get()
        .then((objData) {
      if (objData == "No Internet") {
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
          cb("No Internet");
        });
        return;
      }
      if (objData == null) {
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
          cb([]);
        });

        return;
      } else {
        cb(objData["items"]);
      }
    });
  }
}
