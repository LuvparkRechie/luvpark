// ignore_for_file: prefer_const_constructorss, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:convert';

import 'package:flutter/material.dart';
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
          title: "My Wallet",
          onTap: () {
            Get.back();
          },
        ),
        body: Obx(
          () => SafeArea(
            child: !controller.isNetConnCard.value
                ? NoInternetConnected(
                    onTap: controller.onRefresh,
                  )
                : RefreshIndicator(
                    onRefresh: controller.onRefresh,
                    child: StretchingOverscrollIndicator(
                      axisDirection: AxisDirection.down,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 13, 15, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildProfileImage(),
                            SizedBox(
                              height: 20,
                            ),
                            controller.isLoadingCard.value
                                ? Shimmer.fromColors(
                                    highlightColor: Colors.grey.shade100,
                                    baseColor: Colors.grey.shade300,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          height: 170,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(7)),
                                            border: Border.all(
                                                color: Colors.grey.shade200),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Stack(
                                    fit: StackFit.loose,
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(15, 20, 15, 15),
                                        height: 170,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/images/wallet_bg.png"),
                                              fit: BoxFit.fill),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Image(
                                                  height: 30,
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                    "assets/images/wallet_luvpark1.png",
                                                  ),
                                                ),
                                                Container(
                                                  width: 10,
                                                ),
                                                CustomTitle(
                                                  text: 'luvpark Balance',
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                            Container(height: 10),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: CustomParagraph(
                                                text: controller
                                                        .userData.isEmpty
                                                    ? "........"
                                                    : toCurrencyString(
                                                        controller.userData[0]
                                                            ["amount_bal"]),
                                                color: Color(0xFFF8F8F8),
                                                fontSize: 30,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 15,
                                        left: 15,
                                        right: 15,
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Iconsax.gift,
                                                    size: 20,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Rewards: ',
                                                          style: paragraphStyle(
                                                            color: Color(
                                                                0xFFF4FAFF),
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: !controller
                                                                  .isNetConnCard
                                                                  .value
                                                              ? ""
                                                              : controller
                                                                      .isLoadingCard
                                                                      .value
                                                                  ? "..."
                                                                  : toCurrencyString(controller
                                                                      .userData[
                                                                          0][
                                                                          "points_bal"]
                                                                      .toString()),
                                                          style: paragraphStyle(
                                                            color: Color(
                                                                0xFFF4FAFF),
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
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
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    controller.isLoadingCard.value
                                        ? Shimmer.fromColors(
                                            highlightColor:
                                                Colors.grey.shade100,
                                            baseColor: Colors.grey.shade300,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle),
                                                ),
                                              ],
                                            ),
                                          )
                                        : InkWell(
                                            onTap: () async {
                                              final item =
                                                  await Authentication()
                                                      .getUserData2();
                                              String? fname =
                                                  item["first_name"];

                                              if (fname == null) {
                                                // ignore: use_build_context_synchronously
                                                CustomDialog().errorDialog(
                                                    // ignore: use_build_context_synchronously
                                                    context,
                                                    "Attention",
                                                    "Complete your account information to access the requested service.\nGo to profile and update your account.",
                                                    () {
                                                  Get.back();
                                                });
                                                return;
                                              }
                                              Get.toNamed(
                                                  Routes.walletrecharge);
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  width: 50,
                                                  height: 50,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFFE0EEFF),
                                                  ),
                                                  child: Icon(
                                                    LucideIcons.walletCards,
                                                    color:
                                                        AppColor.primaryColor,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                CustomLinkLabel(
                                                  text: "Load",
                                                  letterSpacing: -0.32,
                                                )
                                              ],
                                            ),
                                          ),
                                    controller.isLoadingCard.value
                                        ? Shimmer.fromColors(
                                            highlightColor:
                                                Colors.grey.shade100,
                                            baseColor: Colors.grey.shade300,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle),
                                                ),
                                              ],
                                            ),
                                          )
                                        : InkWell(
                                            onTap: () async {
                                              Get.toNamed(Routes.walletsend,
                                                  arguments: controller
                                                      .getUserBalance);
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                    padding: EdgeInsets.all(10),
                                                    width: 50,
                                                    height: 50,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFFE0EEFF),
                                                    ),
                                                    child: Icon(
                                                      LucideIcons
                                                          .arrowLeftRight,
                                                      color:
                                                          AppColor.primaryColor,
                                                    )),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                CustomLinkLabel(
                                                  text: "Send",
                                                  letterSpacing: -0.32,
                                                )
                                              ],
                                            ),
                                          ),
                                    controller.isLoadingCard.value
                                        ? Shimmer.fromColors(
                                            highlightColor:
                                                Colors.grey.shade100,
                                            baseColor: Colors.grey.shade300,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle),
                                                ),
                                              ],
                                            ),
                                          )
                                        : InkWell(
                                            onTap: () {
                                              Get.toNamed(Routes.qrwallet);
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  width: 50,
                                                  height: 50,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFFE0EEFF),
                                                  ),
                                                  child: SvgPicture.asset(
                                                    "assets/images/wallet_icons_qr.svg",
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                CustomLinkLabel(
                                                  text: "QR Code",
                                                  letterSpacing: -0.32,
                                                )
                                              ],
                                            ),
                                          ),
                                    SizedBox(
                                      // height: 50,
                                      width: 50,
                                    ),
                                  ]),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            // Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTitle(
                                  text: "Recent Activity",
                                  fontWeight: FontWeight.w800,
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.to(TransactionHistory());
                                  },
                                  child: CustomTitle(
                                    text: "See all",
                                    color: Colors.blue,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                return ScrollConfiguration(
                                  behavior: ScrollBehavior()
                                      .copyWith(overscroll: false),
                                  child: controller.isLoadingLogs.value
                                      ? logShimmer()
                                      : controller.logs.isEmpty
                                          ? NoDataFound()
                                          : ListView.separated(
                                              padding: EdgeInsets.zero,
                                              itemCount: controller.logs.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    Get.bottomSheet(
                                                        TransactionDetails(
                                                            data:
                                                                controller.logs,
                                                            index: index));
                                                  },
                                                  child: ListTile(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    leading: SvgPicture.asset(
                                                      fit: BoxFit.cover,
                                                      "assets/images/${controller.logs[index][" "] == 'Share a token' ? 'wallet_sharetoken' : controller.logs[index]["tran_desc"] == 'Received token' ? 'wallet_receivetoken' : 'wallet_payparking'}.svg",
                                                    ),
                                                    title: CustomTitle(
                                                      text:
                                                          controller.logs[index]
                                                              ["tran_desc"],
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      maxlines: 1,
                                                    ),
                                                    subtitle: CustomParagraph(
                                                      text: DateFormat(
                                                              'MMM d, yyyy h:mm a')
                                                          .format(DateTime
                                                              .parse(controller
                                                                          .logs[
                                                                      index][
                                                                  "tran_date"])),
                                                      fontSize: 12,
                                                      maxlines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    trailing: CustomTitle(
                                                      text:
                                                          controller.logs[index]
                                                              ["amount"],
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: (controller.logs[index]["tran_desc"] == 'Share a token' ||
                                                              controller.logs[
                                                                          index]
                                                                      [
                                                                      "tran_desc"] ==
                                                                  'Received token' ||
                                                              controller.logs[
                                                                          index]
                                                                      [
                                                                      "tran_desc"] ==
                                                                  'Credit top-up')
                                                          ? Color(0xFF0078FF)
                                                          : Color(0xFFBD2424),
                                                    ),
                                                  ),
                                                );
                                              },
                                              separatorBuilder:
                                                  (context, index) =>
                                                      const Divider(
                                                endIndent: 1,
                                                height: 1,
                                              ),
                                            ),
                                );
                              }),
                            ),
                            Container(height: 5),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ));
  }

  Widget buildProfileImage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        controller.userImage.value.isEmpty
            ? Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColor.primaryColor.withOpacity(.6))),
                child: Icon(
                  Icons.person,
                  color: Colors.blueAccent,
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.memory(
                  base64Decode(controller.userImage.value),
                  gaplessPlayback: true,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: CustomTitle(
            fontSize: 20,
            text: controller.fname.value,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.41,
            maxlines: 1,
          ),
        ),
      ],
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

class LoadingTransaction extends StatelessWidget {
  const LoadingTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 20,
        padding: const EdgeInsets.only(top: 15, bottom: 5, left: 15, right: 15),
        physics: ScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.grey.shade100, width: 1.5),
                borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 13,
                    width: 200,
                    color: Colors.grey[100],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 13,
                    width: 200,
                    color: Colors.grey[100],
                  ),
                ],
              ),
              trailing: Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade100),
              ),
            ),
          );
        },
      ),
    );
  }
}
