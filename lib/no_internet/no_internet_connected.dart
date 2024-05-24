import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class NoInternetConnected extends StatefulWidget {
  final Function? onTap;
  final double? size;
  const NoInternetConnected({super.key, this.onTap, this.size});

  @override
  State<NoInternetConnected> createState() => _NoInternetConnectedState();
}

class _NoInternetConnectedState extends State<NoInternetConnected> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: InkWell(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onTap!();
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              height: widget.size ?? MediaQuery.of(context).size.height * .20,
              width: widget.size ?? MediaQuery.of(context).size.width / 2,
              image: const AssetImage("assets/images/no_internet.png"),
            ),
            Container(
              height: 20,
            ),
            CustomDisplayText(
                label: "Please check your internet connection.",
                fontWeight: FontWeight.normal,
                color: AppColor.textSubColor,
                fontSize: 12),
            Container(
              height: 10,
            ),
            if (widget.onTap != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.refresh,
                    size: 17,
                  ),
                  CustomDisplayText(
                      label: " Tap to retry",
                      fontWeight: FontWeight.normal,
                      color: AppColor.textSubColor,
                      fontSize: 12),
                ],
              )
          ],
        ),
      ),
    );
  }
}

class NoDataFound extends StatefulWidget {
  final double? size;
  final Function? onTap;
  final String? textText;
  const NoDataFound({super.key, this.size, this.onTap, this.textText});

  @override
  State<NoDataFound> createState() => _NoDataFoundState();
}

class _NoDataFoundState extends State<NoDataFound> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: InkWell(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              height: widget.size ?? 100,
              width: widget.size ?? 80,
              image: const AssetImage("assets/images/no_data.png"),
            ),
            Container(
              height: 10,
            ),
            CustomDisplayText(
                label: widget.textText ?? "No data found",
                fontWeight: FontWeight.w500,
                color: AppColor.textSubColor,
                alignment: TextAlign.center,
                maxLines: 2,
                minFontsize: 1,
                fontSize: 14),
            Container(
              height: 10,
            ),
            widget.onTap != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.refresh,
                        size: 17,
                      ),
                      CustomDisplayText(
                        label: " Tap to retry",
                        fontWeight: FontWeight.normal,
                        color: AppColor.textSubColor,
                        fontSize: 12,
                      ),
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
