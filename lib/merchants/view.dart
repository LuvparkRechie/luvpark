import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/merchants/controller.dart';

import '../custom_widgets/custom_text.dart';
import '../custom_widgets/no_data_found.dart';
import '../custom_widgets/no_internet.dart';
import '../custom_widgets/page_loader.dart';
import '../wallet_qr/paymerchant/view.dart';

class MerchantBiller extends GetView<MerchantBillerController> {
  const MerchantBiller({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
          backgroundColor: AppColor.bodyColor,
          appBar: AppBar(
            elevation: 1,
            backgroundColor: AppColor.primaryColor,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: AppColor.primaryColor,
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
            ),
            title:
                Text(controller.isPayPage.value ? "Pay Merchant" : "Merchants"),
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                if (controller.isPayPage.value) {
                  controller.isPayPage.value = false;
                  return;
                } else {
                  Get.back();
                }
              },
              child: Icon(
                Iconsax.arrow_left,
                color: Colors.white,
              ),
            ),
          ),
          body: controller.isLoadingPage.value
              ? const PageLoader()
              : AnimatedSwitcher(
                  duration: Duration(milliseconds: 400),
                  child: !controller.isPayPage.value
                      ? !controller.isNetConn.value
                          ? NoInternetConnected(
                              onTap: controller.refresher,
                            )
                          : controller.merchantData.isEmpty
                              ? const NoDataFound(
                                  text: "No registered merchants found",
                                )
                              : Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: SizedBox(
                                        height: 54,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 3,
                                                offset: Offset(0, 0),
                                              ),
                                            ],
                                            borderRadius: BorderRadius.circular(
                                                54), // Match TextField border radius
                                          ),
                                          child: TextField(
                                            autofocus: false,
                                            style: paragraphStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines:
                                                1, // Ensures single line input
                                            textAlign: TextAlign.left,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10),
                                              hintText: "Search Merchant",
                                              filled: true,
                                              fillColor: Colors.white,
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(54),
                                                borderSide: BorderSide(
                                                    color:
                                                        AppColor.primaryColor),
                                              ),
                                              border:
                                                  const OutlineInputBorder(),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(54),
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: Color(0xFFCECECE)),
                                              ),
                                              prefixIcon: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(width: 15),
                                                  Icon(LucideIcons.search),
                                                  Container(width: 10),
                                                ],
                                              ),
                                              hintStyle: paragraphStyle(
                                                color: Color(0xFF646263),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              labelStyle: paragraphStyle(
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.hintColor,
                                              ),
                                            ),
                                            onChanged: (value) {
                                              controller.onSearch(value);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: controller.filterData.length,
                                        itemBuilder: (context, index) {
                                          dynamic data =
                                              controller.filterData[index];

                                          return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                15, 10, 15, 0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 3,
                                                    offset: Offset(0, 0),
                                                  ),
                                                ],
                                              ),
                                              child: ListTile(
                                                title: CustomParagraph(
                                                  fontSize: 12,
                                                  color: AppColor.headerColor,
                                                  fontWeight: FontWeight.w500,
                                                  text: _toTitleCase(
                                                      data["merchant_name"]),
                                                ),
                                                subtitle: CustomParagraph(
                                                  fontSize: 10,
                                                  text:
                                                      data["merchant_address"],
                                                  maxlines: 1,
                                                ),
                                                trailing: const Icon(
                                                    Icons.chevron_right_sharp,
                                                    color: Color(0xFF1C1C1E)),
                                                onTap: () {
                                                  // controller.isPayPage.value =
                                                  //     true;
                                                  controller.getPaymentKey(
                                                    data["items"],
                                                    data["merchant_key"],
                                                    data["merchant_name"],
                                                    data["merchant_address"],
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                      : PayMerchant(data: controller.merchantParam),
                )),
    );
  }
}

String _toTitleCase(String input) {
  if (input.isEmpty) return input;
  return input
      .toLowerCase()
      .split(' ')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
      .join(' ');
}

class ConfirmMerchantPay extends StatefulWidget {
  const ConfirmMerchantPay({super.key});

  @override
  State<ConfirmMerchantPay> createState() => _ConfirmMerchantPayState();
}

class _ConfirmMerchantPayState extends State<ConfirmMerchantPay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.amber,
      child: Column(
        children: [],
      ),
    );
  }
}
