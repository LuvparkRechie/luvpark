import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/color_component.dart';

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
            ? GoogleFonts.manrope(
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

class CustomTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final double letterSpacing;
  final int? maxlines;
  final double wordspacing;
  final TextAlign? textAlign;
  final double? height;

  const CustomTitle({
    super.key,
    required this.text,
    this.fontSize = 16.0,
    this.color = Colors.black87,
    this.fontWeight = FontWeight.w700,
    this.fontStyle = FontStyle.normal,
    this.letterSpacing = -1,
    this.maxlines,
    this.height,
    this.wordspacing = 2, // Set Normal to 4
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: GoogleFonts.manrope(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          wordSpacing: wordspacing,
          height: height ?? height),
      maxLines: maxlines,
      textAlign: textAlign,
    );
  }
}

class CustomParagraph extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final double letterSpacing;
  final double? height;
  final double wordspacing;
  final int? maxlines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  const CustomParagraph({
    super.key,
    required this.text,
    this.fontSize = 14.0,
    this.color,
    this.height,
    this.fontWeight = FontWeight.w600,
    this.fontStyle = FontStyle.normal,
    this.letterSpacing = 0.0,
    this.maxlines,
    this.wordspacing = 4,
    this.textAlign,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: GoogleFonts.manrope(
        fontSize: fontSize,
        color: color ?? AppColor.paragraphColor,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        height: height ?? height,
      ),
      textAlign: textAlign,
      maxLines: maxlines,
      overflow: overflow,
    );
  }
}

class CustomLinkLabel extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final double letterSpacing;
  final double wordspacing;
  final int? maxlines;
  final TextAlign? textAlign;

  const CustomLinkLabel({
    super.key,
    required this.text,
    this.fontSize = 14.0,
    this.color = Colors.white,
    this.fontWeight = FontWeight.w700,
    this.fontStyle = FontStyle.normal,
    this.letterSpacing = 0.0,
    this.maxlines,
    this.wordspacing = 0,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: GoogleFonts.manrope(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
      ),
      textAlign: textAlign,
      maxLines: maxlines,
    );
  }
}
