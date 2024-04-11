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
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomDisplayText(
                        label: "Extend Parking",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textHeaderLabelColor),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // AutoSizeText(
                                  //   "No of hours",
                                  //   style: CustomTextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  //     color: Colors.black,
                                  //   ),
                                  //   softWrap: true,
                                  // ),
                                  // Container(
                                  //   height: 5,
                                  // ),
                                  CustomDisplayText(
                                    label: "No of hours",
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: AppColor.textSecondaryColor,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (counter == 1) return;
                                      counter--;
                                    });
                                  },
                                  child: const CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 10,
                                ),
                                CustomDisplayText(
                                  label: counter.toString(),
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.primaryColor,
                                  fontSize: 20,
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
                                  child: const CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
