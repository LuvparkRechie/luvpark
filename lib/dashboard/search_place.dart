import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                      label: "Search Parking Area",
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.search),
                        Container(width: 10),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search here',
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
                Container(height: 15),
                CustomDisplayText(label: "Results"),
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
                                                  print(
                                                      "searchedPlacessss $searchedPlace");
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
