import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/ticketclipper.dart';
import 'package:luvpark/wallet_qr/merchantreceipt/controller.dart';

class merchantQRReceipt extends GetView<merchantQRRController> {
  final GlobalKey _globalKey = GlobalKey();

  merchantQRReceipt({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        key: _globalKey,
        backgroundColor: AppColor.primaryColor,
        body: Padding(
          padding: const EdgeInsets.only(
            top: 30,
            left: 15,
            right: 15,
          ),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: TicketClipper(
                    clipper: RoundedEdgeClipper(edge: Edge.vertical, depth: 15),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                      width: double.infinity,
                      decoration:
                          const BoxDecoration(color: AppColor.scafColor),
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
                        ],
                      ),
                    ),
                  ),
                ),
                _custombutton("Back to wallet", () {
                  Get.back();
                  Get.back();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
            text: amount,
            fontSize: 18,
            color: Colors.lightBlue,
          ),
        ],
      ),
    );
  }

  Widget _custombutton(String button, Function onpressed) {
    return Column(
      children: [
        SizedBox(height: 20),
        CustomElevatedButton(
          btnHeight: 40,
          btnwidth: double.infinity,
          btnColor: Colors.white,
          text: button,
          textColor: AppColor.primaryColor,
          onPressed: () {
            onpressed();
          },
        )
      ],
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
