import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:sizer/sizer.dart';

class CustomParentWidget extends StatefulWidget {
  final Color appbarColor;
  final Color? bodyColor;
  final Widget child;
  final bool? onPop;
  final TabBar? appBarTabBar;
  final double? toolbarHeight;
  final Widget? floatingButton;
  const CustomParentWidget(
      {super.key,
      required this.child,
      this.appBarTabBar,
      this.onPop = true,
      this.toolbarHeight = 0,
      this.floatingButton,
      this.bodyColor,
      required this.appbarColor});

  @override
  State<CustomParentWidget> createState() => _CustomParentWidgetState();
}

class _CustomParentWidgetState extends State<CustomParentWidget> {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1)),
        child: PopScope(
          canPop: widget.onPop!,
          child: widget.floatingButton == null
              ? Scaffold(
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(0),
                    child: appBar(),
                  ),
                  body: safeArea(),
                )
              : Scaffold(
                  floatingActionButton: widget.floatingButton!,
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(0),
                    child: appBar(),
                  ),
                  body: safeArea(),
                ),
        ),
      );
    });
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      toolbarHeight: widget.toolbarHeight,
      automaticallyImplyLeading: false,
      backgroundColor: widget.appbarColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: widget.appbarColor,
        // statusBarBrightness: Brightness.dark,
        // statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Platform.isIOS
            ? Brightness.light
            : widget.appbarColor == const Color(0xffffffff)
                ? Brightness.dark
                : Brightness.light,
        statusBarIconBrightness: Platform.isIOS
            ? Brightness.light
            : widget.appbarColor == const Color(0xffffffff)
                ? Brightness.dark
                : Brightness.light,
      ),
      bottom: widget.appBarTabBar ?? widget.appBarTabBar,
    );
  }

  Widget safeArea() {
    return SafeArea(
      child: Container(
        color: widget.bodyColor == null ? AppColor.bodyColor : widget.bodyColor,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: widget.child,
      ),
    );
  }
}

class CustomParent1Widget extends StatefulWidget {
  final Widget? floatingButton;
  final String appBarheaderText;
  final Function? appBarIconClick;
  final TabBar? appBarTabBar;
  final Widget child;
  final bool? hasPadding;
  final Color? bodyColor;
  final bool? canPop;
  const CustomParent1Widget(
      {super.key,
      required this.child,
      required this.appBarheaderText,
      this.appBarIconClick,
      this.hasPadding = true,
      this.floatingButton,
      this.bodyColor,
      this.canPop = false,
      this.appBarTabBar});

  @override
  State<CustomParent1Widget> createState() => _CustomParent1WidgetState();
}

class _CustomParent1WidgetState extends State<CustomParent1Widget> {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1)),
        child: PopScope(
          canPop: true,
          child: widget.floatingButton == null
              ? Scaffold(
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                    child: appBar(),
                  ),
                  body: childs(),
                )
              : Scaffold(
                  floatingActionButton: widget.floatingButton!,
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                    child: appBar(),
                  ),
                  body: childs(),
                ),
        ),
      );
    });
  }

  Widget childs() {
    return PopScope(
      canPop: widget.canPop!,
      child: SafeArea(
        child: Container(
          color: widget.bodyColor ?? AppColor.bodyColor,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: !widget.hasPadding!
              ? widget.child
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: widget.child,
                ),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColor.primaryColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColor.primaryColor,
        statusBarBrightness:
            Platform.isIOS ? Brightness.light : Brightness.light,
        statusBarIconBrightness:
            Platform.isIOS ? Brightness.light : Brightness.light,
      ),
      leading: widget.appBarIconClick == null
          ? const SizedBox(
              width: 0,
              height: 0,
            )
          : GestureDetector(
              onTap: () {
                widget.appBarIconClick!();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.arrow_back,
                  weight: 1,
                  color: Colors.white,
                ),
              ),
            ),
      title: AutoSizeText(
        widget.appBarheaderText,
        style: GoogleFonts.lato(
          color: const Color(0xFFFFFFFF),
          fontSize: 16.0,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w600, // FontWeight.bold for a bolder text
          height: 1.0, // line height (1.0 is the default)
        ),
      ),
      centerTitle: true,
      bottom: widget.appBarTabBar ?? widget.appBarTabBar,
    );
  }
}

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Color appbarColor;
  const AppbarWidget({super.key, required this.appbarColor});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      toolbarHeight: 0,
      backgroundColor: appbarColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: appbarColor,
        // statusBarBrightness: Brightness.dark,
        // statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Platform.isIOS
            ? Brightness.light
            : appbarColor == const Color(0xffffffff)
                ? Brightness.dark
                : Brightness.light,
        statusBarIconBrightness: Platform.isIOS
            ? Brightness.light
            : appbarColor == const Color(0xffffffff)
                ? Brightness.dark
                : Brightness.light,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(0);
}

class CustomParentWidgetV2 extends StatefulWidget {
  final Widget? floatingButton;
  final String appBarHeaderText;
  final Function? appBarIconClick;
  final TabBar? appBarTabBar;
  final Widget child;
  final bool? hasPadding;
  final Color? bodyColor;
  final bool? canPop;

  const CustomParentWidgetV2({
    Key? key,
    required this.child,
    required this.appBarHeaderText,
    this.appBarIconClick,
    this.hasPadding = true,
    this.floatingButton,
    this.bodyColor,
    this.canPop = false,
    this.appBarTabBar,
  }) : super(key: key);

  @override
  State<CustomParentWidgetV2> createState() => _CustomParentWidgetV2State();
}

class _CustomParentWidgetV2State extends State<CustomParentWidgetV2> {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
            textScaler:
                TextScaler.linear(1)), // modified TextScaler to textScaleFactor
        child: PopScope(
            canPop: widget.canPop!,
            child: widget.floatingButton == null
                ? Scaffold(
                    appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(kToolbarHeight),
                      child: _buildAppBar(),
                    ),
                    body: _buildChild(),
                  )
                : Scaffold(
                    floatingActionButton: widget.floatingButton!,
                    appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(kToolbarHeight),
                      child: _buildAppBar(),
                    ),
                    body: _buildChild(),
                  )),
      );
    });
  }

  Widget _buildChild() {
    return PopScope(
      canPop: widget.canPop!,
      child: SafeArea(
        child: Container(
          color: widget.bodyColor ?? AppColor.bodyColor,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: !widget.hasPadding!
              ? widget.child
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: widget.child,
                ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Color(0xFFFFFFFF),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColor.primaryColor,
        statusBarBrightness:
            Platform.isIOS ? Brightness.light : Brightness.dark,
        statusBarIconBrightness:
            Platform.isIOS ? Brightness.light : Brightness.dark,
      ),
      leading: widget.appBarIconClick == null
          ? const SizedBox(
              width: 0,
              height: 0,
            )
          : GestureDetector(
              onTap: () {
                widget.appBarIconClick!();
              },
              child: const Icon(
                Icons.arrow_back_ios_new,
                weight: 1,
                color: Colors.black,
                size: 16,
              ),
            ),
      title: Row(
        children: [
          Expanded(
            child: AutoSizeText(
              widget.appBarHeaderText,
              style: GoogleFonts.lato(
                color: Colors.black,
                fontSize: 16.0,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
      centerTitle: false,
      bottom: widget.appBarTabBar ?? widget.appBarTabBar,
      titleSpacing: -4,
    );
  }
}
