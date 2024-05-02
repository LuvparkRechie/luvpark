import 'dart:io';

import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/dashboard/view_area_details.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewList extends StatefulWidget {
  final List nearestData;
  final double balance, minBalance;
  final VoidCallback onTap;
  final List<Widget> bottomW;
  const ViewList(
      {super.key,
      required this.nearestData,
      required this.balance,
      required this.bottomW,
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
                      child: ListView.builder(
                          itemCount: widget.nearestData.length,
                          itemBuilder: (context, index) {
                            return _listItem(widget.nearestData[index], index);
                          }))
            ],
          ),
        ),
      ),
    );
  }

  Widget _listItem(data, index) {
    String finalSttime =
        "${data["start_time"].toString().substring(0, 2)}:${data["start_time"].toString().substring(2)}";
    String finalEndtime =
        "${data["end_time"].toString().substring(0, 2)}:${data["end_time"].toString().substring(2)}";
    bool isOpen =
        DashboardComponent.checkAvailability(finalSttime, finalEndtime);

    return Container(
      decoration: const BoxDecoration(
          color: Color(0xFFffffff),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 73,
                  height: 90,
                  decoration: ShapeDecoration(
                      color: const Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      image: const DecorationImage(
                          image: AssetImage("assets/images/map_view.png"),
                          fit: BoxFit.cover)),
                ),
                Container(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                              "${data["vehicle_types_list"]}",
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    Container(width: 5),
                                    InkWell(
                                      onTap: () async {
                                        String mapUrl = "";
                                        String dest =
                                            "${data["pa_latitude"]},${data["pa_longitude"]}";
                                        if (Platform.isIOS) {
                                          mapUrl =
                                              'https://maps.apple.com/?daddr=$dest';
                                        } else {
                                          mapUrl =
                                              'https://www.google.com/maps/search/?api=1&query=${data["pa_latitude"]},${data["pa_longitude"]}';
                                        }
                                        if (await canLaunchUrl(
                                            Uri.parse(mapUrl))) {
                                          await launchUrl(Uri.parse(mapUrl),
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } else {
                                          throw 'Something went wrong while opening map. Pleaase report problem';
                                        }
                                      },
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: ShapeDecoration(
                                          color: AppColor.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.directions,
                                          size: 20,
                                          color: AppColor.bodyColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 5,
                                ),
                                CustomDisplayText(
                                  label: "${data["park_area_name"]}",
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 5,
                      ),
                      data["address"] == null
                          ? Container()
                          : CustomDisplayText(
                              label: "${data["address"]}",
                              color: const Color(0xFF8D8D8D),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              maxLines: 2,
                            ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 73,
                  child: Center(
                    child: CustomDisplayText(
                      label: isOpen ? "Open Now" : "Closed",
                      color: isOpen ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 10,
                ),
                Expanded(
                  child: CustomButton(
                      label: "Check Parking Zone",
                      onTap: () async {
                        Variables.pageTrans(ViewDetails(areaData: [data]));
                      }),
                )
              ],
            ),

            // Container(
            //   height: 10,
            // ),
            const Divider(
              color: Color.fromARGB(255, 223, 223, 223),
            ),
            Row(
              children: [
                bottomListDetails("time_money", "${data["parking_schedule"]}"),
                bottomListDetails2(
                    "road", "${data["parking_type_name"]} PARKING"),
                bottomListDetails3("carpool",
                    "${data["ps_vacant_count"].toString()} AVAILABLE"),
              ],
            ),

            const Divider(
              color: Color.fromARGB(255, 223, 223, 223),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomListDetails(String icon, String label) {
    return Expanded(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image(
          width: 15,
          height: 15,
          fit: BoxFit.fill,
          image: AssetImage("assets/images/$icon.png"),
        ),
        Container(
          width: 5,
        ),
        Expanded(
          child: CustomDisplayText(
            label: label,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            maxLines: 1,
          ),
        )
      ],
    ));
  }

  Widget bottomListDetails2(String icon, String label) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            width: 15,
            height: 15,
            fit: BoxFit.fill,
            image: AssetImage("assets/images/$icon.png"),
          ),
          Container(
            width: 5,
          ),
          Expanded(
            child: CustomDisplayText(
              label: label,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              maxLines: 1,
            ),
          ),
        ],
      ),
    ));
  }

  Widget bottomListDetails3(String icon, String label) {
    return Expanded(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Image(
          width: 15,
          height: 15,
          fit: BoxFit.fill,
          image: AssetImage("assets/images/$icon.png"),
        ),
        Container(
          width: 5,
        ),
        Expanded(
          child: CustomDisplayText(
            label: label,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            maxLines: 1,
          ),
        )
      ],
    ));
  }
}
