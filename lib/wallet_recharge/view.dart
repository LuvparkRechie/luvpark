import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';

import '../custom_widgets/app_color.dart';
import '../custom_widgets/custom_button.dart';
import '../routes/routes.dart';
import 'controller.dart';

class WalletRechargeScreen extends GetView<WalletRechargeController> {
  const WalletRechargeScreen({super.key});

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
        key: controller.formKeyBuyLoad,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          "Buy Load",
                          style: GoogleFonts.openSans(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: AppColor.headerColor,
                          ),
                        ),
                        Container(height: 20),
                        CustomParagraph(
                          text: "Enter amount",
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        CustomTextField(
                          controller: controller.tokenAmount,
                          labelText: "The minimum load amount is 20 tokens.",
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*$')),
                          ],
                          keyboardType: Platform.isAndroid
                              ? TextInputType.number
                              : const TextInputType.numberWithOptions(
                                  signed: true, decimal: false),
                          onChange: (d) {
                            controller.pads(int.parse(d.toString()));
                            controller.onTextChange();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Amount must not be empty";
                            }
                            if (double.parse(value.toString()) < 20) {
                              return "Minimum load amount is 20";
                            }
                            return null;
                          },
                        ),
                        // CustomParagraph(
                        //     maxlines: 2,
                        //     fontWeight: FontWeight.w500,
                        //     textAlign: TextAlign.center,
                        //     fontSize: 12,
                        //     text: "The minimum load amount is 20 tokens."),
                        // const SizedBox(
                        //   height: 50,
                        // ),
                        SizedBox(
                          height: 30,
                        ),
                        const CustomParagraph(
                          text:
                              'Enter a desired amount or choose from any denominations below.',
                          maxlines: 2,
                          fontWeight: FontWeight.w500,
                          textAlign: TextAlign.center,
                          fontSize: 12,
                        ),
                        const SizedBox(
                          height: 20,
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
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomParagraph(
                              text: "1 token = 1 peso",
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColor.primaryColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  backgroundColor: Colors.white,
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: CustomParagraph(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 10,
                                        text:
                                            "Payment may entail an additional fee for other payment options.",
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Icon(
                                Icons.info_outline_rounded,
                                color: AppColor.primaryColor,
                                size: 20,
                              ),
                            ),
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
                                    if (!controller.formKeyBuyLoad.currentState!
                                        .validate()) {
                                      return; // Stop submission if the form is not valid
                                    }
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
              color: data["is_active"] ? AppColor.primaryColor : Colors.white,
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
                  fontWeight: FontWeight.w700,
                  color: data["is_active"] ? Colors.white : Colors.black,
                ),
                CustomParagraph(
                  text: "Token",
                  maxlines: 1,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: data["is_active"] ? Colors.white : null,
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
