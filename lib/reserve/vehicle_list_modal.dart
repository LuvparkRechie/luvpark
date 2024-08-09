import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleOption extends StatefulWidget {
  final List vehicleData;
  final String vhTypesId;
  final Function onTap;
  final String? vehicleTypeId;
  const VehicleOption({
    required this.onTap,
    required this.vehicleData,
    required this.vhTypesId,
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
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? dropdownValue;
  bool isSecondScreen = false;

  List myVehicles = [];
  List subData = [];
  bool isLoadingPage = false;
  bool hasInternet = true;
  @override
  void initState() {
    super.initState();
    dropdownValue = widget.vehicleData.length == 1
        ? widget.vehicleData[0]["value"].toString()
        : null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  void getMyVehicle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var akongP = prefs.getString(
      'userData',
    );

    DashboardComponent.getAvailableVehicle(
        context, widget.vhTypesId, jsonDecode(akongP!)['user_id'].toString(),
        (cbVehicle) async {
      if (cbVehicle == "No Internet") {
        setState(() {
          hasInternet = false;
          isLoadingPage = false;
        });
        return;
      }

      if (cbVehicle.length > 0) {
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
      child: Wrap(
        children: [
          Container(
            height: !isSecondScreen ? null : Variables.screenSize.height * .55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: Colors.white,
            ),
            child: isLoadingPage
                ? const Center(
                    child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator()),
                  )
                : !hasInternet
                    ? NoInternetConnected(onTap: () {
                        setState(() {
                          hasInternet = true;
                          isLoadingPage = true;
                        });
                        refresh();
                      })
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 10),
                            InkWell(
                              onTap: () {
                                if (isSecondScreen) {
                                  setState(() {
                                    isSecondScreen = false;
                                  });
                                  return;
                                }
                                Navigator.of(context).pop();
                              },
                              child: Icon(
                                Icons.chevron_left,
                                color: Colors.black,
                              ),
                            ),
                            Container(height: 20),
                            !isSecondScreen
                                ? Form(
                                    key: formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomTitle(
                                            text: "What's your plate number?"),
                                        CustomTextField(
                                          title: "Plate No.",
                                          labelText: "Enter Plate No.",
                                          controller: plateNumber,
                                          fontsize: 15,
                                          fontweight: FontWeight.w400,
                                          textCapitalization:
                                              TextCapitalization.characters,
                                        ),
                                        CustomTitle(text: "Select vehicle"),
                                        CustomDropdown(
                                          labelText: "Vehicle Type",
                                          ddData: widget.vehicleData,
                                          ddValue: dropdownValue,
                                          onChange: (newValue) {
                                            FocusManager.instance.primaryFocus!
                                                .unfocus();

                                            setState(() {
                                              dropdownValue = newValue;
                                            });
                                          },
                                        ),
                                        Container(height: 31),
                                        CustomButton(
                                          label: "Confirm",
                                          onTap: () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              String vtName = widget.vehicleData
                                                  .where((element) {
                                                    return element["value"] ==
                                                        int.parse(dropdownValue!
                                                            .toString());
                                                  })
                                                  .toList()[0]["text"]
                                                  .toString();
                                              List callBackData = [
                                                {
                                                  'vehicle_type_id':
                                                      dropdownValue!.toString(),
                                                  'vehicle_brand_id': 0,
                                                  'vehicle_brand_name': vtName,
                                                  'vehicle_plate_no':
                                                      plateNumber.text
                                                }
                                              ];

                                              Navigator.of(context).pop();
                                              widget.onTap(callBackData);
                                            }
                                          },
                                        ),
                                        Container(height: 15),
                                        CustomButtonCancel(
                                            borderColor: Colors.black,
                                            textColor: Colors.black,
                                            color: AppColor.bodyColor,
                                            label: "My Vehicle",
                                            onTap: () {
                                              setState(() {
                                                isSecondScreen = true;
                                              });
                                            })
                                      ],
                                    ),
                                  )
                                : Expanded(
                                    child: VehicleList(
                                      vehicles: myVehicles,
                                      ontap: (data) {
                                        widget.onTap(data);
                                      },
                                    ),
                                  )
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
  final List vehicles;
  const VehicleList({super.key, required this.ontap, required this.vehicles});

  @override
  State<VehicleList> createState() => _VehicleListState();
}

class _VehicleListState extends State<VehicleList> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: widget.vehicles.length == 0
          ? NoDataFound(
              textText: "No registered vehicle",
            )
          : Scrollbar(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: widget.vehicles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomDisplayText(
                          label: widget.vehicles[index]["vehicle_plate_no"],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomDisplayText(
                          label: widget.vehicles[index]["vehicle_brand_name"],
                          fontWeight: FontWeight.w500,
                          color: AppColor.textSubColor,
                          fontSize: 12,
                        ),
                      ],
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Icon(
                        int.parse(widget.vehicles[index]["vehicle_type_id"]
                                    .toString()) ==
                                1
                            ? Icons.motorcycle_outlined
                            : Icons.time_to_leave,
                      ),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.ontap([widget.vehicles[index]]);
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    color: Colors.grey,
                  );
                },
              ),
            ),
    );
  }
}
