import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final Function onTap;
  final double? btnHeight;
  final Color? bordercolor;
  const CustomButton(
      {super.key,
      required this.label,
      required this.onTap,
      this.color,
      this.btnHeight,
      this.bordercolor,
      this.textColor});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: widget.bordercolor ?? Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      color: widget.color ?? AppColor.primaryColor,
      minWidth: Variables.screenSize.width,
      onPressed: () {
        widget.onTap();
      },
      child: Center(
        child: Padding(
            padding: EdgeInsets.all(widget.btnHeight ?? 15.0),
            child: CustomParagraph(
              text: widget.label,
              color: widget.textColor ?? Colors.white,
              fontSize: 14,
              maxlines: 1,
            )),
      ),
    );
  }
}

class CustomButtonCancel extends StatefulWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final Function onTap;
  const CustomButtonCancel(
      {super.key,
      required this.label,
      required this.onTap,
      this.borderColor,
      this.color,
      this.textColor});

  @override
  State<CustomButtonCancel> createState() => _CustomButtonCancelState();
}

class _CustomButtonCancelState extends State<CustomButtonCancel> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Container(
        decoration: BoxDecoration(
            color: widget.color!,
            borderRadius: BorderRadius.circular(7),
            border: widget.borderColor == null
                ? null
                : Border.all(color: widget.borderColor!)),
        clipBehavior: Clip.antiAlias,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              widget.label,
              style: GoogleFonts.lato(
                color: widget.textColor!,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButtonRegistration extends StatefulWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final Function onTap;
  const CustomButtonRegistration(
      {super.key,
      required this.label,
      required this.onTap,
      this.color,
      this.borderColor,
      this.textColor});

  @override
  State<CustomButtonRegistration> createState() =>
      _CustomButtonRegistrationState();
}

class _CustomButtonRegistrationState extends State<CustomButtonRegistration> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.color ?? AppColor.mainColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              widget.label,
              style: GoogleFonts.lato(
                color: widget.textColor ?? Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
