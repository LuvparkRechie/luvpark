import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/onboarding/controller.dart';
import 'package:luvpark/routes/routes.dart';

class MyOnboardingPage extends StatelessWidget {
  const MyOnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        leading: null,
        elevation: 0,
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 40, 15, 0),
          child: GetBuilder<OnboardingController>(builder: (ctxt) {
            return Column(
              children: [
                const Image(
                  image: AssetImage("assets/images/onboardluvpark.png"),
                  width: 189,
                  fit: BoxFit.contain,
                ),
                StretchingOverscrollIndicator(
                  axisDirection: AxisDirection.right,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * .50,
                    child: ScrollConfiguration(
                      behavior: ScrollBehavior().copyWith(overscroll: false),
                      child: PageView(
                        controller: controller.pageController,
                        onPageChanged: (value) {
                          controller.onPageChanged(value);
                        },
                        children: List.generate(
                          controller.sliderData.length,
                          (index) => _buildPage(
                            controller.sliderData[index]["title"],
                            controller.sliderData[index]["subTitle"],
                            controller.sliderData[index]["icon"],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                      ),
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.sliderData.length,
                            (index) => Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.currentPage.value == index
                                    ? AppColor.primaryColor
                                    : const Color(0xFFD9D9D9),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Container(
                      //   height: 20,
                      // ),
                      // CustomButton(
                      //   text: "Log in",
                      //   onPressed: () async {
                      //     CustomDialog().loadingDialog(context);
                      //     await Future.delayed(Duration(seconds: 1));
                      //     Get.back();
                      //     Get.offAndToNamed(Routes.login);
                      //   },
                      // ),
                      // Container(height: 10),
                      // CustomButton(
                      //   bordercolor: AppColor.primaryColor,
                      //   btnColor: Colors.white,
                      //   textColor: AppColor.primaryColor,
                      //   text: "Create Account",
                      //   onPressed: () async {
                      //     CustomDialog().loadingDialog(context);
                      //     await Future.delayed(Duration(seconds: 1));
                      //     Get.back();
                      //     Get.offAndToNamed(Routes.landing);
                      //   },
                      // ),
                      Container(
                        height: MediaQuery.of(context).size.width * .15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Get.offAndToNamed(Routes.login);
                                },
                                child: CustomTitle(
                                  text: "Skip",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            ),
                            Container(width: 10),
                            Expanded(
                              child: CustomNextButton(
                                text: "Next",
                                icon: Icons.arrow_right_alt_outlined,
                                onPressed: controller.btnTap,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * .15,
                      )
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPage(String title, String subTitle, String image) {
    return Column(
      children: [
        Expanded(
          child: SizedBox(
            child: Image(
              image: AssetImage("assets/images/$image.png"),
              width: MediaQuery.of(Get.context!).size.width * .80,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        Center(
          child: CustomTitle(
            text: title,
            maxlines: 1,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          height: 10,
        ),
        Center(
          child: CustomParagraph(
            text: subTitle,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
