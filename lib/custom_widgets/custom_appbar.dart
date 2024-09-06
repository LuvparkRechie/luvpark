import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final PreferredSizeWidget? bottom;
  final double elevation;

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
      this.preferredSize = const Size.fromHeight(kToolbarHeight)});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      centerTitle: true,
      backgroundColor: bgColor ?? Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: bgColor ?? Colors.white,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness:
            bgColor != null ? Brightness.light : Brightness.dark,
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: InkWell(
          onTap: () {
            // defaultBack
            if (onTap == null) {
              Get.back();
              return;
            }
            onTap!();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.chevron_left,
                color: textColor ?? Colors.black,
              ),
              CustomParagraph(
                text: "Back",
                fontSize: 14,
                color: titleColor ?? Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
      leadingWidth: 100,
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
