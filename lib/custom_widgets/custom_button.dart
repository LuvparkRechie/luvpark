import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color? btnColor;
  final bool? loading;
  final Color? bordercolor;
  final Color? textColor;
  final double? borderRadius;
  const CustomButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.btnColor,
      this.bordercolor,
      this.textColor,
      this.loading,
      this.borderRadius = 7,
      int? btnHeight});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: btnColor ?? AppColor.primaryColor,
          border: Border.all(color: bordercolor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Center(
            child: loading == null
                ? CustomLinkLabel(
                    text: text,
                    textAlign: TextAlign.center,
                    color: textColor ?? Colors.white,
                    maxlines: 1,
                  )
                : loading!
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : CustomLinkLabel(
                        text: text,
                        maxlines: 1,
                        textAlign: TextAlign.center,
                        color: textColor ?? Colors.white,
                      ),
          ),
        ),
      ),
    );
  }
}

class CustomButtonCancel extends StatefulWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final Function onPressed;
  const CustomButtonCancel(
      {super.key,
      required this.text,
      required this.onPressed,
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
        widget.onPressed();
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
            child: AutoSizeText(
              widget.text,
              style: GoogleFonts.lato(
                color: widget.textColor!,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDialogButton extends StatelessWidget {
  final String text;
  final Color? borderColor;
  final Color? btnColor;
  final Color? txtColor;
  final Function onTap;
  const CustomDialogButton({
    super.key,
    required this.text,
    this.borderColor,
    this.btnColor,
    this.txtColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: ShapeDecoration(
          color: btnColor ?? Color(0xFFF9FBFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(74),
          ),
        ),
        child: CustomParagraph(
          text: text,
          color: txtColor ?? Color(0xFF0078FF),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.50,
          textAlign: TextAlign.center,
          maxlines: 1,
        ),
      ),
    );
  }
}
