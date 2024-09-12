import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
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
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              'assets/images/pu_nointernet.png', // Use the static image name
              fit: BoxFit.cover,
              height: 100,
              width: double.infinity,
            ),
          ),
          // Title
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CustomTitle(
              text: "No Internet",
              fontSize: 16,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Paragraph
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomParagraph(
              text: "Please check your internet connection and try again.",
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: Colors.black54,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Single Button
          Padding(
            padding:
                const EdgeInsets.only(top: 25, right: 15, left: 15, bottom: 16),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: onTapConfirm,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const CustomParagraph(
                  text: "Close",
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.408,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              'assets/images/pu_servererror.png', // Use the static image name
              fit: BoxFit.cover,
              height: 100,
              width: double.infinity,
            ),
          ),
          // Title
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CustomTitle(
              text: "Server Error",
              fontSize: 16,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Paragraph
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomParagraph(
              text: "Error while connecting to server, Please try again.",
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: Colors.black54,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Single Button
          Padding(
            padding:
                const EdgeInsets.only(top: 25, right: 15, left: 15, bottom: 16),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: onTapConfirm,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const CustomParagraph(
                  text: "Close",
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.408,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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
    Get.dialog(dialogBody(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              'assets/images/pu_confirmation.png', // Use the static image name
              fit: BoxFit.cover,
              height: 100,
              width: double.infinity,
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTitle(
              text: title,
              fontSize: 16,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Paragraph
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomParagraph(
              text: paragraph,
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: Colors.black54,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Single Button
          Padding(
            padding:
                const EdgeInsets.only(top: 25, right: 15, left: 15, bottom: 16),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: onTapConfirm,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      btnOkBackgroundColor ?? AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: CustomParagraph(
                  text: "Close",
                  color: btnOkTextColor ?? Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.408,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
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
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              'assets/images/pu_confirmation.png', // Use the static image name
              fit: BoxFit.cover,
              height: 100,
              width: double.infinity,
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTitle(
              text: title,
              fontSize: 16,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Paragraph
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomParagraph(
              text: paragraph,
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: Colors.black54,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Single Button
          Padding(
            padding:
                const EdgeInsets.only(top: 25, right: 15, left: 15, bottom: 16),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: onTapConfirm,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      btnOkBackgroundColor ?? AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: CustomParagraph(
                  text: "Close",
                  color: btnOkTextColor ?? Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.408,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              'assets/images/pu_success.png', // Use the static image name
              fit: BoxFit.cover,
              height: 100,
              width: double.infinity,
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTitle(
              text: title,
              fontSize: 16,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Paragraph
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomParagraph(
              text: paragraph,
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: Colors.black54,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Single Button
          Padding(
            padding:
                const EdgeInsets.only(top: 25, right: 15, left: 15, bottom: 16),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: onTapConfirm,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      btnOkBackgroundColor ?? AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: CustomParagraph(
                  text: btnOk,
                  color: btnOkTextColor ?? Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.408,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
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
    Get.dialog(dialogBody(
      Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              'assets/images/pu_confirmation.png', // Use the static image name
              fit: BoxFit.cover,
              height: 100,
              width: double.infinity,
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTitle(
              text: title,
              fontSize: 16,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Paragraph
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomParagraph(
              text: paragraph,
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: Colors.black54,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Buttons
          Container(height: 10),
          Padding(
            padding:
                const EdgeInsets.only(top: 30, right: 15, left: 15, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextButton(
                      onPressed: onTapClose,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            btnOkBackgroundColor ?? AppColor.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: CustomParagraph(
                        text: btnNot,
                        color: btnOkTextColor ?? Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.408,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextButton(
                      onPressed: onTapConfirm,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            btnNotBackgroundColor ?? AppColor.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: CustomParagraph(
                        text: btnOk,
                        color: btnNotTextColor ?? Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.408,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 20),
        ],
      ),
    ));
  }

  Widget dialogBody(Widget? child) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
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

  void loadingDialog(
    BuildContext context,
  ) {
    Get.dialog(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          ),
        ),
      ],
    ));
  }

  void mapLoading() {
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
                text: "Getting nearest parking,\nplease wait...",
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  void snackbarDialog(BuildContext context, String text, Color? color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color ?? Colors.red,
        content: Text(text),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Okay',
          onPressed: () {},
        ),
      ),
    );
  }

  void customPopUp(
    BuildContext context,
    String title,
    String paragraph,
    String? btnNot,
    String? btnOk, {
    VoidCallback? onTapClose,
    VoidCallback? onTapConfirm,
    Color? btnNotBackgroundColor,
    Color? btnOkBackgroundColor,
    Color? btnNotTextColor,
    Color? btnOkTextColor,
    bool showTwoButtons = true,
    required String imageName, // Add this parameter for the dynamic image name
  }) {
    Get.dialog(dialogBody(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              'assets/images/$imageName.png', // Use the dynamic image name here
              fit: BoxFit.cover,
              height: 100,
              width: double.infinity,
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTitle(
              text: title,
              fontSize: 16,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Paragraph
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomParagraph(
              text: paragraph,
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: Colors.black54,
              textAlign: TextAlign.center,
              letterSpacing: -0.408,
            ),
          ),
          // Buttons
          Padding(
            padding:
                const EdgeInsets.only(top: 25, right: 15, left: 15, bottom: 16),
            child: showTwoButtons
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextButton(
                            onPressed: onTapClose,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  btnNotBackgroundColor ?? Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: CustomParagraph(
                              text: btnNot!,
                              color: btnNotTextColor ?? Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.408,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextButton(
                            onPressed: onTapConfirm,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  btnOkBackgroundColor ?? AppColor.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: CustomParagraph(
                              text: btnOk!,
                              color: btnOkTextColor ?? Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.408,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: TextButton(
                      onPressed: onTapConfirm,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            btnOkBackgroundColor ?? AppColor.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: CustomParagraph(
                        text: btnOk!,
                        color: btnOkTextColor ?? Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.408,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ));
  }
}
