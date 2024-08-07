import 'package:flutter/material.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/reserve/reserve_confirm.dart';

// show dialog
// ignore: must_be_immutable
class CustomDialog extends StatefulWidget {
  double? amountBal;

  final String referenceNo, dtOut;
  final IconData icon;
  final BuildContext detailContext;
  final Object paramsCalc;

  CustomDialog(
      {required this.amountBal,
      required this.dtOut,
      required this.referenceNo,
      required this.icon,
      required this.detailContext,
      required this.paramsCalc,
      super.key,
      required});

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  int counter = 1;
  BuildContext? mainContext;
  List objParam = [];
  @override
  void initState() {
    super.initState();

    setState(() {
      objParam.add(widget.paramsCalc);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mainContext = context;
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: Wrap(
        children: [
          Center(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: CustomTitle(
                          text: "Cancel",
                          color: Colors.blue,
                        )),
                    const SizedBox(height: 20),
                    CustomParagraph(
                        text: "Extend your parking now",
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        letterSpacing: .5,
                        color: AppColor.textSubColor),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (counter == 1) return;
                              counter--;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.white,
                                border:
                                    Border.all(color: AppColor.primaryColor)),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.remove,
                                color: Colors.grey,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 10,
                        ),
                        Column(
                          children: [
                            CustomTitle(
                              text: counter.toString(),
                              color: AppColor.primaryColor,
                              fontSize: 40,
                            ),
                            CustomParagraph(
                              text: counter == 1 ? "Hour" : "Hours",
                              fontSize: 12,
                            ),
                          ],
                        ),
                        Container(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (counter >= 12) return;
                              counter++;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: AppColor.primaryColor,
                                border:
                                    Border.all(color: AppColor.primaryColor)),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      label: "Submit",
                      onTap: () async {
                        FocusManager.instance.primaryFocus!.unfocus();
                        CustomModal(context: context).loader();
                        var parameters = {
                          "client_id": objParam[0]["client_id"],
                          "park_area_id": objParam[0]["park_area_id"],
                          "vehicle_type_id": objParam[0]["vehicle_type_id"],
                          "vehicle_plate_no": objParam[0]["vehicle_plate_no"],
                          "dt_in": objParam[0]["dt_in"],
                          "dt_out":
                              DateTime.parse(objParam[0]["dt_out"].toString())
                                  .add(Duration(
                                      hours: int.parse(counter.toString())))
                                  .toString()
                                  .split(".")[0],
                          "no_hours": counter,
                          "tran_type": objParam[0]["tran_type"],
                          "ref_no": objParam[0]["tran_type"] == "E"
                              ? widget.referenceNo
                              : "",
                        };

                        HttpRequest(
                                api: ApiKeys.gApiSubFolderPostReserveCalc,
                                parameters: parameters)
                            .post()
                            .then((returnPost) async {
                          if (returnPost == "No Internet") {
                            Navigator.of(context).pop(context);
                            showAlertDialog(context, "Error",
                                "Please check your internet connection and try again.",
                                () {
                              Navigator.of(context).pop();
                            });
                            return;
                          }
                          if (returnPost == null) {
                            Navigator.pop(context);
                            showAlertDialog(context, "Error",
                                "Error while connecting to server, Please try again.",
                                () {
                              Navigator.of(context).pop();
                            });
                          } else {
                            if (returnPost["success"] == 'Y') {
                              var paramHours = [
                                {
                                  "no_hours": counter,
                                  "ps_ref_no": widget.referenceNo,
                                  "luvpark_amount": widget.amountBal
                                }
                              ];

                              Navigator.pop(context);
                              if (mounted) {
                                Navigator.pop(context);
                              }

                              showModalBottomSheet(
                                context: context,
                                isDismissible: false,
                                enableDrag: false,
                                isScrollControlled: true,
                                // This makes the sheet full screen
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                        15.0), // Adjust the radius as needed
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  return PayParkingConfirmation(
                                      amountFee:
                                          returnPost["amount"].toString(),
                                      paramExtend: paramHours,
                                      paramDetails: [parameters],
                                      myBalance: widget.amountBal.toString());
                                },
                              );
                            } else {
                              Navigator.pop(context);
                              showAlertDialog(
                                  context, "Attention", returnPost['msg'], () {
                                Navigator.of(context).pop();
                              });
                            }
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
