// ignore_for_file: prefer_const_literals_to_create_immutables, unused_local_variable, unnecessary_null_comparison, prefer_const_constructors

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/billers/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../custom_widgets/alert_dialog.dart';
import '../../custom_widgets/app_color.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text.dart';
import '../../functions/functions.dart';
import '../controller.dart';
import 'ticketclipper.dart';

class TicketUI extends StatefulWidget {
  const TicketUI({
    super.key,
  });

  @override
  State<TicketUI> createState() => _TicketUIState();
}

class _TicketUIState extends State<TicketUI> {
  final controller = Get.put(BillersController());
  final params = Get.arguments;
  String dateNow = "Loading...";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTime();
    });

    super.initState();
  }

  Future<void> getTime() async {
    try {
      DateTime now = await Functions.getTimeNow();
      setState(() {
        dateNow = DateFormat('MMM dd, yyyy').format(now);
      });
    } catch (e) {
      setState(() {
        dateNow = "Error: $e";
      });
    }
  }

  Future<void> saveTicket() async {
    String randomNumber = Random().nextInt(100000).toString();
    String fname = 'luvpark$randomNumber.png';
    String billerAddress = params["biller_address"] ?? "";
    CustomDialog().loadingDialog(Get.context!);

    ScreenshotController()
        .captureFromWidget(shareDownloadTicket(billerAddress),
            delay: const Duration(seconds: 3))
        .then((image) async {
      final dir = await getApplicationDocumentsDirectory();
      final imagePath = await File('${dir.path}/$fname').create();
      await imagePath.writeAsBytes(image);
      GallerySaver.saveImage(imagePath.path).then((result) {
        Get.back();
        CustomDialog().successDialog(Get.context!, "Success",
            "Receipt has been saved. Please check your gallery.", "Okay", () {
          Get.back();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String billerAddress = params["biller_address"] ?? "";
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        body: Center(
          child: Padding(
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
                  myTicket(billerAddress),
                  SizedBox(
                    height: 30,
                  ),
                  _viewAccount(),
                  SizedBox(height: 10),
                  CustomButton(
                      bordercolor: AppColor.bodyColor,
                      text: "Back to Billers",
                      onPressed: params['user_biller_id'] == null
                          ? () {
                              Get.back();
                              Get.back();
                              Get.back();
                            }
                          : () {
                              Get.back();
                              Get.back();
                            }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget myTicket(billerAddress) => Container(
        padding: const EdgeInsets.all(15),
        child: TicketClipper(
          clipper: RoundedEdgeClipper(edge: Edge.vertical, depth: 15),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            width: double.infinity,
            decoration: const BoxDecoration(color: AppColor.scafColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMessage(),
                Divider(
                  color: AppColor.primaryColor,
                ),
                _buildDetailRow("Biller", params["biller_name"]),
                Visibility(
                    visible: billerAddress != "",
                    child: _buildDetailRow("Biller Address", billerAddress)),
                _buildDetailRow("Account Name", params["account_name"]),
                _buildDetailRow("Date Paid", dateNow),
                _buildDetailRow("Amount", params["original_amount"]),
                _buildTotalAmount(),
                Container(height: 10),
                GestureDetector(
                  onTap: () async {
                    String randomNumber =
                        await Random().nextInt(100000).toString();
                    CustomDialog().loadingDialog(Get.context!);
                    File? imgFile;

                    String fname = "luvpark$randomNumber.png";
                    final directory =
                        (await getApplicationDocumentsDirectory()).path;
                    Uint8List bytes = await ScreenshotController()
                        .captureFromWidget(shareDownloadTicket(billerAddress));
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
                        color: AppColor.primaryColor,
                        LucideIcons.share2,
                        size: 20,
                      ),
                      Container(width: 10),
                      CustomParagraph(
                        color: AppColor.primaryColor,
                        text: "Share",
                        fontSize: 12,
                      )
                    ],
                  ),
                ),
                Container(height: 10),
              ],
            ),
          ),
        ),
      );
  Widget shareDownloadTicket(billerAddress) => Container(
        padding: const EdgeInsets.all(15),
        child: TicketClipper(
          clipper: RoundedEdgeClipper(edge: Edge.vertical, depth: 15),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            width: double.infinity,
            decoration: const BoxDecoration(color: AppColor.scafColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMessage(),
                Divider(
                  color: AppColor.primaryColor,
                ),
                _buildDetailRow("Biller", params["biller_name"]),
                Visibility(
                    visible: billerAddress != "",
                    child: _buildDetailRow("Biller Address", billerAddress)),
                _buildDetailRow("Account Name", params["account_name"]),
                _buildDetailRow("Date Paid", dateNow),
                _buildDetailRow("Amount", params["original_amount"]),
                _buildTotalAmount(),
              ],
            ),
          ),
        ),
      );

  Widget _buildMessage() {
    return Column(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 50),
        SizedBox(height: 10),
        CustomParagraph(
            textAlign: TextAlign.center, text: "Successfully paid biller."),
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
              color: Colors.blueAccent,
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

  Widget _buildTotalAmount() {
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
                  color: Colors.blueAccent,
                ),
                CustomParagraph(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    text: params["service_fee"] == null
                        ? ""
                        : "Service Fee : ${params["service_fee"]}",
                    color: Colors.lightBlue),
              ],
            ),
          ),
          CustomParagraph(
              text: "${params['amount']}",
              fontSize: 18,
              color: Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _viewAccount() {
    return Row(
      children: [
        Visibility(
          visible: params['user_biller_id'] == null,
          child: Expanded(
              child: CustomButton(
                  bordercolor: AppColor.bodyColor,
                  text: "Add to Favorites",
                  onPressed: () {
                    controller.addFavorites(params);
                  })),
        ),
        Visibility(
            visible: params['user_biller_id'] == null,
            child: SizedBox(width: 10)),
        Expanded(
            child: CustomButton(
          bordercolor: AppColor.bodyColor,
          text: "Download Receipt",
          onPressed: () {
            saveTicket();
          },
        ))
      ],
    );
  }
}
