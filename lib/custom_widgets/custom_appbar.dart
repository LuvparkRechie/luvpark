import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final Function? onTap;
  final String? title;
  final double? titleSize;
  final List<Widget>? action;
  final Color? titleColor;
  final Color? textColor;
  final Color? btnColor;
  final Brightness? statusBarBrightness;
  final PreferredSizeWidget? bottom;
  final double elevation;
  final bool hasBtnColor;

  final Color? bgColor;
  const CustomAppbar(
      {super.key,
      this.onTap,
      this.title,
      this.action,
      this.bgColor,
      this.titleSize,
      this.bottom,
      this.titleColor,
      this.elevation = 0.3,
      this.textColor,
      this.preferredSize = const Size.fromHeight(kToolbarHeight),
      this.btnColor = const Color(0xFF0078FF),
      this.hasBtnColor = true,
      this.statusBarBrightness});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      centerTitle: true,
      backgroundColor: bgColor ?? Color(0xFFE8F0F9),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: bgColor ?? Color(0xFFE8F0F9),
        statusBarBrightness: statusBarBrightness ?? Brightness.light,
        statusBarIconBrightness: statusBarBrightness ?? Brightness.dark,
      ),
      leading: InkWell(
        onTap: () {
          if (onTap == null) {
            Get.back();
            return;
          }
          onTap!();
        },
        child: Center(
          child: Container(
            width: 44,
            height: 32,
            //  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: hasBtnColor ? btnColor : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(43),
              ),
              shadows: [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/arrow-left.svg',
                width: 16.0,
                height: 16.0,
              ),
            ),
          ),
        ),
      ),
      title: title == null
          ? null
          : CustomTitle(
              text: title!,
              fontSize: titleSize ?? 16,
              fontWeight: FontWeight.w900,
              color: titleColor ?? Colors.black,
            ),
      actions: action,
      bottom: bottom ?? bottom,
    );
  }
}
