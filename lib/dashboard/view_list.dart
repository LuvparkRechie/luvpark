import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/dashboard/view_area_details.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
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
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1)),
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
              widget.nearestData.isEmpty
                  ? const NoDataFound(
                      size: 130,
                      textText:
                          "No parking area found nearby.\nPlease search another place.",
                    )
                  : Expanded(
                      child: ListItems(
                        data: widget.nearestData,
                        userbal: widget.balance,
                        minBalance: widget.minBalance,
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}

class ListItems extends StatefulWidget {
  final List data;
  final double userbal, minBalance;
  const ListItems(
      {super.key,
      required this.data,
      required this.userbal,
      required this.minBalance});

  @override
  State<ListItems> createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  double averageData = 0.0;
  bool isLoadingPage = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getRateData();
    });
  }

  getRateData() async {
    final prefs = await SharedPreferences.getInstance();
    double? avgRate = prefs.getDouble("Average");

    setState(() {
      averageData = jsonDecode(avgRate!.toString());
      isLoadingPage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoadingPage
        ? Container()
        : ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: widget.data.length,
            itemBuilder: (context, index) {
              return _listItem(widget.data[index], index);
            });
  }

  Widget _listItem(data, index) {
    return GestureDetector(
      onTap: () {
        if (widget.userbal < widget.minBalance) {
          showAlertDialog(
              context,
              "Attention",
              "Your balance is below the required minimum for this feature. "
                  "Please ensure a minimum balance of ${widget.minBalance} tokens to access the requested service.",
              () {
            Navigator.of(context).pop();
          });
          return;
        }
        Variables.pageTrans(ViewDetails(areaData: [data]), context);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Color(0xFFDFE7EF),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28.0, 15, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDisplayText(
                            label: "${data["park_area_name"]}",
                            fontSize: 16,
                            maxLines: 1,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF131313),
                          ),
                          CustomDisplayText(
                            label: "${data["address"]}",
                            fontSize: 14,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w500,
                            color: AppColor.textSecondaryColor,
                          ),
                        ],
                      ),
                    ),
                    Container(width: 10),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF232323),
                    )
                  ],
                ),
                Container(height: 7),
                Row(
                  children: [
                    CustomDisplayText(
                      label: averageData.toString(),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    Container(width: 5),
                    RatingBarIndicator(
                      rating: double.parse(averageData.toString()),
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: AppColor.primaryColor,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      unratedColor: AppColor.primaryColor.withAlpha(50),
                      direction: Axis.horizontal,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
