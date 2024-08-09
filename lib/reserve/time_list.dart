import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  TextEditingController inpDisplay = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.numbersList.length >= 5
          ? Variables.screenSize.height * .60
          : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(7),
          topRight: Radius.circular(7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Iconsax.clock),
                    title: CustomTitle(text: "Booking Duration"),
                    subtitle: CustomParagraph(
                      text: Variables.timeNow(),
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Iconsax.close_circle,
                          color: Colors.grey,
                        )),
                  ),
                  CustomTextField(
                    labelText: "Input number of hours",
                    controller: inputType,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    keyboardType: Platform.isAndroid
                        ? TextInputType.number
                        : TextInputType.numberWithOptions(
                            signed: true, decimal: false),
                    onChange: (value) {
                      inputType.text =
                          value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                      inpDisplay.text =
                          value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

                      if (value.isNotEmpty &&
                          int.parse(value) >
                              int.parse(widget.maxHours.toString()) &&
                          int.parse(widget.maxHours.toString()) != 0) {
                        showAlertDialog(context, "LuvPark",
                            "Booking limit is up to ${widget.maxHours.toString()} hours only.",
                            () {
                          Navigator.pop(context);
                          setState(() {
                            inputType.text = inputType.text
                                .substring(0, inputType.text.length - 1);

                            inpDisplay.text = inputType.text
                                .substring(0, inputType.text.length - 1);
                            inpDisplay.text = inputType.text
                                .substring(0, inputType.text.length - 1);

                            inputType.selection = TextSelection.fromPosition(
                                TextPosition(offset: inputType.text.length));

                            _selectedNumber = int.parse(inputType.text);
                          });
                        });
                      }
                      setState(() {
                        _selectedNumber = inputType.text.isEmpty
                            ? null
                            : int.parse(inputType.text);
                      });
                    },
                  ),
                ],
              )),
          if (widget.numbersList.length > 0)
            if (widget.numbersList.length >= 5)
              Expanded(
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return numberHoursWidget(widget.numbersList, index);
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        height: 2,
                      );
                    },
                    itemCount: widget.numbersList.length),
              ),
          if (widget.numbersList.length > 0)
            if (widget.numbersList.length < 5)
              for (int i = 0; i < widget.numbersList.length; i++)
                numberHoursWidget(widget.numbersList, i),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
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
    );
  }

  Widget numberHoursWidget(data, index) {
    return Container(
      color: _selectedNumber == data[index] ? Color(0xFFe8f3fe) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ListTile(
          onTap: () {
            setState(() {
              _selectedNumber = data[index];
              inputType.text =
                  "$_selectedNumber ${int.parse(_selectedNumber.toString()) > 1 ? "hours" : "hour"}";
            });
          },
          contentPadding: EdgeInsets.zero,
          title: CustomParagraph(
            text: '${data[index]} ${data[index] > 1 ? "hours" : "hour"}',
            color: _selectedNumber == data[index]
                ? AppColor.primaryColor
                : Colors.black,
          ),
          trailing: _selectedNumber == data[index]
              ? Icon(Icons.check, color: AppColor.primaryColor)
              : null,
        ),
      ),
    );
  }
}
