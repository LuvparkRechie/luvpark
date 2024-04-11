import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateMpin extends StatefulWidget {
  final String? headerLabel;
  final Function callback;
  const UpdateMpin({
    this.headerLabel,
    required this.callback,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<UpdateMpin> {
  TextEditingController oldMpinControllerr = TextEditingController();
  TextEditingController mpin1Controller = TextEditingController();
  TextEditingController mpin2Controller = TextEditingController();

  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  int totalPages = 3;
  // ignore: prefer_typing_uninitialized_variables
  var akongP;
  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  void getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    akongP = prefs.getString(
      'userData',
    );
    akongP = jsonDecode(akongP!);
  }

  @override
  Widget build(BuildContext context) {
    bool isShowKeyboard = MediaQuery.of(context).viewInsets.bottom == 0;
    return CustomParent1Widget(
        appBarheaderText: widget.headerLabel!,
        appBarIconClick: () {
          Navigator.of(context).pop();
        },
        child: Column(
          children: [
            Container(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: _currentPage == 0 ||
                            _currentPage == 1 ||
                            _currentPage == 2
                        ? AppColor.primaryColor
                        : const Color.fromARGB(255, 206, 231, 252),
                    child: Center(
                      child: Icon(
                        _currentPage == 0 ||
                                _currentPage == 1 ||
                                _currentPage == 2
                            ? Icons.check
                            : Icons.circle,
                        color: _currentPage == 0 ||
                                _currentPage == 1 ||
                                _currentPage == 2
                            ? Colors.white
                            : AppColor.primaryColor,
                        size: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 3,
                      color: _currentPage == 1 || _currentPage == 2
                          ? AppColor.primaryColor
                          : const Color.fromARGB(255, 206, 231, 252),
                    ),
                  ),
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: _currentPage == 1 || _currentPage == 2
                        ? AppColor.primaryColor
                        : const Color.fromARGB(255, 206, 231, 252),
                    child: Center(
                      child: Icon(
                        _currentPage == 1 || _currentPage == 2
                            ? Icons.check
                            : Icons.circle,
                        color: _currentPage == 1 || _currentPage == 2
                            ? Colors.white
                            : AppColor.primaryColor,
                        size: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 3,
                      color: _currentPage == 2
                          ? AppColor.primaryColor
                          : const Color.fromARGB(255, 206, 231, 252),
                    ),
                  ),
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: _currentPage == 2
                        ? AppColor.primaryColor
                        : const Color.fromARGB(255, 206, 231, 252),
                    child: Center(
                      child: Icon(
                        _currentPage == 2 ? Icons.check : Icons.circle,
                        color: _currentPage == 2
                            ? Colors.white
                            : AppColor.primaryColor,
                        size: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 20,
            ),
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: <Widget>[
                  // Page 1
                  Step1Pin(
                    controller: oldMpinControllerr,
                    onNextPage: () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                  ),
                  Step2Pin(
                    mpin1Controller: mpin1Controller,
                    onNextPage: () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                  ),

                  // Page 2
                  Step3Pin(
                    mpin1Controller: mpin1Controller,
                    mpin2Controller: mpin2Controller,
                    onNextPage: () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                  ),
                ],
              ),
            ),
            if (isShowKeyboard) const SizedBox(height: 20.0),
            if (isShowKeyboard)
              CustomButton(
                label: _currentPage == 2 ? "Submit" : "Continue",
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());

                  if (_currentPage == 0) {
                    if (oldMpinControllerr.text.isNotEmpty &&
                        oldMpinControllerr.text.length == 6) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  } else if (_currentPage == 1) {
                    if (mpin1Controller.text.isNotEmpty &&
                        mpin1Controller.text.length == 6) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  } else {
                    if (mpin1Controller.text.toLowerCase() ==
                        mpin2Controller.text.toLowerCase()) {
                      CustomModal(context: context).loader();
                      FocusManager.instance.primaryFocus!.unfocus();
                      var parameters = {
                        "mobile_no": akongP["mobile_no"],
                        "old_mpin": oldMpinControllerr.text,
                        "new_mpin": mpin2Controller.text,
                      };

                      HttpRequest(
                              api: ApiKeys.gApiSubFolderGetPutPostMpin,
                              parameters: parameters)
                          .put()
                          .then((returnPost) async {
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
                            Navigator.pop(context);
                            showAlertDialog(context, "Success",
                                "You have successfully set your MPIN. You can use it on your next login.",
                                () {
                              Navigator.of(context).pop();
                              if (Navigator.canPop(context)) {
                                Navigator.of(context).pop();
                              }
                              widget.callback();
                            });
                          } else {
                            Navigator.pop(context);
                            setState(() {
                              mpin2Controller.text = "";
                              mpin1Controller.text = "";
                              oldMpinControllerr.text = "";
                            });
                            showAlertDialog(context, "Error",
                                "Your previous MPIN is incorrect.", () {
                              Navigator.of(context).pop();
                              FocusScope.of(context).requestFocus(FocusNode());
                              _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                              Future.delayed(const Duration(milliseconds: 200),
                                  () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut);
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut);
                              });
                            });
                          }
                        }
                      });

                      // Navigator.push(
                      //     context,
                      //     PageTransition(
                      //       type: PageTransitionType.leftToRightWithFade,
                      //       duration: const Duration(seconds: 1),
                      //       alignment: Alignment.centerLeft,
                      //       child: MpinLogin(),
                      //     ));
                    }
                  }
                },
              ),
            const SizedBox(height: 10.0),
          ],
        ));
  }
}

// ignore: must_be_immutable
class Step1Pin extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onNextPage;
  const Step1Pin(
      {super.key, required this.onNextPage, required this.controller});

  @override
  State<Step1Pin> createState() => _Step1PinState();
}

class _Step1PinState extends State<Step1Pin> {
  String mpinValue = "";
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(
        fontSize: 24,
        color: AppColor.primaryColor,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.borderColor, width: 2),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderLabel(
            title: "Enter your MPIN code",
            subTitle: "Make sure to enter the correct MPIN code",
          ),
          Container(
            height: 33,
          ),
          CustomDisplayText(
            label: 'MPIN code',
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 14,
          ),
          Container(
            height: 8,
          ),
          Directionality(
            // Specify direction if desired
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              androidSmsAutofillMethod:
                  AndroidSmsAutofillMethod.smsUserConsentApi,
              listenForMultipleSmsOnAndroid: true,
              defaultPinTheme: defaultPinTheme,

              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) {
                if (pin.length == 6) {
                  setState(() {
                    mpinValue = pin;
                    widget.controller.text = mpinValue;
                  });
                }
              },
              onChanged: (value) {
                setState(() {
                  widget.controller.text = value;
                });
                if (value.isEmpty) {
                  setState(() {
                    mpinValue = "";
                    widget.controller.text = mpinValue;
                  });
                }
              },
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    width: 22,
                    height: 1,
                    color: AppColor.primaryColor,
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColor.primaryColor, width: 2),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColor.bodyColor,
                  border: Border.all(color: AppColor.primaryColor, width: 2),
                ),
              ),
              // errorPinTheme: defaultPinTheme.copyBorderWith(
              //   border: Border.all(color: Colors.redAccent),
              // ),
            ),
          ),
          Container(
            height: 8,
          ),
          CustomDisplayText(
            label: "The MPIN code you've used for login.",
            fontWeight: FontWeight.normal,
            color: Colors.black54,
            fontSize: 14,
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class Step2Pin extends StatefulWidget {
  final TextEditingController mpin1Controller;
  final VoidCallback onNextPage;
  const Step2Pin(
      {super.key, required this.onNextPage, required this.mpin1Controller});

  @override
  State<Step2Pin> createState() => _Step2PinState();
}

class _Step2PinState extends State<Step2Pin> {
  String mpinValue = "";
  bool isMatchPin = true;
  bool netypeNa = false;
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(
        fontSize: 24,
        color: AppColor.primaryColor,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.borderColor, width: 2),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderLabel(
            title: "Enter a new MPIN",
            subTitle:
                "You’ll use it to securely unlock and access your app, so "
                "please don’t share it with anyone.",
          ),
          Container(
            height: 33,
          ),
          CustomDisplayText(
            label: 'MPIN code',
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 14,
          ),
          Container(
            height: 8,
          ),
          Directionality(
            // Specify direction if desired
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              androidSmsAutofillMethod:
                  AndroidSmsAutofillMethod.smsUserConsentApi,
              listenForMultipleSmsOnAndroid: true,
              defaultPinTheme: defaultPinTheme,
              controller: widget.mpin1Controller,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) {
                if (pin.length == 6) {
                  setState(() {
                    mpinValue = pin;
                    widget.mpin1Controller.text = mpinValue;
                  });
                }
              },
              onChanged: (value) {
                setState(() {
                  widget.mpin1Controller.text = value;
                });
                if (value.isEmpty) {
                  setState(() {
                    mpinValue = "";
                    widget.mpin1Controller.text = mpinValue;
                  });
                }
              },
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    width: 22,
                    height: 1,
                    color: AppColor.primaryColor,
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColor.primaryColor, width: 2),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColor.bodyColor,
                  border: Border.all(color: AppColor.primaryColor, width: 2),
                ),
              ),
              // errorPinTheme: defaultPinTheme.copyBorderWith(
              //   border: Border.all(color: Colors.redAccent),
              // ),
            ),
          ),
          Container(
            height: 8,
          ),
          CustomDisplayText(
            label: "You will use this MPIN to login",
            fontWeight: FontWeight.normal,
            color: Colors.black54,
            fontSize: 14,
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class Step3Pin extends StatefulWidget {
  final TextEditingController mpin1Controller;
  final TextEditingController mpin2Controller;
  final VoidCallback onNextPage;
  const Step3Pin(
      {super.key,
      required this.onNextPage,
      required this.mpin1Controller,
      required this.mpin2Controller});

  @override
  State<Step3Pin> createState() => _Step3PinState();
}

class _Step3PinState extends State<Step3Pin> {
  String mpinValue = "";
  bool isMatchPin = true;
  bool netypeNa = false;
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(
        fontSize: 24,
        color: AppColor.primaryColor,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.borderColor, width: 2),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeaderLabel(
            title: "Confirm your MPIN",
            subTitle: "Ensure that you enter the correct MPIN.",
          ),
          Container(
            height: 33,
          ),
          CustomDisplayText(
            label: 'MPIN code',
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 14,
          ),

          Container(
            height: 8,
          ),
          Directionality(
            // Specify direction if desired
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              androidSmsAutofillMethod:
                  AndroidSmsAutofillMethod.smsUserConsentApi,
              listenForMultipleSmsOnAndroid: true,
              defaultPinTheme: defaultPinTheme,
              controller: widget.mpin2Controller,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) {
                if (pin.length == 6) {
                  setState(() {
                    netypeNa = true;
                    mpinValue = pin;
                    widget.mpin2Controller.text = mpinValue;
                  });
                  if (int.parse(widget.mpin1Controller.text) ==
                      int.parse(widget.mpin2Controller.text)) {
                    setState(() {
                      isMatchPin = true;
                    });
                  } else {
                    setState(() {
                      isMatchPin = false;
                    });
                  }
                }
                if (pin.isEmpty) {
                  setState(() {
                    isMatchPin = false;
                  });
                }
              },
              onChanged: (value) {
                setState(() {
                  widget.mpin2Controller.text = value;
                });
                if (value.isEmpty) {
                  setState(() {
                    mpinValue = "";

                    widget.mpin2Controller.text = mpinValue;
                  });
                }
              },
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    width: 22,
                    height: 1,
                    color: AppColor.primaryColor,
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColor.primaryColor, width: 2),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColor.bodyColor,
                  border: Border.all(color: AppColor.primaryColor, width: 2),
                ),
              ),
              // errorPinTheme: defaultPinTheme.copyBorderWith(
              //   border: Border.all(color: Colors.redAccent),
              // ),
            ),
          ),
          Container(
            height: 8,
          ),
          // if (!isMatchPin)
          if (netypeNa)
            Row(
              children: [
                Icon(
                  isMatchPin ? Icons.check_circle : Icons.error_rounded,
                  color: isMatchPin ? Colors.green : Colors.red,
                  size: 15,
                ),
                CustomDisplayText(
                  label:
                      " Your MPIN code are ${isMatchPin ? "" : "not"} the same",
                  fontWeight: FontWeight.w600,
                  color: isMatchPin ? Colors.green : Colors.red,
                  fontSize: 14,
                ),
              ],
            ),
          if (!netypeNa)
            CustomDisplayText(
              label: "You will use this MPIN to login",
              fontWeight: FontWeight.normal,
              color: Colors.black54,
              fontSize: 14,
            ),
        ],
      ),
    );
  }
}
