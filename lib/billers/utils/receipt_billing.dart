import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Map<String, String> param2 = Get.arguments["receipt_data"];
  String billId = Get.arguments["biller_id"];
  String accountNo = Get.arguments["account_no"];
  String dateNow = "Loading...";
  List<Widget> receiptBody = [];

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
    String billerAddress = param2["biller_address"] ?? "";
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
    String billerAddress = param2["biller_address"] ?? "";
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: AppColor.primaryColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColor.primaryColor,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
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
                      onPressed: () {
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
                ...param2.entries.map((entry) {
                  return _buildDetailRow(entry.key, entry.value);
                }).toList(),
                Container(height: 10),
                GestureDetector(
                  onTap: () async {
                    String randomNumber = Random().nextInt(100000).toString();
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
                ...param2.entries.map((entry) {
                  return _buildDetailRow(entry.key, entry.value);
                }).toList(),
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
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.lightBlue,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewAccount() {
    return Row(
      children: [
        Visibility(
          visible: param2['user_biller_id'] == null,
          child: Expanded(
              child: CustomButton(
                  bordercolor: AppColor.bodyColor,
                  text: "Add to Favorites",
                  onPressed: () {
                    controller.addFavorites(param2, billId, accountNo);
                  })),
        ),
        Visibility(
            visible: param2['user_biller_id'] == null,
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
