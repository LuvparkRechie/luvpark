import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_listtile.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:luvpark/vehicle_registration/vehicle_reg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleListModal extends StatefulWidget {
  final List areaData;
  final Function onTap;
  final String? vehicleTypeId;
  const VehicleListModal({
    required this.onTap,
    required this.areaData,
    this.vehicleTypeId,
    super.key,
  });

  @override
  State<VehicleListModal> createState() => _VehicleListModalState();
}

class _VehicleListModalState extends State<VehicleListModal> {
  TextEditingController textController = TextEditingController();
  BuildContext? myContext;
  List myVehicles = [];
  bool isLoadingPage = false;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();

    refresh();
  }

  void getMyVehicle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var akongP = prefs.getString(
      'userData',
    );

    DashboardComponent.getAvailableVehicle(
        myContext, jsonDecode(akongP!)['user_id'].toString(), (cbVehicle) {
      if (cbVehicle == "No Internet") {
        setState(() {
          hasInternet = false;
          isLoadingPage = false;
        });
      }
      if (cbVehicle == null) {
        setState(() {
          hasInternet = true;
          isLoadingPage = false;
        });
        Navigator.of(context).pop();
      } else {
        setState(() {
          if (int.parse(widget.vehicleTypeId.toString()) == 0) {
            myVehicles = List<Map<String, dynamic>>.from(cbVehicle);
          } else {
            myVehicles = List<Map<String, dynamic>>.from(cbVehicle)
                .where((element) =>
                    element["vehicle_type_id"] ==
                    int.parse(widget.vehicleTypeId.toString()))
                .toList();
          }
          hasInternet = true;
          isLoadingPage = false;
        });
      }
    });
  }

  Future<void> refresh() async {
    getMyVehicle();
  }

  @override
  Widget build(BuildContext context) {
    myContext = context;

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: Container(
          height: Variables.screenSize.height * .65,
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
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade100))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            top: 1,
                                            left: 8,
                                            right: 7,
                                            bottom: 1),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          color: AppColor.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(41),
                                          ),
                                        ),
                                        child: CustomDisplayText(
                                          label:
                                              "${widget.areaData[0]["vehicle_types_list"]}",
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    Container(width: 10),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: CircleAvatar(
                                          radius: 13,
                                          backgroundColor: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.close,
                                            size: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: CustomDisplayText(
                                    label: "Select vehicle",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                            child: Scrollbar(
                          child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: myVehicles.length,
                              itemBuilder: ((context, index) {
                                return CustomListtile(
                                  title: myVehicles[index]["vehicle_plate_no"],
                                  subTitle: myVehicles[index]
                                      ["vehicle_brand_name"],
                                  leading: int.parse(myVehicles[index]
                                                  ["vehicle_type_id"]
                                              .toString()) ==
                                          1
                                      ? Icons.motorcycle_outlined
                                      : Icons.time_to_leave,
                                  trailing: Icons.arrow_drop_down,
                                  onTap: () {
                                    widget.onTap([myVehicles[index]]);
                                    Navigator.of(context).pop();
                                  },
                                );
                              })),
                        )),
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  top:
                                      BorderSide(color: Colors.grey.shade100))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: InkWell(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                var akongP = prefs.getString(
                                  'userData',
                                );

                                Variables.pageTrans(VehicleRegDialog(
                                  plateNo: "",
                                  userId:
                                      jsonDecode(akongP!)['user_id'].toString(),
                                  callback: () {
                                    getMyVehicle();
                                  },
                                ));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColor.primaryColor),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.add_circle_outline_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      Container(width: 10),
                                      const Expanded(
                                        child: CustomDisplayText(
                                          label: "Add new vehicle",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(width: 10),
                                      Transform.rotate(
                                        angle: -1.57, // 90 degrees in radians
                                        child: const Icon(
                                          Icons.arrow_drop_down,
                                          size: 24,
                                          color: Colors.white,
                                          semanticLabel:
                                              'Right-oriented Dropdown Arrow',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(height: 10),
                      ],
                    )),
    );
  }
}
