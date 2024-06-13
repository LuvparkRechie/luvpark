import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
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
  var parentWidget = <Widget>[];
  TextEditingController inputType = TextEditingController();

  @override
  void initState() {
    super.initState();
    getNumberOfHours();
  }

  void getNumberOfHours() {}

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
      child: Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: Row(
                children: [
                  Expanded(
                    child: CustomDisplayText(
                      label: 'Booking Duration',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Iconsax.close_circle,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
            CustomDisplayText(
              label:
                  'Please ${int.parse(widget.maxHours.toString()) != 0 ? "choose or " : ""} enter your desired parking duration.',
              color: Colors.grey,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
            CustomTextField(
              labelText: "Input number of hours",
              controller: inputType,
              keyboardType: TextInputType.number,
              onChange: (value) {
                inputType.text = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

                if (value.isNotEmpty &&
                    int.parse(value) > int.parse(widget.maxHours.toString()) &&
                    int.parse(widget.maxHours.toString()) != 0) {
                  showAlertDialog(context, "LuvPark",
                      "Booking limit is up to ${widget.maxHours.toString()} hours only.",
                      () {
                    Navigator.pop(context);
                    setState(() {
                      inputType.text = inputType.text
                          .substring(0, inputType.text.length - 1);
                      inputType.selection = TextSelection.fromPosition(
                          TextPosition(offset: inputType.text.length));
                      _selectedNumber = int.parse(inputType.text);
                    });
                  });
                }
                setState(() {
                  _selectedNumber =
                      inputType.text.isEmpty ? null : int.parse(inputType.text);
                });
              },
            ),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                List<Widget> rows = [];
                for (int i = 0; i < widget.numbersList.length; i += 3) {
                  List<Widget> rowWidgets = [];
                  for (int j = i;
                      j < i + 3 && j < widget.numbersList.length;
                      j++) {
                    rowWidgets.add(
                      numberHoursWidget(widget.numbersList, j),
                    );
                  }
                  if (i + 3 >= widget.numbersList.length) {
                    int emptyWidgetsCount = 3 - rowWidgets.length;
                    for (int k = 0; k < emptyWidgetsCount; k++) {
                      rowWidgets.add(
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: 7.0, bottom: 10),
                            child: Container(), // Empty container for spacing
                          ),
                        ),
                      );
                    }
                  }

                  rows.add(
                    Row(
                      children: rowWidgets,
                    ),
                  );
                }
                return Column(
                  children: rows,
                );
              },
            ),
            Container(
              height: 50,
            ),
            CustomButton(
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
            Builder(
              builder: (context) {
                if (MediaQuery.of(context).viewInsets.bottom != 0) {
                  return Container(
                    height: Variables.screenSize.height * .08 +
                        MediaQuery.of(context).viewInsets.bottom / 2,
                  );
                } else {
                  return Container(
                    height: 30,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget numberHoursWidget(data, index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 7.0, bottom: 10),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedNumber = data[index];
              inputType.text = _selectedNumber.toString();
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: _selectedNumber == data[index]
                  ? Color(0xFF0078FF)
                  : Colors.grey.shade200,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomDisplayText(
                  label: '${data[index]} ${data[index] > 1 ? "hrs" : "hr"}',
                  fontWeight: FontWeight.w600,
                  color: _selectedNumber == data[index]
                      ? Colors.white
                      : Colors.black,
                ),
                Container(width: 5),
                Icon(
                  Iconsax.clock,
                  color: _selectedNumber == data[index]
                      ? Colors.white
                      : Colors.black,
                  size: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
