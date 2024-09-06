import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';

class CustomTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
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
    this.color,
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
      style: titleStyle(
        fontSize: fontSize,
        color: color ?? const Color(0xFF131313),
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordspacing,
        height: height ?? height,
      ),
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
  final TextDecoration? textDecoration;

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
    this.textDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: paragraphStyle(
        fontSize: fontSize,
        color: color ?? AppColor.paragraphColor,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        height: height ?? height,
        textDecoration: textDecoration,
      ),
      textAlign: textAlign,
      maxLines: maxlines,
      overflow: overflow,
      minFontSize: 8,
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
    this.color,
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
      style: linkStyle(
        fontSize: fontSize,
        color: color ?? AppColor.primaryColor,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
      ),
      textAlign: textAlign,
      maxLines: maxlines,
    );
  }
}

// Style for link labels
TextStyle linkStyle({
  double fontSize = 14.0,
  Color? color,
  FontWeight fontWeight = FontWeight.w700,
  FontStyle fontStyle = FontStyle.normal,
  double letterSpacing = 0.0,
}) {
  return GoogleFonts.manrope(
    fontSize: fontSize,
    color: color ?? AppColor.primaryColor,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
  );
}

// Style for paragraphs
TextStyle paragraphStyle({
  double fontSize = 14.0,
  Color? color, // Default value if not provided
  FontWeight fontWeight = FontWeight.w600,
  FontStyle fontStyle = FontStyle.normal,
  double letterSpacing = 0.0,
  double? height,
  TextDecoration? textDecoration,
}) {
  return GoogleFonts.manrope(
    fontSize: fontSize,
    color: color ?? AppColor.paragraphColor,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    height: height,
    decoration: textDecoration,
  );
}

// Style for titles
TextStyle titleStyle({
  double? fontSize = 16.0,
  Color color = Colors.black87,
  FontWeight fontWeight = FontWeight.w700,
  FontStyle fontStyle = FontStyle.normal,
  double letterSpacing = -1.0,
  double wordSpacing = 2.0,
  double? height,
}) {
  return GoogleFonts.manrope(
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    height: height,
  );
}
