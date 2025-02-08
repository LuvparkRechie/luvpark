// ignore_for_file: prefer_const_constructorss, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:luvpark/wallet/controller.dart';
import 'package:luvpark/wallet/utils/transaction_details.dart';
import 'package:shimmer/shimmer.dart';

import '../custom_widgets/app_color.dart';
import '../custom_widgets/variables.dart';
import 'utils/transaction_history/index.dart';

class WalletScreen extends GetView<WalletController> {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: CustomAppbar(
        elevation: 0,
        title: "My Wallet",
        hasBtnColor: true,
        onTap: () {
          Get.back();
        },
      ),
      body: Obx(
        () => SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    color: Color(0xFFE8F0F9),
                    width: double.infinity,
                    height: 80,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 23),
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.1), // Light shadow
                            blurRadius: 8, // Soft blur
                            spreadRadius: 2, // Spread effect
                            offset: Offset(0, 4), // Shadow positioned below
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomParagraph(
                                      text: "Current Balance",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                    CustomTitle(
                                      fontSize: 25,
                                      text: !controller.isNetConnCard.value
                                          ? "........"
                                          : controller.isLoadingCard.value
                                              ? "........"
                                              : !controller.isShowBal.value
                                                  ? "••••••"
                                                  : toCurrencyString(
                                                      controller.userData[0]
                                                          ["amount_bal"],
                                                    ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: controller.onShowBal,
                                icon: Icon(
                                  controller.isShowBal.value
                                      ? LucideIcons.eyeOff
                                      : LucideIcons.eye,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          Container(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomParagraph(
                                      text: "Mobile Number",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: CustomParagraph(
                                        text: Variables.maskMobileNumber(
                                            controller.mobileNo.value,
                                            visibleStartDigits: 4,
                                            visibleEndDigits: 3),
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                        letterSpacing: -.5,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: CustomParagraph(
                                        text: "Reward",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Image.asset(
                                              height: 20,
                                              "assets/images/rewardicon.png"),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: CustomParagraph(
                                              text: !controller
                                                      .isNetConnCard.value
                                                  ? "........"
                                                  : controller
                                                          .isLoadingCard.value
                                                      ? "........"
                                                      : toCurrencyString(
                                                          controller.userData[0]
                                                                  ["points_bal"]
                                                              .toString()),
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < controller.btnData.length; i++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            controller.onBtnTap(i);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      const Color.fromARGB(255, 250, 249, 249),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  controller.btnData[i]["icon"],
                                  color: AppColor.primaryColor,
                                  size: 20,
                                ),
                              ),
                              Container(height: 15),
                              CustomParagraph(
                                text: controller.btnData[i]["btn_name"],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                child: InkWell(
                  onTap: () {
                    Get.toNamed(Routes.myaccount);
                  },
                  child: Column(
                    children: controller.unverified.toList(),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 20, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomParagraph(
                            text: "Recent Transaction",
                            fontSize: 16,
                            color: AppColor.headerColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(TransactionHistory());
                            },
                            child: CustomParagraph(
                              text: "See all",
                              fontWeight: FontWeight.w400,
                              letterSpacing: -.5,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: controller.isLoadingLogs.value
                          ? Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: 10,
                                itemBuilder: (context, index) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      color: Colors.grey[300],
                                    ),
                                    title: Container(
                                      width: double.infinity,
                                      height: 16,
                                      color: Colors.grey[300],
                                    ),
                                    subtitle: Container(
                                      width: 15,
                                      height: 14,
                                      color: Colors.grey[300],
                                    ),
                                    trailing: Container(
                                      width: 60,
                                      height: 16,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : controller.logs.isEmpty
                              ? NoDataFound()
                              : ListView.separated(
                                  physics: BouncingScrollPhysics(
                                      decelerationRate:
                                          ScrollDecelerationRate.fast),
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  itemCount: controller.logs.length,
                                  itemBuilder: (context, index) {
                                    var log = controller.logs[index];

                                    return GestureDetector(
                                      onTap: () {
                                        Get.bottomSheet(TransactionDetails(
                                            data: controller.logs,
                                            index: index));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: CustomParagraph(
                                            text: log["tran_desc"],
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            maxlines: 1,
                                            letterSpacing: -.5,
                                            color: AppColor.headerColor,
                                          ),
                                          subtitle: CustomParagraph(
                                            text:
                                                DateFormat('MMM d, yyyy h:mm a')
                                                    .format(DateTime.parse(
                                                        log["tran_date"])),
                                            fontSize: 12,
                                            maxlines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            letterSpacing: -.5,
                                          ),
                                          trailing: CustomTitle(
                                            text: log["amount"],
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                double.parse(log["amount"]) < 0
                                                    ? const Color(0xFFFF0000)
                                                    : const Color(0xFF0078FF),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return SizedBox(height: 10);
                                  },
                                ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
