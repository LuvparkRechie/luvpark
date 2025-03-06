// ignore_for_file: prefer_const_constructorss, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/wallet/controller.dart';
import 'package:luvpark/wallet/utils/transaction_details.dart';
import 'package:shimmer/shimmer.dart';

import '../billers/tabContainer.dart';
import '../custom_widgets/app_color.dart';
import '../custom_widgets/variables.dart';
import '../routes/routes.dart';
import '../wallet_ui/wallet_ui.dart';
import 'utils/transaction_history/index.dart';
import 'utils/transaction_history/newwallet.dart';

class WalletScreen extends GetView<WalletController> {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("Wallet"),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Iconsax.arrow_left,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              c1(context),
              SizedBox(height: 20),
              c2(),
              SizedBox(height: 20),
              recentTransactions(context),
            ],
          ),
        ),
      ),
    );
  }

  Expanded recentTransactions(BuildContext context) {
    return Expanded(
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          TabContainer(
            tabEdge: TabEdge.top,
            tabMaxLength: MediaQuery.of(context).size.width / 2,
            borderRadius: BorderRadius.circular(30),
            tabBorderRadius: BorderRadius.circular(30),
            childPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            colors: [
              Colors.white,
            ],
            tabs: [
              CustomTitle(
                text: "Recent Transaction",
                color: AppColor.linkLabel,
              ),
            ],
            child: Column(
              children: [
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
                          : Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: ListView.separated(
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
                                          data: controller.logs, index: index));
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade100),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(30),
                                          bottomLeft: Radius.circular(30),
                                          bottomRight: Radius.circular(10),
                                        ),
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
                                          text: DateFormat('MMM d, yyyy h:mm a')
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
                                          color: double.parse(log["amount"]) < 0
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
                ),
              ],
            ),
          ),
          Container(
            width: 130,
            padding: EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: InkWell(
              onTap: () {
                Get.to(TransactionHistory());
              },
              child: CustomParagraph(
                color: AppColor.primaryColor,
                fontSize: 10,
                text: "See more",
                textAlign: TextAlign.center,
                maxlines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row c2() {
    return Row(
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
                    padding: EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: Colors.blue.shade50,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade50,
                          blurRadius: 1,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Icon(
                      controller.btnData[i]["icon"],
                      color: AppColor.primaryColor,
                      size: 25,
                    ),
                  ),
                  Container(height: 15),
                  CustomParagraph(
                    text: controller.btnData[i]["btn_name"],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2b2b2b),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Stack c1(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: [
        TabContainer(
          tabsStart: 0.6,
          tabEdge: TabEdge.bottom,
          tabMaxLength: MediaQuery.of(context).size.width / 2.5,
          borderRadius: BorderRadius.circular(30),
          tabBorderRadius: BorderRadius.circular(30),
          childPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          colors: [Colors.blue.shade100],
          tabs: [
            Container(
              padding: EdgeInsets.zero,
              height: 30,
              width: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/luvpark.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          child: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                currentBalance(),
                SizedBox(height: 10),
                mobileNumber(),
              ],
            ),
          ),
        ),
        topUp(),
      ],
    );
  }

  InkWell topUp() {
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.walletrechargeload);
      },
      child: Container(
        width: 180,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.add_circle, color: AppColor.primaryColor),
            SizedBox(width: 10),
            CustomTitle(
              fontSize: 12,
              text: "Top Up",
              color: AppColor.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Row mobileNumber() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTitle(
              text: "Mobile Number",
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            SizedBox(height: 5),
            CustomParagraph(
              text: Variables.maskMobileNumber(controller.mobileNo.value,
                  visibleStartDigits: 4, visibleEndDigits: 3),
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              letterSpacing: -.5,
            ),
          ],
        ),
        rewardPoints()
      ],
    );
  }

  Row currentBalance() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTitle(
                text: "Current Balance",
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              Obx(() {
                String balanceText = !controller.isNetConnCard.value
                    ? "........"
                    : controller.isLoadingCard.value
                        ? "........"
                        : !controller.isShowBal.value
                            ? "••••••"
                            : toCurrencyString(
                                controller.userData[0]["amount_bal"]);

                String mainPart = balanceText.split('.')[0];
                String decimalPart = balanceText.split('.').length > 1
                    ? '.' + balanceText.split('.')[1]
                    : '';

                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: mainPart,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 25,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: decimalPart,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: AppColor.iconListColor,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        IconButton(
          onPressed: controller.onShowBal,
          icon: Icon(
            controller.isShowBal.value ? LucideIcons.eyeOff : LucideIcons.eye,
            color: AppColor.primaryColor,
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Column rewardPoints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CustomTitle(
          text: "Reward",
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(height: 20, "assets/images/rewardicon.png"),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: CustomParagraph(
                text: !controller.isNetConnCard.value
                    ? "........"
                    : controller.isLoadingCard.value
                        ? "........"
                        : toCurrencyString(
                            controller.userData[0]["points_bal"].toString()),
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
