import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';

import '../../../custom_widgets/app_color.dart';

class LegendDialogScreen extends StatefulWidget {
  final VoidCallback? callback;
  const LegendDialogScreen({super.key, this.callback});

  @override
  State<LegendDialogScreen> createState() => _LegendDialogScreenState();
}

class _LegendDialogScreenState extends State<LegendDialogScreen> {
  int currentPage = 0;
  PageController pageController = PageController();
  List<Map<String, dynamic>> sliderData = [
    {
      "title": "Street Parking",
      "subTitle":
          "Discover parking options in public areas, including streets spaces.",
      "icon": "street_legend",
    },
    {
      "title": "Private Parking",
      "subTitle": "These parking spaces are located "
          "within private establishments.",
      "icon": "private_legend",
    },
    {
      "title": "Commercial Parking",
      "subTitle":
          "Parking areas are located in business districts and commercial zones.",
      "icon": "commerical_legend",
    },
    {
      "title": "Valet Parking",
      "subTitle":
          "You hand your car to an attendant, who\nparks it and brings it back when you ask.",
      "icon": "valet_legend",
    },
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 34),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 34),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LayoutBuilder(builder: (context, constraints) {
                      return SizedBox(
                        height: 200,
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: sliderData.length,
                          itemBuilder: (context, index) {
                            return SingleChildScrollView(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/legend/${sliderData[index]["icon"]}.svg",
                                    ),
                                    SizedBox(height: 28),
                                    CustomParagraph(
                                      text: sliderData[index]["title"],
                                      fontSize: 18,
                                      maxlines: 1,
                                      color: Colors.black87,
                                    ),
                                    SizedBox(height: 15),
                                    CustomParagraph(
                                      text: sliderData[index]["subTitle"],
                                      textAlign: TextAlign.center,
                                      maxlines: 2,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          onPageChanged: (index) {
                            setState(() {
                              currentPage = index;
                            });
                          },
                        ),
                      );
                    }),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          sliderData.length,
                          (index) => Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentPage == index
                                  ? AppColor.primaryColor
                                  : const Color(0xFFD9D9D9),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 22),
                    CustomButton(
                        text: "Okay",
                        onPressed: () {
                          Get.back();
                          widget.callback!();
                        })
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
