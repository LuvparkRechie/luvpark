import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import '../../custom_widgets/app_color.dart';
import '../../custom_widgets/custom_button.dart';

class SubscriptionDetails extends StatelessWidget {
  final List data;

  const SubscriptionDetails({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: CustomParagraph(
                  minFontSize: 8,
                  text: 'Subscriptions',
                  fontSize: 16,
                  maxlines: 1,
                  color: Color(0xFF070707),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Expanded(
            child: data.isEmpty
                ? NoDataFound(
                    text: "No Subscription",
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(15),
                    itemCount: data.length,
                    itemBuilder: ((context, index) {
                      var subscriptionRate = data[index]["subscription_rate"];
                      var parkareaname = data[index]["park_area_name"];
                      var startdate = data[index]["start_date"];
                      var client_name = data[index]["client_name"];
                      var vehicletype = data[index]["vehicle_type"];
                      var vehicle_plate_no = data[index]["vehicle_plate_no"];
                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CustomParagraph(
                                              text: parkareaname.toString(),
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            CustomParagraph(
                                              text: client_name.toString(),
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    //SUBSCRIPTION RATE
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        color: AppColor.primaryColor
                                            .withOpacity(0.1),
                                      ),
                                      child: Row(
                                        children: [
                                          CustomParagraph(
                                            text: "₱",
                                            color: Colors.black,
                                          ),
                                          CustomParagraph(
                                            text: subscriptionRate.toString(),
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                CustomParagraph(
                                  text: vehicle_plate_no,
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                CustomParagraph(
                                  text: vehicletype,
                                  fontSize: 12,
                                  color: AppColor.primaryColor,
                                  fontWeight: FontWeight.normal,
                                ),
                                SizedBox(height: 5),
                                CustomParagraph(
                                  text: formatDate(startdate),
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),
                  ),
          ),
          CustomButton(
            text: 'Close',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  String formatDate(String startDate) {
    DateTime parsedDate = DateTime.parse(startDate);
    DateFormat formattedDate = DateFormat('MMM dd, yyyy');
    return formattedDate.format(parsedDate);
  }
}
