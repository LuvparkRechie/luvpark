// ignore: must_be_immutable
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';

enum AppState {
  free,
  picked,
  cropped,
}

// ignore: must_be_immutable
class RegistrationPage2 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  String image;
  final TextEditingController fname, mname, lname, gender, birthday;
  RegistrationPage2({
    super.key,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.fname,
    required this.mname,
    required this.lname,
    required this.gender,
    required this.birthday,
    required this.image,
    required this.formKey,
  });

  @override
  State<RegistrationPage2> createState() => _RegistrationPage2State();
}

class _RegistrationPage2State extends State<RegistrationPage2> {
  String selectedGender = 'male';
  String anserLabel = "Select your answer";
  bool isValidatedGender = false;
  bool isButtonTapped = false;
  AppState? state;
  File? imageFile;

  //date
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

// ignore: unused_element
  Future<void> _selectDate(BuildContext context) async {
    DateTime? datePicker = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 80),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
    );
    if (datePicker != null && datePicker != DateTime.now()) {
      widget.birthday.clear();
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
          widget.birthday.text = parsedDate(dateTime.toString());
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.gender.text.isEmpty) {
      widget.gender.text = selectedGender;
    } else {
      widget.gender.text = widget.gender.text;
      selectedGender = widget.gender.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const HeaderLabel(
              title: "Enter your personal info",
              subTitle: "Please provide your personal information to proceed.",
            ),
            LabelText(text: "First Name"),
            CustomTextField(
              labelText: "First Name",
              controller: widget.fname,
              onTap: () async {},
              onChange: (value) {
                if (value.isNotEmpty) {
                  widget.fname.value = TextEditingValue(
                      text: Variables.capitalizeAllWord(value),
                      selection: widget.fname.selection);
                }
              },
            ),
            LabelText(text: "Middle Name"),
            CustomTextField(
              labelText: "Middle Name (Optional)",
              controller: widget.mname,
              onTap: () async {},
              onChange: (value) {
                if (value.isNotEmpty) {
                  widget.mname.value = TextEditingValue(
                      text: Variables.capitalizeAllWord(value),
                      selection: widget.mname.selection);
                }
              },
            ),
            LabelText(text: "Last Name"),
            CustomTextField(
              labelText: "Last Name",
              controller: widget.lname,
              onTap: () async {},
              onChange: (value) {
                if (value.isNotEmpty) {
                  widget.lname.value = TextEditingValue(
                      text: Variables.capitalizeAllWord(value),
                      selection: widget.lname.selection);
                }
              },
            ),
            LabelText(text: "Birth Date"),
            CustomTextField(
              labelText: "1998-16-98",
              controller: widget.birthday,
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());

                setState(() {
                  _selectDate(context);
                });
              },
              onChange: (value) {},
            ),
            // LabelText(text: "Gender"),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: <Widget>[
            //     buildRadioButton('Male', 'male'),
            //     buildRadioButton('Female', 'female'),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildRadioButton(String label, String value) {
    return Row(
      children: <Widget>[
        Radio(
          value: value,
          groupValue: selectedGender,
          onChanged: (String? value) {
            setState(() {
              selectedGender = value!;
            });
            widget.gender.text = selectedGender;
          },
        ),
        Text(label),
      ],
    );
  }
}
