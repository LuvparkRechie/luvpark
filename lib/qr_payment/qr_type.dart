import 'package:flutter/material.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/qr_payment/my_qr.dart';
import 'package:luvpark/qr_payment/payment_qr.dart';

class QRType extends StatefulWidget {
  final int index;
  const QRType({super.key, required this.index});

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
        appBarheaderText: widget.index == 0 ? "QR Pay" : "Receive",
        appBarIconClick: () {
          Navigator.of(context).pop();
        },
        child: _pages[widget.index]);
  }
}
