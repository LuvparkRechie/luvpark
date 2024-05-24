import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';

class FilterMap extends StatefulWidget {
  final Function callBack;
  final String radius;
  const FilterMap({super.key, required this.callBack, required this.radius});

  @override
  State<FilterMap> createState() => _FilterMapState();
}

class _FilterMapState extends State<FilterMap> {
  List vehicleTypes = [];
  List pTypeData = [];
  List amenitiess = [];
  List radiusData = [];
  List overNightData = [
    {"name": "Yes", "value": "Y"},
    {"name": "No", "value": "N"}
  ];
  List<String> selectedFilters = [];
  List<String> selectedFiltersAmen = [];
  bool hasNetVhTypes = true;
  bool hasNetAmen = true;
  bool hasNetRadius = true;
  bool loadingRadius = true;
  bool loadingTypes = true;
  bool loadingAmen = true;
  bool loadingPTypes = true;
  String isAllowOverNight = "N";
  String? selectedVehicleType;
  String? ddRadius;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getVhTypeData();
    });
  }

  void getVhTypeData() {
    CustomModal(context: context).loader();
    Functions.getVehicleAllTypesData(context, "", (cb) {
      if (cb["msg"] == "No Internet") {
        setState(() {
          hasNetVhTypes = false;
        });
      }
      if (cb["msg"] == "Success") {
        if (mounted) {
          setState(() {
            vehicleTypes = cb["data"];
            loadingTypes = false;
            hasNetVhTypes = true;
          });
          pTypeDropdown();
        }
      }
    });
  }

  void pTypeDropdown() {
    DashboardComponent.getParkingType(context, (dataPtype) {
      if (dataPtype == "No Internet" || dataPtype == "Error") {
        Navigator.of(context).pop();
        setState(() {
          loadingPTypes = true;
          pTypeData = [];
        });
        return;
      }

      if (dataPtype.isNotEmpty) {
        for (int i = 0; i < dataPtype.length; i++) {
          pTypeData.add({
            "text": dataPtype[i]["parking_type_name"],
            "value": dataPtype[i]["parking_type_code"]
          });
        }
      }
      setState(() {
        loadingPTypes = true;
      });
      getAmenities();
    });
  }

  void getAmenities() {
    Functions.getAmenities(context, "", (cb) {
      if (cb["msg"] == "No Internet") {
        setState(() {
          hasNetAmen = false;
          loadingAmen = false;
        });
      }
      if (cb["msg"] == "Success") {
        if (cb["data"].isNotEmpty) {
          for (int i = 0; i < cb["data"].length; i++) {
            amenitiess.add({
              "text": cb["data"][i]["parking_amenity_desc"],
              "value": cb["data"][i]["parking_amenity_code"]
            });
          }
        }

        setState(() {
          loadingAmen = false;
          hasNetAmen = true;
        });

        radiusDropdown();
      }
    });
  }

  void radiusDropdown() async {
    DashboardComponent.getRadius(context, (dataRadius) {
      if (dataRadius == "No Internet") {
        Navigator.of(context).pop();
        setState(() {
          hasNetRadius = false;
          loadingRadius = false;
          radiusData = [];
        });
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (dataRadius == "Error") {
        Navigator.of(context).pop();
        setState(() {
          hasNetRadius = false;
          loadingRadius = false;
          radiusData = [];
        });
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });

        return;
      }
      Navigator.of(context).pop();
      setState(() {
        hasNetRadius = true;
        loadingRadius = false;
        radiusData = dataRadius;
        if (radiusData.isNotEmpty) {
          ddRadius = radiusData
              .where((e) {
                return e["value"].toString() == widget.radius.toString();
              })
              .toList()[0]["value"]
              .toString();
        }
      });
      print("dddd radius $ddRadius");
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidgetV2(
      appBarHeaderText: 'Map Filter',
      appBarIconClick: () {
        Navigator.pop(context);
      },
      bodyColor: Color.fromARGB(255, 249, 248, 248),
      child: Container(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildOvernight(),
                    SizedBox(height: 10),
                    buildRadius(),
                    SizedBox(height: 10),
                    buildRadioOptions('Vehicle Type'),
                    SizedBox(height: 10),
                    buildFilterChips('Parking Type', pTypeData),
                    SizedBox(height: 10.0),
                    buildFilterChips('Amenities', amenitiess),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomButton(
                    label: 'Apply Filters',
                    onTap: () {
                      String filterVtype = selectedFilters.join('|');
                      String filterAmen = selectedFiltersAmen.join('|');

                      widget.callBack({
                        "vh_type": selectedVehicleType == null
                            ? ""
                            : selectedVehicleType,
                        "amen": filterAmen.toString(),
                        "p_type": filterVtype.toString(),
                        "radius": ddRadius == null ? 10000 : ddRadius,
                        "is_allow_overnight": isAllowOverNight,
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOvernight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(text: "Allow Overnight"),
        Container(
          height: 30,
          child: RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: CustomDisplayText(label: "Yes"),
            value: overNightData[0]["value"],
            groupValue: isAllowOverNight,
            onChanged: (String? value) {
              setState(() {
                isAllowOverNight = value!;
              });
            },
          ),
        ),
        Container(
          height: 30,
          child: RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: CustomDisplayText(label: "No"),
            value: overNightData[1]["value"],
            groupValue: isAllowOverNight,
            onChanged: (String? value) {
              setState(() {
                isAllowOverNight = value!;
              });
            },
          ),
        ),
        SizedBox(height: 10.0),
      ],
    );
  }

  Widget buildRadioOptions(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(text: title),
        loadingTypes
            ? Container(height: 30)
            : Column(
                children: [
                  for (int i = 0; i < vehicleTypes.length; i++)
                    Container(
                      height: 30,
                      child: RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title:
                            CustomDisplayText(label: vehicleTypes[i]["text"]),
                        value: vehicleTypes[i]["value"].toString(),
                        groupValue: selectedVehicleType,
                        onChanged: (String? value) {
                          setState(() {
                            selectedVehicleType = value;
                          });
                        },
                      ),
                    ),
                  Container(
                    height: 30,
                    child: RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: CustomDisplayText(label: "None"),
                      value: "",
                      groupValue: selectedVehicleType,
                      onChanged: (String? value) {
                        setState(() {
                          selectedVehicleType = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
        SizedBox(height: 10.0),
      ],
    );
  }

  Widget buildFilterChips(String title, List filters) {
    return Container(
      width: Variables.screenSize.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelText(text: title),
          SizedBox(height: 8.0),
          Wrap(spacing: 10.0, children: [
            for (int i = 0; i < filters.length; i++)
              FilterChip(
                checkmarkColor: Colors.white,
                backgroundColor: Color.fromARGB(255, 225, 223, 223),
                label: CustomDisplayText(label: filters[i]["text"]),
                selected: title == "Amenities"
                    ? selectedFiltersAmen
                        .contains(filters[i]["value"].toString())
                    : selectedFilters.contains(filters[i]["value"].toString()),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      if (title == "Amenities") {
                        selectedFiltersAmen.add(filters[i]["value"].toString());
                      } else {
                        selectedFilters.add(filters[i]["value"].toString());
                      }
                    } else {
                      if (title == "Amenities") {
                        selectedFiltersAmen
                            .remove(filters[i]["value"].toString());
                      } else {
                        selectedFilters.remove(filters[i]["value"].toString());
                      }
                    }
                  });
                },
                labelStyle: TextStyle(
                  color: (title == "Amenities"
                          ? selectedFiltersAmen
                              .contains(filters[i]["value"].toString())
                          : selectedFilters
                              .contains(filters[i]["value"].toString()))
                      ? Colors.white
                      : Colors.black, // Change text color based on selection
                ),
                selectedColor: AppColor
                    .primaryColor, // Optional: Change background color when selected
              ),
          ]),
        ],
      ),
    );
  }

  Widget buildRadius() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(text: "Radius"),
        SizedBox(height: 8.0),
        DropdownButtonFormField(
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: "",
            hintStyle: GoogleFonts.varela(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              fontSize: 15,
            ),
            contentPadding: const EdgeInsets.all(10),
            border: InputBorder.none,
          ),
          value: ddRadius,
          onChanged: (String? newValue) async {
            ddRadius = newValue!;
          },
          isExpanded: true,
          menuMaxHeight: 400,
          items: radiusData.map((item) {
            return DropdownMenuItem(
                value: item['value'].toString(),
                child: AutoSizeText(
                  item['text'],
                  style: GoogleFonts.varela(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxFontSize: 15,
                  maxLines: 2,
                ));
          }).toList(),
        ),
        SizedBox(height: 10.0),
      ],
    );
  }
}
