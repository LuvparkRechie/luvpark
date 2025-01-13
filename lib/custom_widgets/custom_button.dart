import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color? btnColor;
  final bool? loading;
  final Color? bordercolor;
  final Color? textColor;
  final double? borderRadius;
  final double? btnHeight;
  final double fontSize;
  const CustomButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.fontSize = 14,
      this.btnColor,
      this.bordercolor,
      this.textColor,
      this.loading,
      this.borderRadius = 7,
      this.btnHeight});

  //custombutton

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
        height: btnHeight,
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
                ? CustomParagraph(
                    text: text,
                    fontSize: fontSize,
                    textAlign: TextAlign.center,
                    color: textColor ?? Colors.white,
                    fontWeight: FontWeight.w500,
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
                    : CustomParagraph(
                        text: text,
                        fontSize: fontSize,
                        maxlines: 1,
                        textAlign: TextAlign.center,
                        color: textColor ?? Colors.white,
                        fontWeight: FontWeight.w500,
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
          letterSpacing: 0.50,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w500,
          maxlines: 1,
        ),
      ),
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? btnColor;
  final bool loading;
  final bool disabled;
  final Color? textColor;
  final double borderRadius;
  final double fontSize;
  final double? btnHeight;
  final Color? borderColor;
  final IconData? icon;
  final double iconSize;
  final Color? iconColor;
  final double spacing;
  final double? btnwidth;

  const CustomElevatedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.btnColor,
    this.textColor,
    this.loading = false,
    this.disabled = false,
    this.borderRadius = 7.0,
    this.fontSize = 14.0,
    this.btnHeight,
    this.borderColor,
    this.icon,
    this.iconSize = 20.0,
    this.iconColor,
    this.spacing = 8.0,
    this.btnwidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: btnHeight ?? 50.0,
      width: btnwidth,
      child: ElevatedButton(
        onPressed: (loading || disabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? Colors.grey : btnColor ?? Colors.blue,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: borderColor ?? Colors.transparent,
              width: 1,
            ),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: iconSize,
                      color: iconColor ?? textColor ?? Colors.white,
                    ),
                    SizedBox(width: spacing),
                  ],
                  CustomParagraph(
                    text: text,
                    fontSize: fontSize,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
      ),
    );
  }
}

class CustomNextButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Function onPressed;
  final Color? btnColor;
  final bool? loading;
  final Color? bordercolor;
  final Color? textColor;
  final double? borderRadius;
  final double? btnHeight;
  final double? fontSize;
  const CustomNextButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.btnColor,
    this.loading,
    this.bordercolor,
    this.textColor,
    this.borderRadius = 7,
    this.btnHeight,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
        height: btnHeight,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: btnColor ?? AppColor.primaryColor,
          border: Border.all(color: bordercolor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTitle(
              text: text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            Visibility(visible: icon != null, child: Container(width: 10)),
            Visibility(
                visible: icon != null,
                child: Icon(
                  icon,
                  color: Colors.white,
                ))
          ],
        ),
      ),
    );
  }
}
