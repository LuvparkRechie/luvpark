import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/location_controller.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/sqlite/vehicle_brands_table.dart';
import 'package:shared_preferences/shared_preferences.dart';

BuildContext? ctxt;

class Functions {
  static void init(BuildContext context) {
    ctxt = context;
  }

  static Future<void> getUserBalance(Function cb) async {
    final prefs = await SharedPreferences.getInstance();
    var myData = prefs.getString(
      'userData',
    );
    String subApi =
        "${ApiKeys.gApiSubFolderGetBalance}?user_id=${jsonDecode(myData!)['user_id'].toString()}";

    HttpRequest(api: subApi).get().then((returnBalance) async {
      print("returnBalance $returnBalance");
      if (returnBalance == "No Internet") {
        cb("No Internet");
        showAlertDialog(ctxt!, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(ctxt!).pop();
        });

        return;
      }
      if (returnBalance == null) {
        cb("null");
        showAlertDialog(ctxt!, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(ctxt!).pop();
        });
        return;
      } else {
        cb({
          "user_bal":
              double.parse(returnBalance["items"][0]["amount_bal"].toString()),
          "min_wal_bal": double.parse(
              returnBalance["items"][0]["min_wallet_bal"].toString())
        });
      }
    });
  }

  static Future<void> checkIn(ticketId, lat, long, Function cb) async {
    var otpData = {
      "device_key": null,
      "emp_id": null,
      "ticket_id": ticketId,
      "longitude": long,
      "latitude": lat,
      "is_auto": "Y",
    };

    HttpRequest(api: ApiKeys.gApiLuvParkPutChkIn, parameters: otpData)
        .put()
        .then((returnData) async {
      if (returnData == "No Internet") {
        cb("No Internet");
        showAlertDialog(ctxt!, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(ctxt!).pop();
        });

        return;
      }
      if (returnData == null) {
        cb("null");
        showAlertDialog(ctxt!, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(ctxt!).pop();
        });

        return;
      }

      if (returnData["success"] == 'Y') {
        var otpData = {
          "ticket_ref_no": returnData['ticket_ref_no'],
        };
        HttpRequest(api: ApiKeys.gApiLuvParkPutLPChkIn, parameters: otpData)
            .put()
            .then((returnData2) async {
          if (returnData2 == "No Internet") {
            cb("No Internet");
            showAlertDialog(ctxt!, "Error",
                "Please check your internet connection and try again.", () {
              Navigator.of(ctxt!).pop();
            });

            return;
          }
          if (returnData2 == null) {
            cb("null");
            showAlertDialog(ctxt!, "Error",
                "Error while connecting to server, Please try again.", () {
              Navigator.of(ctxt!).pop();
            });

            return;
          }

          if (returnData2["success"] == 'Y') {
            cb("Success");
          } else {
            cb("Error");
            showAlertDialog(ctxt!, "Attention", returnData["msg"], () {
              Navigator.of(ctxt!).pop();
            });
          }
        });
      } else {
        cb("Error");
        showAlertDialog(ctxt!, "Attention", returnData["msg"], () {
          Navigator.of(ctxt!).pop();
        });
      }
    });
  }

  static Future<void> computeDistanceResorChckIN(
      context, LatLng dest, Function cb) async {
    LocationService.grantPermission(context, (isGranted) {
      if (isGranted) {
        LocationService.getLocation(context, (location) {
          Variables.hasInternetConnection((hasInternet) async {
            if (hasInternet) {
              DashboardComponent.fetchETA(
                  LatLng(location!.latitude, location!.longitude), dest,
                  (estimatedData) {
                if (estimatedData == "No Internet") {
                  cb({"success": false});

                  showAlertDialog(context, "Attention",
                      "Please check your internet connection and try again.",
                      () {
                    Navigator.of(context).pop();
                  });
                  return;
                }
                if (estimatedData.isEmpty) {
                  cb({"success": false});
                  showAlertDialog(
                      context, "LuvPark", Variables.popUpMessageOutsideArea,
                      () {
                    Navigator.of(context).pop();
                  });
                  return;
                }

                const HttpRequest(api: ApiKeys.gApiLuvParkGetComputeDistance)
                    .get()
                    .then((returnData) async {
                  if (returnData == "No Internet") {
                    cb({"success": false});
                    showAlertDialog(context, "Attention",
                        "Please check your internet connection and try again.",
                        () {
                      Navigator.of(context).pop();
                    });
                    return;
                  }
                  if (returnData == null) {
                    cb({"success": false});
                    showAlertDialog(context, "Error",
                        "Error while connecting to server, Please contact support.",
                        () {
                      Navigator.of(context).pop();
                    });
                    return;
                  } else {
                    //COMPUTE DISTANCE BY TIME IF AVAILABLE FOR RESERVATION`
                    if (returnData["items"][0]["user_chk_in_um"] == "TM") {
                      int estimatedMinute = int.parse(
                          estimatedData[0]["time"].toString().split(" ")[0]);
                      double distanceCanChkIn = Variables.convertToMeters(
                          returnData["items"][0]["user_chk_in_within"]
                              .toString());
                      //COMPUTE DISTANCE BY TIME IF ABLE TO RESERVE BY 20000 METERS AWAY`
                      if (estimatedMinute >=
                              int.parse(returnData["items"][0]["min_psr_from"]
                                  .toString()) &&
                          estimatedMinute <=
                              int.parse(returnData["items"][0]["max_psr_from"]
                                  .toString())) {
                        cb({
                          "success": true,
                          "can_checkIn": estimatedMinute <= distanceCanChkIn,
                          "message":
                              "Early check-in is not allowed if you are more than ${returnData["items"][0]["user_chk_in_within"].toString()} minutes away from the selected parking area.",
                        });
                      } else {
                        cb({"success": false});
                        showAlertDialog(context, "LuvPark",
                            "Early booking is not allowed if you are more than ${returnData["items"][0]["max_psr_from"].toString()} minutes away from the selected parking area.",
                            () {
                          Navigator.of(context).pop();
                        });
                      }
                    } else {
                      //COMPUTE DISTANCE BY DISTANCE IN METERS IF AVAILABLE FOR RESERVATION
                      double estimatedDistance = Variables.convertToMeters(
                          estimatedData[0]["distance"].toString());
                      double minDistance = Variables.convertToMeters(
                          returnData["items"][0]["min_psr_from"].toString());
                      double maxDistance = Variables.convertToMeters(
                          returnData["items"][0]["max_psr_from"].toString());
                      double distanceCanChkIn = Variables.convertToMeters(
                          returnData["items"][0]["user_chk_in_within"]
                              .toString());
                      if (estimatedDistance.toDouble() >=
                              minDistance.toDouble() &&
                          estimatedDistance.toDouble() <=
                              maxDistance.toDouble()) {
                        cb({
                          "success": true,
                          "can_checkIn": estimatedDistance <= distanceCanChkIn,
                          "message":
                              "Early check-in is not allowed if you are more than ${returnData["items"][0]["user_chk_in_within"].toString()} meters away from the selected parking area.",
                        });
                      } else {
                        cb({"success": false});
                        showAlertDialog(context, "LuvPark",
                            "Early booking is not allowed if you are more than ${returnData["items"][0]["max_psr_from"].toString()} meters away from the selected parking area.",
                            () {
                          Navigator.of(context).pop();
                        });
                      }
                    }
                  }
                });
              });
            } else {
              cb({"success": false});
              showAlertDialog(context, "Error",
                  "Please check your internet connection and try again.", () {
                Navigator.of(context).pop();
              });
              return;
            }
          });
        });
      } else {
        showAlertDialog(context, "LuvPark", "No permissions granted.", () {
          Navigator.of(context).pop();
        });
      }
    });
  }

  //VERIFY ACCOUNT
  static Future<void> getVerifyAccount(context, mobileNo, Function cb) async {
    CustomModal(context: context).loader();
    var params = "${ApiKeys.gApiSubFolderVerifyNumber}?mobile_no=$mobileNo";

    HttpRequest(
      api: params,
    ).get().then((returnData) async {
      if (returnData == "No Internet") {
        Navigator.pop(context);
        cb(false);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again", () {
          Navigator.pop(context);
        });

        return;
      }

      if (returnData == null) {
        Navigator.pop(context);
        cb(false);
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please contact support.", () {
          Navigator.pop(context);
        });
      }

      if (returnData["items"][0]["is_valid"] == "Y") {
        //   Navigator.of(context).pop();
        cb({"data": returnData["items"][0], "mobile_no": mobileNo});
      } else {
        Navigator.pop(context);
        cb(false);
        showAlertDialog(context, "Error", returnData["items"][0]["msg"], () {
          Navigator.pop(context);
        });
      }
    });
  }

  //Get Sharing data

  static Future<void> getSharedData(String userId, Function cb) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? geoShareId = prefs.getString('geo_share_id');

    var params =
        "${ApiKeys.gApiLuvParkGetActiveShareLoc}?geo_share_id=$geoShareId";

    HttpRequest(api: params).get().then((data) {
      if (data == "No Internet") {
        cb({"data": [], "msg": "No Internet"});
        return;
      }
      if (data == null) {
        cb({"data": [], "msg": "Error"});
        return;
      } else {
        cb({"data": data["items"], "msg": ""});
      }
    });
  }

  //Invite Friend

  static Future<void> inviteFriend(context, friendId, isPendingInvite) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? geoShareId = prefs.getString('geo_share_id');
    String userId = await Variables.getUserId();
    Map<String, dynamic> parameters = {
      "user_id": userId,
      "to_user_id": friendId,
      'geo_share_id': geoShareId,
    };

    HttpRequest(
            api: ApiKeys.gApiLuvParkPostAddUserMapSharing,
            parameters: parameters)
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
        Navigator.pop(context);
        if (returnPost["success"] == "Y") {
          showAlertDialog(context, "Success", "Successfully invited.", () {
            Navigator.of(context).pop();
            if (!isPendingInvite) {
              Navigator.of(context).pop();
            }
          });
        } else {
          Navigator.of(context).pop();
          showAlertDialog(context, "Error", returnPost["msg"], () {
            Navigator.of(context).pop();
          });
        }
      }
    });
  }

  //End sharing
  static Future<void> endSharing(Function cb) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? geoConId = prefs.getString("geo_connect_id");

    var endParam = {"geo_connect_id": geoConId};

    HttpRequest(api: ApiKeys.gApiLuvParkPutEndSharing, parameters: endParam)
        .put()
        .then((returnData) async {
      if (returnData == "No Internet") {
        // Navigator.of(context).pop();
        // showAlertDialog(context, "Error",
        //     'Please check your internet connection and try again.', () {
        //   Navigator.of(context).pop();
        // });
        cb("No Internet");
        return;
      }
      if (returnData == null) {
        // Navigator.of(context).pop();
        // showAlertDialog(context, "Error",
        //     "Error while connecting to server, Please try again.", () {
        //   Navigator.of(context).pop();
        // });
        cb("Error");
        return;
      }
      if (returnData["success"] == 'Y') {
        cb("Success");
        // Navigator.of(context).pop();
        // SharedPreferences prefs = await SharedPreferences.getInstance();

        // prefs.remove("geo_share_id");
        // prefs.remove("geo_connect_id");
        // AwesomeNotifications().cancel(0);
        // AwesomeNotifications().dismiss(0);

        // if (mounted) {
        //   setState(() {
        //     _dataStreamController.close();
        //     _dataStreamController.done;
        //     timers!.cancel();
        //   });
        // }
        // showAlertDialog(
        //     context, "Success", "Live sharing successfully ended.", () async {
        //   Navigator.of(context).pop();
        //   ForegroundNotifTask.stopForegroundTask();
        // });
      } else {
        cb("Error");
        // Navigator.of(context).pop();
        // showAlertDialog(context, "Error",
        //     "Invalid OTP code. Please try again.. Please try again.", () {
        //   Navigator.of(context).pop();
        // });
      }
    });
  }

  static Future<void> getVehicleBrands(context) async {
    List vbData = [];

    HttpRequest(
      api: ApiKeys.gApiLuvParkGetVehicleBrand,
    ).get().then((returnPost) async {
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
        Navigator.pop(context);
        if (returnPost["items"].isNotEmpty) {
          vbData = returnPost["items"];
          await saveDataToPreferences(vbData);
        } else {
          Navigator.of(context).pop();
          showAlertDialog(context, "Error", returnPost["msg"], () {
            Navigator.of(context).pop();
          });
        }
      }
    });
  }

  static Future<void> saveDataToPreferences(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(data);
    await prefs.setString('vehicle_brands', jsonData);
  }

  static Future<void> getPrefData(Function cb) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString("vehicle_brands");
    String jsonData = jsonDecode(data!);
    cb(jsonData);
  }

  static Future<String> getBrandName(int vtId, int vbId) async {
    final String? brandName =
        await VehicleBrandsTable.instance.readVehicleBrandsByVbId(vtId, vbId);

    return brandName!;
  }

//with park_area id param
  static void getVehicleTypesData(context, areaId, Function cb) {
    HttpRequest(
            api: "${ApiKeys.gApiLuvParkDDVehicleTypes2}?park_area_id=$areaId")
        .get()
        .then((returnData) async {
      if (returnData == "No Internet") {
        Navigator.of(context).pop();
        cb({"msg": "Error", "data": []});
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (returnData == null) {
        Navigator.of(context).pop();
        cb({"msg": "Error", "data": []});
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      }

      if (returnData["items"].length > 0) {
        var items = returnData["items"];
        var mappedData = items.map((item) {
          return {
            "text": item["vehicle_type_desc"],
            "value": item["vehicle_type_id"]
          };
        }).toList();
        Navigator.of(context).pop();
        cb({"msg": "Success", "data": mappedData});
      } else {
        Navigator.of(context).pop();
        cb({"msg": "Error", "data": returnData["items"]});
        showAlertDialog(context, "Error", "No data found.", () {
          Navigator.of(context).pop();
        });
        return;
      }
    });
  }

  static void getVehicleAllTypesData(context, areaId, Function cb) {
    HttpRequest(api: ApiKeys.gApiLuvParkDDVehicleTypes)
        .get()
        .then((returnData) async {
      if (returnData == "No Internet") {
        Navigator.of(context).pop();
        cb({"msg": "No Internet", "data": []});
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (returnData == null) {
        Navigator.of(context).pop();
        cb({"msg": "Error", "data": []});
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      }

      if (returnData["items"].length > 0) {
        cb({"msg": "Success", "data": returnData["items"]});
      } else {
        Navigator.of(context).pop();
        cb({"msg": "Success", "data": returnData["items"]});
        showAlertDialog(context, "Error", "No data found.", () {
          Navigator.of(context).pop();
        });
        return;
      }
    });
  }

  static void getAmenities(context, areaId, Function cb) {
    HttpRequest(api: ApiKeys.gApiSubFolderGetAllAmenities)
        .get()
        .then((returnData) async {
      if (returnData == "No Internet") {
        Navigator.of(context).pop();
        cb({"msg": "Error", "data": []});
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (returnData == null) {
        Navigator.of(context).pop();
        cb({"msg": "Error", "data": []});
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      }

      if (returnData["items"].length > 0) {
        cb({"msg": "Success", "data": returnData["items"]});
      } else {
        Navigator.of(context).pop();
        cb({"msg": "Success", "data": returnData["items"]});
        showAlertDialog(context, "Error", "No data found.", () {
          Navigator.of(context).pop();
        });
        return;
      }
    });
  }

//Get Average
  static Future<void> getAverage(Function cb, BuildContext context) async {
    HttpRequest(api: ApiKeys.gApiSubFolderGetAverage)
        .get()
        .then((avgData) async {
      if (avgData == "No Internet") {
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          cb({"msg": "No Internet", "data": []});
          Navigator.of(context).pop();
        });

        return;
      }
      if (avgData == null) {
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          cb({"msg": "Error", "data": []});
          Navigator.of(context).pop();
        });
        return;
      } else {
        cb({"msg": "Success", "data": avgData["items"]});
      }
    });
  }
}
