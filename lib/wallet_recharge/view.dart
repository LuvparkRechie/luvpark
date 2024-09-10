import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_body.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';

import '../custom_widgets/app_color.dart';
import '../custom_widgets/custom_button.dart';
import '../routes/routes.dart';
import 'controller.dart';

class WalletRechargeScreen extends GetView<WalletRechargeController> {
  const WalletRechargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      bodyColor: Colors.white,
      canPop: true,
      children: SingleChildScrollView(
        child: Column(
          children: [
            const CustomAppbar(title: "Load"),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        children: [
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.50,
                              child: TextFormField(
                                controller: controller.tokenAmount,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*$')),
                                ],
                                keyboardType: Platform.isAndroid
                                    ? TextInputType.number
                                    : const TextInputType.numberWithOptions(
                                        signed: true, decimal: false),
                                textInputAction: TextInputAction.done,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 5),
                                  hintText: "0.00",
                                ),
                                onChanged: (valueee) {
                                  controller.onTextChange();
                                },
                                style: GoogleFonts.prompt(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomParagraph(
                              text: '1 token = 1 peso',
                              fontSize: 12,
                              color: AppColor.primaryColor,
                              fontWeight: FontWeight.w600),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 20,
                  ),
                  const CustomTitle(
                      text:
                          'Enter a desired amount or choose from any denominations below.',
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),
                  const SizedBox(
                    height: 20,
                  ),
                  for (int i = 0; i < controller.dataList.length; i += 3)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int j = i;
                            j < i + 3 && j < controller.dataList.length;
                            j++)
                          myPads(controller.dataList[j].toString(), j)
                      ],
                    ),
                  Container(
                    height: MediaQuery.of(context).size.height / 15,
                  ),
                  if (MediaQuery.of(context).viewInsets.bottom ==
                      0) //hide button
                    Obx(
                      () => CustomButton(
                        text: "Proceed",
                        btnColor: controller.isActiveBtn.value
                            ? AppColor.primaryColor
                            : AppColor.primaryColor.withOpacity(.7),
                        onPressed: controller.isActiveBtn.value
                            ? () {
                                Get.toNamed(
                                  Routes.walletrechargeload,
                                  arguments: controller.tokenAmount.text
                                      .replaceAll(" ", ""),
                                );
                              }
                            : () {},
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

//this is my pads color and functions
  Widget myPads(String value, int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: InkWell(
          onTap: () {
            controller.pads(index);
          },
          child: Obx(() => Container(
                padding: const EdgeInsets.fromLTRB(22, 17, 23, 17),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  color: controller.denoInd.value == index
                      ? AppColor.primaryColor
                      : AppColor
                          .bodyColor, // Background color changes based on selection
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTitle(
                      text: value,
                      fontWeight: FontWeight.w600,
                      color: controller.denoInd.value == index
                          ? Colors.white
                          : Colors.black,
                      fontSize: 20,
                    ),
                    CustomTitle(
                      text: "Token",
                      fontWeight: FontWeight.w500,
                      color: controller.denoInd.value == index
                          ? Colors.white
                          : Colors.black,
                      fontSize: 11,
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
