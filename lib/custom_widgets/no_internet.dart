import 'package:flutter/material.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';

class NoInternetConnected extends StatelessWidget {
  final Function? onTap;
  final double? width;
  final double? height;
  const NoInternetConnected({
    super.key,
    this.onTap,
    this.width = 220,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 20,
          ),
          Image.asset(
              width: width, height: height, "assets/images/nosignaltower.png"),
          Container(
            height: height == null ? 55 : height! * .30,
          ),
          const CustomParagraph(
            text: "luvpark",
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Color(0xFF1E1E1E),
          ),
          Container(
            height: 10,
          ),
          const CustomParagraph(
              text: "Seems like you’ve lost connection.",
              fontWeight: FontWeight.w400,
              fontSize: 16),
          Container(
            height: 25,
          ),
          if (onTap != null)
            TextButton(
                onPressed: () {
                  onTap!();
                },
                child: const CustomLinkLabel(text: "Reconnect"))
        ],
      ),
    );
  }
}
