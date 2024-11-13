// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';

import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/variables.dart';
import 'controller.dart';

class WalletRechargeLoadScreen extends GetView<WalletRechargeLoadController> {
  const WalletRechargeLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Form(
        key: controller.topUpKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Color(0xFF0078FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(43),
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
                      child: Icon(
                        LucideIcons.arrowLeft,
                        color: Colors.white,
                        size: 16,
                      )),
                ),
                Container(height: 20),
                Text(
                  "Top-up Account",
                  style: GoogleFonts.openSans(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: AppColor.headerColor,
                  ),
                ),
                Container(height: 20),
                Column(
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
                        print("pisti $value");
                        controller.isActiveBtn.value = true;
                        controller.onSearchChanged(
                            value.replaceAll(" ", ""), false);
                      },
                    ),
                    CustomTextField(
                      isReadOnly: true,
                      controller: controller.rname,
                      labelText: "Recipient Name",
                      filledColor: Colors.grey.shade200,
                      isFilled: true,
                    ),
                    CustomTextField(
                      isReadOnly: true,
                      filledColor: Colors.grey.shade200,
                      controller: controller.amountController,
                      isFilled: true,
                      labelText: "Amount",
                    ),
                  ],
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
