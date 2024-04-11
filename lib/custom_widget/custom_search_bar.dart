import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function onTap;
  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        readOnly: true,
        enabled: true,
        autofocus: false,
        controller: controller,
        decoration: InputDecoration(
          hintText: "Search parking area",
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF9C9C9C),
          ),
          hintStyle: Platform.isAndroid
              ? GoogleFonts.dmSans(
                  color: Color(0x993C3C43),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  height: 0.08,
                  letterSpacing: -0.41,
                )
              : TextStyle(
                  color: Color(0x993C3C43),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  height: 0.08,
                  letterSpacing: -0.41,
                ),
        ),
        onTap: () {
          onTap();
        },
      ),
    );
  }
}
