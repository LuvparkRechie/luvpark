import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
      bodyColor: AppColor.bodyColor,
      canPop: true,
      children: SingleChildScrollView(
        child: Column(
          children: [
            const CustomAppbar(title: "Load"),
            Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.grey.shade200, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            children: [
                              Center(
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.50,
                                  child: TextFormField(
                                      controller: controller.tokenAmount,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d*$')),
                                      ],
                                      keyboardType: Platform.isAndroid
                                          ? TextInputType.number
                                          : const TextInputType
                                              .numberWithOptions(
                                              signed: true, decimal: false),
                                      textInputAction: TextInputAction.done,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                          contentPadding:
                                              EdgeInsets.only(left: 5),
                                          hintText: "0.00",
                                          hintStyle: paragraphStyle()),
                                      onChanged: (valueee) {
                                        controller.pads(
                                            int.parse(valueee.toString()));
                                        controller.onTextChange();
                                      },
                                      style: titleStyle()),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomParagraph(
                                  text: '1 token = 1 peso',
                                  fontSize: 10,
                                  color: AppColor.primaryColor,
                                  fontWeight: FontWeight.w700),
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
                      const CustomParagraph(
                        maxlines: 2,
                        text:
                            'Enter a desired amount or choose from any denominations below.',
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      for (int i = 0; i < controller.padData.length; i += 3)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (int j = i;
                                j < i + 3 && j < controller.padData.length;
                                j++)
                              myPads(controller.padData[j], j)
                          ],
                        ),
                      Container(
                        height: MediaQuery.of(context).size.height / 15,
                      ),
                      if (MediaQuery.of(context).viewInsets.bottom ==
                          0) //hide button
                        CustomButton(
                          text: "Proceed",
                          btnColor: controller.isActiveBtn.value
                              ? AppColor.primaryColor
                              : AppColor.primaryColor.withOpacity(.7),
                          onPressed: controller.isActiveBtn.value
                              ? () {
                                  FocusScope.of(Get.context!)
                                      .requestFocus(FocusNode());
                                  Get.toNamed(
                                    Routes.walletrechargeload,
                                    arguments: controller.tokenAmount.text
                                        .replaceAll(" ", ""),
                                  );
                                }
                              : () {},
                        ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget myPads(data, int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: InkWell(
          onTap: () {
            controller.pads(data["value"]);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 17, 23, 17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              color: data["is_active"]
                  ? AppColor.primaryColor
                  : Colors.white, // Background color changes based on selection
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomParagraph(
                  maxlines: 1,
                  minFontSize: 8,
                  text: "${data["value"]}",
                  fontWeight: FontWeight.w800,
                  color: data["is_active"] ? Colors.white : Colors.black,
                ),
                CustomParagraph(
                  text: "Token",
                  maxlines: 1,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: data["is_active"] ? Colors.white : Colors.black,
                  minFontSize: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
