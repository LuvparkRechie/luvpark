import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final int strength;
  final int currentStrength;

  const PasswordStrengthIndicator(
      {super.key, required this.strength, required this.currentStrength});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 7,
        decoration: BoxDecoration(
          color: strength <= currentStrength
              ? AppColor.primaryColor
              : Colors.grey.shade400,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(15),
            left: Radius.circular(
              15,
            ),
          ),
        ),
      ),
    );
  }
}
