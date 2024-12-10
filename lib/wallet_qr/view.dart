// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_tciket_style.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../custom_widgets/app_color.dart';
import '../wallet_qr/controller.dart';

class QrWallet extends GetView<QrWalletController> {
  const QrWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: AppColor.primaryColor,
          body: Column(
            children: [
              CustomAppbar(
                title: controller.currentPage.value == 0 ? "Payment" : "My QR",
                bgColor: AppColor.primaryColor,
                titleColor: Colors.white,
                textColor: Colors.white,
                btnColor: null,
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
                                text: "My QR",
                                fontSize: 10,
                                color: controller.currentPage.value != 1
                                    ? Colors.white38
                                    : Colors.white,
                              ),
                            ),
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
                    : ScrollConfiguration(
                        behavior: ScrollBehavior().copyWith(overscroll: false),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(15, 17, 15, 15),
                                child: Column(
                                  children: [
                                    controller.userImage.isEmpty
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
                                              base64Decode(
                                                  controller.userImage.value),
                                            )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    CustomTitle(
                                      text: controller.fullName.value,
                                      maxlines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                    Container(height: 5),
                                    CustomParagraph(
                                      text: controller.mono.value,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF616161),
                                      maxlines: 2,
                                      textAlign: TextAlign.center,
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height /
                                        4.5,
                                    child: PrettyQrView(
                                      decoration: const PrettyQrDecoration(
                                          image: PrettyQrDecorationImage(
                                              image: AssetImage(
                                                  "assets/images/logo.png"))),
                                      qrImage: QrImage(QrCode.fromData(
                                          data: controller.payKey.value,
                                          errorCorrectLevel:
                                              QrErrorCorrectLevel.H)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  // QrImageView(
                                  //   data: controller.payKey.value,
                                  //   version: QrVersions.auto,
                                  //   size: 200,
                                  //   gapless: false,
                                  // ),
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .80,
                                          height: 40,
                                          padding: const EdgeInsets.all(
                                              10), // Padding values
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Color(0xFF0078FF),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(7),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: const [
                                              CustomParagraph(
                                                textAlign: TextAlign.center,
                                                minFontSize: 12,
                                                text: 'Generate QR code',
                                                color: Color(0xFF0078FF),
                                                fontWeight: FontWeight.normal,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons.sync_outlined,
                                                size: 20.0,
                                                color: Color(0xFF0078FF),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            controller.shareQr();
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .37,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(7)),
                                                border: Border.all(
                                                  color: Color(0xFF0078FF),
                                                )),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 0, 20, 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  CustomParagraph(
                                                    textAlign: TextAlign.center,
                                                    minFontSize: 12,
                                                    text: 'Share',
                                                    color: Color(0xFF0078FF),
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Icon(
                                                    Icons.share_outlined,
                                                    size: 17.0,
                                                    color: Color(0xFF0078FF),
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
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .37,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(7)),
                                                border: Border.all(
                                                  color: Color(0xFF0078FF),
                                                )),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 0, 20, 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  CustomParagraph(
                                                    textAlign: TextAlign.center,
                                                    minFontSize: 12,
                                                    text: 'Save',
                                                    color: Color(0xFF0078FF),
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Icon(
                                                    Icons
                                                        .download_for_offline_outlined,
                                                    size: 20.0,
                                                    color: Color(0xFF0078FF),
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
        child: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 17, 0, 15),
                  child: Column(
                    children: [
                      controller.userImage.value.isEmpty
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
                                base64Decode(controller.userImage.value),
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
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 4.5,
                      child: PrettyQrView(
                        decoration: const PrettyQrDecoration(
                            image: PrettyQrDecorationImage(
                                image: AssetImage("assets/images/logo.png"))),
                        qrImage: QrImage(QrCode.fromData(
                            data: controller.mobNum.value,
                            errorCorrectLevel: QrErrorCorrectLevel.H)),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // QrImageView(
                    //   data: controller.mobNum.value,
                    //   version: QrVersions.auto,
                    //   gapless: false,
                    //   size: 200,
                    // ),
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
                        width: MediaQuery.of(context).size.width * .37,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(7)),
                            border: Border.all(
                              color: Color(0xFF0078FF),
                            )),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomParagraph(
                                textAlign: TextAlign.center,
                                minFontSize: 12,
                                text: 'Share',
                                color: Color(0xFF0078FF),
                                fontWeight: FontWeight.normal,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.share_outlined,
                                size: 17.0,
                                color: Color(0xFF0078FF),
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
                        width: MediaQuery.of(context).size.width * .37,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(7)),
                            border: Border.all(
                              color: Color(0xFF0078FF),
                            )),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomParagraph(
                                textAlign: TextAlign.center,
                                minFontSize: 12,
                                text: 'Save',
                                color: Color(0xFF0078FF),
                                fontWeight: FontWeight.normal,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.download_for_offline_outlined,
                                size: 20.0,
                                color: Color(0xFF0078FF),
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
      ),
    );
  }
}
