import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleOption extends StatefulWidget {
  final List vehicleData;
  final Function onTap;
  final String? vehicleTypeId;
  const VehicleOption({
    required this.onTap,
    required this.vehicleData,
    this.vehicleTypeId,
    super.key,
  });

  @override
  State<VehicleOption> createState() => _VehicleOptionState();
}

class _VehicleOptionState extends State<VehicleOption> {
  TextEditingController textController = TextEditingController();
  TextEditingController plateNumber = TextEditingController();
  TextEditingController vehicleType = TextEditingController();

  String? dropdownValue;

  @override
  void initState() {
    print("vehicle list ${widget.vehicleData}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: Wrap(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back_ios_new_outlined),
                  ),
                  Container(height: 20),
                  CustomDisplayText(
                    label: "What's your plate number?",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomTextField(
                    labelText: "Plate number",
                    controller: plateNumber,
                  ),
                  CustomDisplayText(
                    label: "Choose vehicle type?",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  Container(height: 10),
                  DropdownButtonFormField(
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      constraints: const BoxConstraints.tightFor(height: 50),
                      contentPadding: const EdgeInsets.all(10),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.primaryColor),
                      ),
                      hintText: "Vehicle Type",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.primaryColor),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 223, 223, 223)),
                      ),
                    ),
                    value: dropdownValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    isExpanded: true,
                    items: widget.vehicleData.map((item) {
                      return DropdownMenuItem(
                          value: item['value'].toString(),
                          child: AutoSizeText(
                            item['text'],
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
                  Container(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton(
                      elevation: 1,
                      backgroundColor: AppColor.primaryColor,
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        List callBackData = [
                          {
                            'vehicle_type_id': dropdownValue!.toString(),
                            'vehicle_brand_id': 0,
                            'vehicle_brand_name': "",
                            'vehicle_plate_no': plateNumber.text
                          }
                        ];

                        Navigator.of(context).pop();
                        widget.onTap(callBackData);
                      },
                    ),
                  ),
                  Container(height: 30),
                  CustomButtonCancel(
                      borderColor: Colors.black,
                      textColor: Colors.black,
                      color: AppColor.bodyColor,
                      label: "Select from my vehicle",
                      onTap: () {
                        Variables.customBottomSheet(
                            context, VehicleList(ontap: widget.onTap));
                      })
                ],
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).viewInsets.bottom,
          )
        ],
      ),
    );
  }
}

class VehicleList extends StatefulWidget {
  final Function ontap;
  const VehicleList({super.key, required this.ontap});

  @override
  State<VehicleList> createState() => _VehicleListState();
}

class _VehicleListState extends State<VehicleList> {
  List myVehicles = [];
  List subData = [];
  bool isLoadingPage = false;
  bool hasInternet = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  void getMyVehicle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var akongP = prefs.getString(
      'userData',
    );
    CustomModal(context: context).loader();
    print("akongP $akongP");
    DashboardComponent.getAvailableVehicle(
        context, jsonDecode(akongP!)['user_id'].toString(), (cbVehicle) async {
      print("cbVehicle $cbVehicle");
      if (cbVehicle == "No Internet") {
        Navigator.of(context).pop();
        setState(() {
          hasInternet = false;
          isLoadingPage = false;
        });
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (cbVehicle == null) {
        Navigator.of(context).pop();
        setState(() {
          hasInternet = true;
          isLoadingPage = false;
        });
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      } else {}
      if (cbVehicle.length > 0) {
        Navigator.of(context).pop();
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
        if (mounted) {
          setState(() {
            hasInternet = true;
            isLoadingPage = false;
          });
        }
      } else {
        Navigator.of(context).pop();

        showAlertDialog(context, "Error", "No data found.", () {
          Navigator.of(context).pop();
        });
        return;
      }
    });
  }

  Future<void> refresh() async {
    getMyVehicle();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: isLoadingPage
          ? const Center(
              child: SizedBox(
                  height: 30, width: 30, child: CircularProgressIndicator()),
            )
          : !hasInternet
              ? NoInternetConnected(onTap: () {
                  setState(() {
                    hasInternet = true;
                    isLoadingPage = true;
                  });
                  refresh();
                })
              : Container(
                  height: MediaQuery.of(context).size.height * .50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.arrow_back_ios_new_outlined),
                        ),
                        Container(height: 20),
                        Expanded(
                            child: Scrollbar(
                          child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: myVehicles.length,
                              itemBuilder: ((context, index) {
                                return ListTile(
                                  title: CustomDisplayText(
                                    label: myVehicles[index]
                                        ["vehicle_plate_no"],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  subtitle: CustomDisplayText(
                                    label: myVehicles[index]
                                        ["vehicle_brand_name"],
                                    fontWeight: FontWeight.normal,
                                    color: AppColor.textSubColor,
                                    fontSize: 12,
                                  ),
                                  leading: Icon(int.parse(myVehicles[index]
                                                  ["vehicle_type_id"]
                                              .toString()) ==
                                          1
                                      ? Icons.motorcycle_outlined
                                      : Icons.time_to_leave),
                                  trailing: Icon(Icons.keyboard_arrow_right),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    widget.ontap([myVehicles[index]]);
                                    if (Navigator.canPop(context)) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                );
                              })),
                        )),
                        Container(height: 10),
                      ],
                    ),
                  ),
                ),
    );
  }
}
