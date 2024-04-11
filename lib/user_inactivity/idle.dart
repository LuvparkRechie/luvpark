import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdleScreen extends StatefulWidget {
  const IdleScreen({super.key});

  @override
  State<IdleScreen> createState() => _IdleScreenState();
}

class _IdleScreenState extends State<IdleScreen> {
  bool isLoading = true;
  String myTime = "";
  String? dropdownValue;
  List<dynamic> dataSeconds = [
    {"name": "30 Seconds", "value": "30"},
    {"name": "1 Minute", "value": "60"},
    {"name": "2 Minutes", "value": "120"},
    {"name": "3 Minutes", "value": "180"},
    {"name": "4 Minutes", "value": "240"},
    {"name": "5 Minutes", "value": "300"},
  ];
  @override
  void initState() {
    dropdownValue = dataSeconds
        .where((element) {
          return int.parse(element["value"]) ==
              int.parse(Variables.timerSec!.toString());
        })
        .toList()[0]["value"]
        .toString();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String myTimeInactivity(myTime) {
    int minutes = (myTime / 60).toInt();

    int seconds = (myTime % 60);

    return "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
        appBarheaderText: "User Inactivity",
        appBarIconClick: () {
          Navigator.of(context).pop();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 10,
            ),
            Container(
              color: const Color(0xFFFDFDEA),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF723B13),
                    ),
                    Container(
                      width: 10,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                                text:
                                    "Please note that the initial idle time is set to ",
                                style: Platform.isAndroid
                                    ? GoogleFonts.dmSans(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF723B13),
                                        fontSize: 14,
                                      )
                                    : TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                      )),
                            TextSpan(
                                text: "${Variables.timerSec}",
                                style: Platform.isAndroid
                                    ? GoogleFonts.dmSans(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontSize: 14,
                                      )
                                    : TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontSize: 14,
                                        fontFamily: "SFProTextReg",
                                      )),
                            TextSpan(
                                text:
                                    " seconds. You have the flexibility to adjust this limit to your preference.",
                                style: Platform.isAndroid
                                    ? GoogleFonts.dmSans(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF723B13),
                                        fontSize: 14,
                                      )
                                    : TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF723B13),
                                        fontSize: 14,
                                        fontFamily: "SFProTextReg",
                                      )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            LabelText(text: "Duration"),
            Container(
              height: 5,
            ),
            DropdownButtonFormField(
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                //   constraints: BoxConstraints.tightFor(height: 60),
                // fillColor: Colors.white,
                // filled: true,
                constraints: const BoxConstraints.tightFor(height: 50),
                contentPadding: const EdgeInsets.all(10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.primaryColor),
                ),
                hintText: "",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.primaryColor),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 223, 223, 223)),
                ),
              ),
              value: dropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              isExpanded: true,
              items: dataSeconds.map((item) {
                return DropdownMenuItem(
                    value: item['value'].toString(),
                    child: AutoSizeText(
                      item['name'],
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 15,
                        letterSpacing: 1,
                        fontWeight: FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ));
              }).toList(),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                CustomDisplayText(
                  label: "Current inactivity ",
                  fontWeight: FontWeight.normal,
                  color: Colors.black54,
                  fontSize: 14,
                ),
                CustomDisplayText(
                  label: myTimeInactivity(
                      int.parse(Variables.timerSec.toString())),
                  fontWeight: FontWeight.normal,
                  color: Colors.red,
                  fontSize: 14,
                ),
              ],
            ),
            Container(
              height: 20,
            ),
            const SizedBox(
              height: 20,
            ),
            CustomButton(
              label: "Submit",
              onTap: () async {
                if (dropdownValue!.isEmpty) return;
                CustomModal(context: context).loader();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                var akongP = prefs.getString(
                  'userData',
                );
                var data = {
                  "timeout": int.parse(dropdownValue.toString()),
                  "user_id": jsonDecode(akongP!)['user_id'].toString(),
                };

                HttpRequest(api: ApiKeys.gApiSubFolderIdle, parameters: data)
                    .put()
                    .then((returnPut) {
                  if (returnPut == "No Internet") {
                    Navigator.pop(context);
                    showAlertDialog(context, "Error",
                        "Please check your internet connection and try again.",
                        () {
                      Navigator.pop(context);
                    });
                    return;
                  }
                  if (returnPut["success"] == "Y") {
                    Navigator.of(context).pop();
                    showAlertDialog(
                        context, "Success", "Succesfully submitted!", () {
                      setState(() {
                        Variables.timerSec =
                            int.parse(dropdownValue.toString());
                      });

                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }

                      Navigator.pop(context);
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
              },
            ),
          ],
        ));
  }
}
