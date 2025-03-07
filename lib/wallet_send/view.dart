import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/wallet_send/index.dart';
import 'package:permission_handler/permission_handler.dart';

import '../auth/authentication.dart';
import '../custom_widgets/app_color.dart';
import '../custom_widgets/variables.dart';
import '../otp_field/index.dart';

class WalletSend extends GetView<WalletSendController> {
  const WalletSend({super.key});

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
            title: Text(controller.isPage2.value
                ? "Confirm password"
                : "Transfer Token"),
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                if (controller.isPage2.value) {
                  controller.onPageSnap();
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
          body: AnimatedCrossFade(
            firstChild: page1(),
            firstCurve: Curves.easeInOut, // Smooth ease-in-out for fade
            secondCurve: Curves.easeInOut, // Smooth ease-in-out for fade
            secondChild: ConfirmPassword(),
            crossFadeState: !controller.isPage2.value
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: Duration(milliseconds: 200),
          )),
    );
  }

  Widget page1() {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(overscroll: false),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: controller.isLoading.value
              ? Container(
                  height: MediaQuery.of(Get.context!).size.height * 0.8,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    CustomParagraph(text: "Account Balance"),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: controller.isLoading.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
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
                                      : toCurrencyString(controller.userData[0]
                                              ["amount_bal"]
                                          .toString()),
                              color: AppColor.primaryColor,
                              fontWeight: FontWeight.w600,
                              textAlign: TextAlign.right,
                              fontSize: 30,
                            ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(),
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
                                availableBalance = double.parse(
                                    controller.userData.isEmpty
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
                          CustomButton(
                            text: "Continue",
                            btnColor: AppColor.primaryColor,
                            onPressed: () async {
                              if (controller.formKeySend.currentState!
                                  .validate()) {
                                final item =
                                    await Authentication().getUserLogin();

                                if (item["mobile_no"].toString() ==
                                    controller.recipientData[0]["mobile_no"]
                                        .toString()) {
                                  CustomDialog().snackbarDialog(
                                      Get.context!,
                                      "Please use another number.",
                                      Colors.red,
                                      () {});
                                  return;
                                }
                                if (double.parse(controller.userData.isEmpty
                                        ? "0.0"
                                        : controller.userData[0]["amount_bal"]
                                            .toString()) <
                                    double.parse(controller.tokenAmount.text
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

                                controller.getVerifiedAcc();
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
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: AppColor.primaryColor.withOpacity(.1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: controller.userImage.value.isEmpty
                              ? Colors.white
                              : null,
                          backgroundImage: controller.userImage.value.isNotEmpty
                              ? MemoryImage(
                                  base64Decode(
                                    controller.userImage.value.toString(),
                                  ),
                                )
                              : null,
                          child: controller.userImage.value.isEmpty
                              ? Icon(
                                  Icons
                                      .person, // Placeholder when no image is available
                                  size: 30,
                                  color: Colors.grey,
                                )
                              : null,
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

  Future<void> selectSingleContact() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      Contact? selectedContact = await ct.contactPicker.selectContact();
      if (selectedContact != null) {
        ct.contact.value = selectedContact;

        if (ct.contact.value != null) {
          String contactString = ct.contact.value.toString();
          String mobileNumber =
              contactString.replaceAll(RegExp(r'^.*\[\s*|\s*\].*$'), '');
          mobileNumber = mobileNumber.replaceAll(" ", "");
          if (mobileNumber.startsWith('0')) {
            mobileNumber = mobileNumber.substring(1);
          }
          mobileNo.text = mobileNumber;
        }

        Get.back();
      }
    } else {
      ct.checkAndRequestPermissions();
    }
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
                suffixIcon: Icons.add_box_outlined,
                onIconTap: () async {
                  Get.dialog(
                    barrierColor: Colors.black54,
                    Center(
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          height: 150,
                          padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTitle(text: "Select Method"),
                              SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                  onTap: () {
                                    FocusManager.instance.primaryFocus!
                                        .unfocus();
                                    ct.requestCameraPermission();
                                  },
                                  child: Container(
                                      width: 230,
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColor.primaryColor,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                              color: AppColor.primaryColor,
                                              Icons.qr_code),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          CustomTitle(
                                              color: AppColor.primaryColor,
                                              text: "Scan QR Code"),
                                        ],
                                      ))),
                              SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                  onTap: () {
                                    selectSingleContact();
                                  },
                                  child: Container(
                                    width: 230,
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColor.primaryColor,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                            color: AppColor.primaryColor,
                                            Icons.contact_page_outlined),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        CustomTitle(
                                            color: AppColor.primaryColor,
                                            text: "Select from Contacts"),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
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

class ConfirmPassword extends StatefulWidget {
  const ConfirmPassword({super.key});

  @override
  State<ConfirmPassword> createState() => _ConfirmPasswordState();
}

class _ConfirmPasswordState extends State<ConfirmPassword> {
  final GlobalKey<FormState> confirmFormKey = GlobalKey<FormState>();
  bool isShowPass = false;
  @override
  void initState() {
    controller.myPass = TextEditingController();
    super.initState();
  }

  void visibilityChanged(bool visible) {
    isShowPass = visible;
    setState(() {});
  }

  final controller = Get.put(WalletSendController());
  @override
  Widget build(BuildContext context) {
    return Form(
      key: confirmFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 20),
            CustomParagraph(
              text: "Confirm password to proceed.",
            ),
            Container(height: 20),
            CustomParagraph(
              text: "Input password",
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            CustomTextField(
              hintText: "Enter your password",
              controller: controller.myPass,
              isObscure: isShowPass,
              suffixIcon: !isShowPass ? Icons.visibility_off : Icons.visibility,
              onIconTap: () {
                visibilityChanged(!isShowPass);
              },
              validator: (d) {
                if (d == null || d.isEmpty) {
                  return "Password is required";
                }
                return null;
              },
            ),
            Container(height: 30),
            CustomButton(
                text: "Continue",
                onPressed: () async {
                  final uData = await Authentication().getUserData2();

                  if (confirmFormKey.currentState!.validate()) {
                    Map<String, String> requestParam = {
                      "mobile_no": uData["mobile_no".toString()].toString(),
                      "pwd": controller.myPass.text
                    };
                    CustomDialog().loadingDialog(Get.context!);
                    DateTime timeNow = await Functions.getTimeNow();
                    Get.back();
                    Functions().requestOtp(requestParam, (objData) async {
                      DateTime timeExp = DateFormat("yyyy-MM-dd hh:mm:ss a")
                          .parse(objData["otp_exp_dt"].toString());
                      DateTime otpExpiry = DateTime(
                          timeExp.year,
                          timeExp.month,
                          timeExp.day,
                          timeExp.hour,
                          timeExp.minute,
                          timeExp.millisecond);

                      // Calculate difference
                      Duration difference = otpExpiry.difference(timeNow);

                      if (objData["success"] == "Y" ||
                          objData["status"] == "PENDING") {
                        Map<String, String> putParam = {
                          "mobile_no": uData["mobile_no"].toString(),
                          "otp": objData["otp"].toString(),
                          "req_type": "SR"
                        };

                        Object args = {
                          "time_duration": difference,
                          "mobile_no": uData["mobile_no".toString()].toString(),
                          "req_otp_param": requestParam,
                          "verify_param": putParam,
                          "callback": (otp) async {
                            print("return otp $otp");
                            if (otp != null) {
                              controller.shareToken();
                            }
                          },
                        };

                        Get.to(
                          OtpFieldScreen(
                            arguments: args,
                          ),
                          transition: Transition.rightToLeftWithFade,
                          duration: Duration(milliseconds: 400),
                        );
                      }
                    });
                  }
                })
          ],
        ),
      ),
    );
  }
}
