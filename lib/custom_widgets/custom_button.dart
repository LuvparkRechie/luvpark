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
  const CustomButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.btnColor,
      this.bordercolor,
      this.textColor,
      this.loading,
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
          borderRadius: BorderRadius.circular(7),
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
