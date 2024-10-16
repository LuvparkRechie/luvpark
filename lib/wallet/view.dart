// ignore_for_file: prefer_const_constructorss, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';

import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/no_data_found.dart';

import 'package:luvpark_get/routes/routes.dart';
import 'package:luvpark_get/wallet/controller.dart';
import 'package:luvpark_get/wallet/utils/transaction_details.dart';
import 'package:shimmer/shimmer.dart';

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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset:
                                Offset(0, 2), // horizontal & vertical offset
                            blurRadius: 6, // softening the shadow
                            spreadRadius: 1, // spread of the shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(7),
                                              topRight: Radius.circular(7),
                                            ),
                                            border: Border(
                                              top: BorderSide(
                                                  color: Colors.black12),
                                              left: BorderSide(
                                                  color: Colors.black12),
                                              right: BorderSide(
                                                  color: Colors.black12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(width: 15),
                                                  Image.asset(
                                                      height: 30,
                                                      "assets/images/logo.png"),
                                                  SizedBox(width: 14),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomParagraph(
                                                        text: "My balance",
                                                      ),
                                                      CustomParagraph(
                                                        text: !controller
                                                                .isNetConnCard
                                                                .value
                                                            ? "........"
                                                            : controller
                                                                    .isLoadingCard
                                                                    .value
                                                                ? "........"
                                                                : toCurrencyString(
                                                                    controller
                                                                            .userData[0]
                                                                        [
                                                                        "amount_bal"]),
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.black,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(7),
                                        bottomRight: Radius.circular(7),
                                      ),
                                      border: Border.all(
                                        color: Colors.black12,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(width: 15),
                                            Image.asset(
                                                height: 30,
                                                "assets/images/rewardicon.png"),
                                            SizedBox(width: 14),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CustomParagraph(
                                                  text: "My rewards",
                                                ),
                                                CustomParagraph(
                                                  text: !controller
                                                          .isNetConnCard.value
                                                      ? "........"
                                                      : controller.isLoadingCard
                                                              .value
                                                          ? "........"
                                                          : toCurrencyString(
                                                              controller
                                                                  .userData[0][
                                                                      "points_bal"]
                                                                  .toString()),
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 23),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        Get.toNamed(Routes.walletrecharge);
                      },
                      icon: SvgPicture.asset(
                        'assets/images/wallet_wallet.svg',
                        height: 20,
                        width: 20,
                      ),
                      label: CustomParagraph(
                        text: "Load",
                        fontSize: 12,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.scafColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(41),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(Routes.walletsend);
                      },
                      icon: SvgPicture.asset(
                        'assets/images/wallet_send.svg',
                        height: 20,
                        width: 20,
                      ),
                      label: CustomParagraph(
                        text: "Send",
                        fontSize: 12,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.scafColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(41),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(Routes.qrwallet);
                      },
                      icon: SvgPicture.asset(
                        'assets/images/wallet_qr.svg',
                        height: 20,
                        width: 20,
                      ),
                      label: CustomParagraph(
                        text: "QR Code",
                        fontSize: 12,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.scafColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(41),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 25, 25),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomParagraph(
                              text: "Current Transactions",
                              color: Colors.black,
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
                                    padding: EdgeInsets.zero,
                                    itemCount: controller.logs.length,
                                    itemBuilder: (context, index) {
                                      var log = controller.logs[index];
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
                                            "assets/images/${log["tran_desc"] == 'Share a token' ? 'wallet_sharetoken' : log["tran_desc"] == 'Received token' ? 'wallet_receivetoken' : 'wallet_payparking'}.svg",
                                          ),
                                          title: CustomTitle(
                                            text: log["tran_desc"],
                                            fontSize: 14,
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
                                            color: (log["tran_desc"] ==
                                                        'Share a token' ||
                                                    log["tran_desc"] ==
                                                        'Received token' ||
                                                    log["tran_desc"] ==
                                                        'Credit top-up')
                                                ? Color(0xFF0078FF)
                                                : Color(0xFFBD2424),
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
