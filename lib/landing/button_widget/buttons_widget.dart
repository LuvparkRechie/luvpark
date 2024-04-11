import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ButtonsWidget extends StatefulWidget {
  IconData icons;
  String labelText;
  Function onTap;
  Color color;
  ButtonsWidget(
      {super.key,
      required this.icons,
      required this.labelText,
      required this.onTap,
      required this.color});

  @override
  State<ButtonsWidget> createState() => _ButtonsWidgetState();
}

class _ButtonsWidgetState extends State<ButtonsWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap();
      },
      child: Column(
        children: [
          Icon(
            widget.icons,
            color: const Color(0xFFffffff),
            size: MediaQuery.of(context).size.width * 0.05,
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              widget.labelText,
              style: const TextStyle(
                  fontFamily: 'Regular',
                  fontWeight: FontWeight.normal,
                  fontSize: 11,
                  color: Color(0xFFffffff)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
