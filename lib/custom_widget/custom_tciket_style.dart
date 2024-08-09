import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';

class TicketStyle extends StatelessWidget {
  const TicketStyle({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 25,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: 1,
                  child: Row(
                    children: List.generate(
                        700 ~/ 10,
                        (index) => Expanded(
                              child: Container(
                                color: index % 2 == 0
                                    ? Colors.grey
                                    : Theme.of(context).canvasColor,
                                height: 2,
                              ),
                            )),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
            left: -10,
            bottom: 0,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: AppColor.bodyColor,
            )),
        Positioned(
            right: -10,
            bottom: 0,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: AppColor.bodyColor,
            ))
      ],
    );
  }
}
