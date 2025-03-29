// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../auth/authentication.dart';
import '../custom_widgets/app_color.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/custom_text.dart';
import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/no_internet.dart';
import '../functions/functions.dart';
import 'controller.dart';

class GenerateReceiveQR extends StatefulWidget {
  const GenerateReceiveQR({super.key});

  @override
  State<GenerateReceiveQR> createState() => _GenerateReceiveQRState();
}

class _GenerateReceiveQRState extends State<GenerateReceiveQR> {
  final GlobalKey _qrKey = GlobalKey();
  bool isButtonActive = true;
  bool isLoading = true;
  final args = Get.arguments;
  bool hasNet = true;
  List userData = [];
  bool isBalanceVisible = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  Timer? _timer;
  String selectedAmount = "";
  List padData = [];
  bool isActiveBtn = false;
  List dataList = [
    {"value": 50, "is_active": false},
    {"value": 100, "is_active": false},
    {"value": 150, "is_active": false},
    {"value": 200, "is_active": false},
    {"value": 250, "is_active": false},
    {"value": 300, "is_active": false},
    {"value": 350, "is_active": false},
    {"value": 400, "is_active": false},
    {"value": 500, "is_active": false},
  ];
  @override
  void initState() {
    super.initState();
    padData = dataList;
    getUserBalance();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setCursorToEnd();
    });
    timerPeriodic();
  }

  Future<void> timerPeriodic() async {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      getUserBalance();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setCursorToEnd() {
    amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountController.text.length));
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 1) {
      return 'Please enter a valid amount greater than zero';
    }
    if (amount < 50) {
      return 'Amount must not be less than 50';
    }
    if (amount > 500) {
      return 'Amount must not be greater than 500';
    }

    return null;
  }

  Future<void> getUserBalance() async {
    await Functions.getUserBalance2(Get.context!, (dataBalance) async {
      if (!dataBalance[0]["has_net"]) {
        setState(() {
          isLoading = false;
          hasNet = false;
        });
        return;
      } else {
        setState(() {
          isLoading = false;
          hasNet = true;
          userData = dataBalance[0]["items"];
        });
      }
      setState(() {});
    });
  }

  Future<void> pads(int value) async {
    selectedAmount = value.toString();
    amountController.text = selectedAmount;
    _setCursorToEnd();

    bool existsInDataList = dataList.any((obj) => obj["value"] == value);

    if (existsInDataList) {
      padData = dataList.map((obj) {
        obj["is_active"] = (obj["value"] == value);
        return obj;
      }).toList();
      isActiveBtn = true;
    } else {
      padData = dataList.map((obj) {
        obj["is_active"] = false;
        return obj;
      }).toList();
      isActiveBtn = false;
    }

    setState(() {});
  }

  Widget myPads(data, int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: InkWell(
          onTap: () {
            pads(data["value"]);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              color: data["is_active"] ? AppColor.primaryColor : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomParagraph(
                  maxlines: 1,
                  minFontSize: 8,
                  text: "${data["value"]}",
                  fontWeight: FontWeight.w700,
                  color: data["is_active"] ? Colors.white : Colors.black,
                ),
                CustomParagraph(
                  text: "Token",
                  maxlines: 1,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: data["is_active"] ? Colors.white : null,
                  minFontSize: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QrWalletController());
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("QR Receive"),
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
      body: isLoading
          ? PageLoader()
          : !hasNet
              ? NoInternetConnected(onTap: () {
                  setState(() {
                    getUserBalance();
                  });
                })
              : Container(
                  padding: EdgeInsets.all(15),
                  child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                        color: AppColor.primaryColor, width: 1),
                                    top: BorderSide(
                                        color: AppColor.primaryColor,
                                        width: 0.2),
                                    right: BorderSide(
                                        color: AppColor.primaryColor,
                                        width: 0.2),
                                    bottom: BorderSide(
                                        color: AppColor.primaryColor, width: 1),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "assets/images/wallet_card.png"),
                                      fit: BoxFit.cover)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomTitle(
                                            text: "Wallet Balance",
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            letterSpacing: .5,
                                          ),
                                          CustomParagraph(
                                            text: toCurrencyString(userData[0]
                                                    ["amount_bal"]
                                                .toString()),
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      ),
                                      Image(
                                        fit: BoxFit.fitWidth,
                                        image: AssetImage(
                                          "assets/images/logo.png",
                                        ),
                                        height: 35,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomTitle(
                                            text: "Number",
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            letterSpacing: .5,
                                          ),
                                          CustomParagraph(
                                            text:
                                                "+${args["mobile_no"].toString().replaceRange(3, 8, '*****')}",
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomTitle(
                                            text: "Name",
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            letterSpacing: .5,
                                          ),
                                          CustomParagraph(
                                            text: controller.fullName.value,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(height: 20),
                            CustomParagraph(
                              text: "Amount",
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            CustomTextField(
                              suffixIcon: amountController.text != ""
                                  ? Iconsax.close_square
                                  : null,
                              onIconTap: () {
                                setState(() {
                                  amountController.clear();
                                  isActiveBtn = false;
                                  padData = dataList.map((obj) {
                                    obj["is_active"] = false;
                                    return obj;
                                  }).toList();
                                });
                              },
                              isReadOnly: true,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(3)
                              ],
                              hintText: "0.0",
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              controller: amountController,
                              validator: _validateAmount,
                              onChange: (value) {
                                setState(() {
                                  amountController.text = value.toString();
                                  isActiveBtn = false;
                                  padData = dataList.map((obj) {
                                    obj["is_active"] = false;
                                    return obj;
                                  }).toList();

                                  if (value.isEmpty) {
                                    selectedAmount = "";
                                  } else {
                                    selectedAmount = value;
                                  }
                                });
                              },
                            ),
                            Container(height: 10),
                            for (int i = 0; i < padData.length; i += 3)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (int j = i;
                                      j < i + 3 && j < padData.length;
                                      j++)
                                    myPads(padData[j], j)
                                ],
                              ),
                            Container(height: 30),
                            CustomButton(
                                text: "Generate QR Code",
                                onPressed: isButtonActive
                                    ? () async {
                                        final data = await Authentication()
                                            .getUserData2();

                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            isButtonActive = false;
                                          });

                                          await Future.delayed(
                                              Duration(milliseconds: 200));
                                          Map<String, String> args = {
                                            "mobile_no":
                                                data["mobile_no"].toString(),
                                            "amount":
                                                amountController.text.isEmpty
                                                    ? ""
                                                    : amountController.text,
                                          };
                                          showModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            isDismissible: false,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              return Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.75,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(7),
                                                  ),
                                                ),
                                                child: ScanGeneratedQR(
                                                  key: _qrKey,
                                                  onBack: () {
                                                    getUserBalance();
                                                  },
                                                  args: jsonEncode(args),
                                                ),
                                              );
                                            },
                                          );

                                          setState(() {
                                            isButtonActive = true;
                                          });
                                        }
                                      }
                                    : () {})
                          ],
                        ),
                      )),
                ),
    );
  }
}

class ScanGeneratedQR extends StatefulWidget {
  const ScanGeneratedQR({Key? key, required this.onBack, required this.args})
      : super(key: key);
  final Function onBack;
  final String args;

  @override
  State<ScanGeneratedQR> createState() => _ScanGeneratedQRState();
}

class _ScanGeneratedQRState extends State<ScanGeneratedQR> {
  late Map<String, dynamic> decoded;

  @override
  void initState() {
    super.initState();
    decoded = jsonDecode(widget.args);
  }

  void saveQr() async {
    CustomDialog().loadingDialog(Get.context!);
    String randomNumber = await Random().nextInt(100000).toString();
    String fname = "receive$randomNumber.png";
    ScreenshotController()
        .captureFromWidget(MyQRR(), delay: const Duration(seconds: 2))
        .then((image) async {
      final dir = await getApplicationDocumentsDirectory();
      final imagePath = await File('${dir.path}/$fname').create();
      await imagePath.writeAsBytes(image);
      GallerySaver.saveImage(imagePath.path).then((result) {
        CustomDialog().successDialog(Get.context!, "Success",
            "QR code has been saved. Please check your gallery.", "Okay", () {
          Get.back();
          Get.back();
        });
      });
    });
  }

  void shareQr() async {
    String randomNumber = await Random().nextInt(100000).toString();
    String fname = "shared$randomNumber.png";
    CustomDialog().loadingDialog(Get.context!);
    final directory = (await getApplicationDocumentsDirectory()).path;
    Uint8List bytes = await ScreenshotController().captureFromWidget(MyQRR());
    Uint8List pngBytes = bytes.buffer.asUint8List();

    final imgFile = File('$directory/$fname');
    imgFile.writeAsBytes(pngBytes);
    Get.back();
    await Share.shareFiles([imgFile.path]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyQRR(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      saveQr();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.download,
                          color: AppColor.primaryColor,
                        ),
                        Container(height: 10),
                        CustomParagraph(text: "Download")
                      ],
                    ),
                  ),
                  Container(width: 60),
                  GestureDetector(
                    onTap: () {
                      shareQr();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.share,
                          color: AppColor.primaryColor,
                        ),
                        Container(height: 10),
                        CustomParagraph(text: "Share")
                      ],
                    ),
                  ),
                ],
              ),
              CustomButton(
                  text: "Close",
                  onPressed: () {
                    widget.onBack();
                    Get.back();
                  }),
            ],
          ),
        ));
  }

  Center MyQRR() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(7),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTitle(
                text: "Scan QR Code",
                fontSize: 20,
              ),
              Container(height: 5),
              CustomParagraph(
                text: "Align the QR code within the frame to scan",
                fontSize: 14,
              ),
              Container(height: 30),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: PrettyQrView(
                  decoration: const PrettyQrDecoration(
                    background: Colors.white,
                    image: PrettyQrDecorationImage(
                      image: AssetImage("assets/images/logo.png"),
                    ),
                  ),
                  qrImage: QrImage(
                    QrCode.fromData(
                      data: widget.args,
                      errorCorrectLevel: QrErrorCorrectLevel.H,
                    ),
                  ),
                ),
              ),
              Container(height: 20),
              Visibility(
                visible: decoded["amount"].toString().isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomParagraph(
                      text: "Amount requested",
                      fontSize: 12,
                      color: AppColor.subtitleColor,
                    ),
                    CustomTitle(
                      text: decoded["amount"].toString(),
                      fontSize: 14,
                      color: AppColor.primaryColor,
                    ),
                    Container(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
