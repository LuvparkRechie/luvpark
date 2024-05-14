import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/qr_payment/my_qr.dart';
import 'package:luvpark/qr_payment/payment_qr.dart';

class QRType extends StatefulWidget {
  const QRType({
    super.key,
  });

  @override
  State<QRType> createState() => _QRTypeState();
}

class _QRTypeState extends State<QRType> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int tabIndex = 0;
  final List<Widget> _pages = <Widget>[];
  @override
  void initState() {
    super.initState();
    _pages.add(const QRPay());
    _pages.add(const MyQrPage());
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
        canPop: true,
        appBarheaderText: "",
        prefSize: 80,
        appBarIconClick: () {
          Navigator.of(context).pop();
        },
        appBarTabBar: TabBar(
          indicatorColor: AppColor.mainColor, // Indicator color
          indicatorWeight: 4, // Indicator thickness
          controller: _tabController,
          onTap: (index) {
            setState(() {
              tabIndex = index;
            });
          },
          tabs: [
            Tab(text: 'QR Pay'),
            Tab(text: 'Receive'),
          ],
        ),
        child: TabBarView(
          controller: _tabController,
          children: _pages,
        ));
  }
}
