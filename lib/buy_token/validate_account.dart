import 'dart:async';
import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/webview/webview.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ValidateNumberPage extends StatefulWidget {
  const ValidateNumberPage({super.key, required this.tokenAmount});
  final String tokenAmount;
  @override
  State<ValidateNumberPage> createState() => _ValidateNumberPageState();
}

class _ValidateNumberPageState extends State<ValidateNumberPage> {
  Timer? _debounce;
  final GlobalKey<FormState> page1Key = GlobalKey<FormState>();
  FocusNode focusNudes = FocusNode();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController rname = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController amountController = TextEditingController();
  String fullName = "";
  String hash = "";
  String pageUrl = "";
  String aesKeys = "";
  String accountName = "";
  bool isActiveBtn = false;
  bool isValidNumber = false;
  bool isLoadingPage = true;
  bool isDisabledButton = true;
  int? akongId;
  int? selectedBankType;
  int? selectedBankTracker;
  bool isSelectedPartner = false;
  // ignore: prefer_typing_uninitialized_variables
  var akongP;
  final List<dynamic> bankPartner = [
    {
      "name": "U-Bank",
      "value": "UB",
      "img_url": "assets/images/ubank.png",
    },
    // {
    //   "name": "U-Bank",
    //   "value": "GC",
    //   "img_url": "assets/images/gcash.png",
    // },
  ];

  // ignore: prefer_typing_uninitialized_variables
  var userDataInfo;
  var bankData = [];

  @override
  void initState() {
    super.initState();

    rname = TextEditingController();
    amountController = TextEditingController(text: widget.tokenAmount);
    fullName = "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserInfo();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    akongP = prefs.getString(
      'userData',
    );

    mobileNo.text = jsonDecode(akongP!)['mobile_no'].toString().substring(2);
    _onSearchChanged(mobileNo.text, true);
  }

  void getBankUrl(bankCode, ind) {
    String subApi = "${ApiKeys.gApiSubFolderGetUbDetails}?code=$bankCode";

    CustomModal(context: context).loader();
    HttpRequest(api: subApi).get().then((objData) {
      if (objData == "No Internet") {
        setState(() {
          isSelectedPartner = false;
          selectedBankType = null;
          selectedBankTracker = null;
        });
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (objData == null || objData["items"].length == 0) {
        Navigator.of(context).pop();
        setState(() {
          isSelectedPartner = false;
          isLoadingPage = false;
          selectedBankType = null;
          selectedBankTracker = null;
        });

        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });

        return;
      } else {
        Navigator.of(context).pop();
        getBankData(objData["items"][0]["app_id"],
            objData["items"][0]["page_url"], ind);
      }
    });
  }

  getBankData(appId, url, ind) {
    String bankParamApi = "${ApiKeys.gApiSubFolderGetBankParam}?app_id=$appId";
    CustomModal(context: context).loader();
    HttpRequest(api: bankParamApi).get().then((objData) {
      if (objData == "No Internet") {
        setState(() {
          isSelectedPartner = false;
          selectedBankType = null;
          selectedBankTracker = null;
        });

        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (objData == null || objData["items"].length == 0) {
        Navigator.of(context).pop();
        setState(() {
          isSelectedPartner = false;
          isLoadingPage = false;
          selectedBankType = null;
          selectedBankTracker = null;
        });

        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });

        return;
      } else {
        var dataObj = {};

        for (int i = 0; i < objData["items"].length; i++) {
          dataObj[objData["items"][i]["param_key"]] =
              objData["items"][i]["param_value"];
        }

        setState(() {
          isLoadingPage = false;
          selectedBankType = ind;
          selectedBankTracker = ind;
          isSelectedPartner = true;
          aesKeys = dataObj["AES_KEY"];
          pageUrl = Uri.decodeFull(url);
        });

        Navigator.of(context).pop();
      }
    });
  }

  _onSearchChanged(mobile, isFirst) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (mobile.toString().length < 10) {
      return;
    }
    Duration duration = const Duration(milliseconds: 200);
    if (isFirst) {
      setState(() {
        duration = const Duration(milliseconds: 200);
      });
    } else {
      setState(() {
        duration = const Duration(seconds: 2);
      });
    }

    _debounce = Timer(duration, () {
      CustomModal(context: context).loader();

      HttpRequest(
              api:
                  "${ApiKeys.gApiSubFolderGetUserInfo}?mobile_no=63${mobile.toString().replaceAll(" ", '')}")
          .get()
          .then((objData) {
        if (objData == "No Internet") {
          setState(() {
            isValidNumber = false;
            rname.text = "";
            fullName = "";
            userName.text = "";
          });
          Navigator.of(context).pop();
          showAlertDialog(context, "Error",
              "Please check your internet connection and try again.", () {
            Navigator.of(context).pop();
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          });
          return;
        }
        if (objData == null) {
          Navigator.of(context).pop();
          setState(() {
            isActiveBtn = false;
            isValidNumber = false;
            rname.text = "";
            fullName = "";
            userName.text = "";
          });
          showAlertDialog(context, "Error",
              "Error while connecting to server, Please try again.", () {
            Navigator.of(context).pop();
          });
          return;
        }
        if (objData["items"].length == 0) {
          Navigator.of(context).pop();
          setState(() {
            isActiveBtn = false;
            userDataInfo = null;
            rname.text = "";
            userName.text = "";
            fullName = "";
            isValidNumber = false;
          });
          showAlertDialog(
              context, "Error", "Sorry, we're unable to find your account.",
              () {
            //  onChangeText();
            Navigator.of(context).pop();
          });
          return;
        } else {
          Navigator.of(context).pop();
          setState(() {
            isActiveBtn = true;
            userDataInfo = objData["items"][0];
            isValidNumber = true;
            String originalFullName = userDataInfo["first_name"].toString();
            String transformedFullName = Variables.transformFullName(
                originalFullName.replaceAll(RegExp(r'\..*'), ''));
            String transformedLname = Variables.transformFullName(
                userDataInfo["last_name"]
                    .toString()
                    .replaceAll(RegExp(r'\..*'), ''));

            String middelName = "";
            if (userDataInfo["middle_name"] != null) {
              setState(() {
                middelName = "${userDataInfo["middle_name"].toString()[0]}";
              });
            } else {
              setState(() {
                middelName = "";
              });
            }
            userName.text =
                "$originalFullName $middelName ${userDataInfo["last_name"].toString()}";
            fullName =
                '$transformedFullName $middelName${middelName.isNotEmpty ? "." : ""} $transformedLname';
            rname.text = fullName;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return bodyniya();
  }

  Widget bodyniya() {
    return CustomParent1Widget(
        canPop: true,
        appBarheaderText: "Load",
        appBarIconClick: () {
          Navigator.of(context).pop();
        },
        child: Form(
          key: page1Key,
          autovalidateMode: AutovalidateMode.always,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: CustomDisplayText(
                    label: 'Payment Method',
                    fontSize: 15,
                    color: Colors.black87,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                FadeInLeft(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int index = 0; index < bankPartner.length; index++)
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (!isValidNumber) {
                                    return;
                                  }
                                  setState(() {
                                    selectedBankType = index;
                                  });
                                  SchedulerBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (bankPartner[index]["value"] == "GC") {
                                      CustomModal(context: context).loader();

                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        Navigator.pop(context);
                                        setState(() {
                                          selectedBankType =
                                              selectedBankTracker;
                                        });
                                        showAlertDialog(context, "Error",
                                            "We're currently working on it, Please try again later.",
                                            () {
                                          Navigator.of(context).pop();
                                        });
                                      });

                                      return;
                                    }
                                    setState(() {
                                      selectedBankTracker = selectedBankType;
                                    });
                                    getBankUrl(
                                        bankPartner[index]["value"], index);
                                  });
                                },
                                child: Container(
                                  height: 70,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: selectedBankType == index
                                            ? AppColor.primaryColor
                                            : Colors.black12,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFFffffff),
                                    image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: AssetImage(
                                          bankPartner[index]["img_url"]),
                                    ),
                                  ),
                                  child: Stack(children: [
                                    Align(
                                      alignment: const Alignment(1.0, 1.0),
                                      child: selectedBankType == index
                                          ? const Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.green,
                                              size: 25,
                                            )
                                          : const SizedBox(),
                                    )
                                  ]),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 10.0),
                //   child: AutoSizeText(
                //     'Top-up account',
                //     style: GoogleFonts.varela(
                //         fontSize: 15,
                //         color: Colors.black87,
                //         letterSpacing: 1,
                //         fontWeight: FontWeight.w600),
                //     softWrap: true,
                //     overflow: TextOverflow.ellipsis,
                //   ),
                // ),
                CustomDisplayText(
                  label: 'Top-up account',
                  fontSize: 15,
                  color: Colors.black87,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFffffff),
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        LabelText(text: "Recipient Number"),
                        CustomMobileNumber(
                          labelText: "Mobile No",
                          controller: mobileNo,
                          inputFormatters: [Variables.maskFormatter],
                          onChange: (value) {
                            setState(() {
                              isActiveBtn = false;
                            });
                            _onSearchChanged(value.replaceAll(" ", ""), false);
                            //  onChangeText();
                          },
                        ),
                        LabelText(text: "Recipient Name"),
                        CustomTextField(
                          isReadOnly: true,
                          controller: rname,
                          labelText: "Recipient Name",
                        ),
                        LabelText(text: "Amount"),
                        CustomTextField(
                          isReadOnly: true,
                          controller: amountController,
                          labelText: "Amount",
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                Center(
                    child: CustomButton(
                        color: !isActiveBtn || !isSelectedPartner
                            ? AppColor.primaryColor.withOpacity(.7)
                            : AppColor.primaryColor,
                        label: "Pay Now",
                        onTap: () {
                          if (page1Key.currentState!.validate()) {
                            FocusManager.instance.primaryFocus!.unfocus();
                            if (!isActiveBtn) {
                              return;
                            }
                            if (!isSelectedPartner) {
                              showAlertDialog(context, "Attention",
                                  "Please Select payment method", () {
                                Navigator.of(context).pop();
                              });
                              return;
                            }

                            var dataParam = {
                              "amount": widget.tokenAmount,
                              "user_id": userDataInfo["user_id"],
                              "to_mobile_no":
                                  "63${mobileNo.text.replaceAll(" ", "")}",
                            };
                            CustomModal(context: context).loader();
                            HttpRequest(
                                    api: ApiKeys.gApiSubFolderPostUbTrans,
                                    parameters: dataParam)
                                .post()
                                .then((returnPost) {
                              if (returnPost == "No Internet") {
                                Navigator.pop(context);
                                showAlertDialog(context, "Error",
                                    "Please check your internet connection and try again.",
                                    () {
                                  Navigator.pop(context);
                                });
                                return;
                              }
                              if (returnPost == null) {
                                Navigator.pop(context);
                                showAlertDialog(context, "Error",
                                    "Error while connecting to server, Please try again.",
                                    () {
                                  Navigator.of(context).pop();
                                });
                              } else {
                                if (returnPost["success"] == 'Y') {
                                  var plainText = {
                                    "Amt": widget.tokenAmount,
                                    "Email":
                                        jsonDecode(akongP!)['email'].toString(),
                                    "Mobile": mobileNo.text.replaceAll(" ", ""),
                                    "Redir": "https://www.example.com",
                                    "References": [
                                      {
                                        "Id": "1",
                                        "Name": "RECIPIENT_MOBILE_NO",
                                        "Val":
                                            "63${mobileNo.text.replaceAll(" ", "")}"
                                      },
                                      {
                                        "Id": "2",
                                        "Name": "RECIPIENT_FULL_NAME",
                                        "Val": userName.text
                                            .replaceAll(RegExp(' +'), ' ')
                                      },
                                      {
                                        "Id": "3",
                                        "Name": "TNX_HK",
                                        "Val": returnPost["hash-key"]
                                      }
                                    ]
                                  };
                                  print("plainText $plainText");

                                  Navigator.of(context).pop();

                                  testUBUriPage(
                                      json.encode(plainText), aesKeys);
                                  if (Navigator.canPop(context)) {
                                    Navigator.of(context).pop();
                                  }
                                } else {
                                  Navigator.pop(context);
                                  showAlertDialog(
                                      context, "Error", returnPost['msg'], () {
                                    Navigator.of(context).pop();
                                  });
                                }
                              }
                            });
                          }
                        })),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> testUBUriPage(plainText, secretKeyHex) async {
    final secretKey = Variables.hexStringToArrayBuffer(secretKeyHex);
    final nonce = Variables.generateRandomNonce();

    // Encrypt
    final encrypted = await Variables.encryptData(secretKey, nonce, plainText);

    final concatenatedArray = Variables.concatBuffers(nonce, encrypted);
    final output = Variables.arrayBufferToBase64(concatenatedArray);

    setState(() {
      hash = Uri.encodeComponent(output);
    });
    print("hash $hash");
    // ignore: use_build_context_synchronously

    // ignore: use_build_context_synchronously
    Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.scale,
          duration: const Duration(seconds: 1),
          alignment: Alignment.centerLeft,
          child: WebviewPage(urlDirect: "$pageUrl$hash", label: "Bank Payment"),
        ));
  }

  Widget ngenge(String label, Function onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(70.0),
        ),
        color: const Color(0xFFffffff),
        child: SizedBox(
          width: 70,
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    letterSpacing: 1,
                    fontWeight: FontWeight.normal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                "php",
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                    letterSpacing: 1,
                    fontWeight: FontWeight.normal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
