import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';

class TimeList extends StatefulWidget {
  final List<int> numbersList;
  final Function(int) onTap;

  TimeList({required this.numbersList, required this.onTap});

  @override
  _TimeListState createState() => _TimeListState();
}

class _TimeListState extends State<TimeList> {
  int? _selectedNumber;
  String inputTimeLabel = 'Input Time Duration';

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
      constraints: BoxConstraints(maxHeight: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 15,
            ),
            child: LabelText(text: 'Select Time Duration'),
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
                    });
                  },
                  child: Container(
                    color: _selectedNumber == number
                        ? Color(0xFF0078FF).withOpacity(0.2)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
    );
  }
}
