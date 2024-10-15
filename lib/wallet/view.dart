// ignore_for_file: prefer_const_constructorss, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/no_data_found.dart';
import 'package:luvpark_get/custom_widgets/no_internet.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:luvpark_get/wallet/controller.dart';
import 'package:luvpark_get/wallet/utils/transaction_details.dart';
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
                                                        text: controller
                                                                .userData
                                                                .isEmpty
                                                            ? "........"
                                                            : toCurrencyString(
                                                                controller
                                                                        .userData[0]
                                                                    [
                                                                    "amount_bal"]),
                                                        color: Colors.black,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.chevron_right_rounded,
                                                  color: AppColor.primaryColor,
                                                ),
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
                                                      ? ""
                                                      : controller.isLoadingCard
                                                              .value
                                                          ? "........"
                                                          : toCurrencyString(
                                                              controller
                                                                  .userData[0][
                                                                      "points_bal"]
                                                                  .toString()),
                                                  color: Colors.black,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.chevron_right_rounded,
                                            color: AppColor.primaryColor,
                                          ),
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

              Column(
                children: controller.unverified.toList(),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 25, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 25, 0, 25),
                          child: CustomParagraph(
                            text: "Wallet Transactions",
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return controller.logs.isEmpty
                                ? SizedBox(
                                    height: 300,
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Column(
                                        children: List.generate(
                                            3,
                                            (index) => Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: ListTile(
                                                    contentPadding:
                                                        EdgeInsets.zero,
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
                                                )),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: [
                                      ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: controller.logs.length,
                                        shrinkWrap: true,
                                        physics:
                                            NeverScrollableScrollPhysics(), // Prevents scroll conflicts
                                        itemBuilder: (context, index) {
                                          var log = controller.logs[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Get.bottomSheet(
                                                  TransactionDetails(
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
                                                text: DateFormat(
                                                        'MMM d, yyyy h:mm a')
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
                                    ],
                                  );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              )

              // Column(
              //   children: [
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         CustomTitle(
              //           text: "Wallet Transactions",
              //           fontWeight: FontWeight.w800,
              //         ),
              //         InkWell(
              //           onTap: () {
              //             Get.to(TransactionHistory());
              //           },
              //           child: CustomTitle(
              //             text: "See all",
              //             color: Colors.blue,
              //           ),
              //         )
              //       ],
              //     ),
              //     SizedBox(
              //       height: 10,
              //     ),
              //     Expanded(
              //       child: LayoutBuilder(builder: (context, constraints) {
              //         return ScrollConfiguration(
              //           behavior: ScrollBehavior().copyWith(overscroll: false),
              //           child: controller.isLoadingLogs.value
              //               ? logShimmer()
              //               : controller.logs.isEmpty
              //                   ? NoDataFound()
              //                   : ListView.separated(
              //                       padding: EdgeInsets.zero,
              //                       itemCount: controller.logs.length,
              //                       itemBuilder: (context, index) {
              //                         return GestureDetector(
              //                           onTap: () {
              //                             Get.bottomSheet(TransactionDetails(
              //                                 data: controller.logs,
              //                                 index: index));
              //                           },
              //                           child: ListTile(
              //                             contentPadding: EdgeInsets.zero,
              //                             leading: SvgPicture.asset(
              //                               fit: BoxFit.cover,
              //                               "assets/images/${controller.logs[index]["tran_desc"] == 'Share a token' ? 'wallet_sharetoken' : controller.logs[index]["tran_desc"] == 'Received token' ? 'wallet_receivetoken' : 'wallet_payparking'}.svg",
              //                               // "assets/images/${controller.logs[index][" "] == 'Share a token' ? 'wallet_sharetoken' : controller.logs[index]["tran_desc"] == 'Received token' ? 'wallet_receivetoken' : 'wallet_payparking'}.svg",
              //                             ),
              //                             title: CustomTitle(
              //                               text: controller.logs[index]
              //                                   ["tran_desc"],
              //                               fontSize: 14,
              //                               fontWeight: FontWeight.w600,
              //                               maxlines: 1,
              //                             ),
              //                             subtitle: CustomParagraph(
              //                               text:
              //                                   DateFormat('MMM d, yyyy h:mm a')
              //                                       .format(DateTime.parse(
              //                                           controller.logs[index]
              //                                               ["tran_date"])),
              //                               fontSize: 12,
              //                               maxlines: 1,
              //                               overflow: TextOverflow.ellipsis,
              //                             ),
              //                             trailing: CustomTitle(
              //                               text: controller.logs[index]
              //                                   ["amount"],
              //                               fontSize: 14,
              //                               fontWeight: FontWeight.w600,
              //                               color: (controller.logs[index]
              //                                               ["tran_desc"] ==
              //                                           'Share a token' ||
              //                                       controller.logs[index]
              //                                               ["tran_desc"] ==
              //                                           'Received token' ||
              //                                       controller.logs[index]
              //                                               ["tran_desc"] ==
              //                                           'Credit top-up')
              //                                   ? Color(0xFF0078FF)
              //                                   : Color(0xFFBD2424),
              //                             ),
              //                           ),
              //                         );
              //                       },
              //                       separatorBuilder: (context, index) =>
              //                           const Divider(
              //                         endIndent: 1,
              //                         height: 1,
              //                       ),
              //                     ),
              //         );
              //       }),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget logShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Container(
              padding: const EdgeInsetsDirectional.all(5),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(7)),
                  border: Border.all(color: Colors.grey.shade200)),
              child: Shimmer.fromColors(
                highlightColor: Colors.grey.shade100,
                baseColor: Colors.grey.shade300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(70)),
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 10,
                                width: 180,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Colors.white,
                                ),
                              ),
                              Container(height: 10),
                              Container(
                                height: 10,
                                width: 150,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          endIndent: 1,
          height: 5,
        ),
      ),
    );
  }
}
