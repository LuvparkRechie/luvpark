import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/ticketclipper.dart';
import 'package:luvpark/wallet_qr/merchantreceipt/controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class MerchantQRReceipt extends GetView<MerchantQRRController> {
  final GlobalKey _globalKey = GlobalKey();

  MerchantQRReceipt({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        key: _globalKey,
        backgroundColor: AppColor.primaryColor,
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: TicketClipper(
                  clipper: RoundedEdgeClipper(edge: Edge.vertical, depth: 15),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                    width: double.infinity,
                    decoration: const BoxDecoration(color: AppColor.scafColor),
                    child: Column(
                      children: [
                        _buildMessage(controller.parameter["amount"],
                            "${_capitalize(controller.parameter["merchant_name"])}"),
                        _buildDetailRow("Merchant",
                            "${_capitalize(controller.parameter["merchant_name"] ?? "N/A")}"),
                        _buildDetailRow(
                          "Date of Transaction",
                          controller.formatDate(
                            DateTime.parse(
                              controller.parameter["date_time"],
                            ),
                          ),
                        ),
                        _buildDetailRow("Time of Transaction",
                            "${DateFormat('hh:mm a').format(DateTime.now())} "),
                        _buildTotalAmount(controller.parameter["amount"]),
                        _buildReferenceRow(
                            controller.parameter["reference_no"]),
                        Container(height: 30),
                        GestureDetector(
                          onTap: () async {
                            String randomNumber =
                                Random().nextInt(100000).toString();
                            CustomDialog().loadingDialog(Get.context!);
                            File? imgFile;

                            String fname = "booking$randomNumber.png";
                            final directory =
                                (await getApplicationDocumentsDirectory()).path;
                            Uint8List bytes = await ScreenshotController()
                                .captureFromWidget(_downloadWidget());
                            imgFile = File('$directory/$fname');
                            imgFile.writeAsBytes(bytes);

                            Get.back();

                            // ignore: deprecated_member_use
                            await Share.shareFiles([imgFile.path]);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.share2,
                                size: 20,
                              ),
                              Container(width: 10),
                              Text(
                                "Share",
                                style:
                                    subtitleStyle(fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Container(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 30,
              ),
              CustomButton(
                bordercolor: AppColor.bodyColor,
                text: "Download Receipt",
                onPressed: () async {
                  String randomNumber = Random().nextInt(100000).toString();
                  String fname = 'luvpark$randomNumber.png';

                  CustomDialog().loadingDialog(Get.context!);

                  ScreenshotController()
                      .captureFromWidget(_downloadWidget(),
                          delay: const Duration(seconds: 3))
                      .then((image) async {
                    final dir = await getApplicationDocumentsDirectory();
                    final imagePath = await File('${dir.path}/$fname').create();
                    await imagePath.writeAsBytes(image);
                    GallerySaver.saveImage(imagePath.path).then((result) {
                      Get.back();
                      CustomDialog().successDialog(
                          Get.context!,
                          "Success",
                          "Receipt has been saved. Please check your gallery.",
                          "Okay", () {
                        Get.back();
                      });
                    });
                  });
                },
              ),
              Container(
                height: 10,
              ),
              _custombutton("Back to wallet", () {
                Get.back();
                Get.back();
                Get.back();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _downloadWidget() => SizedBox(
        height: MediaQuery.of(Get.context!).size.height * .60,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: TicketClipper(
            clipper: RoundedEdgeClipper(edge: Edge.vertical, depth: 15),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              width: double.infinity,
              decoration: const BoxDecoration(color: AppColor.scafColor),
              child: Column(
                children: [
                  _buildMessage(controller.parameter["amount"],
                      "${_capitalize(controller.parameter["merchant_name"])}"),
                  _buildDetailRow("Merchant",
                      "${_capitalize(controller.parameter["merchant_name"] ?? "N/A")}"),
                  _buildDetailRow(
                    "Date of Transaction",
                    controller.formatDate(
                      DateTime.parse(
                        controller.parameter["date_time"],
                      ),
                    ),
                  ),
                  _buildDetailRow("Time of Transaction",
                      "${DateFormat('hh:mm a').format(DateTime.now())} "),
                  _buildTotalAmount(controller.parameter["amount"]),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomParagraph(
                                text: "Reference No.",
                                color: AppColor.primaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                              CustomParagraph(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  text: controller.parameter["reference_no"],
                                  color: Colors.lightBlue),
                            ],
                          ),
                        ),
                        Container()
                      ],
                    ),
                  ),
                  Container(height: 10),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildMessage(amount, merchant) {
    return Column(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 50),
        CustomTitle(
            text: 'Success', textAlign: TextAlign.center, color: Colors.green),
        SizedBox(
          height: 10,
        ),
        CustomParagraph(
          text: "You have paid ${amount} to ${merchant}",
          fontSize: 12,
        ),
        SizedBox(height: 10),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDetailRow(String text, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CustomParagraph(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              text: text,
              color: AppColor.primaryColor,
            ),
          ),
          Expanded(
            child: CustomParagraph(
              text: value,
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Colors.lightBlue,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceRow(referenceno) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomParagraph(
                  text: "Reference No.",
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                CustomParagraph(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    text: referenceno,
                    color: Colors.lightBlue),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: referenceno)).then((_) {
                ScaffoldMessenger.of(Get.context!).showSnackBar(
                  SnackBar(
                    content: Text('Copied to clipboard!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              });
            },
            child: Icon(
              Icons.copy_sharp,
              color: Colors.lightBlue,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmount(amount) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomParagraph(
                  text: "Total Amount",
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColor.primaryColor,
                ),
              ],
            ),
          ),
          CustomParagraph(
            text: toCurrencyString(amount.toString()),
            color: Colors.lightBlue,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  Widget _custombutton(String button, Function onpressed) {
    return CustomButton(
      bordercolor: Colors.white,
      textColor: Colors.white,
      text: "Back to wallet",
      onPressed: onpressed,
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
