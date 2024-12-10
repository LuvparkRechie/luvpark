import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';

class ImageViewer extends StatelessWidget {
  final String base64Image;

  const ImageViewer({Key? key, required this.base64Image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(),
      body: Center(
        child: base64Image.isNotEmpty
            ? Image.memory(base64.decode(base64Image))
            : Text("No image available"),
      ),
    );
  }
}
