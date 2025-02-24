import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/my_account/controller.dart';

import '../custom_widgets/no_data_found.dart';

class MyAccount extends GetView<MyAccountScreenController> {
  const MyAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppbar(
          elevation: 0,
          titleSize: 20,
          textColor: Colors.white,
          titleColor: Colors.white,
          bgColor: Colors.transparent,
          btnColor: null,
          title: "My Profile",
          onTap: () {
            Get.back();
            controller.callBack();
          },
        ),
        body: controller.isLoading.value
            ? const PageLoader()
            : Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/images/profile_bg.png"),
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Column(children: controller.heroTag),
                              // Edit button
                              Positioned(
                                right: -5,
                                bottom: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    controller.showBottomSheetCamera();
                                  },
                                  child: SvgPicture.asset(
                                    'assets/drawer_icon/editpicture.svg',
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          CustomTitle(
                            text: controller.myName.value,
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.normal,
                            textAlign: TextAlign.center,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.408,
                          ),
                          CustomParagraph(
                            text: "+${controller.userData[0]['mobile_no']}",
                            color: const Color.fromARGB(255, 240, 240, 240),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      color: AppColor.bodyColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTitle(
                                  text: "Personal Details",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.primaryColor,
                                  maxlines: 2,
                                ),
                              ),
                              Container(width: 15),
                              OutlinedButton(
                                onPressed: () {
                                  controller.getRegions();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets
                                      .zero, // Rely on container for padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20), // Rounded corners
                                  ),
                                  side: BorderSide(
                                      color: AppColor
                                          .primaryColor), // Custom border color
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Center(
                                    child: CustomParagraph(
                                      text: "Update Profile",
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Container(height: 20),
                          Expanded(
                            child: controller.userData[0]['first_name'] == null
                                ? const NoDataFound(
                                    text:
                                        "No personal data to be displayed. \nplease update your profile.",
                                  )
                                : StretchingOverscrollIndicator(
                                    axisDirection: AxisDirection.down,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const CustomParagraph(
                                                      text: "Civil Status",
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    Container(height: 5),
                                                    CustomParagraph(
                                                      fontSize: 12,
                                                      text: controller
                                                              .civilStatus
                                                              .value
                                                              .isEmpty
                                                          ? "No civil status provided"
                                                          : controller
                                                              .civilStatus
                                                              .value,
                                                    ),
                                                    Divider(
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const CustomParagraph(
                                                      text: "Gender",
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                    Container(height: 5),
                                                    CustomParagraph(
                                                        fontSize: 12,
                                                        text: controller.gender
                                                                .value.isEmpty
                                                            ? "No gender provided"
                                                            : controller
                                                                .gender.value),
                                                    Divider(
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(height: 10),
                                          const CustomParagraph(
                                            text: "Birthday",
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          Container(height: 5),
                                          CustomParagraph(
                                              fontSize: 12,
                                              text: Variables.convertBday(
                                                  controller.userData[0]
                                                      ['birthday'])),
                                          Divider(
                                            color: Colors.grey.shade500,
                                          ),
                                          Container(height: 10),
                                          const CustomParagraph(
                                            text: "Address",
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          Container(height: 5),
                                          CustomParagraph(
                                            fontSize: 12,
                                            text: controller.myAddress.value,
                                          ),
                                          Divider(
                                            color: Colors.grey.shade500,
                                          ),
                                          Container(height: 10),
                                          const CustomParagraph(
                                            text: "Province",
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          Container(height: 5),
                                          CustomParagraph(
                                              fontSize: 12,
                                              text: controller.province.value),
                                          Divider(
                                            color: Colors.grey.shade500,
                                          ),
                                          Container(height: 10),
                                          const CustomParagraph(
                                            text: "Zip Code",
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          Container(height: 5),
                                          CustomParagraph(
                                              fontSize: 12,
                                              text: controller.userData[0]
                                                          ['zip_code'] ==
                                                      null
                                                  ? "No zip code provided"
                                                  : controller.userData[0]
                                                          ['zip_code']
                                                      .toString()),
                                          Divider(
                                            color: Colors.grey.shade500,
                                          ),
                                          Container(height: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
