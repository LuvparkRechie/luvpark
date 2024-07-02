import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';

class SearchPlaces extends StatefulWidget {
  final LatLng latlng;
  final String radius, pTypeCode, vtypeId, amenities, isAllowOverNight;
  final Function callback;

  const SearchPlaces(
      {super.key,
      required this.latlng,
      required this.radius,
      required this.pTypeCode,
      required this.vtypeId,
      required this.callback,
      required this.isAllowOverNight,
      required this.amenities});

  @override
  State<SearchPlaces> createState() => _SearchPlacesState();
}

class _SearchPlacesState extends State<SearchPlaces> {
  TextEditingController searchController = TextEditingController();
  List<String> suggestions = [];
  int searchData = 0;
  @override
  void initState() {
    super.initState();
  }

  void onChangeTrigger(textSuggest) async {
    await DashboardComponent()
        .fetchSuggestions(
            textSuggest,
            double.parse(widget.latlng.latitude.toString()),
            double.parse(widget.latlng.longitude.toString()),
            widget.radius.toString())
        .then((suggestions) {
      setState(() {
        this.suggestions = suggestions;
        searchData = suggestions.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
        appbarColor: AppColor.primaryColor,
        child: Container(
          color: AppColor.bodyColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 20),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.arrow_back_outlined),
                    ),
                    Container(width: 10),
                    CustomDisplayText(
                      label: "Where do you want to park",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.41,
                    )
                  ],
                ),
                Container(height: 20),
                Container(
                  width: Variables.screenSize.width,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 248, 234, 233),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              CupertinoIcons.search,
                              color: Color.fromARGB(255, 216, 128, 122),
                            ),
                          ),
                        ),
                        Container(width: 10),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search address, places or city',
                              hintStyle: Platform.isAndroid
                                  ? GoogleFonts.dmSans(
                                      color: Color(0x993C3C43),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 0.08,
                                      letterSpacing: -0.41,
                                    )
                                  : TextStyle(
                                      color: Color(0x993C3C43),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 0.08,
                                      letterSpacing: -0.41,
                                    ),
                            ),
                            onChanged: (String text) {
                              onChangeTrigger(text);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(height: 20),
                CustomDisplayText(
                  label: "Results",
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.5,
                  wordSpacing: 1.0,
                  height: 1.2,
                  decoration: TextDecoration.none,
                ),
                Container(height: 5),
                Expanded(
                  child: FadeInUp(
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white,
                        child: suggestions.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomDisplayText(
                                      label: "No data",
                                      fontWeight: FontWeight.normal,
                                      color: AppColor.textSubColor,
                                      fontSize: 16),
                                  Container(
                                    height: 10,
                                  ),
                                ],
                              )
                            : suggestions[0] == "No Internet"
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .20,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        image: const AssetImage(
                                            "assets/images/no_internet.png"),
                                      ),
                                      Container(
                                        height: 20,
                                      ),
                                      CustomDisplayText(
                                          label:
                                              "Please check your internet connection.",
                                          fontWeight: FontWeight.normal,
                                          color: AppColor.textSubColor,
                                          fontSize: 12),
                                      Container(
                                        height: 10,
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    itemCount: suggestions.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                              onTap: () async {
                                                CustomModal(context: context)
                                                    .loader();
                                                await DashboardComponent
                                                    .searchPlaces(
                                                        context,
                                                        suggestions[index]
                                                            .split(
                                                                "=Rechie=")[0],
                                                        (searchedPlace) {
                                                  if (searchedPlace.isEmpty) {
                                                    Navigator.pop(context);
                                                    return;
                                                  } else {
                                                    List data = [
                                                      {
                                                        "lat": searchedPlace[0]
                                                            .toString(),
                                                        "long": searchedPlace[1]
                                                            .toString(),
                                                        "place": suggestions[
                                                                index]
                                                            .toString()
                                                            .split(
                                                                "=Rechie=")[0],
                                                        "radius": widget.radius
                                                            .toString(),
                                                      }
                                                    ];

                                                    DashboardComponent.getNearest(
                                                        ctxt,
                                                        widget.pTypeCode,
                                                        widget.radius
                                                            .toString(),
                                                        data[0]["lat"]
                                                            .toString(),
                                                        data[0]["long"]
                                                            .toString(),
                                                        widget.vtypeId,
                                                        widget.amenities,
                                                        widget.isAllowOverNight,
                                                        (nearestData) {
                                                      Navigator.pop(context);
                                                      widget.callback({
                                                        "data": nearestData,
                                                        "latlng": LatLng(
                                                          double.parse(data[0]
                                                                  ["lat"]
                                                              .toString()),
                                                          double.parse(
                                                            data[0]["long"]
                                                                .toString(),
                                                          ),
                                                        ),
                                                        "searchedData": data
                                                      });
                                                    });
                                                  }
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: AppColor
                                                            .primaryColor,
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(3.0),
                                                        child: Icon(
                                                          Icons.location_pin,
                                                          size: 20,
                                                          color: AppColor
                                                              .bodyColor,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                        child:
                                                            CustomDisplayText(
                                                      label: suggestions[index]
                                                          .split("=Rechie=")[0],
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black,
                                                      maxLines: 2,
                                                    ))
                                                  ],
                                                ),
                                              )),
                                          const Divider()
                                        ],
                                      );
                                    },
                                  )),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
