import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class CustomListtile extends StatefulWidget {
  final String title, subTitle;

  final IconData leading, trailing;
  final Function onTap;

  const CustomListtile(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.leading,
      required this.trailing,
      required this.onTap});

  @override
  State<CustomListtile> createState() => _CustomListtileState();
}

class _CustomListtileState extends State<CustomListtile> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: InkWell(
          onTap: () {
            widget.onTap();
          },
          child: Container(
            padding: EdgeInsets.only(bottom: 10, top: 5),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.leading,
                  color: AppColor.primaryColor,
                ),
                Container(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomDisplayText(
                        label: widget.title,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 30, 30, 30),
                      ),
                      widget.subTitle.isEmpty
                          ? Container()
                          : CustomDisplayText(
                              label: widget.subTitle,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                    ],
                  ),
                ),
                Container(width: 10),
                Transform.rotate(
                  angle: -1.57, // 90 degrees in radians
                  child: Icon(
                    widget.trailing,
                    size: 24,
                    color: Colors.black54,
                    semanticLabel: 'Right-oriented Dropdown Arrow',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
