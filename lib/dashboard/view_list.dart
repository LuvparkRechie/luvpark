import 'package:flutter/material.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/dashboard/dashboard3.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: widget.data.length,
        itemBuilder: (context, index) {
          String getDistanceString() {
            if (widget.data[index]["distance"] >= 1000) {
              double distanceInKilometers =
                  widget.data[index]["distance"] / 1000;
              return '${distanceInKilometers.toStringAsFixed(2)} km';
            } else {
              return '${widget.data[index]["distance"].toStringAsFixed(2)} m';
            }
          }

          String finalSttime =
              "${widget.data[index]["start_time"].toString().substring(0, 2)}:${widget.data[index]["start_time"].toString().substring(2)}";
          String finalEndtime =
              "${widget.data[index]["end_time"].toString().substring(0, 2)}:${widget.data[index]["end_time"].toString().substring(2)}";
          bool isOpen =
              DashboardComponent.checkAvailability(finalSttime, finalEndtime);
          return NearestList(
              nearestData: widget.data[index],
              isOpen: isOpen,
              distance: getDistanceString());
        });
  }
}
