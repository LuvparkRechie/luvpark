// ignore: must_be_immutable
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class UpdateProfStep1 extends StatefulWidget {
  final TextEditingController firstName,
      middleName,
      lastName,
      bday,
      email,
      gender,
      civil;

  final GlobalKey<FormState> formKey;
  final VoidCallback onNextPage;

  const UpdateProfStep1(
      {super.key,
      required this.onNextPage,
      required this.firstName,
      required this.middleName,
      required this.lastName,
      required this.bday,
      required this.email,
      required this.gender,
      required this.civil,
      required this.formKey});

  @override
  State<UpdateProfStep1> createState() => _RegistrationPage1State();
}

class _RegistrationPage1State extends State<UpdateProfStep1> {
  int tabIndex = 0;
  String? ddCivil;
  bool loading = true;
  // ignore: prefer_typing_uninitialized_variables
  var akongP;
  List civilStatusData = [
    {"status": "Single", "value": "S"},
    {"status": "Married", "value": "M"},
    {"status": "Widowed", "value": "W"},
    {"status": "Divorced", "value": "D"},
  ];
  @override
  void initState() {
    super.initState();
    getAccountData();
  }

  void getAccountData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    akongP = prefs.getString(
      'userData',
    );
    akongP = jsonDecode(akongP!);

    setState(() {
      ddCivil = (widget.civil.text == 'null' || widget.civil.text.isEmpty)
          ? null
          : widget.civil.text;
    });

    setState(() {
      if (widget.gender.text == "F") {
        tabIndex = 1;
      } else {
        tabIndex = 0;
      }
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const HeaderLabel(
                title: "Your Information",
                subTitle: "Kindly provide your details in the space below.",
              ),
              CustomTextField(
                title: "First Name",
                labelText: "First Name",
                controller: widget.firstName,
                onTap: () async {},
                onChange: (value) {
                  if (value.isNotEmpty) {
                    widget.firstName.value = TextEditingValue(
                        text: Variables.capitalizeAllWord(value),
                        selection: widget.firstName.selection);
                  }
                },
              ),
              CustomTextField(
                title: "Middle Name",
                labelText: "Middle Name (Optional)",
                controller: widget.middleName,
                onTap: () async {},
                onChange: (value) {
                  if (value.isNotEmpty) {
                    widget.middleName.value = TextEditingValue(
                        text: Variables.capitalizeAllWord(value),
                        selection: widget.middleName.selection);
                  }
                },
              ),
              CustomTextField(
                labelText: "Last Name",
                title: "Last Name",
                controller: widget.lastName,
                onTap: () async {},
                onChange: (value) {
                  if (value.isNotEmpty) {
                    widget.lastName.value = TextEditingValue(
                        text: Variables.capitalizeAllWord(value),
                        selection: widget.lastName.selection);
                  }
                },
              ),
              CustomTextField(
                title: "Email",
                labelText: "Email",
                controller: widget.email,
              ),
              LabelText(text: "Gender"),
              Container(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    tabIndex = 0;
                    widget.gender.text = "M";
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.circle,
                            color: tabIndex == 0
                                ? AppColor.primaryColor
                                : AppColor.bodyColor,
                            size: 15,
                          ),
                        ),
                      ),
                      Container(
                        width: 10,
                      ),
                      Expanded(
                          child: CustomDisplayText(
                        label: "Male",
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ))
                    ],
                  ),
                ),
              ),
              Container(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    tabIndex = 1;
                    widget.gender.text = "F";
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.circle,
                            color: tabIndex == 1
                                ? AppColor.primaryColor
                                : AppColor.bodyColor,
                            size: 15,
                          ),
                        ),
                      ),
                      Container(
                        width: 10,
                      ),
                      Expanded(
                          child: CustomDisplayText(
                        label: "Female",
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ))
                    ],
                  ),
                ),
              ),

              ///
              Container(
                height: 20,
              ),
              CustomTextField(
                title: "Birth Date",
                labelText: "YYYY-MM-DD",
                controller: widget.bday,
                onTap: () async {
                  setState(() {
                    _selectDate(context);
                  });
                },
                onChange: (value) {},
              ),
              Container(
                height: 10,
              ),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(5),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         DropdownButtonFormField(
              //           dropdownColor: Colors.white,
              //           padding: EdgeInsets.zero,
              //           decoration: const InputDecoration(
              //             //   constraints: BoxConstraints.tightFor(height: 60),

              //             constraints: BoxConstraints.tightFor(height: 50),

              //             focusedBorder: InputBorder.none,
              //             hintText: "Select your answer",
              //             border: InputBorder.none,
              //             enabledBorder: InputBorder.none,
              //           ),
              //           style: GoogleFonts.dmSans(
              //             color: Colors.grey,
              //             fontWeight: FontWeight.normal,
              //           ),
              //           value: ddCivil,
              //           onChanged: (String? newValue) {
              //             setState(() {
              //               ddCivil = newValue!;
              //               widget.civil.text = ddCivil!;
              //             });
              //           },
              //           isExpanded: true,
              //           items: civilStatusData.map((item) {
              //             return DropdownMenuItem(
              //                 value: item['value'].toString(),
              //                 child: CustomDisplayText(
              //                   label: item['status'],
              //                   color: Colors.black,
              //                   fontWeight: FontWeight.normal,
              //                 ));
              //           }).toList(),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField(
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: "Civil Status",
                        labelStyle: TextStyle(
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                        contentPadding:
                            const EdgeInsets.only(left: 17, right: 17),
                        constraints: BoxConstraints.tightFor(height: 50),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.15)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.15)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.15)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        hintText: "Select your answer",
                      ),
                      style: GoogleFonts.dmSans(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                      value: ddCivil,
                      onChanged: (String? newValue) {
                        setState(() {
                          ddCivil = newValue!;
                          widget.civil.text = ddCivil!;
                        });
                      },
                      isExpanded: true,
                      items: civilStatusData.map((item) {
                        return DropdownMenuItem(
                          value: item['value'].toString(),
                          child: Text(
                            item['status'],
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              Container(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  late DateTime dateTime;
  DateTime? selectedDate;
  DateTime? minimumDate;
  String parsedDate(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? datePicker = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 80),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
    );
    if (datePicker != null && datePicker != DateTime.now()) {
      widget.bday.clear();
      setState(() {
        selectedDate = datePicker;
      });

      // Check if the selected date is at least 12 years ago

      final today = DateTime.now();
      final age = today.year -
          selectedDate!.year -
          (today.month > selectedDate!.month ||
                  (today.month == selectedDate!.month &&
                      today.day >= selectedDate!.day)
              ? 0
              : 1);

      if (age < 12) {
        // ignore: use_build_context_synchronously
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Age Restriction'),
              content:
                  const Text('You must be at least 12 years old to proceed.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          dateTime = datePicker;
          widget.bday.text = parsedDate(dateTime.toString());
        });
      }
    }
  }
}
