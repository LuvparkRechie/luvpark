// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_textfield.dart';
import 'package:luvpark_get/wallet/controller.dart';

import '../../custom_widgets/custom_text.dart';

class WalletTransactionFilter extends GetView<WalletController> {
  const WalletTransactionFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 25, 15, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: controller.formKeyFilter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTitle(
                  text: "Transaction Period",
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(
                    Iconsax.close_circle,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
            Container(height: 20),
            CustomTitle(text: "Start Date"),
            CustomTextField(
              suffixIcon: Iconsax.calendar_1,
              onTap: () {
                controller.selectDate(context, true);
              },
              onIconTap: () {
                controller.selectDate(context, true);
              },
              isReadOnly: true,
              labelText: "From",
              controller: controller.fromDate,
            ),
            CustomTitle(text: "End Date"),
            CustomTextField(
              suffixIcon: Iconsax.calendar_1,
              onTap: () {
                controller.selectDate(context, false);
              },
              onIconTap: () {
                controller.selectDate(context, false);
              },
              isReadOnly: true,
              labelText: "To",
              controller: controller.toDate,
            ),
            Container(height: 20),
            CustomButton(
              text: "Apply",
              onPressed: () {
                controller.applyFilter();
              },
            ),
          ],
        ),
      ),
    );
  }
}
