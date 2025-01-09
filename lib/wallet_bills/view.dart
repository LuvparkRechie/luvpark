import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:luvpark/wallet_bills/controller.dart';

class walletBiller extends GetView<walletBillerController> {
  const walletBiller({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Merchants",
      ),
      body: Obx(() {
        // Show loading indicator
        if (controller.isLoadingPage.value) {
          return const PageLoader();
        }

        // Show no internet UI
        if (!controller.isNetConn.value) {
          return NoInternetConnected(
            onTap: controller.refresher,
          );
        }

        // Show no data UI
        if (controller.merchantData.isEmpty) {
          return const NoDataFound(
            text: "No registered merchants",
          );
        }

        // Show merchant list
        return ListView.builder(
          itemCount: controller.merchantData.length,
          itemBuilder: (context, index) {
            dynamic data = controller.merchantData[index];

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.primaryColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    Iconsax.bill,
                    color: AppColor.primaryColor,
                    size: 24,
                  ),
                ),
                title: CustomTitle(
                  text: _toTitleCase(data["merchant_name"]),
                  fontSize: 14,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.408,
                ),
                trailing: const Icon(Icons.chevron_right_sharp,
                    color: Color(0xFF1C1C1E)),
                onTap: () {
                  controller.getPaymentKey(
                    data["items"],
                    data["merchant_key"],
                    data["merchant_name"],
                  );
                },
              ),
            );
          },
        );
      }),
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
