import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';

class FilterMap extends StatefulWidget {
  const FilterMap({Key? key}) : super(key: key);

  @override
  State<FilterMap> createState() => _FilterMapState();
}

class _FilterMapState extends State<FilterMap> {
  List<String> vehicleType = [
    '3W / 4W Light Vehicles',
    'Motorcycle',
    'Delivery Vans',
  ];
  List<String> amenities = [
    "with CCTV",
    "Concrete Floor",
    "With Security",
    "Covered / Shaded",
    "Grass Area",
    "Asphalt Floor",
  ];
  List<String> parkingType = [
    "Valet",
    "Street",
    "Commercial",
    "Residential",
    "Building",
    "Illegal",
  ];

  String? selectedVehicleType;
  List<String> selectedFilters = [];

  @override
  Widget build(BuildContext context) {
    return CustomParentWidgetV2(
      appBarHeaderText: 'Map Filter',
      appBarIconClick: () {
        Navigator.pop(context);
      },
      bodyColor: Color.fromARGB(255, 249, 248, 248),
      child: Container(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        20,
                      ),
                    ),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  child: ListView(
                    padding: EdgeInsets.all(16.0),
                    children: [
                      SizedBox(height: 10),
                      buildRadioOptions('Vehicle Type', vehicleType),
                      SizedBox(height: 20),
                      buildFilterChips('Amenities', amenities),
                      SizedBox(height: 20),
                      buildFilterChips('Parking Type', parkingType),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomButton(
                    label: 'Apply Filters',
                    onTap: () {
                      print('Selected Vehicle Type: $selectedVehicleType');
                      print('Selected Filters: $selectedFilters');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRadioOptions(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(text: title),
        SizedBox(height: 8.0),
        Column(
          children: options.map((option) {
            return SizedBox(
              height: 40,
              child: RadioListTile<String>(
                title: CustomDisplayText(label: option),
                value: option,
                groupValue: selectedVehicleType,
                onChanged: (String? value) {
                  setState(() {
                    selectedVehicleType = value;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildFilterChips(String title, List<String> filters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(text: title),
        SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: filters.map((filter) {
            return FilterChip(
              checkmarkColor: Colors.white,
              backgroundColor: Color.fromARGB(255, 225, 223, 223),
              label: CustomDisplayText(label: filter),
              selected: selectedFilters.contains(filter),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedFilters.add(filter);
                  } else {
                    selectedFilters.remove(filter);
                  }
                });
              },
              labelStyle: TextStyle(
                color: selectedFilters.contains(filter)
                    ? Colors.white
                    : Colors.black, // Change text color based on selection
              ),
              selectedColor: AppColor
                  .primaryColor, // Optional: Change background color when selected
            );
          }).toList(),
        ),
      ],
    );
  }
}
