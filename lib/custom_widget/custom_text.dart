import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDisplayText extends StatelessWidget {
  final int? maxLines;
  final TextOverflow? overflow;
  final String label;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final TextDecoration? decoration;
  final double? letterSpacing, minFontsize, maxFontsize, wordSpacing;
  final FontStyle? fontStyle;
  final TextAlign? alignment;
  final List<double>? presetFontSizes;
  const CustomDisplayText(
      {super.key,
      this.color,
      this.fontSize,
      this.fontWeight,
      this.height,
      this.decoration,
      this.letterSpacing,
      required this.label,
      this.maxLines,
      this.overflow,
      this.alignment,
      this.presetFontSizes,
      this.minFontsize,
      this.wordSpacing,
      this.maxFontsize,
      this.fontStyle});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: AutoSizeText(
        label,
        style: Platform.isAndroid
            ? GoogleFonts.dmSans(
                color:
                    color ?? Colors.black, // Default to black if color is null
                fontSize: fontSize ?? 14,
                fontWeight: fontWeight ?? FontWeight.normal,
                height: height,
                letterSpacing: letterSpacing,
                decoration: decoration ?? TextDecoration.none,
                fontStyle: fontStyle ?? FontStyle.normal,
                wordSpacing: wordSpacing)
            : TextStyle(
                color:
                    color ?? Colors.black, // Default to black if color is null
                fontSize: fontSize ?? 14,
                fontWeight: fontWeight ?? FontWeight.normal,
                height: height,
                letterSpacing: letterSpacing,
                decoration: decoration ?? TextDecoration.none,
                fontStyle: fontStyle ?? FontStyle.normal,
                fontFamily: "SFProTextReg",
                wordSpacing: wordSpacing),
        textAlign: alignment,
        maxLines: maxLines,
        overflow: overflow,
        presetFontSizes: presetFontSizes,
        softWrap: true,
        minFontSize: 1,
        wrapWords: true,
      ),
    );
  }
}

class CustomDisplayTextkanit extends StatelessWidget {
  final String label;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final TextDecoration? decoration;
  final double? letterSpacing;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? alignment;
  final List<double>? presetFontSizes;
  final double? minFontsize;
  final double? maxFontsize;
  final FontStyle? fontStyle;

  const CustomDisplayTextkanit({
    Key? key,
    required this.label,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.decoration,
    this.letterSpacing,
    this.maxLines,
    this.overflow,
    this.alignment,
    this.presetFontSizes,
    this.minFontsize,
    this.maxFontsize,
    this.fontStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: AutoSizeText(
        label,
        style: GoogleFonts.kanit(
          textStyle: TextStyle(
            color: color,
            fontSize: fontSize ?? 14,
            fontWeight: fontWeight,
            height: height,
            letterSpacing: letterSpacing,
            decoration: decoration,
            fontStyle: fontStyle,
          ),
        ),
        minFontSize: 1,
        textAlign: alignment,
        maxLines: maxLines,
        overflow: overflow,
        presetFontSizes: presetFontSizes,
      ),
    );
  }
}
