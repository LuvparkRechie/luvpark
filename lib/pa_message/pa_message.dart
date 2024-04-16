import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/bottom_tab/bottom_tab.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:luvpark/sqlite/pa_message_table.dart';

class PaMessage extends StatefulWidget {
  const PaMessage({super.key});

  @override
  State<PaMessage> createState() => _PaMessageState();
}

class _PaMessageState extends State<PaMessage> {
  List paData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    paData = [];
    CustomModal(context: context).loader();
    Timer(Duration(seconds: 1), () async {
      await PaMessageDatabase.instance.readAllMessage().then((objData) {
        Navigator.of(context).pop();
        if (objData.isNotEmpty) {
          setState(() {
            paData = objData;
          });
        }
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
      appBarIconClick: () {
        Navigator.pop(context);
        Variables.pageTrans(MainLandingScreen());
      },
      canPop: true,
      appBarheaderText: "Messages",
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: isLoading
            ? Container()
            : RefreshIndicator(
                onRefresh: fetchData,
                child: paData.isEmpty
                    ? NoDataFound(
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              isLoading = true;
                            });
                          }
                          fetchData();
                        },
                      )
                    : ListView.builder(
                        itemCount: paData.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 6,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: const Icon(
                                Iconsax.message_question,
                              ),
                              title: CustomDisplayText(
                                label: "${paData[index]["message"]}",
                                fontWeight: FontWeight.bold,
                              ),
                              trailing: InkWell(
                                  onTap: () {
                                    showCupertinoModalPopup(
                                        context: context,
                                        builder: (BuildContext cont) {
                                          return CupertinoActionSheet(
                                            actions: [
                                              CupertinoActionSheetAction(
                                                  onPressed: () {
                                                    CustomModal(
                                                            context: context)
                                                        .loader();
                                                    var params = {
                                                      "push_status": "R",
                                                      "push_msg_id":
                                                          paData[index]
                                                              ["push_msg_id"],
                                                    };
                                                    HttpRequest(
                                                            api: ApiKeys
                                                                .gApiLuvParkPutUpdMessageNotif,
                                                            parameters: params)
                                                        .put()
                                                        .then(
                                                            (updateData) async {
                                                      print(
                                                          "updateData $updateData");
                                                      if (updateData ==
                                                          "No Internet") {
                                                        Navigator.of(context)
                                                            .pop();
                                                        showAlertDialog(
                                                            context,
                                                            "Error",
                                                            "Please check your internet connection and try again.",
                                                            () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        });
                                                        return;
                                                      }
                                                      if (updateData == null) {
                                                        Navigator.of(context)
                                                            .pop();
                                                        showAlertDialog(
                                                            context,
                                                            "Error",
                                                            "Error while connecting to server, Please try again.",
                                                            () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        });
                                                        return;
                                                      }
                                                      if (updateData[
                                                              "success"] ==
                                                          "Y") {
                                                        Navigator.of(context)
                                                            .pop();
                                                        int messageId = int
                                                                .tryParse(paData[
                                                                            index]
                                                                        [
                                                                        "push_msg_id"]
                                                                    .toString()) ??
                                                            -1; // Ensure a valid ID
                                                        int rowsAffected =
                                                            await PaMessageDatabase
                                                                .instance
                                                                .deleteMessageById(
                                                                    messageId);
                                                        print(
                                                            "rowsAffected $rowsAffected");
                                                        if (rowsAffected > 0) {
                                                          showAlertDialog(
                                                              context,
                                                              "Success",
                                                              "Successfully deleted.",
                                                              () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            if (mounted) {
                                                              setState(() {});
                                                            }
                                                            fetchData();
                                                          });
                                                        } else {
                                                          showAlertDialog(
                                                              context,
                                                              "Error",
                                                              "Failed to delete message.",
                                                              () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          });
                                                        }
                                                        // Navigator.of(context).pop();
                                                        // PaMessageDatabase.instance
                                                        //     .deleteMessageById(
                                                        //         int.parse(
                                                        //             item["push_msg_id"]
                                                        //                 .toString()));

                                                        // showAlertDialog(
                                                        //     context,
                                                        //     "Success",
                                                        //     "Successfully deleted.",
                                                        //     () {
                                                        //   Navigator.of(context).pop();
                                                        //   Navigator.of(context).pop();
                                                        //   fetchData();
                                                        // });
                                                      } else {
                                                        Navigator.of(context)
                                                            .pop();
                                                        showAlertDialog(
                                                            context,
                                                            "Success",
                                                            updateData["MSG"],
                                                            () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        });
                                                      }
                                                    });
                                                  },
                                                  child: Text(
                                                    "Delete",
                                                    style: Platform.isAndroid
                                                        ? GoogleFonts.dmSans(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 15,
                                                          )
                                                        : TextStyle(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 15,
                                                            fontFamily:
                                                                "SFProTextReg",
                                                          ),
                                                  )),
                                            ],
                                          );
                                        });
                                  },
                                  child: Icon(Icons.delete)),
                            ),
                          );
                        },
                      ),
              ),
      ),
    );
  }
}
