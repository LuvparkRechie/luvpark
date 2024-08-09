import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:luvpark/vehicle_registration/vehicle_reg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyVehicles extends StatefulWidget {
  const MyVehicles({super.key});

  @override
  State<MyVehicles> createState() => _MyVehiclesState();
}

class _MyVehiclesState extends State<MyVehicles> {
  BuildContext? myContext;
  List myVehicles = [];
  bool isLoadingPage = true;
  bool hasInternet = true;
  bool isClicked = false;
  var akongP;
  @override
  void initState() {
    super.initState();
    onRefresh();
  }

  void getMyVehicle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    akongP = prefs.getString(
      'userData',
    );

    DashboardComponent.getAvailableVehicle(
        myContext, "", jsonDecode(akongP!)['user_id'].toString(),
        (cbVehicle) async {
      if (cbVehicle == "No Internet") {
        setState(() {
          hasInternet = false;
          isLoadingPage = false;
        });
      } else {
        setState(() {
          myVehicles = [];
        });
        for (var row in cbVehicle) {
          String brandName = await Functions.getBrandName(
              row["vehicle_type_id"], row["vehicle_brand_id"]);

          myVehicles.add({
            "vehicle_type_id": row["vehicle_type_id"],
            "vehicle_brand_id": row["vehicle_brand_id"],
            "vehicle_brand_name": brandName,
            "vehicle_plate_no": row["vehicle_plate_no"],
          });
        }
        setState(() {
          isLoadingPage = false;
          hasInternet = true;
        });
      }
    });
  }

  Future<void> onRefresh() async {
    setState(() {
      isLoadingPage = true;
    });
    getMyVehicle();
  }

  @override
  Widget build(BuildContext context) {
    myContext = context;
    return CustomParentWidgetV2(
      canPop: true,
      appBarHeaderText: "My Vehicles",
      bodyColor: Colors.grey.shade50,
      appBarIconClick: () {
        Navigator.pop(context);
      },
      floatingButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            backgroundColor: AppColor.primaryColor,
            onPressed: () async {
              Variables.pageTrans(
                  VehicleRegDialog(
                    userId: jsonDecode(akongP!)['user_id'].toString(),
                    plateNo: "",
                    callback: () {
                      onRefresh();
                    },
                  ),
                  context);
            },
            tooltip: 'Toggle',
            child: const Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      child: !hasInternet
          ? NoInternetConnected(onTap: onRefresh)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      itemCount: myVehicles.length,
                      itemBuilder: ((context, index) {
                        if (myVehicles.isEmpty) {
                          return NoDataFound(
                            onTap: onRefresh,
                          );
                        } else {
                          return Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext cont) {
                                        return CupertinoActionSheet(
                                          actions: [
                                            CupertinoActionSheetAction(
                                                onPressed: () {
                                                  CustomModal(context: context)
                                                      .loader();
                                                  var params = {
                                                    "user_id": jsonDecode(
                                                            akongP!)['user_id']
                                                        .toString(),
                                                    "vehicle_plate_no":
                                                        myVehicles[index][
                                                            "vehicle_plate_no"],
                                                  };

                                                  HttpRequest(
                                                          api: ApiKeys
                                                              .gApiLuvParkDeleteVehicle,
                                                          parameters: params)
                                                      .deleteData()
                                                      .then((retDelete) {
                                                    if (retDelete ==
                                                        "Success") {
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                      onRefresh();
                                                      return;
                                                    }
                                                    if (retDelete ==
                                                        "No Internet") {
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() {
                                                        hasInternet = false;
                                                      });
                                                      return;
                                                    } else {
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() {
                                                        hasInternet = true;
                                                      });
                                                      return;
                                                    }
                                                  });
                                                },
                                                child: Text(
                                                  "Delete",
                                                  style: Platform.isAndroid
                                                      ? GoogleFonts.dmSans(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 15,
                                                        )
                                                      : TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 15,
                                                          fontFamily:
                                                              "SFProTextReg",
                                                        ),
                                                )),
                                          ],
                                        );
                                      });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 232, 241, 248))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          child: Icon(
                                            myVehicles[index]
                                                        ["vehicle_type_id"] ==
                                                    1
                                                ? Icons.motorcycle_outlined
                                                : Icons.time_to_leave_outlined,
                                            color: AppColor.primaryColor,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 10,
                                                ),
                                                CustomTitle(
                                                  text: myVehicles[index]
                                                      ["vehicle_brand_name"],
                                                ),
                                                CustomParagraph(
                                                  text: myVehicles[index]
                                                      ["vehicle_plate_no"],
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 20.0,
                                                top: 5,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.chevron_right_sharp,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      })),
                ))
              ],
            ),
    );
  }
}
