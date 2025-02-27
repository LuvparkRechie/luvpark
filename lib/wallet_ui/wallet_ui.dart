import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../custom_widgets/app_color.dart';

class WalletUI extends StatefulWidget {
  const WalletUI({super.key});

  @override
  State<WalletUI> createState() => _WalletUIState();
}

class _WalletUIState extends State<WalletUI> {
  bool isSecond = false;
  bool isFlipCard = false;

  List features = [
    {"btn_name": "Load", "icon": LucideIcons.wallet},
    {"btn_name": "Transfer", "icon": LucideIcons.arrowLeftRight},
    {"btn_name": "QR Code", "icon": LucideIcons.qrCode},
    {"btn_name": "Bill", "icon": LucideIcons.wallet},
    {"btn_name": "Merchant", "icon": Iconsax.receipt_text}
  ];

  @override
  void initState() {
    super.initState();
    onLoading();
  }

  void onLoading() {
    Timer(Duration(milliseconds: 200), () {
      setState(() {
        isSecond = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text("My Wallet"),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 30),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: switchCard(),
              crossFadeState: !isSecond
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 200),
            ),
            Container(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomParagraph(
                text: "Features",
                fontWeight: FontWeight.w600,
                color: AppColor.headerColor,
              ),
            ),
            Container(height: 20),
            Expanded(
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      buildButton("Load"),
                      buildButton("Transfer"),
                      buildButton("QR Code"),
                      buildButton("More")
                    ],
                  ),
                  // AnimatedSize(
                  //   duration: const Duration(milliseconds: 300),
                  //   curve: Curves.easeInOut,
                  //   child: Column(
                  //     children: List.generate(isExpanded ? features.length : 4,
                  //         (index) {
                  //       Widget? myWidget;
                  //       for (int i = 0; i < features.length; i += 4)
                  //         myWidget = Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //           children: [
                  //             for (int j = i;
                  //                 j < i + 4 && j < features.length;
                  //                 j++)
                  //               buildButton()
                  //           ],
                  //         );

                  //       return myWidget!;
                  //     }),
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                ],
              )),
            )
          ],
        ),
      ),
    );
  }

  Widget switchCard() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFlipCard = !isFlipCard;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: AnimatedCrossFade(
          firstChild: buildWalletCard(),
          secondChild: builQRCard(),
          crossFadeState: !isFlipCard
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: Duration(milliseconds: 200),
        ),
      ),
    );
  }

  Widget buildWalletCard() {
    return Container(
      height: 190,
      width: double.infinity,
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage("assets/images/wallet_card.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        fit: StackFit.loose,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 50),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomParagraph(
                            text: "Balance",
                            fontSize: 11,
                            color: AppColor.bodyColor.withOpacity(.7),
                          ),
                          Container(height: 5),
                          CustomParagraph(
                            text: "0.00",
                            fontSize: 20,
                            color: AppColor.bodyColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ],
                      ),
                    ),
                    Container(width: 10),
                    CustomParagraph(
                      text: "Tap to show QR",
                      fontSize: 14,
                      minFontSize: 10,
                      color: Colors.white.withOpacity(.4),
                      fontWeight: FontWeight.bold,
                    )
                  ],
                ),
                Container(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CustomParagraph(
                              text: "Mobile number",
                              fontSize: 11,
                              color: AppColor.bodyColor.withOpacity(.7),
                            ),
                          ),
                          Container(height: 5),
                          CustomParagraph(
                            text: "639996780889",
                            fontSize: 14,
                            color: AppColor.bodyColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                    Container(width: 10),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: CustomParagraph(
                            text: "Reward",
                            fontSize: 12,
                            color: AppColor.bodyColor.withOpacity(.7),
                          ),
                        ),
                        Container(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset(
                                height: 20, "assets/images/rewardicon.png"),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: CustomParagraph(
                                text: "20.00",
                                fontSize: 14,
                                color: AppColor.bodyColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: -5,
            child: Container(
              padding: EdgeInsets.zero,
              height: 30,
              width: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/luvpark.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 5,
            child: CustomParagraph(
              text: DateFormat('yyyy-MM-dd HH:mm:ss').format(
                DateTime.now(),
              ),
              fontSize: 12,
              color: AppColor.bodyColor.withOpacity(.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget builQRCard() {
    return Container(
      height: 190,
      width: double.infinity,
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage("assets/images/wallet_card.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: PrettyQrView(
              decoration: const PrettyQrDecoration(
                background: Colors.white,
                image: PrettyQrDecorationImage(
                  image: AssetImage("assets/images/logo.png"),
                ),
              ),
              qrImage: QrImage(
                QrCode.fromData(
                  data: "639996780889",
                  errorCorrectLevel: QrErrorCorrectLevel.H,
                ),
              ),
            ),
          ),
          Container(width: 15),
          Expanded(
            child: CustomParagraph(
              text: "Place the QR code inside the frame to scan.",
              textAlign: TextAlign.center,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget buildButton(String btnName) {
    double myWidth = MediaQuery.of(context).size.width / 3.6;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Container(
              width: myWidth,
              height: myWidth / 1.8,
              // padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7), color: Colors.white),
              child: Icon(
                LucideIcons.share,
                color: AppColor.primaryColor,
              ),
            ),
            Container(height: 5),
            CustomParagraph(
              text: btnName,
              color: AppColor.headerColor,
            )
          ],
        ),
      ),
    );
  }
}
