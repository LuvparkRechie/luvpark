// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';

import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/variables.dart';
import 'controller.dart';

class WalletRechargeLoadScreen extends GetView<WalletRechargeLoadController> {
  const WalletRechargeLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Top-up",
      ),
      backgroundColor: AppColor.scafColor,
      body: Form(
        key: controller.page1Key,
        autovalidateMode: AutovalidateMode.disabled,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15,
                ),
                CustomTitle(
                  text: 'Top-up Account',
                  fontSize: 18,
                  letterSpacing: 1,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFffffff),
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      CustomMobileNumber(
                        labelText: "Recipient Number",
                        controller: controller.mobNum,
                        inputFormatters: [Variables.maskFormatter],
                        onChange: (value) {
                          controller.isActiveBtn.value = true;
                          controller.onSearchChanged(
                              value.replaceAll(" ", ""), false);
                        },
                      ),
                      CustomTextField(
                        isReadOnly: true,
                        controller: controller.rname,
                        labelText: "Recipient Name",
                      ),
                      CustomTextField(
                        isReadOnly: true,
                        controller: controller.amountController,
                        labelText: "Amount",
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (MediaQuery.of(context).viewInsets.bottom ==
                    0) //hide custombutton
                  Obx(() => CustomButton(
                        text: "Pay Now",
                        btnColor: !controller.isActiveBtn.value
                            ? AppColor.primaryColor.withOpacity(.7)
                            : AppColor.primaryColor,
                        onPressed: !controller.isActiveBtn.value
                            ? () {}
                            : () {
                                controller.onPay();
                              },
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
