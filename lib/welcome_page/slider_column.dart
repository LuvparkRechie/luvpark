// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:luvpark/welcome_page/welcome_slider.dart';

class SlideItem extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final index;
  int currentPage;
  SlideItem({super.key, @required this.index, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(slideList[index].imageUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
