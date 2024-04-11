import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class ParkingSpotFilter extends StatefulWidget {
  const ParkingSpotFilter({super.key});

  @override
  State<ParkingSpotFilter> createState() => _ParkingSpotFilterState();
}

class _ParkingSpotFilterState extends State<ParkingSpotFilter> {
  List dimensions = [15, 100, 500, 1000, 5000, 10000, 20000];
  String? ddType;
  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
      appbarColor: AppColor.bodyColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
            ),
            Row(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close)),
                Container(
                  width: 40,
                ),
                CustomDisplayText(
                  label: "Filter",
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ],
            ),
            Container(
              height: 40,
            ),
            CustomDisplayText(
              label: "Distance",
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 22, 22, 22),
              fontSize: 18,
            ),
            Container(
              height: 10,
            ),
            CustomDisplayText(
              label: "Display all parking spot within the range you provided.",
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            Container(height: 10),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dimensions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 237, 247, 255)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: CustomDisplayText(
                            label: '${dimensions[index]} meters',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              height: 20,
            ),
            CustomDisplayText(
              label: "Parking Type",
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 22, 22, 22),
              fontSize: 18,
            ),
            Container(height: 10),
            Container(
              height: 50,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color.fromARGB(255, 237, 247, 255),
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: DropdownButtonFormField(
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                    hintText: "",
                    hintStyle: GoogleFonts.varela(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.all(10),
                    border: InputBorder.none),
                value: ddType,
                onChanged: (String? newValue) async {
                  ddType = newValue!;
                },
                isExpanded: true,
                items: dimensions.map((item) {
                  return DropdownMenuItem(
                      value: item.toString(),
                      child: AutoSizeText(
                        item.toString(),
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
            ),
            Container(
              height: 20,
            ),
            CustomDisplayText(
              label: "Location",
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 22, 22, 22),
              fontSize: 18,
            ),
            Container(
              height: 10,
            ),
            Container(
              height: 50,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.12999999523162842),
                  ),
                  borderRadius: BorderRadius.circular(33),
                ),
              ),
              child: Center(
                child: TextField(
                  readOnly: false,
                  enabled: true,
                  decoration: InputDecoration(
                    hintText: 'Where are you going?',
                    enabled: false,
                    border: InputBorder.none,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF9C9C9C),
                    ),
                    hintStyle: GoogleFonts.lato(
                      color: const Color(0xFF9C9C9C),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onChanged: (query) async {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
