import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/dashboard/nearest_list.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';

class ViewList extends StatefulWidget {
  final List nearestData;
  final double balance, minBalance;
  final VoidCallback onTap;

  const ViewList(
      {super.key,
      required this.nearestData,
      required this.balance,
      required this.minBalance,
      required this.onTap});

  @override
  State<ViewList> createState() => _ViewListState();
}

class _ViewListState extends State<ViewList> {
  bool isLoadingBtn = false;
  int selectedButtonIndex = -1;
  List searchedZone = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    searchedZone = widget.nearestData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
      appBarheaderText: "Parking Areas",
      canPop: true,
      hasPadding: false,
      appBarIconClick: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: widget.nearestData.isEmpty
                  ? Variables.screenSize.height * .20
                  : 0,
            ),
            if (widget.nearestData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    child: TextField(
                      autofocus: false,
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search parking zone/address",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 10),
                        hintStyle: Platform.isAndroid
                            ? GoogleFonts.dmSans(
                                color: Color(0x993C3C43),
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                height: 0.08,
                                letterSpacing: -0.41,
                              )
                            : TextStyle(
                                color: Color(0x993C3C43),
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                height: 0.08,
                                letterSpacing: -0.41,
                              ),
                      ),
                      onChanged: (String value) async {
                        setState(() {
                          searchedZone = widget.nearestData;
                          searchedZone = widget.nearestData.where((e) {
                            return e["park_area_name"]
                                    .toString()
                                    .toLowerCase()
                                    .contains(value.toLowerCase()) ||
                                e["address"]
                                    .toString()
                                    .toLowerCase()
                                    .contains(value.toLowerCase());
                          }).toList();
                        });
                      },
                    ),
                  ),
                ),
              ),
            if (widget.nearestData.isEmpty)
              NoDataFound(
                size: 130,
                textText:
                    "No parking area found nearby.\nPlease search another place.",
              )
            else
              Expanded(
                child: ListItems(
                  data: searchedZone,
                  userbal: widget.balance,
                  minBalance: widget.minBalance,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ListItems extends StatelessWidget {
  final List data;
  final double userbal, minBalance;
  ListItems(
      {super.key,
      required this.data,
      required this.userbal,
      required this.minBalance});

  double averageData = 0.0;

  bool isLoadingPage = true;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: data.length,
        itemBuilder: (context, index) {
          String getDistanceString() {
            if (data[index]["distance"] >= 1000) {
              double distanceInKilometers = data[index]["distance"] / 1000;
              return '${distanceInKilometers.toStringAsFixed(2)} km';
            } else {
              return '${data[index]["distance"].toStringAsFixed(2)} m';
            }
          }

          String finalSttime =
              "${data[index]["start_time"].toString().substring(0, 2)}:${data[index]["start_time"].toString().substring(2)}";
          String finalEndtime =
              "${data[index]["end_time"].toString().substring(0, 2)}:${data[index]["end_time"].toString().substring(2)}";
          bool isOpen =
              DashboardComponent.checkAvailability(finalSttime, finalEndtime);
          return NearestList(
              nearestData: data[index],
              isOpen: isOpen,
              distance: getDistanceString());
        });
  }
}
