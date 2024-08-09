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
        appbarColor: AppColor.secondaryColor,
        bodyColor: AppColor.secondaryColor,
        child: Container(
          padding: const EdgeInsets.only(
            top: 18,
          ),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Color(0xFFF8F8F8),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.chevron_left,
                      ),
                      CustomParagraph(
                        text: "Back",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
                Container(height: 20),
                CustomTitle(
                  text: "Where do you want to park?",
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: -0.41,
                  //  height: 0.06,
                ),
                Container(height: 15),
                Container(
                  width: Variables.screenSize.width,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            CupertinoIcons.search,
                            color: AppColor.paragraphColor,
                          ),
                        ),
                        Container(width: 10),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search address, places or city',
                                hintStyle: GoogleFonts.manrope(
                                  color: Color(0x993C3C43),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 0.08,
                                  letterSpacing: -0.41,
                                )),
                            onChanged: (String text) {
                              onChangeTrigger(text);
                            },
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                              letterSpacing: 0.0,
                              color: AppColor.paragraphColor,
                              wordSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.callback({
                      "data": [],
                      "latlng": LatLng(0.0, 0.0),
                      "searchedData": []
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 9, 8, 0),
                    child: Row(
                      children: [
                        Image(
                          image:
                              AssetImage("assets/dashboard_icon/precise.png"),
                          width: 48,
                          height: 48,
                        ),
                        Container(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTitle(
                                text: "Use my current location",
                                maxlines: 1,
                                fontSize: 16,
                                letterSpacing: -0.41,
                              ),
                              CustomParagraph(
                                text: "Within 10 kilometers of you",
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.41,
                              )
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_outlined,
                          color: AppColor.primaryColor,
                        ),
                        Container(width: 10),
                      ],
                    ),
                  ),
                ),
                Container(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.callback({
                      "data": [],
                      "latlng": LatLng(0.0, 0.0),
                      "searchedData": []
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 9, 8, 0),
                    child: Row(
                      children: [
                        Image(
                          image:
                              AssetImage("assets/dashboard_icon/precise.png"),
                          width: 48,
                          height: 48,
                        ),
                        Container(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTitle(
                                text: "Enter location zone ID",
                                maxlines: 1,
                                fontSize: 16,
                                letterSpacing: -0.41,
                              ),
                              CustomParagraph(
                                text: "Within 10 kilometers of you",
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.41,
                              )
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_outlined,
                          color: AppColor.primaryColor,
                        ),
                        Container(width: 10),
                      ],
                    ),
                  ),
                ),
                Container(height: 35),
                CustomParagraph(
                  text: "Parking areas near you",
                  fontWeight: FontWeight.bold,
                ),
                Container(height: 10),
                Expanded(
                  child: suggestions.isEmpty
                      ? Center(
                          child: CustomParagraph(text: "No data", fontSize: 16))
                      : suggestions[0] == "No Internet"
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                  height:
                                      MediaQuery.of(context).size.height * .20,
                                  width: MediaQuery.of(context).size.width / 2,
                                  image: const AssetImage(
                                      "assets/images/no_internet.png"),
                                ),
                                Container(
                                  height: 20,
                                ),
                                CustomParagraph(
                                    text:
                                        "Please check your internet connection.",
                                    fontSize: 12),
                                Container(
                                  height: 10,
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: suggestions.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                        onTap: () async {
                                          CustomModal(context: context)
                                              .loader();
                                          await DashboardComponent.searchPlaces(
                                              context,
                                              suggestions[index]
                                                  .split("=Rechie=")[0],
                                              (searchedPlace) {
                                            print(
                                                "searchedPlace $searchedPlace");
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
                                                  "place": suggestions[index]
                                                      .toString()
                                                      .split("=Rechie=")[0],
                                                  "radius":
                                                      widget.radius.toString(),
                                                }
                                              ];

                                              DashboardComponent.getNearest(
                                                  ctxt,
                                                  widget.pTypeCode,
                                                  widget.radius.toString(),
                                                  data[0]["lat"].toString(),
                                                  data[0]["long"].toString(),
                                                  widget.vtypeId,
                                                  widget.amenities,
                                                  widget.isAllowOverNight,
                                                  (nearestData) {
                                                Navigator.pop(context);
                                                widget.callback({
                                                  "data": nearestData,
                                                  "latlng": LatLng(
                                                    double.parse(data[0]["lat"]
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
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            children: [
                                              Image(
                                                image: AssetImage(
                                                    "assets/dashboard_icon/parking.png"),
                                                width: 34,
                                                height: 34,
                                              ),
                                              Container(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomTitle(
                                                      text: suggestions[index]
                                                              .split("=structured=")[
                                                                  1]
                                                              .contains(",")
                                                          ? suggestions[index]
                                                              .split("=structured=")[
                                                                  1]
                                                              .split(",")[0]
                                                          : suggestions[index]
                                                              .split(
                                                                  "=structured=")[1],
                                                      maxlines: 1,
                                                      fontSize: 16,
                                                    ),
                                                    CustomParagraph(
                                                      text: suggestions[index]
                                                          .split("=Rechie=")[0],
                                                      fontSize: 12,
                                                      maxlines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      letterSpacing: -0.41,
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right,
                                                color: AppColor.primaryColor,
                                              )
                                            ],
                                          ),
                                        )),
                                    const Divider()
                                  ],
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ));
  }
}
