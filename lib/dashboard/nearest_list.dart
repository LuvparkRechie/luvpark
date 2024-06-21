import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/dashboard/view_area_details.dart';

class NearestList extends StatelessWidget {
  final dynamic nearestData;
  final bool isOpen;
  final String distance;
  const NearestList(
      {super.key,
      required this.nearestData,
      required this.isOpen,
      required this.distance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: InkWell(
        onTap: () {
          CustomModal(context: context).loader();
          Functions.getAmenities(context, "", (cb) {
            if (cb["msg"] == "Success") {
              Navigator.of(context).pop();
              if (cb["data"].isNotEmpty) {
                Variables.pageTrans(
                    ViewDetails(
                        areaData: [nearestData], amenitiesData: cb["data"]),
                    context);
              }
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          width: Variables.screenSize.width * .88,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomDisplayText(
                      label: nearestData["park_area_name"],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      maxLines: 1,
                    ),
                    CustomDisplayText(
                      label: nearestData["address"],
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      maxLines: 2,
                    ),
                    Container(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                "$distance  ●  ${nearestData["parking_schedule"]}  ●  ",
                            style: GoogleFonts.varela(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: "${isOpen ? "OPEN" : "CLOSE"}",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w500,
                              color: isOpen ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_right_outlined,
                color: AppColor.primaryColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}
