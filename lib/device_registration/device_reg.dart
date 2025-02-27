import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/app_color.dart';
import '../functions/functions.dart';
import '../http/api_keys.dart';
import '../http/http_request.dart';
import '../routes/routes.dart';

class DeviceRegScreen extends StatefulWidget {
  final String mobileNo;
  final String? userId;
  const DeviceRegScreen({super.key, required this.mobileNo, this.userId});

  @override
  State<DeviceRegScreen> createState() => _DeviceRegScreenState();
}

class _DeviceRegScreenState extends State<DeviceRegScreen> {
  final args = Get.arguments;
  bool isVerifiedOtp = false;

  @override
  void initState() {
    super.initState();
  }

  void onRegisterDev() async {
    Map<String, String> reqParam = {
      "mobile_no": widget.mobileNo.toString(),
      "req_type": "SR",
    };
    Functions().requestOtp(reqParam, (obj) {
      if (obj["success"] == "Y") {
        Map<String, String> putParam = {
          "mobile_no": widget.mobileNo.toString(),
          "otp": obj["otp"].toString(),
          "req_type": "SR"
        };
        Get.toNamed(
          Routes.otpField,
          arguments: {
            "mobile_no": widget.mobileNo,
            "verify_param": putParam,
            "callback": (otp) async {
              if (otp != null) {
                registerDevice();
              } else {
                isVerifiedOtp = false;
              }
            },
          },
        );
      }
    });
    // Get.toNamed(Routes.otpField, arguments: {
    //   "mobile_no": widget.mobileNo,
    //   "callback": (otp) async {
    //     FocusManager.instance.primaryFocus?.unfocus();

    //     CustomDialog().loadingDialog(Get.context!);

    //     final devKey = await Functions().getUniqueDeviceId();
    //     Map<String, dynamic> postParamRegDev = {
    //       "user_id": userId,
    //       "device_key": devKey
    //     };

    //     final response = await HttpRequest(
    //             api: ApiKeys.postRegDevice, parameters: postParamRegDev)
    //         .postBody();

    //     Get.back();
    //     if (response == "No Internet") {
    //       CustomDialog().internetErrorDialog(Get.context!, () {
    //         Get.back();
    //       });
    //       return;
    //     }
    //     if (response == null) {
    //       CustomDialog().errorDialog(Get.context!, "Error",
    //           "Error while connecting to server, Please try again.", () {
    //         Get.back();
    //       });
    //       return;
    //     }
    //     if (response["success"] == 'Y') {
    //       if (args["cb"] == null) {
    //         CustomDialog().successDialog(
    //             Get.context!,
    //             "Success",
    //             "Device Registered Successfully.\nPlease login to continue",
    //             "Okay", () {
    //           Get.offAndToNamed(Routes.login);
    //         });
    //       } else {
    //         args["cb"]();
    //       }
    //     } else {
    //       CustomDialog().errorDialog(Get.context!, "Error", response["msg"],
    //           () {
    //         Get.back();
    //       });
    //     }
    //   }
    // });
  }

  Future<void> registerDevice() async {
    final userId =
        widget.userId == null ? args["data"]["user_id"] : widget.userId;

    isVerifiedOtp = true;
    FocusManager.instance.primaryFocus?.unfocus();

    CustomDialog().loadingDialog(Get.context!);

    final devKey = await Functions().getUniqueDeviceId();
    Map<String, dynamic> postParamRegDev = {
      "user_id": userId,
      "device_key": devKey
    };

    print("register device $postParamRegDev");

    final response = await HttpRequest(
            api: ApiKeys.postRegDevice, parameters: postParamRegDev)
        .postBody();

    print("register response $response");
    Get.back();
    if (response == "No Internet") {
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    if (response == null) {
      CustomDialog().errorDialog(Get.context!, "Error",
          "Error while connecting to server, Please try again.", () {
        Get.back();
      });
      return;
    }
    if (response["success"] == 'Y') {
      if (args["cb"] == null) {
        CustomDialog().successDialog(
            Get.context!,
            "Success",
            "Device Registered Successfully.\nPlease login to continue",
            "Okay", () {
          Get.offAndToNamed(Routes.login);
        });
      } else {
        args["cb"]();
      }
    } else {
      CustomDialog().errorDialog(Get.context!, "Error", response["msg"], () {
        Get.back();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomButtonClose(onTap: () {
              Get.back();
            }),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("assets/images/dev_reg.png"),
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width / 2.5,
                    height: MediaQuery.of(context).size.width / 2.5,
                  ),
                  Container(height: 50),
                  CustomTitle(
                    text: "Device Registration",
                    fontSize: 20,
                  ),
                  Container(height: 10),
                  CustomParagraph(
                    text:
                        "Register your device to get started and access your wallet securely.",
                    textAlign: TextAlign.center,
                  ),
                  Container(height: 30),
                  CustomButton(
                      text: "Register this device",
                      onPressed:
                          isVerifiedOtp ? registerDevice : onRegisterDev),
                ],
              ),
            ),
            Container(height: 50),
          ],
        ),
      )),
    );
  }
}
