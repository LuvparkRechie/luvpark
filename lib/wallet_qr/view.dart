// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_tciket_style.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/no_internet.dart';
import 'package:luvpark_get/custom_widgets/page_loader.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../custom_widgets/app_color.dart';
import 'controller.dart';

class QrWallet extends GetView<QrWalletController> {
  const QrWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: AppColor.primaryColor,
          body: Column(
            children: [
              CustomAppbar(
                title:
                    controller.currentPage.value == 0 ? "Payment" : "Receive",
                bgColor: AppColor.primaryColor,
                titleColor: Colors.white,
                textColor: Colors.white,
              ),
              Container(
                color: AppColor.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D62C3),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: const Color(0xFF0D62C3),
                      ),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (controller.isLoading.value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Loading on progress, Please wait...'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.blue,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            controller.onTabChanged(0);
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeIn,
                            padding: const EdgeInsets.all(10),
                            decoration: controller.currentPage.value != 0
                                ? decor2()
                                : decor1(),
                            child: Center(
                              child: CustomParagraph(
                                text: "QR Pay",
                                fontSize: 10,
                                color: controller.currentPage.value != 0
                                    ? Colors.white38
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 5),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (controller.isLoading.value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Loading on progress, Please wait...'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.blue,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            controller.onTabChanged(1);
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.all(10),
                            decoration: controller.currentPage.value != 1
                                ? decor2()
                                : decor1(),
                            child: Center(
                                child: CustomParagraph(
                              text: "Receive",
                              fontSize: 10,
                              color: controller.currentPage.value != 1
                                  ? Colors.white38
                                  : Colors.white,
                            )),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              Expanded(
                child:
                    controller.currentPage.value == 0 ? PayQr() : ReceiveQr(),
              )
            ],
          ),
        ));
  }

//selected tab
  BoxDecoration decor1() {
    return BoxDecoration(
      color: Colors.white30,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(
        color: Colors.transparent,
      ),
    );
  }

//unselected tab
  BoxDecoration decor2() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      color: const Color(0xFF0D62C3),
      border: Border.all(
        color: const Color(0xFF0D62C3),
      ),
    );
  }
}

class PayQr extends GetView<QrWalletController> {
  const PayQr({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 1,
                    spreadRadius: 1,
                    offset: Offset(0, 1),
                    color: AppColor.primaryColor.withOpacity(.5),
                  )
                ]),
            child: !controller.isInternetConn.value
                ? NoInternetConnected(onTap: controller.getQrData)
                : controller.isLoading.value
                    ? PageLoader()
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 17, 0, 15),
                              child: Column(
                                children: [
                                  controller.userImage == null
                                      ? Container(
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: AppColor.primaryColor
                                                      .withOpacity(.6))),
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.blueAccent,
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 40,
                                          backgroundImage: MemoryImage(
                                            base64Decode(controller.userImage!),
                                          )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  CustomTitle(
                                    text: controller.fullName.value,
                                    maxlines: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                  Container(height: 5),
                                  CustomParagraph(
                                    text: controller.mono.value,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF616161),
                                  ),
                                ],
                              ),
                            ),
                            TicketStyle(
                              dtColor: AppColor.primaryColor,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                QrImageView(
                                  data: controller.payKey.value,
                                  version: QrVersions.auto,
                                  size: 200,
                                  gapless: false,
                                ),
                                CustomTitle(
                                  text: controller.isLoading.value
                                      ? ""
                                      : 'Scan QR code to pay',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF070707),
                                ),
                              ],
                            ),
                            Container(height: 20),
                            TicketStyle(
                              dtColor: AppColor.primaryColor,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(15, 10, 15, 10),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      controller.generateQr();
                                    },
                                    child: Center(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .60,
                                        padding: const EdgeInsets.all(
                                            10), // Padding values
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Color(0xFF0078FF),
                                            width: 1.0, // 1-pixel width
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.sync_outlined,
                                              size: 28.0,
                                              color: Color(0xFF0078FF),
                                            ),
                                            SizedBox(width: 5),
                                            CustomTitle(
                                              text: 'Generate QR code',
                                              color: Color(0xFF0078FF),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          controller.shareQr();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(7)),
                                              border: Border.all(
                                                color: Color(0xFF0078FF),
                                              )),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 14, 20, 14),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Share",
                                                  style: Platform.isAndroid
                                                      ? GoogleFonts.dmSans(
                                                          color:
                                                              Color(0xFF0078FF),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: 1,
                                                          fontSize: 14)
                                                      : TextStyle(
                                                          color:
                                                              Color(0xFF0078FF),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: 1,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              "SFProTextReg",
                                                        ),
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                const Icon(
                                                  Icons.ios_share_outlined,
                                                  color: Color(0xFF0078FF),
                                                  size: 25,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.saveQr();
                                        },
                                        child: Container(
                                          width: 117,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(7)),
                                              border: Border.all(
                                                color: Color(0xFF0078FF),
                                              )),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 14, 20, 14),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Save",
                                                  style: Platform.isAndroid
                                                      ? GoogleFonts.dmSans(
                                                          color:
                                                              Color(0xFF0078FF),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: 1,
                                                          fontSize: 14)
                                                      : TextStyle(
                                                          color:
                                                              Color(0xFF0078FF),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: 1,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              "SFProTextReg",
                                                        ),
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                const Icon(
                                                  Icons.download,
                                                  color: Color(0xFF0078FF),
                                                  size: 25,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ));
  }
}

class ReceiveQr extends GetView<QrWalletController> {
  const ReceiveQr({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 1,
                spreadRadius: 1,
                offset: Offset(0, 1),
                color: AppColor.primaryColor.withOpacity(.5),
              )
            ]),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 17, 0, 15),
                child: Column(
                  children: [
                    controller.userImage == null
                        ? Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color:
                                        AppColor.primaryColor.withOpacity(.6))),
                            child: Icon(
                              Icons.person,
                              color: Colors.blueAccent,
                            ),
                          )
                        : CircleAvatar(
                            radius: 40,
                            backgroundImage: MemoryImage(
                              base64Decode(controller.userImage!),
                            ),
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTitle(
                      text: controller.fullName.value,
                      maxlines: 1,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    CustomParagraph(
                      text: controller.mono.value,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF616161),
                    ),
                  ],
                ),
              ),
              TicketStyle(
                dtColor: AppColor.primaryColor,
              ),
              Column(
                children: [
                  QrImageView(
                    data: controller.mobNum.value,
                    version: QrVersions.auto,
                    gapless: false,
                    size: 200,
                  ),
                  CustomTitle(
                    text: 'Scan QR code to receive',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF070707),
                  ),
                ],
              ),
              Container(height: 20),
              TicketStyle(
                dtColor: AppColor.primaryColor,
              ),
              Container(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      controller.shareQr();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          border: Border.all(
                            color: Color(0xFF0078FF),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Share",
                              style: Platform.isAndroid
                                  ? GoogleFonts.dmSans(
                                      color: Color(0xFF0078FF),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                      fontSize: 14)
                                  : TextStyle(
                                      color: Color(0xFF0078FF),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                      fontSize: 14,
                                      fontFamily: "SFProTextReg",
                                    ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            const Icon(
                              Icons.ios_share_outlined,
                              color: Color(0xFF0078FF),
                              size: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  InkWell(
                    onTap: () {
                      controller.saveQr();
                    },
                    child: Container(
                      width: 117,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          border: Border.all(
                            color: Color(0xFF0078FF),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Save",
                              style: Platform.isAndroid
                                  ? GoogleFonts.dmSans(
                                      color: Color(0xFF0078FF),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                      fontSize: 14)
                                  : TextStyle(
                                      color: Color(0xFF0078FF),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                      fontSize: 14,
                                      fontFamily: "SFProTextReg",
                                    ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            const Icon(
                              Icons.download,
                              color: Color(0xFF0078FF),
                              size: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
