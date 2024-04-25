import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:sizer/sizer.dart';

class ViewRates extends StatefulWidget {
  final List data;
  final int areaid;

  const ViewRates({
    Key? key,
    required this.data,
    required this.areaid,
  }) : super(key: key);

  @override
  State<ViewRates> createState() => _ViewRatesState();
}

class _ViewRatesState extends State<ViewRates>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  bool hasInternet = true;
  List<String> amenities = [];

  Map<String, IconData> amenityIcons = {
    "WITH CCTV": FontAwesomeIcons.camera,
    "CONCRETE FLOOR": FontAwesomeIcons.road,
    "WITH SECURITY": FontAwesomeIcons.personMilitaryPointing,
    "COVERED / SHADED": FontAwesomeIcons.warehouse,
    "GRASS AREA": FontAwesomeIcons.leaf,
    "ASPHALT FLOOR": FontAwesomeIcons.road
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void getAmenities() async {
    CustomModal(context: context).loader();
    HttpRequest(
      api: '${ApiKeys.gApiSubFolderGetAmenities}?park_area_id=${widget.areaid}',
    ).get().then((returnData) async {
      print("inataya");
      if (returnData == "No Internet") {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (returnData == null) {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (returnData["items"].isNotEmpty) {
        Navigator.of(context).pop();
        List<String> amenityDescriptions = [];
        for (var item in returnData["items"]) {
          amenityDescriptions.add(item["parking_amenity_desc"]);
        }
        setState(() {
          amenities = amenityDescriptions;
        });
        return;
      } else {
        Navigator.of(context).pop();
        showAlertDialog(context, "LuvPark", returnData["msg"], () {
          Navigator.of(context).pop();
        });
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1)),
          child: CustomParent1Widget(
            canPop: true,
            appBarIconClick: () {
              Navigator.pop(context);
            },
            appBarheaderText: "More Info",
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColor.primaryColor,
                  labelColor: Colors.black,
                  onTap: (index) {
                    if (index == 1) {
                      getAmenities();
                    }
                  },
                  tabs: [
                    Tab(text: 'Vehicle Rates'),
                    Tab(text: 'Amenities'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // First Tab: Vehicle Rates
                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              itemCount: widget.data.length,
                              itemBuilder: ((context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColor.bodyColor,
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomDisplayText(
                                            label: "Vehicle",
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                          Container(height: 5),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: IntrinsicHeight(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      widget.data[index][
                                                                  "vehicle_type"]
                                                              .toString()
                                                              .toLowerCase()
                                                              .contains(
                                                                  "motorcycle")
                                                          ? Icons.motorcycle
                                                          : Icons.time_to_leave,
                                                      size: 30,
                                                      color:
                                                          AppColor.primaryColor,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      "TYPE",
                                                      style: Platform.isAndroid
                                                          ? GoogleFonts.dmSans(
                                                              color: Colors
                                                                  .black54,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            )
                                                          : TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontFamily:
                                                                  "SFProTextReg",
                                                            ),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Container(
                                                      width: 3,
                                                      height: 15,
                                                      color: AppColor.mainColor,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Expanded(
                                                      child: Text(
                                                        "${widget.data[index]["vehicle_type"]}",
                                                        style:
                                                            Platform.isAndroid
                                                                ? GoogleFonts
                                                                    .dmSans(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  )
                                                                : TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        "SFProTextReg",
                                                                  ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          CustomDisplayText(
                                            label: "Rates",
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          SizedBox(height: 5),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                              ),
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  details(
                                                      "Base Rate",
                                                      toCurrencyString(widget
                                                          .data[index]
                                                              ["base_rate"]
                                                          .toString()
                                                          .trim())),
                                                  details(
                                                    "Base Hours",
                                                    "${widget.data[index]['base_hours']} ${int.parse(widget.data[index]['base_hours'].toString()) > 1 ? "hrs" : "hr"}",
                                                  ),
                                                  details(
                                                      "Succeeding Rate",
                                                      toCurrencyString(widget
                                                          .data[index][
                                                              "succeeding_rate"]
                                                          .toString()
                                                          .trim())),
                                                  details(
                                                      "Overnight Rate",
                                                      toCurrencyString(widget
                                                          .data[index]
                                                              ["overnight_rate"]
                                                          .toString()
                                                          .trim())),
                                                  details(
                                                      "Daily Rate",
                                                      toCurrencyString(widget
                                                          .data[index]
                                                              ["daily_rate"]
                                                          .toString()
                                                          .trim())),
                                                  details(
                                                      "Daily Penalty Rate",
                                                      toCurrencyString(widget
                                                          .data[index][
                                                              "daily_penalty_rate"]
                                                          .toString()
                                                          .trim())),
                                                  details(
                                                      "First Hour Penalty Rate",
                                                      toCurrencyString(widget
                                                          .data[index][
                                                              "first_hr_penalty_rate"]
                                                          .toString()
                                                          .trim())),
                                                  details(
                                                      "Succeeding Penalty Rate",
                                                      toCurrencyString(widget
                                                          .data[index][
                                                              "succeeding_hr_penalty_rate"]
                                                          .toString()
                                                          .trim())),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                      amenities.isEmpty
                          ? Center(
                              child: CustomDisplayText(
                                label: 'No Amenities Available',
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : ListView.builder(
                              itemCount: amenities.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          amenitiesDetails(
                                            amenities[index],
                                            amenityIcons.containsKey(
                                                    amenities[index])
                                                ? Icon(amenityIcons[
                                                    amenities[index]])
                                                : Icon(
                                                    FontAwesomeIcons
                                                        .squareParking,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget details(String label, value) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomDisplayText(
              label: "$value",
              color: AppColor.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 10),
          Container(
            color: Colors.grey,
            width: 2,
            height: 8,
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: CustomDisplayText(
              label: label,
              color: Colors.black87.withOpacity(.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget amenitiesDetails(String label, Widget icon) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: IconTheme(
              data: IconThemeData(color: AppColor.primaryColor),
              child: icon,
            ),
          ),
          SizedBox(width: 10),
          Container(
            color: Colors.grey,
            width: 2,
            height: 8,
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: CustomDisplayText(
              label: label,
              color: Colors.black87.withOpacity(.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
