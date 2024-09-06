import 'package:flutter/material.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';

class CustomScaffold extends StatelessWidget {
  final Widget children;
  final AppBar? appBar;
  final Color? bodyColor;
  final Widget? bottomNavigationBar;
  final Widget? floatingButton;
  final bool canPop;
  const CustomScaffold(
      {super.key,
      required this.children,
      this.appBar,
      this.bodyColor,
      this.canPop = true,
      this.bottomNavigationBar,
      this.floatingButton});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColor.scafColor,
        appBar: appBar ?? appBar,
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: bodyColor ?? AppColor.bodyColor,
            height: MediaQuery.of(context).size.height,
            child: children,
          ),
        ),
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: bottomNavigationBar ?? bottomNavigationBar,
        floatingActionButton: floatingButton,
      ),
    );
  }
}
