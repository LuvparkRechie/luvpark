import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/variables.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.textInputAction,
    this.validator,
    required this.hasFormatter,
    required this.hasReadOnly,
  });

  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final String? hint;
  final Function? validator;
  final bool hasFormatter;
  final bool hasReadOnly;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (prefix != null) ...[
          prefix!,
          const SizedBox(width: 10),
        ],
        Expanded(
          child: TextFormField(
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            controller: controller,
            inputFormatters: hasFormatter
                ? [Variables.maskFormatter]
                : hint == "Password" ||
                        hint == "New Password" ||
                        hint == "Confirm new Password"
                    ? []
                    : <TextInputFormatter>[UpperCaseTextFormatter()],
            //  maxLines: 11,
            obscureText: obscureText,
            readOnly: hasReadOnly,
            style:
                GoogleFonts.prompt(fontWeight: FontWeight.normal, fontSize: 15),
            decoration: InputDecoration(
              suffixIcon: suffix,
              hintText: hint,
              hintStyle: GoogleFonts.prompt(
                fontSize: 15.0,
              ),
            ),
            validator: ((value) {
              validator!();
              return null;
            }),
          ),
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: Variables.capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}
