import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/custom_widgets/app_color.dart';

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
    this.letterSpacing = 0,
    this.maxlines,
    this.height,
    this.wordspacing = 2, // Set Normal to 4
    this.textAlign,
  });
//customtext
  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: titleStyle(
        fontSize: fontSize,
        color: color ?? AppColor.titleColor,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordspacing,
        height: height ?? height,
      ),
      maxLines: maxlines,
      textAlign: textAlign,
      minFontSize: 12,
      overflow: TextOverflow.ellipsis,
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
  final double? minFontSize;
  final TextDecoration? textDecoration;

  const CustomParagraph({
    super.key,
    required this.text,
    this.fontSize = 14.0,
    this.color,
    this.height,
    this.fontWeight = FontWeight.w400,
    this.fontStyle = FontStyle.normal,
    this.letterSpacing = 0,
    this.maxlines,
    this.wordspacing = 4,
    this.textAlign,
    this.overflow,
    this.textDecoration,
    this.minFontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      softWrap: true,
      group: AutoSizeGroup(),
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
      minFontSize: minFontSize!,
      textScaleFactor: 1.1,
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
  return GoogleFonts.openSans(
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
  FontWeight? fontWeight = FontWeight.w400,
  FontStyle fontStyle = FontStyle.normal,
  double letterSpacing = 0.0,
  double? height,
  TextDecoration? textDecoration,
}) {
  return GoogleFonts.roboto(
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
  Color? color,
  FontWeight fontWeight = FontWeight.w700,
  FontStyle fontStyle = FontStyle.normal,
  double letterSpacing = 0,
  double wordSpacing = 2.0,
  double? height,
}) {
  return GoogleFonts.openSans(
    fontSize: fontSize,
    color: color ?? AppColor.titleColor,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    height: height,
  );
}

TextStyle listTitleStyle({
  double fontSize = 16.0,
  Color? color,
  FontWeight? fontWeight = FontWeight.w800,
  FontStyle fontStyle = FontStyle.normal,
  double letterSpacing = 0.0,
  double? height,
  TextDecoration? textDecoration,
}) {
  return GoogleFonts.roboto(
    fontSize: fontSize,
    color: color ?? AppColor.titleColor,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    height: height,
    decoration: textDecoration,
  );
}

TextStyle subtitleStyle({
  double fontSize = 14.0,
  Color? color,
  FontWeight? fontWeight = FontWeight.w500,
  FontStyle fontStyle = FontStyle.normal,
  double letterSpacing = 0.0,
  double? height,
  TextDecoration? textDecoration,
}) {
  return GoogleFonts.nunito(
    fontSize: fontSize,
    color: color ?? AppColor.subtitleColor,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    height: height,
    decoration: textDecoration,
  );
}
