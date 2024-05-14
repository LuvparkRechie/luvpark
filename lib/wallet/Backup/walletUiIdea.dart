import 'dart:math';

import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class WalletUiIdea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: SearchHeader(
              icon: Icons.terrain,
              title: 'Trees',
              search: _Search(),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                Text('some text'),
                Placeholder(
                  color: Colors.red,
                  fallbackHeight: 200,
                ),
                Container(
                  color: Colors.blueGrey,
                  height: 500,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Search extends StatefulWidget {
  _Search({Key? key}) : super(key: key);

  @override
  __SearchState createState() => __SearchState();
}

class __SearchState extends State<_Search> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Icon(Icons.local_activity),
            CustomDisplayText(label: "Load")
          ],
        ),
        Column(
          children: [Icon(Icons.share), CustomDisplayText(label: "Share")],
        ),
        Column(
          children: [Icon(Icons.qr_code), CustomDisplayText(label: "QR")],
        )
      ],
    );
  }
}

class SearchHeader extends SliverPersistentHeaderDelegate {
  final double minTopBarHeight = 200;
  final double maxTopBarHeight = 300;
  final String title;
  final IconData icon;
  final Widget search;

  SearchHeader({
    required this.title,
    required this.icon,
    required this.search,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    var shrinkFactor = min(1, shrinkOffset / (maxExtent - minExtent));

    var topBar = Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            )),
        alignment: Alignment.center,
        height:
            max(maxTopBarHeight * (1 - shrinkFactor * 1.45), minTopBarHeight),
        width: Variables.screenSize.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDisplayText(
              label: "My Wallet",
              color: Colors.white,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
    return Container(
      height: max(maxExtent - shrinkOffset, minExtent),
      child: Stack(
        fit: StackFit.loose,
        children: [
          if (shrinkFactor <= 0.5) topBar,
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                alignment: Alignment.center,
                child: search,
                width: Variables.screenSize.width,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 10),
                        blurRadius: 10,
                        color: Colors.green.withOpacity(0.23),
                      )
                    ]),
              ),
            ),
          ),
          if (shrinkFactor > 0.5) topBar,
        ],
      ),
    );
  }

  @override
  double get maxExtent => 330;

  @override
  double get minExtent => 200;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
