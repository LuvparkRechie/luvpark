import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/http_request/http_request_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyUserAcct extends StatefulWidget {
  final String? mobileNoParam;
  final bool isInvite;
  const VerifyUserAcct({super.key, required this.isInvite, this.mobileNoParam});

  @override
  State<VerifyUserAcct> createState() => _VerifyUserAcctState();
}

class _VerifyUserAcctState extends State<VerifyUserAcct> {
  TextEditingController mobileNumber = TextEditingController();
  bool isLoadingBtn = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15),
          ),
        ),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Container(height: 20),
                  CustomDisplayText(
                    label: "Location Sharing",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textHeaderLabelColor,
                  ),
                  Container(
                    height: 5,
                  ),
                  CustomDisplayText(
                    label: "To proceed please input registered\nmobile number.",
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: AppColor.textSubColor,
                  ),
                  Container(
                    height: 15,
                  ),
                  CustomMobileNumber(
                    labelText: "Mobile No",
                    controller: mobileNumber,
                    inputFormatters: [Variables.maskFormatter],
                  ),
                  Container(
                    height: 20,
                  ),
                  CustomButton(
                      label: !widget.isInvite ? "Invite friend" : "Proceed",
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        dynamic akongP = prefs.getString(
                          'userData',
                        );

                        if (jsonDecode(akongP!)['mobile_no'].toString() ==
                            "63${mobileNumber.text.replaceAll(" ", "")}") {
                          showAlertDialog(context, "Attention",
                              "Please use another number.", () {
                            Navigator.of(context).pop();
                          });
                          return;
                        }
                        if (mobileNumber.text.isEmpty) return;
                        Functions.getVerifyAccount(
                            context,
                            widget.mobileNoParam != null
                                ? widget.mobileNoParam
                                : "63${mobileNumber.text.toString().replaceAll(" ", "")}",
                            (data) async {
                          if (data["data"]["is_valid"] == "Y") {
                            if (widget.isInvite)
                              addFriend(data["data"]["user_id"]);
                            else
                              Functions.inviteFriend(
                                  context, data["data"]["user_id"], false);
                          }
                        });
                      }),
                ]),
          ),
        ),
      ),
    );
  }

  Future<void> addFriend(friendId) async {
    Functions.getLocation(context, (location) async {
      String userId = await Variables.getUserId();
      Map<String, dynamic> parameters = {
        "user_id": userId,
        "to_user_id": friendId,
        'longitude': location.longitude,
        'latitude': location.latitude,
      };

      HttpRequest(api: ApiKeys.gApiLuvParkPutShareLoc, parameters: parameters)
          .post()
          .then((returnPost) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();

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
            prefs.setString('geo_share_id', returnPost["geo_share_id"]);
            prefs.setString('geo_connect_id', returnPost["geo_connect_id"]);

            showModalConfirmation(
                context,
                "Location Sharing",
                "You have successfully shared your location. \Do you want to view on map?",
                "",
                "Yes", () {
              Navigator.of(context).pop();
            }, () async {
              Navigator.pop(context);
              Navigator.pop(context);
              // Variables.pageTrans(MapSharingScreen(), context);
            });
          } else {
            Navigator.of(context).pop();
            showAlertDialog(context, "Error", returnPost["msg"], () {
              Navigator.of(context).pop();
            });
          }
        }
      });
    });
  }
}
