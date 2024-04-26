import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';

class TimeList extends StatefulWidget {
  final List<int> numbersList;
  final String maxHours;
  final Function(int) onTap;

  TimeList(
      {required this.numbersList, required this.onTap, required this.maxHours});

  @override
  _TimeListState createState() => _TimeListState();
}

class _TimeListState extends State<TimeList> {
  int? _selectedNumber;
  String inputTimeLabel = 'Input Time Duration';
  TextEditingController inputType = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      constraints: BoxConstraints(
          maxHeight: 400 + (MediaQuery.of(context).viewInsets.bottom / 2)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 5),
              child: LabelText(text: 'Select Time Duration'),
            ),
            CustomTextField(
              labelText: "No of hours",
              controller: inputType,
              keyboardType: TextInputType.number,
              onChange: (value) {
                inputType.text = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

                if (value.isNotEmpty &&
                    int.parse(value) > int.parse(widget.maxHours.toString())) {
                  showAlertDialog(context, "LuvPark",
                      "Booking limit is up to ${widget.maxHours.toString()} hours only.",
                      () {
                    inputType.text =
                        inputType.text.substring(0, inputType.text.length - 1);
                    inputType.selection = TextSelection.fromPosition(
                        TextPosition(offset: inputType.text.length));
                    setState(() {
                      _selectedNumber = int.parse(inputType.text);
                    });
                    Navigator.pop(context);
                  });
                }
                setState(() {
                  _selectedNumber = int.parse(inputType.text);
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.numbersList.length,
                itemBuilder: (context, index) {
                  final number = widget.numbersList[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedNumber = number;
                        inputType.text = "";
                      });
                    },
                    child: Container(
                      color: _selectedNumber == number
                          ? Color(0xFF0078FF).withOpacity(0.2)
                          : null,
                      child: ListTile(
                        title: CustomDisplayText(
                          label: '$number ${number > 1 ? "Hours" : "Hour"}',
                          fontWeight: FontWeight.w600,
                        ),
                        trailing: _selectedNumber == number
                            ? Icon(
                                Icons.check,
                                color: Color(0xFF0078FF),
                              )
                            : SizedBox(),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomButton(
                onTap: () {
                  if (_selectedNumber != null) {
                    setState(() {
                      inputTimeLabel =
                          "$_selectedNumber ${_selectedNumber! > 1 ? "Hours" : "Hour"}";
                    });
                    widget.onTap(_selectedNumber!);
                    Navigator.pop(context);
                  }
                },
                label: 'Confirm',
                color: _selectedNumber != null
                    ? AppColor.primaryColor
                    : AppColor.primaryColor.withOpacity(.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
