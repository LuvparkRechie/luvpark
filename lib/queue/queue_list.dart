import 'dart:async';

import 'package:flutter/material.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/landing/payment/ticket_widget.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:wave_divider/wave_divider.dart';

class QueueList extends StatefulWidget {
  const QueueList({super.key});

  @override
  State<QueueList> createState() => _QueueListState();
}

class _QueueListState extends State<QueueList> {
  List queData = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    String akongId = await Variables.getUserId();
    CustomModal(context: context).loader();
    HttpRequest(
      api: "${ApiKeys.gApiLuvParkResQueue}?user_id=${akongId.toString()}",
    ).get().then((queueData) async {
      if (queueData == "No Internet") {
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again", () {
          Navigator.pop(context);
        });

        return;
      }

      if (queueData == null) {
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please contact support.", () {
          Navigator.pop(context);
        });
      }

      if (queueData["items"].isNotEmpty) {
        Navigator.of(context).pop();
        if (mounted) {
          setState(() {
            queData = queueData["items"];
            isLoading = false;
          });
        }
      } else {
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
      bodyColor: const Color(0xFFF1F1F1),
      appBarIconClick: () {
        Navigator.pop(context);
      },
      canPop: true,
      appBarheaderText: "Parking Queue",
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: isLoading
            ? Container()
            : RefreshIndicator(
                onRefresh: fetchData,
                child: queData.isEmpty
                    ? NoDataFound(
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              isLoading = true;
                            });
                          }
                          fetchData();
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: Offset(5, 10),
                              )
                            ]),
                            child: TicketWidget(
                              width: Variables.screenSize.width,
                              height: Variables.screenSize.height * 0.40,
                              child: childWidget(queData[index]),
                              isCornerRounded: true,
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(
                              height: 15,
                            ),
                        itemCount: queData.length),
              ),
      ),
    );
  }

  Widget status() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 228, 206),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Center(
          child: CustomDisplayText(
            label: "QUEUED",
            fontSize: 12,
            color: Colors.orange,
            fontWeight: FontWeight.w600,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  Widget childWidget(data) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      width: 1.0,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  child: Center(
                    child: CustomDisplayText(
                      label: data["park_area_name"],
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryColor,
                      minFontsize: 1,
                      maxLines: 2,
                    ),
                  ),
                ),
                Container(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomDisplayText(
                          label: data['vehicle_plate_no'],
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          maxLines: 1,
                          minFontsize: 1,
                          alignment: TextAlign.right,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Image.asset(
                        'assets/images/license-plate.png',
                        width: 40,
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: Colors.black,
          ),
          Center(
            child: CustomDisplayText(
              label: 'Parking Ticket',
              color: AppColor.primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          //middle part
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              left: 50,
              right: 50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDisplayText(
                      label: 'Valid until:',
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    SizedBox(height: 5),
                    CustomDisplayText(
                      label:
                          "${Variables.formatDateTicket(Variables.convertToManilaTime(data["valid_until"]))}",
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDisplayText(
                      label: 'Time Valid:',
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    SizedBox(height: 5),
                    CustomDisplayText(
                      label:
                          "${Variables.formatTimeTicket(Variables.convertToManilaTime(data["valid_until"]))}",
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDisplayText(
                  label: 'Parking Area:',
                  color: Colors.grey,
                  fontSize: 13,
                ),
                SizedBox(height: 5),
                CustomDisplayText(
                  label: data['address'],
                  color: Colors.black,
                  fontSize: 15,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          WaveDivider(
            color: Colors.black,
          ),
          Container(
            height: 20,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: ElevatedButton.icon(
                      onPressed: () async {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const StadiumBorder(
                          side: BorderSide(width: 0.5, color: Colors.blue),
                        ),
                      ),
                      icon: Icon(
                        Icons.cancel,
                        color: AppColor.primaryColor,
                      ),
                      label: CustomDisplayText(
                        label: 'Cancel'.toUpperCase(),
                        fontSize: 12,
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.bold,
                        maxLines: 2,
                        alignment: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.4, // Adjust width as needed
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const StadiumBorder(
                          side: BorderSide(width: 0.5, color: Colors.blue),
                        ),
                      ),
                      icon: Icon(Icons.local_parking_outlined,
                          color: AppColor.primaryColor),
                      label: CustomDisplayText(
                        label: 'Park'.toUpperCase(),
                        fontSize: 12,
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.bold,
                        maxLines: 2,
                        alignment: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 20,
          ),
        ],
      ),
    );
  }
}
