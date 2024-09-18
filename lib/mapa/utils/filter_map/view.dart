import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/no_internet.dart';
import 'package:luvpark_get/custom_widgets/page_loader.dart';

import '../../../custom_widgets/alert_dialog.dart';
import '../../../http/api_keys.dart';
import '../../../http/http_request.dart';

class FilterMap extends StatefulWidget {
  final Function cb;
  const FilterMap({Key? key, required this.cb}) : super(key: key);

  @override
  State<FilterMap> createState() => _FilterMapState();
}

class _FilterMapState extends State<FilterMap> {
  final List items = [
    {"text": "Allow Overnight", "value": "Y"},
    {"text": "No Overnight", "value": "N"},
    {"text": "Both", "value": ""},
  ];
  double currentDistance = 1.0;
  String labelDistance = "1km";

  bool isLoadingPage = true;
  bool isNetConn = true;
  List vhTypeData = [];
  List parkTypeData = [];
  List amenitiesData = [];
  List radiusData = [];
  List sfVt = [];
  List sfPt = [];
  List sfAmen = [];
  List<Map<String, String>> filterParam = [
    {"ovp": "", "radius": "", "vh_type": "", "park_type": "", "amen": ""}
  ];
  String? selectedVehicleType;
  int? selectedOvp;

  // Dependencies
  @override
  void initState() {
    super.initState();
    filterParam = filterParam.map((e) {
      e["radius"] = currentDistance.toStringAsFixed(2);
      return e;
    }).toList();

    loadData();
  }

  Future<void> onPickDistance(value) async {
    currentDistance = value;

    if ((currentDistance * 1000) > 1000) {
      labelDistance =
          "${(currentDistance * 1000).toDouble().round() / 1000} km";
    } else {
      labelDistance = "${(currentDistance * 1000).round()} m";
    }
    setState(() {});
  }

  Future<void> loadData() async {
    vhTypeData = [];
    isLoadingPage = true;
    setState(() {});
    const HttpRequest(api: ApiKeys.gApiLuvParkDDVehicleTypes)
        .get()
        .then((returnData) async {
      if (returnData == "No Internet") {
        isNetConn = false;
        isLoadingPage = false;
        setState(() {});
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });

        return;
      }
      if (returnData == null) {
        isNetConn = true;
        isLoadingPage = false;
        setState(() {});
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData["items"].length > 0) {
        vhTypeData = returnData["items"];
        setState(() {});
        loadParkingType();
      } else {
        CustomDialog().errorDialog(Get.context!, "luvpark", "No vehicle found",
            () {
          Get.back();
        });
      }
    });
  }

  Future<void> loadParkingType() async {
    parkTypeData = [];
    setState(() {});
    var returnData =
        await const HttpRequest(api: ApiKeys.gApiSubFolderGetParkingTypes)
            .get();

    if (returnData == "No Internet") {
      isNetConn = false;
      isLoadingPage = false;
      setState(() {});
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });

      return;
    }
    if (returnData == null) {
      isNetConn = true;
      isLoadingPage = false;
      setState(() {});
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }

    if (returnData["items"].length > 0) {
      parkTypeData = returnData["items"];
      setState(() {});
      loadAmenities();
    } else {
      CustomDialog().errorDialog(Get.context!, "luvpark", "No vehicle found",
          () {
        Get.back();
      });
    }
  }

  Future<void> loadAmenities() async {
    amenitiesData = [];
    setState(() {});
    var returnData =
        await const HttpRequest(api: ApiKeys.gApiSubFolderGetAllAmenities)
            .get();

    if (returnData == "No Internet") {
      isNetConn = false;
      isLoadingPage = false;
      setState(() {});
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });

      return;
    }
    if (returnData == null) {
      isNetConn = true;
      isLoadingPage = false;
      setState(() {});
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }

    if (returnData["items"].length > 0) {
      amenitiesData = returnData["items"];
      setState(() {});
      loadRadius();
    } else {
      CustomDialog().errorDialog(Get.context!, "luvpark", "No vehicle found",
          () {
        Get.back();
      });
    }
  }

  Future<void> loadRadius() async {
    radiusData = [];
    setState(() {});
    var returnData =
        await const HttpRequest(api: ApiKeys.gApiSubFolderGetDDNearest).get();

    if (returnData == "No Internet") {
      isNetConn = false;
      isLoadingPage = false;
      setState(() {});
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    if (returnData == null) {
      isNetConn = true;
      isLoadingPage = false;
      setState(() {});
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    isNetConn = true;
    isLoadingPage = false;
    setState(() {});
    if (returnData["items"].length > 0) {
      radiusData = returnData["items"];
      setState(() {});
    } else {
      CustomDialog().errorDialog(Get.context!, "luvpark", "No vehicle found",
          () {
        Get.back();
      });
    }
  }

  void onRadioChanged(String value) async {
    selectedVehicleType = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.0)), // Rounded top corners
      ),
      child: !isNetConn
          ? Center(
              child: NoInternetConnected(
                onTap: loadData,
              ),
            )
          : isLoadingPage
              ? const PageLoader()
              : StretchingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(overscroll: false),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //VEHICLE TYPE
                        Container(height: 20),
                        Center(
                          child: Container(
                            width: 71,
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(56),
                              color: const Color(0xffd9d9d9),
                            ),
                          ),
                        ),

                        Container(height: 20),
                        Expanded(
                            child: StretchingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomParagraph(
                                  text: "Vehicle Type",
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                ),
                                Container(height: 10),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      buildFilterOptions(),
                                    ],
                                  ),
                                ),
                                Container(height: 10),
                                //PARKING TYPE
                                const CustomParagraph(
                                  text: "Parking Type",
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                ),
                                Container(height: 10),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      buildFilterChips(),
                                    ],
                                  ),
                                ),
                                const CustomParagraph(
                                  text: "Radius",
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                ),
                                //RADIUS
                                Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: currentDistance,
                                        min: double.parse(
                                            radiusData.first["value"]),
                                        max: double.parse(
                                            radiusData.last["value"]),
                                        divisions: 1998,
                                        label: labelDistance,
                                        onChanged: (value) {
                                          onPickDistance(value);
                                          filterParam = filterParam.map((e) {
                                            e["radius"] = currentDistance
                                                .roundToDouble()
                                                .toString();
                                            return e;
                                          }).toList();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    Text(
                                      labelDistance,
                                      style: paragraphStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                //OVERNIGHT PARKING
                                const CustomParagraph(
                                  text: "Overnight Parking",
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.408,
                                  fontSize: 14,
                                ),
                                Container(height: 10),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children:
                                        List.generate(items.length, (index) {
                                      return InkWell(
                                        onTap: () {
                                          filterParam = filterParam.map((e) {
                                            e["ovp"] = items[index]["value"];
                                            return e;
                                          }).toList();
                                          selectedOvp = index;
                                          setState(() {});
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 7),
                                            decoration: BoxDecoration(
                                              color: selectedOvp == index
                                                  ? const Color(0xFFEDF7FF)
                                                  : const Color(0xFFE6EBF0),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(
                                                    7), // Rounded corners
                                              ),
                                            ),
                                            child: CustomParagraph(
                                              text: items[index]["text"],
                                              fontSize: 14,
                                              color: selectedOvp == index
                                                  ? const Color(0xFF0078FF)
                                                  : const Color(0xFFB6C1CC),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                Container(height: 10),

                                const Divider(
                                  color: Colors.grey,
                                ),
                                Container(height: 10),

                                //Amenities
                                const CustomParagraph(
                                  text: "Amenities",
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                ),
                                Container(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: buildFilterChipsAmenities(),
                                    ),
                                  ],
                                ),
                                Container(height: 5),
                                SizedBox(
                                  width: double.infinity,
                                  child: CustomButton(
                                    text: "Apply",
                                    onPressed: () {
                                      Get.back();
                                      widget.cb(filterParam);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget buildFilterOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (int i = 0; i < vhTypeData.length; i++)
          GestureDetector(
            onTap: () {
              bool isSelected =
                  sfVt.contains(vhTypeData[i]["value"].toString());

              if (isSelected) {
                sfVt.remove(vhTypeData[i]["value"].toString());
              } else {
                sfVt.add(vhTypeData[i]["value"].toString());
              }

              String filterVtype = sfVt.join('|');
              filterParam = filterParam.map((e) {
                e["vh_type"] = filterVtype.toString();
                return e;
              }).toList();

              setState(() {});
            },
            child: SizedBox(
              width: MediaQuery.of(Get.context!).size.width / 4,
              height: MediaQuery.of(Get.context!).size.width / 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      _getSvgForVehicle(
                        vhTypeData[i]["text"].toString(),
                        sfVt.contains(
                          vhTypeData[i]["value"].toString(),
                        ),
                      ),
                      width: 40.0,
                      height: 40.0,
                    ),
                    const SizedBox(height: 5.0),
                    CustomParagraph(
                      textAlign: TextAlign.center,
                      fontSize: 12,
                      text: vhTypeData[i]["text"].toString(),
                      color: sfVt.contains(vhTypeData[i]["value"].toString())
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getSvgForVehicle(String vhTypeText, bool isActive) {
    switch (vhTypeText) {
      case 'Large Vehicle':
        return isActive
            ? 'assets/map_filter/active/largevehicle_active.svg'
            : 'assets/map_filter/inactive/largevehicle_inactive.svg';
      case 'Motorcycle':
        return isActive
            ? 'assets/map_filter/active/motor_active.svg'
            : 'assets/map_filter/inactive/motor_inactive.svg';
      case 'Trikes and Cars':
        return isActive
            ? 'assets/map_filter/active/car_active.svg'
            : 'assets/map_filter/inactive/car_inactive.svg';
      default:
        return isActive
            ? 'assets/map_filter/active/car_active.svg'
            : 'assets/map_filter/inactive/car_inactive.svg';
    }
  }

  Widget buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          //spacing: 10.0,
          children: [
            for (int i = 0; i < parkTypeData.length; i++)
              GestureDetector(
                onTap: () {
                  bool isSelected = sfPt.contains(
                      parkTypeData[i]["parking_type_code"].toString());

                  if (isSelected) {
                    sfPt.remove(
                        parkTypeData[i]["parking_type_code"].toString());
                  } else {
                    sfPt.add(parkTypeData[i]["parking_type_code"].toString());
                  }

                  String filterVtype = sfPt.join('|');
                  filterParam = filterParam.map((e) {
                    e["park_type"] = filterVtype.toString();
                    return e;
                  }).toList();
                  setState(() {});
                },
                child: SizedBox(
                  width: MediaQuery.of(Get.context!).size.width / 4,
                  height: MediaQuery.of(Get.context!).size.width / 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          _getSvgForParkingType(
                            parkTypeData[i]["parking_type_name"],
                            sfPt.contains(parkTypeData[i]["parking_type_code"]
                                .toString()), // Determines active/inactive state
                          ),
                          width: 40.0,
                          height: 40.0,
                        ),
                        const SizedBox(height: 5.0),
                        CustomParagraph(
                          textAlign: TextAlign.center,
                          fontSize: 12,
                          text: capitalizeWords(
                            parkTypeData[i]["parking_type_name"].toString(),
                          ),
                          color: sfPt.contains(parkTypeData[i]
                                      ["parking_type_code"]
                                  .toString())
                              ? Colors.black // Black when selected
                              : Colors.grey, // Grey when not selected
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String capitalizeWords(String str) {
    return str.toLowerCase().split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _getSvgForParkingType(String ptText, bool isActive) {
    // Return active/inactive SVG based on selection state
    switch (ptText) {
      case 'STREET':
        return isActive
            ? 'assets/map_filter/active/street_active.svg'
            : 'assets/map_filter/inactive/street_inactive.svg';
      case 'COMMERCIAL':
        return isActive
            ? 'assets/map_filter/active/commercial_active.svg'
            : 'assets/map_filter/inactive/commercial_inactive.svg';
      case 'PRIVATE':
        return isActive
            ? 'assets/map_filter/active/private_active.svg'
            : 'assets/map_filter/inactive/private_inactive.svg';
      default:
        return isActive
            ? 'assets/map_filter/active/street_active.svg'
            : 'assets/map_filter/inactive/street_inactive.svg';
    }
  }

  Widget buildFilterChipsAmenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 5.0,
          alignment: WrapAlignment.center,
          children: [
            for (int i = 0; i < amenitiesData.length; i++)
              SizedBox(
                width: MediaQuery.of(Get.context!).size.width / 4,
                height: MediaQuery.of(Get.context!).size.width / 4,
                child: GestureDetector(
                  onTap: () {
                    bool isSelected = sfAmen.contains(
                        amenitiesData[i]["parking_amenity_code"].toString());

                    if (isSelected) {
                      sfAmen.remove(
                          amenitiesData[i]["parking_amenity_code"].toString());
                    } else {
                      sfAmen.add(
                          amenitiesData[i]["parking_amenity_code"].toString());
                    }

                    String filterAmen = sfAmen.join('|');
                    filterParam = filterParam.map((e) {
                      e["amen"] = filterAmen.toString();
                      return e;
                    }).toList();
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          _getSvgForAmenities(
                            amenitiesData[i]["parking_amenity_desc"],
                            sfAmen.contains(amenitiesData[i]
                                    ["parking_amenity_code"]
                                .toString()),
                          ),
                          width: 40.0,
                          height: 40.0,
                        ),
                        const SizedBox(height: 5.0),
                        CustomParagraph(
                          textAlign: TextAlign.center,
                          text: _capitalTextAmen(
                            amenitiesData[i]["parking_amenity_desc"].toString(),
                          ),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sfAmen.contains(amenitiesData[i]
                                      ["parking_amenity_code"]
                                  .toString())
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _getSvgForAmenities(String amenText, bool isActive) {
    switch (amenText) {
      case 'ASPHALT FLOOR':
        return isActive
            ? 'assets/map_filter/active/asphalt_active.svg'
            : 'assets/map_filter/inactive/asphalt_inactive.svg';
      case 'CONCRETE FLOOR':
        return isActive
            ? 'assets/map_filter/active/concrete_active.svg'
            : 'assets/map_filter/inactive/concrete_inactive.svg';
      case 'COVERED / SHADED':
        return isActive
            ? 'assets/map_filter/active/covered_active.svg'
            : 'assets/map_filter/inactive/covered_inactive.svg';
      case 'SAND AND GRAVEL':
        return isActive
            ? 'assets/map_filter/active/gravel_active.svg'
            : 'assets/map_filter/inactive/gravel_inactive.svg';
      case 'WITH CCTV':
        return isActive
            ? 'assets/map_filter/active/cctv_active.svg'
            : 'assets/map_filter/inactive/cctv_inactive.svg';
      case 'WITH SECURITY':
        return isActive
            ? 'assets/map_filter/active/security_active.svg'
            : 'assets/map_filter/inactive/security_inactive.svg';
      default:
        return isActive
            ? 'assets/map_filter/active/gravel_active.svg'
            : 'assets/map_filter/inactive/gravel_inactive.svg'; // Default icon
    }
  }

  String _capitalTextAmen(String amenText) {
    switch (amenText) {
      case 'ASPHALT FLOOR':
        return 'Asphalt Floor';
      case 'CONCRETE FLOOR':
        return 'Concrete Floor';
      case 'COVERED / SHADED':
        return 'Covered/ Shaded';
      case 'SAND  AND GRAVEL':
        return 'Sand and Gravel';
      case 'WITH CCTV':
        return 'With CCTV';
      case 'WITH SECURITY':
        return 'With Security';
      default:
        return 'DEFAULT';
    }
  }
}
