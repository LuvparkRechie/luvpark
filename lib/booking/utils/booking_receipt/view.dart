import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luvpark_get/booking/utils/booking_receipt/controller.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_tciket_style.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../custom_widgets/app_color.dart';
import '../../../custom_widgets/custom_cutter.dart';
import '../../../custom_widgets/custom_cutter_top_bottom.dart';
import '../../../custom_widgets/custom_text.dart';

class BookingReceipt extends GetView<BookingReceiptController> {
  BookingReceipt({Key? key}) : super(key: key) {
    Get.put(BookingReceiptController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: CustomAppbar(
        bgColor: AppColor.primaryColor,
        title: "Parking Details",
        textColor: Colors.white,
        titleColor: Colors.white,
        elevation: 0,
        onTap: () {
          if (controller.parameters["status"] == "B") {
            Get.offAllNamed(Routes.map);
            return;
          }
          Get.back();
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Stack(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: constraints.maxHeight,
                        ),
                        Container(
                          color: AppColor.primaryColor,
                          width: MediaQuery.of(context).size.width,
                          height: constraints.maxHeight * .15,
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          right: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 0, 15, 0),
                                      child: Column(
                                        children: [
                                          Stack(
                                            fit: StackFit.passthrough,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomTitle(
                                                            text: controller
                                                                    .parameters[
                                                                "parkArea"],
                                                            fontSize: 20,
                                                            maxlines: 1,
                                                            letterSpacing: 0,
                                                            color: AppColor
                                                                .primaryColor,
                                                          ),
                                                          CustomParagraph(
                                                            text: controller
                                                                    .parameters[
                                                                "address"],
                                                            maxlines: 2,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 50),
                                                ],
                                              ),
                                              Positioned(
                                                right: 0,
                                                top: 5,
                                                child: Center(
                                                  child: IconButton(
                                                    onPressed: () async {
                                                      CustomDialog()
                                                          .loadingDialog(
                                                              context);
                                                      String mapUrl = "";

                                                      String dest =
                                                          "${controller.parameters["lat"]},${controller.parameters["long"]}";
                                                      if (Platform.isIOS) {
                                                        mapUrl =
                                                            'https://maps.apple.com/?daddr=$dest';
                                                      } else {
                                                        mapUrl =
                                                            'https://www.google.com/maps/search/?api=1&query=$dest';
                                                      }
                                                      Future.delayed(
                                                          const Duration(
                                                              seconds: 2),
                                                          () async {
                                                        Get.back();
                                                        if (await canLaunchUrl(
                                                            Uri.parse(
                                                                mapUrl))) {
                                                          await launchUrl(
                                                              Uri.parse(mapUrl),
                                                              mode: LaunchMode
                                                                  .externalApplication);
                                                        } else {
                                                          throw 'Something went wrong while opening map. Pleaase report problem';
                                                        }
                                                      });
                                                    },
                                                    icon: SvgPicture.asset(
                                                      "assets/dashboard_icon/direction_map.svg",
                                                      width: 34,
                                                      height: 34,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          if (controller.parameters["status"] ==
                                              "A")
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: CustomLinkLabel(
                                                        text:
                                                            "${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(controller.parameters["startTime"]))} - ${DateFormat.jm().format(DateFormat("hh:mm:ss").parse(controller.parameters["endTime"]))}",
                                                        maxlines: 1,
                                                      ),
                                                    ),
                                                    Container(width: 5),
                                                    Expanded(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Obx(
                                                          () => CustomParagraph(
                                                            text: controller
                                                                        .timeLeft
                                                                        .value ==
                                                                    null
                                                                ? ""
                                                                : Variables.formatTimeLeft(
                                                                    controller
                                                                        .timeLeft
                                                                        .value!),
                                                            fontSize: 12,
                                                            color: const Color(
                                                                0xFF666666),
                                                            maxlines: 1,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Container(height: 10),
                                                Obx(
                                                  () => controller
                                                              .progress.value >=
                                                          1
                                                      ? const Text(
                                                          'Time has expired!',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color:
                                                                  Colors.red),
                                                        )
                                                      : LinearProgressIndicator(
                                                          value: controller
                                                              .progress.value,
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFFCEE4F4),
                                                          minHeight: 5,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                  Color>(
                                                            controller.progress
                                                                        .value >=
                                                                    1
                                                                ? Colors.red
                                                                : AppColor
                                                                    .primaryColor,
                                                          ),
                                                        ),
                                                ),
                                              ],
                                            )
                                        ],
                                      ),
                                    ),
                                    const TicketStyle(),
                                  ],
                                ),
                                _buildDetailsSection(false),
                                _buildQrSection(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (controller.parameters["status"] == "A")
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Find vehicle",
                        onPressed: () async {
                          CustomDialog().loadingDialog(context);
                          String mapUrl = "";

                          String dest =
                              "${controller.parameters["lat"]},${controller.parameters["long"]}";
                          if (Platform.isIOS) {
                            mapUrl = 'https://maps.apple.com/?daddr=$dest';
                          } else {
                            mapUrl =
                                'https://www.google.com/maps/search/?api=1&query=$dest';
                          }
                          Future.delayed(const Duration(seconds: 2), () async {
                            Get.back();
                            if (await canLaunchUrl(Uri.parse(mapUrl))) {
                              await launchUrl(Uri.parse(mapUrl),
                                  mode: LaunchMode.externalApplication);
                            } else {
                              throw 'Something went wrong while opening map. Pleaase report problem';
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: controller.parameters["isAutoExtend"] == "Y"
                          ? CustomButton(
                              text: "Cancel auto extend",
                              textColor: const Color(0xFFCF4B4B),
                              btnColor: Colors.white,
                              bordercolor: const Color(0xFFCF4B4B),
                              onPressed: controller.cancelAutoExtend)
                          : CustomButton(
                              text: "Extend parking",
                              onPressed: controller.onExtend,
                            ),
                    ),
                  ],
                ),
              ),
            if (controller.parameters["can_cancel"])
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    CustomButton(
                      textColor: AppColor.primaryColor,
                      btnColor: Colors.white,
                      bordercolor: AppColor.primaryColor,
                      text: "Cancel booking",
                      onPressed: controller.cancelAdvanceParking,
                    )
                  ],
                ),
              ),
            Container(height: 10)
          ],
        ),
      ),
    );
  }

  Widget _buildQrSection() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: QrImageView(
              data: controller.parameters["refno"],
              version: QrVersions.auto,
              gapless: false,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildIconButton(Icons.share_outlined, () async {
                        CustomDialog().loadingDialog(Get.context!);
                        File? imgFile;

                        final directory =
                            (await getApplicationDocumentsDirectory()).path;
                        Uint8List bytes = await ScreenshotController()
                            .captureFromWidget(printScreen());
                        imgFile = File('$directory/screenshot.png');
                        imgFile.writeAsBytes(bytes);

                        Get.back();

                        // ignore: deprecated_member_use
                        await Share.shareFiles([imgFile.path]);
                      }),
                      CustomParagraph(
                        text: "Share",
                        letterSpacing: -0.41,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryColor,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildIconButton(Icons.download, () async {
                        CustomDialog().loadingDialog(Get.context!);
                        ScreenshotController()
                            .captureFromWidget(printScreen(),
                                delay: const Duration(seconds: 3))
                            .then((image) async {
                          final dir = await getApplicationDocumentsDirectory();
                          final imagePath =
                              await File('${dir.path}/captured.png').create();
                          await imagePath.writeAsBytes(image);
                          Get.back();

                          GallerySaver.saveImage(imagePath.path).then((result) {
                            CustomDialog().successDialog(
                                Get.context!,
                                "Success",
                                "QR code has been saved. Please check your gallery.",
                                "Okay", () {
                              Get.back();
                            });
                          });
                        });
                      }),
                      CustomParagraph(
                        text: "Save",
                        letterSpacing: -0.41,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Function onTap) {
    return InkWell(
      child: CircleAvatar(
        backgroundColor: const Color(0xFFF4F7FE),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Icon(
            icon,
            color: AppColor.primaryColor,
          ),
        ),
      ),
      onTap: () async {
        onTap();
      },
    );
  }

  Widget _buildDetailsSection(bool isBtnAction) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTitle(
                      text: "Total Token",
                      color: AppColor.primaryColor,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CustomTitle(
                        text: controller.parameters["amount"],
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ticketDetailsWidget(
                  'Plate No.', controller.parameters["plateNo"]),
              const SizedBox(height: 5),
              ticketDetailsWidget(
                'Date',
                controller.formatDateTime(
                  DateTime.parse(controller.parameters["paramsCalc"]["dt_in"]),
                  DateTime.parse(controller.parameters["paramsCalc"]["dt_out"]),
                ),
              ),
              const SizedBox(height: 5),
              ticketDetailsWidget(
                  'Time',
                  controller.formatTimeRange(
                      controller.parameters["paramsCalc"]["dt_in"],
                      controller.parameters["paramsCalc"]["dt_out"])),
              const SizedBox(height: 5),
              ticketDetailsWidget('Duration',
                  "${controller.parameters["hours"]} ${int.parse(controller.parameters["hours"].toString()) > 1 ? "Hours" : "Hour"}"),
              const SizedBox(height: 5),

              // ticketDetailsWidget(
              //     'Reference No.', controller.parameters["refno"]),
            ],
          ),
        ),
        if (!isBtnAction) const TicketStyle(),
      ],
    );
  }

  Widget ticketDetailsWidget(String firstTitle, String firstDesc) {
    return Row(
      children: [
        Expanded(
          child: CustomParagraph(text: firstTitle),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: CustomParagraph(
              text: firstDesc,
              fontWeight: FontWeight.w700,
              maxlines: 1,
              minFontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget printScreen() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      color: Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: AppColor.bodyColor,
            ),
            child: Column(
              children: [
                TopRowDecoration(color: Colors.grey.shade300),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Image(
                      height: 50,
                      fit: BoxFit.cover,
                      image: AssetImage("assets/images/login_logo.png"),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 2,
                              color: Color(0x162563EB),
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: QrImageView(
                            data: controller.parameters["refno"],
                            version: QrVersions.auto,
                            gapless: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomParagraph(
                          text: controller.parameters["refno"],
                          fontWeight: FontWeight.w700,
                          maxlines: 1,
                          textAlign: TextAlign.center,
                          minFontSize: 10,
                        ),
                        CustomParagraph(
                          text: "Reference No.",
                          fontSize: 12,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LineCutter(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: _buildDetailsSection(true),
                    ),
                  ],
                ),
                BottomRowDecoration(color: Colors.grey.shade300)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
