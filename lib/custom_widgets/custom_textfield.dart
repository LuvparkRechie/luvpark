// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/variables.dart';

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
  final String? errorText;
  final String? hintText;

  const CustomTextField(
      {super.key,
      this.title,
      this.labelText,
      this.hintText,
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
      this.onTap,
      this.errorText});

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
          minLines: 1,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
          obscureText: widget.isObscure,
          autofocus: false,
          inputFormatters: widget.inputFormatters,
          controller: widget.controller,
          textInputAction: TextInputAction.done,
          readOnly: widget.isReadOnly ?? false,
          keyboardType: widget.keyboardType!,
          textAlign:
              widget.textAlign != null ? widget.textAlign! : TextAlign.left,
          focusNode: focusNode,
          decoration: InputDecoration(
            errorText: widget.errorText,
            filled: widget.isFilled ?? widget.isFilled,
            fillColor: widget.filledColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(
                color: AppColor.borderColor,
              ),
            ),
            errorStyle: paragraphStyle(
              color: Colors.red,
              fontWeight: FontWeight.normal,
              fontSize: 11,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(7)),
                borderSide: BorderSide(color: Color(0xFF0078FF))),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(
                color: AppColor.borderColor,
              ),
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(7)),
                borderSide: BorderSide(color: Color(0xFFDF0000))),
            suffixIcon: widget.suffixIcon != null
                ? InkWell(
                    onTap: () {
                      widget.onIconTap!();
                    },
                    child: Icon(
                      widget.suffixIcon!,
                      // color: widget.isFilled != null && widget.isFilled!
                      //     ? AppColor.primaryColor
                      //     : null,
                      color: AppColor.primaryColor,
                    ),
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
            hintText: widget.hintText,
            hintStyle: paragraphStyle(
              color: AppColor.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          style:
              paragraphStyle(color: Colors.black, fontWeight: FontWeight.w500),
          onChanged: (value) {
            widget.onChange!(value);
          },
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            }
          },
          validator: widget.validator,
        ));
  }
}

class CustomMobileNumber extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final bool? isReadOnly;
  final Widget? prefix;
  final IconData? suffixIcon;
  final Function? onIconTap;
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
    this.labelText,
    required this.controller,
    required this.hintText,
    this.onChange,
    this.prefixIcon,
    this.isReadOnly = false,
    this.inputFormatters,
    this.prefix = const Text(""),
    this.keyboardType = TextInputType.text,
    this.onTap,
    this.isEnabled = true,
    this.validator,
    this.suffixIcon,
    this.onIconTap,
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
        maxLines: 1,
        autofocus: false,
        inputFormatters: [Variables.maskFormatter],
        controller: widget.controller,
        textInputAction: TextInputAction.done,
        readOnly: !widget.isEnabled || widget.isReadOnly!,
        textAlign: TextAlign.left,
        enabled: widget.isEnabled,
        keyboardType: widget.keyboardType!,
        decoration: InputDecoration(
          errorStyle: paragraphStyle(
            color: Colors.red,
            fontWeight: FontWeight.normal,
            fontSize: 11,
          ),
          isDense: true,
          labelText: widget.labelText,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7)),
            borderSide: BorderSide(
              color: AppColor.borderColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(color: Color(0xFF0078FF))),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7)),
            borderSide: BorderSide(
              color: AppColor.borderColor,
            ),
          ),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(color: Color(0xFFDF0000))),
          suffixIcon: widget.suffixIcon != null
              ? InkWell(
                  onTap: () {
                    widget.onIconTap!();
                  },
                  child: Icon(widget.suffixIcon!),
                )
              : null,
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
          hintText: widget.hintText,
          hintStyle: paragraphStyle(
            color: AppColor.hintColor,
            fontWeight: FontWeight.w400,
          ),
          labelStyle: paragraphStyle(
              fontWeight: FontWeight.w400, color: AppColor.hintColor),
          floatingLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
        style: paragraphStyle(color: Colors.black, fontWeight: FontWeight.w500),
        onTap: widget.isEnabled ? widget.onTap : null,
        onChanged: (value) {
          widget.onChange!(value);
        },
        validator: widget.validator ??
            (value) {
              if (widget.hintText == "10 digit mobile number") {
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
//custom textfield
              return null;
            },
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

DropdownButtonFormField<String> customDropdown({
  required bool isDisabled,
  required String labelText,
  required List items,
  required String? selectedValue,
  required ValueChanged<String?> onChanged,
  String? Function(String?)? validator,
}) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      filled: isDisabled,
      fillColor: Colors.grey.shade200,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColor.borderColor,
        ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: Color(0xFF0078FF))),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: AppColor.borderColor,
        ),
      ),
      hintText: labelText,
      hintStyle: paragraphStyle(
        color: AppColor.hintColor,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: paragraphStyle(
        color: Colors.red,
        fontWeight: FontWeight.normal,
        fontSize: 11,
      ),
    ),
    style: paragraphStyle(color: Colors.black, fontWeight: FontWeight.w400),
    items: items.map((item) {
      return DropdownMenuItem(
          value: item['value'].toString(),
          child: AutoSizeText(
            item['text'].toString(),
            style: paragraphStyle(
                color: Colors.black, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            maxFontSize: 16,
            maxLines: 2,
          ));
    }).toList(),
    value: selectedValue,
    onChanged: isDisabled ? null : onChanged,
    validator: validator,
    isExpanded: true,
    focusNode: FocusNode(),
    icon: Icon(Icons.arrow_drop_down,
        color: items.isEmpty || isDisabled ? Colors.grey : Colors.black),
    dropdownColor: Colors.white,
    autovalidateMode: AutovalidateMode.onUserInteraction,
  );
}
