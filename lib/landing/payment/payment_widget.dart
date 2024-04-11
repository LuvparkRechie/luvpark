import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentWidget extends StatelessWidget {
  final Function onTap;
  final String labelName;
  final String logoName;
  // ignore: prefer_typing_uninitialized_variables

  const PaymentWidget({
    Key? key,
    required this.onTap,
    required this.labelName,
    required this.logoName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 78, 154, 241),
            Color.fromARGB(255, 51, 129, 218),
          ],
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      height: 85,
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFFffffff)),
            child: IconButton(
              onPressed: () {
                onTap();
              },
              icon: Image(
                image: AssetImage("assets/images/$logoName"),
              ),
              // child: Image(
              //   image: AssetImage("assets/images/$logoName"),
              // ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            labelName,
            style: GoogleFonts.prompt(
              color: const Color(0xFFffffff),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          )
        ],
      ),
    );
  }
}
