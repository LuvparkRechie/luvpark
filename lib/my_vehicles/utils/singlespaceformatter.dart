import 'package:flutter/services.dart';

class SingleSpaceTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^[ -]+|[ -]+$'), '');

    if (newText != oldValue.text) {
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    return newValue;
  }
}
