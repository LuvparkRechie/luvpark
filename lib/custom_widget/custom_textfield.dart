import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
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

  const CustomTextField(
      {super.key,
      this.title,
      required this.labelText,
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
      padding: const EdgeInsets.only(top: 10.0, bottom: 20),
      child: IntrinsicHeight(
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
            filled: widget.isFilled != null && widget.isFilled!
                ? widget.isFilled!
                : null,
            suffixIcon: widget.suffixIcon != null
                ? InkWell(
                    onTap: () {
                      widget.onIconTap!();
                    },
                    child: Icon(widget.suffixIcon!),
                  )
                : null,
            fillColor: widget.isFilled != null && widget.isFilled!
                ? Colors.white
                : null,
            // constraints: const BoxConstraints.tightFor(height: 60),
            prefixIcon: widget.prefixIcon != null
                ? InkWell(
                    onTap: () {
                      widget.onIconTap!();
                    },
                    child: widget.prefixIcon,
                  )
                : null,

            hintText: widget.labelText == "seca1" ||
                    widget.labelText == "seca2" ||
                    widget.labelText == "seca3"
                ? "Answer"
                : widget.labelText,

            hintStyle: Platform.isAndroid
                ? paragraphStyle(fontWeight: FontWeight.w500)
                : TextStyle(
                    fontWeight: widget.fontweight,
                    color: const Color(0xFF9C9C9C),
                    fontSize: widget.fontsize,
                    fontFamily: "SFProTextReg",
                  ),

            contentPadding: const EdgeInsets.only(left: 17, right: 17),

            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(color: Colors.blue),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(
                width: 2,
                color: Colors.black.withOpacity(0.07999999821186066),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(
                width: 2,
                color: Colors.black.withOpacity(0.07999999821186066),
              ),
            ),
          ),
          style: Platform.isAndroid
              ? paragraphStyle(color: Colors.black)
              : TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  fontFamily: "SFProTextReg",
                ),
          onChanged: (value) {
            widget.onChange!(value);
          },
          onTap: () {
            widget.onTap!();
          },
          validator: (value) {
            if (widget.labelText == "Email") {
              if (value!.isEmpty) {
                focusNode.requestFocus();
                return "Field is required";
              } else {
                if (!EmailValidator.validate(value) ||
                    !Variables.emailRegex.hasMatch(value)) {
                  focusNode.requestFocus();
                  return "Invalid email format";
                }
              }
            } else if (widget.labelText == "Password") {
              if (value!.isEmpty) {
                focusNode.requestFocus();
                return "Field is required";
              }
            } else if (widget.labelText == "Plate No.") {
              if (value!.isEmpty) {
                focusNode.requestFocus();
                return "Plate no is required";
              }
            } else {
              if (widget.labelText.toLowerCase().contains("optional")) {
                return null;
              } else {
                if (value!.isEmpty) {
                  focusNode.requestFocus();
                  return "Field is required";
                }
              }
            }

            return null;
          },
        ),
      ),
    );
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
  });

  @override
  State<CustomMobileNumber> createState() => _CustomMobileNumberState();
}

class _CustomMobileNumberState extends State<CustomMobileNumber> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
      child: IntrinsicHeight(
        child: TextFormField(
          autofocus: false,
          inputFormatters: widget.inputFormatters,
          controller: widget.controller,
          textInputAction: TextInputAction.done,
          readOnly: !widget.isEnabled || widget.isReadOnly!,
          textAlign: TextAlign.left,
          enabled: widget.isEnabled,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            floatingLabelAlignment: FloatingLabelAlignment.start,
            labelText: 'Mobile Number',
            prefixIcon: Container(
              decoration: BoxDecoration(
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
                        ? paragraphStyle()
                        : TextStyle(
                            fontFamily: "SFProTextReg",
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                  ),
                ],
              ),
            ),
            hintText: "10 digit mobile number",
            hintStyle: Platform.isAndroid
                ? paragraphStyle(fontWeight: FontWeight.w500)
                : TextStyle(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9C9C9C),
                    fontSize: 14,
                    fontFamily: "SFProTextReg",
                  ),
            contentPadding: const EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(color: Colors.blue),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(
                width: 2,
                color: Colors.black.withOpacity(0.07999999821186066),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(
                width: 2,
                color: Colors.black.withOpacity(0.07999999821186066),
              ),
            ),
          ),
          style: Platform.isAndroid
              ? paragraphStyle(color: Colors.black)
              : TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  fontFamily: "SFProTextReg",
                ),
          onChanged: widget.isEnabled ? widget.onChange : null,
          onTap: widget.isEnabled
              ? widget.onTap
              : null, // Updated onTap assignment
          validator: (value) {
            if (widget.labelText == "Mobile No" ||
                widget.labelText == "10 digit mobile number") {
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
      ),
    );
  }
}

class CustomDropdown extends StatefulWidget {
  final String? ddValue;
  final List ddData;
  final String labelText;
  final ValueChanged<String> onChange;

  const CustomDropdown({
    super.key,
    required this.labelText,
    required this.ddData,
    required this.onChange,
    this.ddValue,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final numericRegex = RegExp(r'[0-9]');
  final upperCaseRegex = RegExp(r'[A-Z]');
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
          decoration: InputDecoration(
            hintText: widget.labelText,
            hintStyle: Platform.isAndroid
                ? paragraphStyle(fontWeight: FontWeight.w500)
                : TextStyle(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9C9C9C),
                    fontSize: 16,
                    fontFamily: "SFProTextReg",
                  ),
            contentPadding: const EdgeInsets.all(10),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(color: Colors.blue),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(
                width: 2,
                color: Colors.black.withOpacity(0.07999999821186066),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(
                width: 2,
                color: Colors.black.withOpacity(0.07999999821186066),
              ),
            ),
          ),
          value: widget.ddValue,
          isExpanded: true,
          onChanged: (String? newValue) {
            widget.onChange(newValue!);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a ${widget.labelText}';
            }
            return null;
          },
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
