import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';

import '../../auth/authentication.dart';
import '../../custom_widgets/custom_text.dart';
import '../../custom_widgets/variables.dart';

class MyVhList extends StatefulWidget {
  final List vhData;
  final List vhType;
  final int noOfHrs;
  final Function cb;
  const MyVhList(
      {super.key,
      required this.vhData,
      required this.vhType,
      required this.cb,
      required this.noOfHrs});

  @override
  State<MyVhList> createState() => _MyVhListState();
}

class _MyVhListState extends State<MyVhList> {
  final GlobalKey<FormState> formKeyBook = GlobalKey<FormState>();
  TextEditingController vhType = TextEditingController();
  TextEditingController vhPlNo = TextEditingController();
  bool isFirst = true;
  String? _selectedVehicleType;
  Object paramSeldVh = {};
  RegExp regExp = RegExp(r'[^a-zA-Z0-9]');
  Map<String, dynamic> bookParam = {};

  @override
  void initState() {
    super.initState();
    isFirst = true;
  }

  Future<List> filterSubscriotion(String plNo, int vhTypeid) async {
    List data = Variables.subsVhList.where((obj) {
      return obj["vehicle_type_id"] == vhTypeid &&
          obj["vehicle_plate_no"].toString().replaceAll(regExp, "") ==
              plNo.toString().replaceAll(regExp, "");
    }).toList();
    return data;
  }

  void initParam(List subData, dataRate) async {
    var userId = await Authentication().getUserId();
    int selBaseHours = int.parse(dataRate["base_hours"].toString());
    int selSucceedRate = int.parse(dataRate["succeeding_rate"].toString());
    int amount = int.parse(dataRate["base_rate"].toString());
    int totalAmt = 0;
    int subDtlId = subData.isEmpty ? 0 : subData[0]["zv_subscription_dtl_id"];
    if (subData.isNotEmpty) {
      totalAmt = subData[0]["subscription_rate"];
    } else {
      if (widget.noOfHrs > selBaseHours) {
        totalAmt = amount + (widget.noOfHrs - selBaseHours) * selSucceedRate;
      } else {
        totalAmt = amount;
      }
    }

    bookParam = {
      "user_id": userId,
      "amount": totalAmt,
      "no_hours": widget.noOfHrs,
      "dt_in": "",
      "dt_out": "",
      "eta_in_mins": "",
      "vehicle_type_id": dataRate["value"],
      "vehicle_plate_no": dataRate["plate_no"],
      "park_area_id": "",
      "points_used": "",
      'zv_subscription_dtl_id': subDtlId,
      "auto_extend": "N",
      "version": 3,
      'base_rate': dataRate["base_rate"],
      "base_hours": dataRate["base_hours"],
      "succeeding_rate": dataRate["succeeding_rate"],
      "disc_rate": 0,
    };

    widget.cb(bookParam);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          top: isFirst ? MediaQuery.of(context).size.height : 0,
          left: 0,
          right: 0,
          bottom: 10,
          child: vehicleList(),
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          top: isFirst ? 0 : -MediaQuery.of(context).size.height,
          left: 0,
          right: 0,
          child: inputVehicle(),
        ),
      ],
    );
  }

  Widget inputVehicle() {
    return Container(
      color: AppColor.bodyColor,
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Form(
        key: formKeyBook,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            CustomParagraph(
              text: "Vehicle Plate Number",
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            CustomTextField(
              controller: vhPlNo,
              hintText: "Input vehicle plate number",
              inputFormatters: [
                LengthLimitingTextInputFormatter(15),
                FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9]+|\s ")),
              ],
              onChange: (value) {
                final selection = vhPlNo.selection;
                vhPlNo.text = value.toUpperCase();
                vhPlNo.selection = selection;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Plate no. is required";
                }
                if ((value.endsWith(' ') ||
                    value.endsWith('-') ||
                    value.startsWith(" ") ||
                    value.endsWith('.'))) {
                  return "Invalid Plate no. format";
                }

                return null;
              },
            ),
            CustomParagraph(
              text: "Vehicle Type",
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            SizedBox(height: 10),
            customDropdown(
                isDisabled: false,
                labelText: "Select vehicle type",
                items: widget.vhType,
                selectedValue: _selectedVehicleType,
                onChanged: (value) {
                  setState(() {
                    _selectedVehicleType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vehicle type is required";
                  }
                  return null;
                }),
            SizedBox(height: 30),
            CustomButton(
                text: "Proceed",
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  if (formKeyBook.currentState!.validate()) {
                    var selVh = widget.vhType
                        .where((element) =>
                            element["value"] ==
                            int.parse(_selectedVehicleType.toString()))
                        .toList();

                    selVh.map((e) {
                      e["plate_no"] = vhPlNo.text;
                      return e;
                    }).toList();
                    paramSeldVh = selVh[0];
                    var ddd = await filterSubscriotion(
                        selVh[0]["plate_no"], selVh[0]["value"]);

                    initParam(ddd, paramSeldVh);
                  }
                }),
            SizedBox(height: 20),
            Visibility(
              visible: widget.vhData.isNotEmpty,
              child: CustomButton(
                  btnColor: Colors.white,
                  bordercolor: AppColor.primaryColor,
                  textColor: AppColor.primaryColor,
                  text: "Choose from the list",
                  onPressed: () {
                    setState(() {
                      isFirst = false;
                    });
                  }),
            )
          ],
        ),
      ),
    );
  }

  Widget vehicleList() {
    return Container(
      color: AppColor.bodyColor,
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                itemBuilder: (context, index) => VehicleCard(
                      vehicle: widget.vhData[index],
                      callback: (data) async {
                        var selVh = widget.vhType
                            .where((element) =>
                                element["value"] ==
                                int.parse(data["vehicle_type_id"].toString()))
                            .toList();

                        selVh.map((e) {
                          e["plate_no"] = data["plate_no"];
                          return e;
                        }).toList();
                        paramSeldVh = selVh[0];
                        var ddd = await filterSubscriotion(
                            selVh[0]["plate_no"], selVh[0]["value"]);

                        initParam(ddd, paramSeldVh);
                      },
                    ),
                separatorBuilder: (context, index) => SizedBox(height: 0),
                itemCount: widget.vhData.length),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: CustomButton(
                text: "Go back",
                onPressed: () {
                  setState(() {
                    isFirst = true;
                  });
                }),
          ),
        ],
      ),
    );
  }
}

class VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final Function callback;
  const VehicleCard({required this.vehicle, required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        callback({
          "plate_no": vehicle["vehicle_plate_no"],
          "vehicle_type_id": vehicle["vehicle_type_id"]
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: CustomTitle(
            text: vehicle["vehicle_plate_no"].toString(),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            maxlines: 1,
            letterSpacing: -.5,
            color: AppColor.headerColor,
          ),
          subtitle: CustomParagraph(
            text: "Brand: ${vehicle["vehicle_brand_name"]}",
            fontSize: 12,
            maxlines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
