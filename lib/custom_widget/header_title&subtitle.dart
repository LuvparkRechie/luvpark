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
        CustomTitle(
          text: title,
        ),
        Container(
          height: 5,
        ),
        CustomParagraph(
          text: subTitle,
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
    return CustomTitle(
      text: text,
    );
  }
}
