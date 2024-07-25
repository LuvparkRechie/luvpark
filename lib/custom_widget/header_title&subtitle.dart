// ignore: file_names
import 'package:flutter/material.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class HeaderLabel extends StatelessWidget {
  const HeaderLabel({super.key, required this.title, required this.subTitle});

  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDisplayText(
          label: title,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 16,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Container(
          height: 5,
        ),
        CustomDisplayText(
          label: subTitle,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
          fontSize: 14,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Container(
          height: 20,
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class LabelText extends StatelessWidget {
  late String text;
  LabelText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomDisplayText(
      label: text,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      fontSize: 16,
    );
  }
}
