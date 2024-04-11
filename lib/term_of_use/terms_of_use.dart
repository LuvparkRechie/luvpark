import 'package:flutter/material.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
      appBarheaderText: "Terms of Use",
      child: SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
