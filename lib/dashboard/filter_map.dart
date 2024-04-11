import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';

class VerticalModal extends StatefulWidget {
  final Function callBack;
  const VerticalModal({super.key, required this.callBack});

  @override
  State<VerticalModal> createState() => _VerticalModalState();
}

class _VerticalModalState extends State<VerticalModal> {
  List radiusData = [];
  String? ddRadius;
  bool isLoadingRadius = true;
  bool hasNetRadius = true;
  List pTypeData = [];
  String? ddPtype;
  bool isLoadingPtype = true;
  bool hasNetPType = true;

  @override
  void initState() {
    super.initState();
    radiusDropdown();
    pTypeDropdown();
  }

  void radiusDropdown() async {
    DashboardComponent.getRadius(context, (dataRadius) {
      if (dataRadius == "No Internet" || dataRadius == "Error") {
        setState(() {
          hasNetRadius = false;
          isLoadingRadius = false;
          radiusData = [];
        });
        return;
      } else {}
      setState(() {
        hasNetRadius = true;
        isLoadingRadius = false;
        radiusData = dataRadius;
      });
    });
  }

  void pTypeDropdown() {
    DashboardComponent.getParkingType(context, (dataPtype) {
      if (dataPtype == "No Internet" || dataPtype == "Error") {
        setState(() {
          hasNetPType = false;
          isLoadingPtype = false;
          pTypeData = [];
        });
        return;
      }
      setState(() {
        hasNetPType = true;
        isLoadingPtype = false;
        pTypeData = dataPtype;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
            child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 50.0, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: CustomDisplayText(
                                label: "Cancel",
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 137, 140, 148),
                                fontSize: 14,
                              ),
                            ),
                            CustomDisplayText(
                              label: "SEARCH FILTERS",
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            InkWell(
                              onTap: () {
                                if (ddRadius == null || ddPtype == null) return;
                                Navigator.pop(context);
                                widget.callBack(
                                    {"radius": ddRadius, "pType": ddPtype});
                              },
                              child: CustomDisplayText(
                                label: "Apply",
                                fontWeight: FontWeight.w600,
                                color: AppColor.primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      CustomDisplayText(
                        label:
                            "Show all available parking spaces within the specified range you provided.",
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                        fontSize: 14,
                        maxLines: 2,
                      ),
                      Container(height: 10),
                      CustomDisplayText(
                        label: "Distance",
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 22, 22, 22),
                        fontSize: 14,
                      ),
                      Container(height: 10),
                      isLoadingRadius
                          ? const Center(child: Text("Loading..."))
                          : Container(
                              height: 50,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: Colors.black
                                        .withOpacity(0.12999999523162842),
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              child: !hasNetRadius
                                  ? InkWell(
                                      onTap: () {
                                        if (isLoadingRadius) return;
                                        setState(() {
                                          isLoadingRadius = true;
                                        });
                                        radiusDropdown();
                                      },
                                      child: Center(
                                        child: CustomDisplayText(
                                            label: "Tap to retry",
                                            fontWeight: FontWeight.normal,
                                            color: AppColor.textSubColor,
                                            fontSize: 12),
                                      ),
                                    )
                                  : DropdownButtonFormField(
                                      dropdownColor: Colors.white,
                                      decoration: InputDecoration(
                                          hintText: "",
                                          hintStyle: GoogleFonts.varela(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade500,
                                            fontSize: 15,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.all(10),
                                          border: InputBorder.none),
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
                            ),
                      Container(
                        height: 10,
                      ),
                      CustomDisplayText(
                        label: "Type of Parking",
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 22, 22, 22),
                        fontSize: 14,
                      ),
                      Container(height: 10),
                      isLoadingPtype
                          ? const Center(child: Text("Loading..."))
                          : Container(
                              height: 50,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: Colors.black
                                        .withOpacity(0.12999999523162842),
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              child: !hasNetRadius
                                  ? InkWell(
                                      onTap: () {
                                        if (isLoadingPtype) return;
                                        setState(() {
                                          isLoadingPtype = true;
                                        });
                                        pTypeDropdown();
                                      },
                                      child: Center(
                                        child: CustomDisplayText(
                                          label: " Tap to retry",
                                          fontWeight: FontWeight.normal,
                                          color: AppColor.textSubColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : DropdownButtonFormField(
                                      dropdownColor: Colors.white,
                                      decoration: InputDecoration(
                                          hintText: "",
                                          hintStyle: GoogleFonts.varela(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade500,
                                            fontSize: 15,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.all(10),
                                          border: InputBorder.none),
                                      value: ddPtype,
                                      onChanged: (String? newValue) async {
                                        ddPtype = newValue!;
                                      },
                                      isExpanded: true,
                                      items: pTypeData.map((item) {
                                        return DropdownMenuItem(
                                            value: item['parking_type_code']
                                                .toString(),
                                            child: AutoSizeText(
                                              item['parking_type_name'],
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
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
