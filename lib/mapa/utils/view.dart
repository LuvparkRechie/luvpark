import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/no_internet.dart';
import 'package:luvpark_get/custom_widgets/page_loader.dart';

import 'controller.dart';

class FilterMap extends GetView<FilterMapController> {
  const FilterMap({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(FilterMapController());
    return Scaffold(
      appBar: CustomAppbar(
        title: "Map Filter",
        titleSize: 16,
        action: [
          InkWell(
            onTap: () {
              if (controller.filterParam[0]["ovp"]!.isEmpty &&
                  controller.filterParam[0]["amen"]!.isEmpty &&
                  controller.filterParam[0]["vh_type"]!.isEmpty &&
                  controller.filterParam[0]["park_type"]!.isEmpty) {
                return;
              }

              Get.back();
              controller.arguments(controller.filterParam);
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: CustomParagraph(
                  text: "Apply",
                  fontWeight: FontWeight.w700,
                  color: AppColor.primaryColor,
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          color: AppColor.bodyColor,
          child: StretchingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            child: Obx(() => !controller.isNetConn.value
                ? Center(
                    child: NoInternetConnected(
                      onTap: controller.loadData,
                    ),
                  )
                : controller.isLoadingPage.value
                    ? const PageLoader()
                    : ListView(
                        padding: const EdgeInsets.all(15),
                        children: [
                          const CustomParagraph(
                            text: "Overnight Parking",
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                          Container(height: 20),
                          Row(
                            children:
                                List.generate(controller.items.length, (index) {
                              return InkWell(
                                onTap: () {
                                  controller.filterParam.value =
                                      controller.filterParam.map((e) {
                                    e["ovp"] = controller.items[index]["value"];
                                    return e;
                                  }).toList();
                                  controller.selectedOvp.value = index;
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 13, vertical: 7),
                                    decoration: BoxDecoration(
                                      color:
                                          controller.selectedOvp.value == index
                                              ? AppColor.primaryColor
                                              : AppColor.primaryColor
                                                  .withOpacity(.1),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(15), // Rounded corners
                                      ),
                                    ),
                                    child: CustomParagraph(
                                      text: controller.items[index]["text"],
                                      color:
                                          controller.selectedOvp.value == index
                                              ? Colors.white
                                              : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          Container(height: 10),
                          Divider(
                            color: Colors.grey.shade300,
                          ),
                          Container(height: 10),
                          const CustomParagraph(
                            text: "Radius",
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: controller.currentDistance.value,
                                  min: double.parse(
                                      controller.radiusData.first["value"]),
                                  max: double.parse(
                                      controller.radiusData.last["value"]),
                                  divisions: 1998,
                                  label: controller.labelDistance.value,
                                  onChanged: (value) {
                                    controller.onPickDistance(value);
                                    controller.filterParam.value =
                                        controller.filterParam.map((e) {
                                      e["radius"] = controller
                                          .currentDistance.value
                                          .roundToDouble()
                                          .toString();
                                      return e;
                                    }).toList();
                                  },
                                ),
                              ),
                              Text(
                                controller.labelDistance.value,
                                style:
                                    paragraphStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),

                          Divider(
                            color: Colors.grey.shade300,
                          ),

                          const CustomParagraph(
                            text: "Vehicle Type",
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),

                          buildRadioOptions(),
                          Container(height: 10),
                          Divider(
                            color: Colors.grey.shade300,
                          ),
                          Container(height: 10),
                          const CustomParagraph(
                            text: "Parking Type",
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),

                          buildFilterChips(),
                          Container(height: 10),
                          Divider(
                            color: Colors.grey.shade300,
                          ),
                          Container(height: 10),

                          //Amenities
                          const CustomParagraph(
                            text: "Amenities",
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),

                          buildFilterChipsAmenities(),
                          Container(height: 10),
                          Divider(
                            color: Colors.grey.shade300,
                          ),
                          Container(height: 10),
                        ],
                      )),
          ),
        ),
      ),
    );
  }

  Widget buildRadioOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < controller.vhTypeData.length; i++)
          SizedBox(
            height: 30,
            child: RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: CustomParagraph(
                text: controller.vhTypeData[i]["text"],
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              value: controller.vhTypeData[i]["value"].toString(),
              groupValue: controller.selectedVehicleType.value,
              activeColor: AppColor.primaryColor,
              onChanged: (String? value) {
                controller.onRadioChanged(value!);
                controller.filterParam.value = controller.filterParam.map((e) {
                  e["vh_type"] = value.toString();
                  return e;
                }).toList();
              },
            ),
          ),
        SizedBox(
          height: 30,
          child: RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: const CustomParagraph(
              text: "All",
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            value: "",
            groupValue: controller.selectedVehicleType.value,
            activeColor: AppColor.primaryColor,
            onChanged: (String? value) {
              controller.onRadioChanged(value!);
              controller.filterParam.value = controller.filterParam.map((e) {
                e["vh_type"] = value.toString();
                return e;
              }).toList();
            },
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  Widget buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(spacing: 10.0, children: [
          for (int i = 0; i < controller.parkTypeData.length; i++)
            FilterChip(
              checkmarkColor: Colors.white,
              backgroundColor: AppColor.primaryColor.withOpacity(.1),
              label: CustomParagraph(
                text: controller.parkTypeData[i]["parking_type_name"],
                color: controller.sfPt.contains(controller.parkTypeData[i]
                            ["parking_type_code"]
                        .toString())
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              selected: controller.sfPt.contains(
                  controller.parkTypeData[i]["parking_type_code"].toString()),
              onSelected: (bool selected) {
                if (selected) {
                  controller.sfPt.add(controller.parkTypeData[i]
                          ["parking_type_code"]
                      .toString());
                } else {
                  controller.sfPt.remove(controller.parkTypeData[i]
                          ["parking_type_code"]
                      .toString());
                }
                String filterVtype = controller.sfPt.join('|');
                controller.filterParam.value = controller.filterParam.map((e) {
                  e["park_type"] = filterVtype.toString();
                  return e;
                }).toList();
              },

              selectedColor: AppColor
                  .primaryColor, // Optional: Change background color when selected
            ),
        ]),
      ],
    );
  }

  Widget buildFilterChipsAmenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(spacing: 10.0, children: [
          for (int i = 0; i < controller.amenitiesData.length; i++)
            FilterChip(
              checkmarkColor: Colors.white,
              backgroundColor: AppColor.primaryColor.withOpacity(.1),
              label: CustomParagraph(
                text: controller.amenitiesData[i]["parking_amenity_desc"],
                color: controller.sfAmen.contains(controller.amenitiesData[i]
                            ["parking_amenity_code"]
                        .toString())
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              selected: controller.sfAmen.contains(controller.amenitiesData[i]
                      ["parking_amenity_code"]
                  .toString()),
              onSelected: (bool selected) {
                if (selected) {
                  controller.sfAmen.add(controller.amenitiesData[i]
                          ["parking_amenity_code"]
                      .toString());
                } else {
                  controller.sfAmen.remove(controller.amenitiesData[i]
                          ["parking_amenity_code"]
                      .toString());
                }
                String filterAmen = controller.sfAmen.join('|');
                controller.filterParam.value = controller.filterParam.map((e) {
                  e["amen"] = filterAmen.toString();
                  return e;
                }).toList();
              },

              selectedColor: AppColor
                  .primaryColor, // Optional: Change background color when selected
            ),
        ]),
      ],
    );
  }
}
