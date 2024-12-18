// ignore_for_file: prefer_const_constructorss, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:luvpark/wallet/controller.dart';
import 'package:luvpark/wallet/utils/transaction_details.dart';
import 'package:shimmer/shimmer.dart';

import '../auth/authentication.dart';
import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/app_color.dart';
import 'utils/transaction_history/index.dart';

class WalletScreen extends GetView<WalletController> {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    height: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 23),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                        border: Border(
                          left: BorderSide(width: 1, color: Color(0xFFDFE7EF)),
                          top: BorderSide(color: Color(0xFFDFE7EF)),
                          right: BorderSide(width: 1, color: Color(0xFFDFE7EF)),
                          bottom:
                              BorderSide(width: 1, color: Color(0xFFDFE7EF)),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                    height: 30, "assets/images/logo.png"),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomParagraph(
                                        text: "My balance",
                                      ),
                                      CustomTitle(
                                        text: !controller.isNetConnCard.value
                                            ? "........"
                                            : controller.isLoadingCard.value
                                                ? "........"
                                                : toCurrencyString(controller
                                                    .userData[0]["amount_bal"]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.black12,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                            child: Row(
                              children: [
                                Image.asset(
                                    height: 30, "assets/images/rewardicon.png"),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomParagraph(
                                        text: "My rewards",
                                      ),
                                      CustomTitle(
                                        text: !controller.isNetConnCard.value
                                            ? "........"
                                            : controller.isLoadingCard.value
                                                ? "........"
                                                : toCurrencyString(controller
                                                    .userData[0]["points_bal"]
                                                    .toString()),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 23),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      overlayColor:
                          MaterialStatePropertyAll(Colors.transparent),
                      onTap: () async {
                        final item = await Authentication().getUserData2();
                        String? fname = item["first_name"];

                        if (fname == null || fname.toString().isEmpty) {
                          CustomDialog().infoDialog("Unverified Account",
                              "Complete your account information to access the requested service.\nGo to profile and update your account.",
                              () {
                            Get.back();
                          });
                          return;
                        }
                        Get.toNamed(Routes.walletrecharge);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3.6,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 13),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side:
                                BorderSide(width: 1, color: Color(0xFFDFE7EF)),
                            borderRadius: BorderRadius.circular(41),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/wallet_wallet.svg',
                              height: 20,
                              width: 20,
                            ),
                            Container(
                              width: 10,
                            ),
                            CustomParagraph(
                              text: "Load",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 5),
                    InkWell(
                      overlayColor:
                          MaterialStatePropertyAll(Colors.transparent),
                      onTap: () {
                        Get.toNamed(Routes.send2);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3.6,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 13),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side:
                                BorderSide(width: 1, color: Color(0xFFDFE7EF)),
                            borderRadius: BorderRadius.circular(41),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/wallet_send.svg',
                              height: 20,
                              width: 20,
                            ),
                            Container(
                              width: 10,
                            ),
                            CustomParagraph(
                              text: "Send",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 5),
                    InkWell(
                      overlayColor:
                          MaterialStatePropertyAll(Colors.transparent),
                      onTap: () {
                        Get.toNamed(Routes.qrwallet);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3.2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 13),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side:
                                BorderSide(width: 1, color: Color(0xFFDFE7EF)),
                            borderRadius: BorderRadius.circular(41),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/wallet_qr.svg',
                              height: 20,
                              width: 20,
                            ),
                            Container(
                              width: 5,
                            ),
                            CustomParagraph(
                              text: "QR Code",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
                child: Container(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTitle(
                              text: "Current Transactions",
                              fontSize: 16,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(TransactionHistory());
                              },
                              child: CustomParagraph(
                                text: "See all",
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
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
                                : ListView.builder(
                                    physics: BouncingScrollPhysics(
                                        decelerationRate:
                                            ScrollDecelerationRate.fast),
                                    padding: EdgeInsets.zero,
                                    itemCount: controller.logs.length,
                                    itemBuilder: (context, index) {
                                      var log = controller.logs[index];
                                      String trans = log["tran_desc"]
                                          .toString()
                                          .toLowerCase();
                                      String img = "";
                                      if (trans.contains("share")) {
                                        img = "wallet_sharetoken";
                                      } else if (trans.contains("received")) {
                                        img = "wallet_receivetoken";
                                      } else if (trans.contains("credit")) {
                                        img = "wallet_receivetoken";
                                      } else {
                                        img = "wallet_payparking";
                                      }
                                      return GestureDetector(
                                        onTap: () {
                                          Get.bottomSheet(TransactionDetails(
                                              data: controller.logs,
                                              index: index));
                                        },
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: SvgPicture.asset(
                                            fit: BoxFit.cover,
                                            "assets/images/$img.svg",
                                          ),
                                          title: CustomTitle(
                                            text: log["tran_desc"],
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            maxlines: 1,
                                          ),
                                          subtitle: CustomParagraph(
                                            text:
                                                DateFormat('MMM d, yyyy h:mm a')
                                                    .format(DateTime.parse(
                                                        log["tran_date"])),
                                            fontSize: 12,
                                            maxlines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
