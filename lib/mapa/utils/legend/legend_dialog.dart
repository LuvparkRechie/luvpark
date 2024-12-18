import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';

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

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
      child: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (widget.callback != null) {
            widget.callback!();
          }
          return;
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () {
                            Get.back();
                            if (widget.callback != null) {
                              widget.callback!();
                            }
                          },
                          child: Container(
                            decoration: ShapeDecoration(
                              color: Color(0xFFF3F4F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(37.39),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                Icons.close,
                                color: Color(0xFF747579),
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .60,
                        child: ScrollConfiguration(
                          behavior:
                              ScrollBehavior().copyWith(overscroll: false),
                          child: StretchingOverscrollIndicator(
                            axisDirection: AxisDirection.right,
                            child: PageView(
                              controller: pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  currentPage = index;
                                });
                              },
                              children: [page1(), page2()],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            2,
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
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget page1() {
    return SingleChildScrollView(
      child: Column(children: [
        SvgPicture.asset(
          "assets/legend/leg1.svg",
        ),
        SizedBox(height: 8),
        Text(
          'Parking Zone Signs',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 20,
            fontFamily: 'openSans',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'These are the meanings of the colors\nassigned to each parking zone',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF616161),
            fontSize: 14,
            fontFamily: 'openSans',
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 5),
          decoration: ShapeDecoration(
            color: Color(0xFFF8F9FB),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1, color: Color(0xFFE6EBF0)),
                  ),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/legend/leg_orange.svg",
                    ),
                    Container(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTitle(
                            text: "Private Parking",
                            fontSize: 16,
                          ),
                          Container(height: 5),
                          CustomParagraph(
                            text:
                                'These parking spaces are located within private establishments.',
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1, color: Color(0xFFE6EBF0)),
                  ),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/legend/leg_blue.svg",
                    ),
                    Container(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTitle(
                            text: "Commercial Parking",
                            fontSize: 16,
                          ),
                          Container(height: 5),
                          CustomParagraph(
                            text:
                                'Parking areas are located in business districts and commercial zones.',
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/legend/leg_green.svg",
                    ),
                    Container(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTitle(
                            text: "Street Parking",
                            fontSize: 16,
                          ),
                          Container(height: 5),
                          CustomParagraph(
                            text:
                                'Discover parking options in public\nareas, including street spaces.',
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget page2() {
    return Column(
      children: [
        SvgPicture.asset(
          "assets/legend/parking_leg.svg",
        ),
        SizedBox(height: 8),
        Text(
          'Parking Icons',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 20,
            fontFamily: 'openSans',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Watch out for these parking signs to see which vehicles are allowed',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF616161),
            fontSize: 14,
            fontFamily: 'openSans',
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 18),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 5),
          decoration: ShapeDecoration(
            color: Color(0xFFF8F9FB),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Color(0xFFE6EBF0),
                          ),
                          right: BorderSide(
                            width: 1,
                            color: Color(0xFFE6EBF0),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            "assets/legend/leg_motor.svg",
                          ),
                          Container(height: 10),
                          Text(
                            'Motor Parking',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 12,
                              fontFamily: 'openSans',
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Color(0xFFE6EBF0),
                          ),
                          left: BorderSide(
                            width: 1,
                            color: Color(0xFFE6EBF0),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            "assets/legend/leg_car.svg",
                          ),
                          Container(height: 10),
                          Text(
                            'Car Parking',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 12,
                              fontFamily: 'openSans',
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 1,
                            color: Color(0xFFE6EBF0),
                          ),
                          right: BorderSide(
                            width: 1,
                            color: Color(0xFFE6EBF0),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            "assets/legend/leg_pwd.svg",
                          ),
                          Container(height: 10),
                          Text(
                            'PWD Friendly',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 12,
                              fontFamily: 'openSans',
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 1,
                            color: Color(0xFFE6EBF0),
                          ),
                          left: BorderSide(
                            width: 1,
                            color: Color(0xFFE6EBF0),
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/legend/leg_valet.svg",
                          ),
                          Container(height: 10),
                          Text(
                            'Valet Parking',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 12,
                              fontFamily: 'openSans',
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
