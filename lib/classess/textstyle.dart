import 'package:flutter/material.dart';

class CustomTextStyle extends TextStyle {
  CustomTextStyle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    TextDecoration? decoration,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) : super(
            color: color,
            fontSize: fontSize ?? 14,
            fontFamily: "SFProTextReg",
            fontWeight: fontWeight,
            height: height,
            letterSpacing: letterSpacing,
            decoration: decoration,
            fontStyle: fontStyle);
}
