import 'package:flutter/material.dart';

class MySeparator extends StatelessWidget {
  final double height;
  final double? width;
  final Color? color;

  const MySeparator(
      {super.key, this.width, this.height = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    final boxWidth = MediaQuery.of(context).size.width;
    const dashWidth = 5.0;
    final dashHeight = height;
    final dashCount = (boxWidth / (2 * dashWidth)).floor();
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        direction: Axis.horizontal,
        children: List.generate(dashCount, (_) {
          return SizedBox(
            width: dashWidth,
            height: dashHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(color: color!),
            ),
          );
        }),
      ),
    );
  }
}
