import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';

import '../../custom_widgets/custom_appbar.dart';
import '../../custom_widgets/custom_text.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../controller.dart';

class AddFavoritesWidget extends GetView<BillersController> {
  AddFavoritesWidget({super.key});
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final accountName = TextEditingController();
    final accountNo = TextEditingController();
    final args = Get.arguments;
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("Favorite Biller"),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Iconsax.arrow_left,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTitle(
                  text: args["biller_name"],
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                Container(height: 5),
                CustomParagraph(
                  text: args["biller_address"],
                  fontSize: 10,
                  maxlines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Divider(
                  color: AppColor.linkLabel,
                ),
                SizedBox(height: 20),
                CustomParagraph(
                  text: "Account Number",
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                CustomTextField(
                  controller: accountNo,
                  hintText: "Enter Account Number",
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(15),
                    FilteringTextInputFormatter.digitsOnly,
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  keyboardType: Platform.isAndroid
                      ? TextInputType.numberWithOptions(decimal: true)
                      : const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Account number is required";
                    } else if (value.length < 5) {
                      return "Account number must be at least 5 digits";
                    } else if (value.length > 15) {
                      return "Account number must not exceed 15 digits";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                CustomParagraph(
                  text: "Account Name",
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                CustomTextField(
                  controller: accountName,
                  hintText: "Enter Account Name",
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(30),
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\s]'))
                  ],
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Account Name is required";
                    }
                    if ((value.startsWith(' ') ||
                        value.endsWith(' ') ||
                        value.endsWith('-') ||
                        value.endsWith('.'))) {
                      return "Account Name cannot start or end with a space";
                    }

                    return null;
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                CustomButton(
                  text: "Add to favorites",
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    await Future.delayed(Duration(milliseconds: 300));
                    if (formKey.currentState!.validate()) {
                      controller.addFavorites(
                          args, args["biller_id"], accountNo.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AutoDecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final numericValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    final value = double.tryParse(numericValue) ?? 0.0;
    final formattedValue = (value / 100).toStringAsFixed(2);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
