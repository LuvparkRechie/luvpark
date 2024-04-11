import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/webview/webview.dart';
import 'package:page_transition/page_transition.dart';

class AboutLuvPark extends StatelessWidget {
  const AboutLuvPark({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: CustomParentWidget(
        appbarColor: AppColor.primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Logo or Icon
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 20,
                ),
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

                CustomDisplayText(
                  label: 'About luvpark',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 10),
                CustomDisplayText(
                  label:
                      "Meet luvpark, your ultimate parking solution. Gone are the days of circling for parking spaces and maneuvering through congested lots. With luvpark, finding a spot near your destination is quick and easy. Our intuitive interface guides you to available spots, ensuring a smooth and stress-free arrival. Plus, our convenient booking feature elevates your urban travel, by securing your parking in advance. Experience the future of parking with luvpark.",
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  fontSize: 14,
                ),

                const SizedBox(height: 20),
                CustomDisplayText(
                  label: 'Contact Us',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 10),
                CustomDisplayText(
                  label: 'Email: support@luvpark.ph',
                  fontWeight: FontWeight.normal,
                  color: const Color.fromARGB(255, 18, 17, 17),
                  fontSize: 14,
                ),
                CustomDisplayText(
                  label: 'Phone: (63 34) 441 2409',
                  fontWeight: FontWeight.normal,
                  color: const Color.fromARGB(255, 18, 17, 17),
                  fontSize: 14,
                ),

                const SizedBox(height: 50),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.scale,
                          duration: const Duration(seconds: 1),
                          alignment: Alignment.centerLeft,
                          child: const WebviewPage(
                              isBuyToken: false,
                              urlDirect: "https://luvpark.ph",
                              label: "luvpark"),
                        ),
                      );
                    },
                    child: CustomDisplayText(
                        label: 'Visit Our Website',
                        fontWeight: FontWeight.normal,
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Variables.pageTrans(const WebviewPage(
                        urlDirect: "https://luvpark.ph/privacy-policy/",
                        label: "luvpark",
                        isBuyToken: false,
                      ));
                    },
                    child: CustomDisplayText(
                      label: 'Privacy Policy',
                      fontWeight: FontWeight.normal,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
