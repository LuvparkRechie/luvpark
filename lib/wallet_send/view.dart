import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/wallet_send/index.dart';

import '../auth/authentication.dart';
import '../custom_widgets/app_color.dart';
import '../custom_widgets/variables.dart';

class WalletSend extends GetView<WalletSendController> {
  const WalletSend({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: ScrollConfiguration(
        behavior: ScrollBehavior().copyWith(overscroll: false),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Obx(
              () => controller.isLoading.value
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 20),
                        CustomButtonClose(onTap: () {
                          FocusNode().unfocus();
                          CustomDialog().loadingDialog(context);
                          Future.delayed(Duration(milliseconds: 200), () {
                            Get.back();
                            Get.back();
                          });
                        }),
                        Container(height: 20),
                        CustomTitle(
                          text: "Transfer Token",
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                        Container(height: 5),
                        Row(
                          children: [
                            CustomParagraph(text: "Account balance:"),
                            Container(
                              width: 5,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: controller.isLoading.value
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      )
                                    : CustomParagraph(
                                        text: !controller.isNetConn.value
                                            ? "No internet"
                                            : controller.userData.isEmpty
                                                ? ""
                                                : toCurrencyString(controller
                                                    .userData[0]["amount_bal"]
                                                    .toString()),
                                        color: AppColor.primaryColor,
                                        fontWeight: FontWeight.w500,
                                        textAlign: TextAlign.right,
                                      ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: secondChild(),
                          crossFadeState: controller.recipientData.isEmpty
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: Duration(milliseconds: 200),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Form(
                          key: controller.formKeySend,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomParagraph(
                                text: "Amount",
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              CustomTextField(
                                hintText: "Enter amount",
                                controller: controller.tokenAmount,
                                inputFormatters: [
                                  AutoDecimalInputFormatter(),
                                ],
                                keyboardType: Platform.isAndroid
                                    ? TextInputType.number
                                    : const TextInputType.numberWithOptions(
                                        signed: true, decimal: false),
                                onChange: (text) {
                                  controller.pads(text);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Amount is required";
                                  }

                                  double parsedValue;
                                  try {
                                    parsedValue = double.parse(value);
                                  } catch (e) {
                                    return "Invalid amount";
                                  }

                                  double availableBalance;
                                  try {
                                    availableBalance = double.parse(controller
                                            .userData.isEmpty
                                        ? "0.0"
                                        : controller.userData[0]["amount_bal"]
                                            .toString());
                                  } catch (e) {
                                    return "Error retrieving balance";
                                  }
                                  if (parsedValue < 10) {
                                    return "Amount must not be less than 10";
                                  }
                                  if (parsedValue > availableBalance) {
                                    return "You don't have enough balance to proceed";
                                  }

                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  CustomParagraph(
                                    text: "Description",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  Container(width: 5),
                                  CustomParagraph(
                                    text: "(Optional)",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                              CustomTextField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(
                                    30,
                                  ),
                                ],
                                maxLength: 30,
                                controller: controller.message,
                                maxLines: 5,
                                minLines: 3,
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              if (MediaQuery.of(Get.context!)
                                      .viewInsets
                                      .bottom ==
                                  0) //hide button
                                CustomButton(
                                  text: "Continue",
                                  btnColor: AppColor.primaryColor,
                                  onPressed: () async {
                                    if (controller.formKeySend.currentState!
                                        .validate()) {
                                      final item =
                                          await Authentication().getUserLogin();

                                      if (item["mobile_no"].toString() ==
                                          controller.recipientData[0]
                                                  ["mobile_no"]
                                              .toString()) {
                                        CustomDialog().snackbarDialog(
                                            Get.context!,
                                            "Please use another number.",
                                            Colors.red,
                                            () {});
                                        return;
                                      }
                                      if (double.parse(
                                              controller.userData.isEmpty
                                                  ? "0.0"
                                                  : controller.userData[0]
                                                          ["amount_bal"]
                                                      .toString()) <
                                          double.parse(controller
                                              .tokenAmount.text
                                              .toString()
                                              .removeAllWhitespace)) {
                                        CustomDialog().snackbarDialog(
                                          Get.context!,
                                          "Insufficient balance.",
                                          Colors.red,
                                          () {},
                                        );
                                        return;
                                      }

                                      CustomDialog().confirmationDialog(
                                          Get.context!,
                                          "Confirmation",
                                          "Are you sure you want to proceed?",
                                          "Back",
                                          "Yes", () {
                                        Get.back();
                                      }, () {
                                        Get.back();
                                        controller.getVerifiedAcc();
                                      });
                                    }
                                  },
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget secondChild() {
    return controller.recipientData.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomParagraph(
                text: "Recipient",
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: AppColor.primaryColor.withOpacity(.1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius:
                                BorderRadius.circular(30), // Make it circular
                          ),
                          child: ClipRRect(
                            clipBehavior: Clip.none,
                            borderRadius: BorderRadius.circular(
                                30), // Clip image to circle
                            child: controller.userImage.value.isNotEmpty
                                ? Image.memory(
                                    base64Decode(
                                        controller.userImage.value.toString()),
                                    fit: BoxFit
                                        .cover, // Ensures image covers the container
                                    width: 60,
                                    height: 60,
                                  )
                                : Icon(
                                    Icons
                                        .person, // Placeholder when no image is available
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        Container(width: 10),
                        Expanded(
                          child: controller.userName.value == "Not Verified"
                              ? CustomParagraph(
                                  text: controller.userName.value,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomParagraph(
                                      text: controller.userName.value,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    Container(height: 5),
                                    CustomParagraph(
                                      text: controller.recipientData[0]["email"]
                                          .toString(),
                                      fontSize: 13,
                                    )
                                  ],
                                ),
                        ),
                        Container(width: 5),
                        GestureDetector(
                          onTap: () {
                            Get.bottomSheet(
                                UsersBottomsheet(
                                    index: 2,
                                    cb: (index) {
                                      Functions.popPage(index);
                                    }),
                                isDismissible: false);
                          },
                          child: Icon(
                            LucideIcons.edit,
                            size: 18,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Expanded(
                            child: CustomParagraph(
                          text: "Mobile No",
                          fontSize: 12,
                        )),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: CustomParagraph(
                              text: controller.recipientData[0]["mobile_no"],
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
  }
}

class UsersBottomsheet extends StatefulWidget {
  final int index;
  final Function cb;
  const UsersBottomsheet({super.key, required this.index, required this.cb});

  @override
  State<UsersBottomsheet> createState() => _UsersBottomsheetState();
}

class _UsersBottomsheetState extends State<UsersBottomsheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController mobileNo = TextEditingController();
  final ct = Get.put(WalletSendController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        height: 260,
        padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(7),
          ),
          color: Colors.white,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    Functions.popPage(widget.index == 1 ? 2 : 1);
                  },
                  child: Icon(
                    Iconsax.close_circle,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
              ),
              CustomTitle(text: "Recipient Number"),
              CustomMobileNumber(
                hintText: "Enter mobile number",
                controller: mobileNo,
                inputFormatters: [Variables.maskFormatter],
                keyboardType: Platform.isAndroid
                    ? TextInputType.number
                    : const TextInputType.numberWithOptions(
                        signed: true, decimal: false),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Field is required';
                  }
                  if (value.toString().replaceAll(" ", "").length < 10) {
                    return 'Invalid mobile number';
                  }
                  if (value.toString().replaceAll(" ", "")[0] == '0') {
                    return 'Invalid mobile number';
                  }

                  return null;
                },
                suffixIcon: Icons.qr_code,
                onIconTap: () async {
                  FocusManager.instance.primaryFocus!.unfocus();
                  ct.requestCameraPermission();
                },
              ),
              Container(height: 30),
              CustomButton(
                  text: "Proceed",
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ct.getRecipient(mobileNo.text);
                    }
                  }),
              Container(height: 10),
            ],
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

    // Remove non-numeric characters
    final numericValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Format as decimal (e.g., "123" -> "1.23")
    final value = double.tryParse(numericValue) ?? 0.0;
    final formattedValue = (value / 100).toStringAsFixed(2);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}
