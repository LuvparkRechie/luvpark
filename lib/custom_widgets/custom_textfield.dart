// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';

class CustomTextField extends StatefulWidget {
  final String? labelText;
  final bool? isReadOnly, isFilled;
  final Widget? prefix;
  final bool isObscure;
  final Color? filledColor;
  final String? title;

  final TextEditingController controller;
  final ValueChanged<String>? onChange;
  final List<TextInputFormatter>? inputFormatters;
  final Function? onTap;
  final Function? onIconTap;
  final TextInputType? keyboardType;
  final Icon? prefixIcon;
  final IconData? suffixIcon;
  final int? maxLength;
  final double? fontsize;
  final FontWeight? fontweight;
  final TextAlign? textAlign;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;

  const CustomTextField(
      {super.key,
      this.title,
      this.labelText,
      required this.controller,
      this.fontweight,
      this.fontsize = 14,
      this.onChange,
      this.prefixIcon,
      this.isObscure = false,
      this.isReadOnly = false,
      this.inputFormatters,
      this.prefix = const Text(""),
      this.suffixIcon,
      this.onIconTap,
      this.maxLength,
      this.textAlign,
      this.filledColor,
      this.isFilled,
      this.validator,
      this.keyboardType = TextInputType.text,
      this.textCapitalization = TextCapitalization.none,
      this.onTap});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final numericRegex = RegExp(r'[0-9]');
  final upperCaseRegex = RegExp(r'[A-Z]');
  FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
        child: TextFormField(
          textCapitalization: widget.textCapitalization,
          obscureText: widget.isObscure,
          autofocus: false,
          inputFormatters: widget.inputFormatters,
          controller: widget.controller,
          textInputAction: TextInputAction.done,
          readOnly: widget.isReadOnly!,
          keyboardType: widget.keyboardType!,
          textAlign:
              widget.textAlign != null ? widget.textAlign! : TextAlign.left,
          focusNode: focusNode,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFF0078FF))),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFFDF0000))),
            labelText: widget.title ?? widget.labelText,
            hintText: widget.labelText,
            suffixIcon: widget.suffixIcon != null
                ? InkWell(
                    onTap: () {
                      widget.onIconTap!();
                    },
                    child: Icon(widget.suffixIcon!),
                  )
                : null,
            prefixIcon: widget.prefixIcon != null
                ? InkWell(
                    onTap: () {
                      widget.onIconTap!();
                    },
                    child: widget.prefixIcon,
                  )
                : null,
          ),
          style: paragraphStyle(color: Colors.black),
          onChanged: (value) {
            widget.onChange!(value);
          },
          onTap: () {
            widget.onTap!();
          },
          validator: widget.validator,
        ));
  }
}

class CustomMobileNumber extends StatefulWidget {
  final String labelText;
  final bool? isReadOnly;
  final Widget? prefix;
  final TextEditingController controller;
  final ValueChanged<String>? onChange;
  final List<TextInputFormatter>? inputFormatters;
  final void Function()? onTap; // Change the type to match void Function()?
  final TextInputType? keyboardType;
  final Icon? prefixIcon;
  final bool isEnabled;
  final String? Function(String?)? validator;

  const CustomMobileNumber({
    super.key,
    required this.labelText,
    required this.controller,
    this.onChange,
    this.prefixIcon,
    this.isReadOnly = false,
    this.inputFormatters,
    this.prefix = const Text(""),
    this.keyboardType = TextInputType.text,
    this.onTap,
    this.isEnabled = true,
    this.validator,
  });

  @override
  State<CustomMobileNumber> createState() => _CustomMobileNumberState();
}

class _CustomMobileNumberState extends State<CustomMobileNumber> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
      child: TextFormField(
        autofocus: false,
        inputFormatters: [Variables.maskFormatter],
        controller: widget.controller,
        textInputAction: TextInputAction.done,
        readOnly: !widget.isEnabled || widget.isReadOnly!,
        textAlign: TextAlign.left,
        enabled: widget.isEnabled,
        keyboardType: widget.keyboardType!,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFF0078FF))),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFFDF0000))),
          labelText: widget.labelText,
          prefixIcon: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
              ),
            ),
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 15),
                Text(
                  '+63',
                  style: Platform.isAndroid
                      ? GoogleFonts.dmSans(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        )
                      : const TextStyle(
                          fontFamily: "SFProTextReg",
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                ),
              ],
            ),
          ),
        ),
        style: paragraphStyle(color: Colors.black),
        onChanged: widget.onChange,
        onTap: widget.isEnabled ? widget.onTap : null,
        validator: widget.validator ??
            (value) {
              if (widget.labelText == "10 digit mobile number") {
                if (value!.isEmpty) {
                  return 'Field is required';
                }
                if (value.toString().replaceAll(" ", "").length < 10) {
                  return 'Invalid mobile number';
                }
                if (value.toString().replaceAll(" ", "")[0] == '0') {
                  return 'Invalid mobile number';
                }
              }

              return null;
            },
      ),
    );
  }
}

class CustomDropdown extends StatefulWidget {
  final String? ddValue;
  final List ddData;
  final String labelText;
  final ValueChanged<String>? onChange;
  final Function? onTap;
  final FormFieldValidator<String>? validator;
  const CustomDropdown(
      {super.key,
      required this.labelText,
      required this.ddData,
      this.onChange,
      this.validator,
      required this.ddValue,
      this.onTap});

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final numericRegex = RegExp(r'[0-9]');
  final upperCaseRegex = RegExp(r'[A-Z]');
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
      child: IntrinsicHeight(
        child: DropdownButtonFormField(
          dropdownColor: Colors.white,
          focusNode: focusNode,
          decoration: InputDecoration(
              floatingLabelStyle: TextStyle(fontWeight: FontWeight.w600),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFF0078FF))),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.0),
              ),
              labelText: widget.labelText,
              labelStyle: paragraphStyle()),
          style: paragraphStyle(color: Colors.black),
          value: widget.ddValue,
          isExpanded: true,
          onChanged: (value) {
            widget.onChange!(value!);
          },
          validator: widget.validator,
          items: widget.ddData.map((item) {
            return DropdownMenuItem(
                value: item['value'].toString(),
                child: AutoSizeText(
                  item['text'],
                  style: paragraphStyle(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                  maxFontSize: 15,
                  maxLines: 2,
                ));
          }).toList(),
        ),
      ),
    );
  }
}

class CustomButtonClose extends StatefulWidget {
  final Function onTap;
  const CustomButtonClose({super.key, required this.onTap});

  @override
  State<CustomButtonClose> createState() => _CustomButtonCloseState();
}

class _CustomButtonCloseState extends State<CustomButtonClose> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColor.primaryColor,
        ),
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(
            Icons.close,
            size: 23,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
