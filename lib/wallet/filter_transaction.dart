// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:luvpark/custom_widget/custom_button.dart';
// import 'package:luvpark/custom_widget/custom_parent_widget.dart';
// import 'package:luvpark/custom_widget/custom_text.dart';
// import 'package:luvpark/custom_widget/custom_textfield.dart';
// import 'package:luvpark/custom_widget/header_title&subtitle.dart';

// class FilterTrans extends StatefulWidget {
//   const FilterTrans({super.key, required this.callback});
//   final ValueChanged<Object> callback;

//   @override
//   State<FilterTrans> createState() => _FilterTransState();
// }

// class _FilterTransState extends State<FilterTrans> {
//   TextEditingController from = TextEditingController();
//   TextEditingController to = TextEditingController();
//   late DateTime dateTime;
//   final DateTime _date = DateTime.now();

//   @override
//   void initState() {
//     super.initState();
//     from = TextEditingController();
//     to = TextEditingController();
//   }

//   String parsedDate(String date) {
//     final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
//     final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
//     final DateTime displayDate = displayFormater.parse(date);
//     final String formatted = serverFormater.format(displayDate);
//     return formatted;
//   }

// // ignore: unused_element
//   Future<void> _selectDate(BuildContext context, bool isFrom) async {
//     DateTime? datePicker = await showDatePicker(
//       context: context,
//       initialDate: _date,
//       firstDate: DateTime(1950),
//       lastDate: _date,
//       initialDatePickerMode: DatePickerMode.day,
//     );
//     if (datePicker != null && datePicker != _date) {
//       setState(() {
//         dateTime = datePicker;

//         if (isFrom) {
//           from.text = parsedDate(dateTime.toString());
//         } else {
//           to.text = parsedDate(dateTime.toString());
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomParent1Widget(
//         canPop: true,
//         appBarheaderText: "Filter Transaction",
//         appBarIconClick: () {
//           Navigator.of(context).pop();
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Center(
//               child: Image(
//                 height: 150,
//                 width: 150,
//                 image: AssetImage("assets/images/filter_calendar.png"),
//               ),
//             ),
//             Container(
//               height: 20,
//             ),
//             CustomDisplayText(
//               label: "Transaction Period",
//               color: Colors.black,
//               fontWeight: FontWeight.w600,
//               fontSize: 20,
//             ),
//             Container(
//               height: 5,
//             ),
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   LabelText(text: "Start Date"),
//                   CustomTextField(
//                     labelText: "From",
//                     controller: from,
//                     isReadOnly: true,
//                     suffixIcon: Icons.calendar_month,
//                     onTap: () {
//                       _selectDate(context, true);
//                     },
//                     onIconTap: () {
//                       _selectDate(context, true);
//                     },
//                   ),
//                   LabelText(text: "End Date"),
//                   CustomTextField(
//                     labelText: "To",
//                     controller: to,
//                     isReadOnly: true,
//                     suffixIcon: Icons.calendar_month,
//                     onTap: () {
//                       _selectDate(context, false);
//                     },
//                     onIconTap: () {
//                       _selectDate(context, false);
//                     },
//                   ),
//                   Container(
//                     height: 30,
//                   ),
//                   Center(
//                     child: CustomButton(
//                         label: "Apply",
//                         onTap: () {
//                           if (from.text.isEmpty || to.text.isEmpty) {
//                             return;
//                           } else {
//                             FocusManager.instance.primaryFocus!.unfocus();
//                             widget.callback(
//                                 {"date_from": from.text, "date_to": to.text});
//                             Navigator.pop(context);
//                           }
//                         }),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ));
//   }
// }

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/textstyle.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';

class FilterTrans extends StatefulWidget {
  const FilterTrans({super.key, required this.callback});
  final ValueChanged<Object> callback;

  @override
  State<FilterTrans> createState() => _FilterTransState();
}

class _FilterTransState extends State<FilterTrans> {
  TextEditingController from = TextEditingController();
  TextEditingController to = TextEditingController();
  late DateTime dateTime;
  final DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    from = TextEditingController();
    to = TextEditingController();
  }

  String parsedDate(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
  }

// ignore: unused_element
  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final List<DateTime?>? pickedDates = await showCalendarDatePicker2Dialog(
      useSafeArea: true,
      config: CalendarDatePicker2WithActionButtonsConfig(
        okButton: CustomDisplayText(
          color: AppColor.primaryColor,
          fontWeight: FontWeight.bold,
          label: 'APPLY',
        ),
        cancelButton: CustomDisplayText(
          label: 'CANCEL',
          fontWeight: FontWeight.bold,
          color: AppColor.primaryColor,
        ),
        firstDate: DateTime(1950),
        lastDate: _date,
        controlsTextStyle: CustomTextStyle(
          color: Colors.black,
        ),
      ),
      dialogSize: const Size(325, 400),
      context: context,
    );

    if (pickedDates != null && pickedDates.isNotEmpty) {
      final DateTime pickedDate = pickedDates.first!;

      setState(() {
        dateTime = pickedDate;

        if (isFrom) {
          from.text = parsedDate(dateTime.toString());
        } else {
          to.text = parsedDate(dateTime.toString());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: CustomDisplayText(
            label: "Transaction Period",
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Container(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelText(text: "Start Date"),
              CustomTextField(
                labelText: "From",
                controller: from,
                isReadOnly: true,
                suffixIcon: Iconsax.calendar_1,
                onTap: () {
                  _selectDate(context, true);
                },
                onIconTap: () {
                  _selectDate(context, true);
                },
              ),
              LabelText(text: "End Date"),
              CustomTextField(
                labelText: "To",
                controller: to,
                isReadOnly: true,
                suffixIcon: Iconsax.calendar_1,
                onTap: () {
                  _selectDate(context, false);
                },
                onIconTap: () {
                  _selectDate(context, false);
                },
              ),
              Container(
                height: 30,
              ),
              Center(
                child: CustomButton(
                    label: "Apply",
                    onTap: () {
                      if (from.text.isEmpty || to.text.isEmpty) {
                        return;
                      } else {
                        FocusManager.instance.primaryFocus!.unfocus();
                        widget.callback(
                            {"date_from": from.text, "date_to": to.text});
                        Navigator.pop(context);
                      }
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
