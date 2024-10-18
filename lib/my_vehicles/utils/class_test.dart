import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../custom_widgets/custom_text.dart';

DropdownButtonFormField<String> customDropdown({
  required String labelText,
  required List items,
  required String? selectedValue,
  required ValueChanged<String?> onChanged,
  String? Function(String?)? validator,
}) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      floatingLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF0078FF))),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.0),
      ),
      labelText: labelText,
      labelStyle: paragraphStyle(),
    ),
    style: paragraphStyle(color: Colors.black),
    items: items.map((item) {
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
    value: selectedValue,
    onChanged: onChanged,
    validator: validator,
    isExpanded: true,
    focusNode: FocusNode(),
    icon: Icon(Icons.arrow_drop_down,
        color: items.isEmpty ? Colors.grey : Colors.black),
    dropdownColor: Colors.white,
    autovalidateMode: AutovalidateMode.onUserInteraction,
  );
}
