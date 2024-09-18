import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/about_us/index.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';

class AboutUs extends GetView<AboutUsController> {
  const AboutUs({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        title: "About Us",
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image(
                height: MediaQuery.of(context).size.height * 0.15,
                width: MediaQuery.of(context).size.width * .60,
                image: const AssetImage("assets/images/login_logo.png"),
              ),
            ),
            Container(
              height: 20,
            ),
            const CustomTitle(
              text: 'About luvpark',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 10),
            const CustomParagraph(
              text:
                  "Meet luvpark, your ultimate parking solution. Gone are the days of circling for parking spaces and maneuvering through congested lots. With luvpark, finding a spot near your destination is quick and easy. Our intuitive interface guides you to available spots, ensuring a smooth and stress-free arrival. Plus, our convenient booking feature elevates your urban travel, by securing your parking in advance. Experience the future of parking with luvpark.",
              fontWeight: FontWeight.normal,
              //color: Colors.black,
              fontSize: 14,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            const CustomTitle(
              text: 'Contact Us',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 10),
            const CustomParagraph(
              text: 'Email: support@luvpark.ph',
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(255, 18, 17, 17),
              fontSize: 14,
            ),
            const CustomParagraph(
              text: 'Phone: (63 34) 441 2409',
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(255, 18, 17, 17),
              fontSize: 14,
            ),
            Container(height: 10),
            const CustomTitle(
              text: 'Official Numbers:',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            Container(height: 5),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomParagraph(text: "09853919304"),
                CustomParagraph(text: "09853919305")
              ],
            ),
          ],
        ),
      ),
    );
  }
}
