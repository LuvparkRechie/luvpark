import 'package:flutter/material.dart';
import 'package:luvpark/classess/variables.dart';

class CustomModal {
  final BuildContext context;
  final bool? isCancel;
  final String? title;
  final String? msg;
  final Function()? onTap;

  const CustomModal(
      {required this.context, this.isCancel, this.title, this.msg, this.onTap});

  loader() => load(MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1)),
        child: SizedBox(
          child: PopScope(
            canPop: isCancel ?? false,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 15,
                    ),
                    // SizedBox(
                    //   height: 30,
                    //   width: 30,
                    //   child: CircularProgressIndicator(
                    //     color: AppColor.secondaryColor,
                    //     backgroundColor: AppColor.mainColor,
                    //   ),
                    // ),
                    Container(
                      height: Variables.screenSize.width * .25,
                      width: Variables.screenSize.width * .25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Image(
                          image: AssetImage("assets/gif/Luvpark_loading.gif")),
                    ),
                    // const SizedBox(
                    //   width: 15,
                    // ),
                    // Expanded(
                    //   child: CustomDisplayText(
                    //     label: title ?? "Loading please wait...",
                    //     fontSize: 14,
                    //     maxLines: 2,
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
          ),
        ),
      ));

  load(Widget child) {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
                child: widget,
              ));
        },
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) {
          return child;
        });
  }
}
