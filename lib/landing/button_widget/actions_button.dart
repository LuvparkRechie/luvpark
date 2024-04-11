import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ButtonWidget extends StatefulWidget {
  String image;
  String labelText;
  Function onTap;
  Color color;
  ButtonWidget(
      {super.key,
      required this.image,
      required this.labelText,
      required this.onTap,
      required this.color});

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.20,
        child: Column(
          children: [
            Image(
              image: AssetImage(widget.image),
              height: 30,
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                widget.labelText,
                style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                    color: Colors.black,
                    letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        widget.onTap();
      },
    );
  }
}
