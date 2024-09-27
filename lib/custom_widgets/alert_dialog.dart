import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';

class CustomDialog {
  void internetErrorDialog(
    BuildContext context,
    VoidCallback onTapConfirm,
  ) {
    Get.dialog(dialogBody(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: SvgPicture.asset("assets/images/no_net.svg"),
          ),
          Container(height: 20),
          CustomTitle(
            text: "Internet Error",
            color: Color(0xFF0D0E0E),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            maxlines: 1,
          ),
          const SizedBox(height: 15),
          // Paragraph
          CustomParagraph(
            text: "Please check your internet connection and try again.",
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          // Buttons
          Container(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: CustomDialogButton(
                  btnColor: AppColor.primaryColor,
                  txtColor: Colors.white,
                  borderColor: AppColor.primaryColor,
                  text: "Okay",
                  onTap: onTapConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  void serverErrorDialog(
    BuildContext context,
    VoidCallback onTapConfirm,
  ) {
    Get.dialog(dialogBody(
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: SvgPicture.asset("assets/images/server_error.svg"),
          ),
          Container(height: 20),
          CustomTitle(
            text: "Server Error",
            color: Color(0xFF0D0E0E),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            maxlines: 1,
          ),
          const SizedBox(height: 15),
          // Paragraph
          CustomParagraph(
            text: "Error while connecting to server, Please try again.",
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          // Buttons
          Container(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: CustomDialogButton(
                  btnColor: AppColor.primaryColor,
                  txtColor: Colors.white,
                  borderColor: AppColor.primaryColor,
                  text: "Okay",
                  onTap: onTapConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  void errorDialog(
    BuildContext context,
    String title,
    String paragraph,
    VoidCallback onTapConfirm, {
    Color? btnOkBackgroundColor,
    Color? btnOkTextColor,
  }) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                width: MediaQuery.of(Get.context!).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: SvgPicture.asset("assets/images/error.svg"),
                    ),
                    Container(height: 20),
                    CustomTitle(
                      text: title,
                      color: Color(0xFF0D0E0E),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      maxlines: 1,
                    ),
                    const SizedBox(height: 15),
                    // Paragraph
                    CustomParagraph(
                      text: paragraph,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),
                    // Single Button
                    Container(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: CustomDialogButton(
                            btnColor: AppColor.primaryColor,
                            txtColor: Colors.white,
                            borderColor: AppColor.primaryColor,
                            text: "Okay",
                            onTap: onTapConfirm,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  void infoDialog(
    String title,
    String paragraph,
    VoidCallback onTapConfirm, {
    Color? btnOkBackgroundColor,
    Color? btnOkTextColor,
  }) {
    Get.dialog(dialogBody(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: SvgPicture.asset("assets/images/info.svg"),
          ),
          Container(height: 20),
          CustomTitle(
            text: title,
            color: Color(0xFF0D0E0E),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            maxlines: 1,
          ),
          const SizedBox(height: 15),
          // Paragraph
          CustomParagraph(
            text: paragraph,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          // Single Button
          Container(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: CustomDialogButton(
                  btnColor: AppColor.primaryColor,
                  txtColor: Colors.white,
                  borderColor: AppColor.primaryColor,
                  text: "Okay",
                  onTap: onTapConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  void successDialog(
    BuildContext context,
    String title,
    String paragraph,
    String btnOk,
    VoidCallback onTapConfirm, {
    Color? btnOkBackgroundColor,
    Color? btnOkTextColor,
  }) {
    Get.dialog(dialogBody(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: SvgPicture.asset("assets/images/success.svg"),
          ),
          Container(height: 20),
          CustomTitle(
            text: title,
            color: Color(0xFF0D0E0E),
            fontSize: 20,
            maxlines: 1,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 15),
          // Paragraph
          CustomParagraph(
            text: paragraph,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          // Buttons
          Container(height: 25),
          // Single Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: CustomDialogButton(
                  btnColor: AppColor.primaryColor,
                  txtColor: Colors.white,
                  borderColor: AppColor.primaryColor,
                  text: btnOk,
                  onTap: onTapConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  void bookingNotice(
    String title,
    String paragraph,
    VoidCallback onClose,
    VoidCallback onConfirm,
  ) {
    Get.dialog(
      noticeBody(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SvgPicture.asset("assets/images/info.svg"),
            ),
            Container(height: 20),
            CustomTitle(
              text: title,
              color: Color(0xFF0D0E0E),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              maxlines: 1,
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: StretchingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      // Paragraph
                      CustomParagraph(
                        text: paragraph,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.start,
                      ),
                      // Buttons
                      Container(height: 25),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: CustomDialogButton(
                      text: "Close",
                      onTap: () {
                        onClose();
                      }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomDialogButton(
                    btnColor: AppColor.primaryColor,
                    txtColor: Colors.white,
                    borderColor: AppColor.primaryColor,
                    text: "Proceed Booking",
                    onTap: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

//FInished
  void confirmationDialog(
    BuildContext context,
    String title,
    String paragraph,
    String btnNot,
    String btnOk,
    VoidCallback onTapClose,
    VoidCallback onTapConfirm, {
    Color? btnNotBackgroundColor,
    Color? btnOkBackgroundColor,
    Color? btnNotTextColor,
    Color? btnOkTextColor,
  }) {
    Get.dialog(
      dialogBody(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTitle(
              text: title,
              color: Color(0xFF0D0E0E),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              maxlines: 1,
            ),
            const SizedBox(height: 15),
            // Paragraph
            CustomParagraph(
              text: paragraph,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.left,
            ),
            // Buttons
            Container(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: CustomDialogButton(text: btnNot, onTap: onTapClose),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomDialogButton(
                    btnColor: AppColor.primaryColor,
                    txtColor: Colors.white,
                    borderColor: AppColor.primaryColor,
                    text: btnOk,
                    onTap: onTapConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void loadingDialog(
    BuildContext context,
  ) {
    Get.dialog(
        loadingBody(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  width: 90,
                  height: 90,
                  child: Center(
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        backgroundColor: Colors.blue.withOpacity(.3),
                        strokeWidth: 5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        barrierColor: Colors.black.withOpacity(0.2));
  }

  Widget noticeBody(Widget? child) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
                height: MediaQuery.of(Get.context!).size.height * .70,
                width: MediaQuery.of(Get.context!).size.width,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: child),
          )
        ]),
      ),
    );
  }

  Widget loadingBody(Widget? child) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
      ),
    );
  }

  Widget dialogBody(Widget? child) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                width: MediaQuery.of(Get.context!).size.width,
                child: child),
          )
        ]),
      ),
    );
  }

  Widget dialogBody2(Widget? child) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                width: MediaQuery.of(Get.context!).size.width,
                child: child),
          )
        ]),
      ),
    );
  }

  void mapLoading(String title) {
    Get.dialog(
      dialogBody(
        Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 150,
                  width: MediaQuery.of(Get.context!).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    image: DecorationImage(
                        image: AssetImage('assets/dashboard_icon/loadBg.png'),
                        fit: BoxFit.cover),
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset('assets/dashboard_icon/loading_map.gif'),
                )
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
              child: CustomParagraph(
                text: "Getting nearest parking within \n$title, please wait...",
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  void snackbarDialog(
      BuildContext context, String text, Color? color, VoidCallback? onTap) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color ?? Colors.red,
        content: Text(text),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Okay',
          onPressed: () {
            // Call onTap only if it is not null
            onTap!();
          },
        ),
      ),
    );
  }

  void snackbarDialog2(
      BuildContext context, String text, Color? color, VoidCallback? onTap) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(text),

        duration: Duration(seconds: 30), // No auto-dismiss
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Okay',
          onPressed: () {
            // Call onTap only if it is not null
            onTap!();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
