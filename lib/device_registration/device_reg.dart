import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/otp_field/index.dart';

import '../auth/authentication.dart';
import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/app_color.dart';
import '../functions/functions.dart';
import '../http/api_keys.dart';
import '../http/http_request.dart';
import '../routes/routes.dart';

class DeviceRegScreen extends StatefulWidget {
  final String mobileNo;
  final String? userId;
  final String pwd;
  final String? sessionId;
  const DeviceRegScreen(
      {super.key,
      required this.mobileNo,
      this.userId,
      this.sessionId,
      required this.pwd});

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
    CustomDialog().loadingDialog(context);
    DateTime timeNow = await Functions.getTimeNow();
    Get.back();
    Map<String, String> reqParam = {
      "mobile_no": widget.mobileNo.toString(),
      "pwd": widget.pwd,
    };
    // "req_type": "SR",
    Functions().requestOtp(reqParam, (obj) async {
      DateTime timeExp = DateFormat("yyyy-MM-dd hh:mm:ss a")
          .parse(obj["otp_exp_dt"].toString());
      DateTime otpExpiry = DateTime(timeExp.year, timeExp.month, timeExp.day,
          timeExp.hour, timeExp.minute, timeExp.millisecond);

      // Calculate difference
      Duration difference = otpExpiry.difference(timeNow);

      if (obj["success"] == "Y" || obj["status"] == "PENDING") {
        Map<String, String> putParam = {
          "mobile_no": widget.mobileNo.toString(),
          "otp": obj["otp"].toString(),
          "req_type": "SR"
        };
        Object args = {
          "time_duration": difference,
          "mobile_no": widget.mobileNo,
          "req_otp_param": reqParam,
          "verify_param": putParam,
          "callback": (otp) async {
            final uData = await Authentication().getUserData2();
            if (otp != null) {
              if (widget.sessionId == null) {
                registerDevice();
                return;
              }
              Functions.logoutUser(
                  uData == null
                      ? widget.sessionId.toString()
                      : uData["session_id"].toString(), (isSuccess) async {
                if (isSuccess["is_true"]) {
                  registerDevice();
                }
              });
            } else {
              isVerifiedOtp = false;
            }
          },
        };
        Get.to(
          OtpFieldScreen(
            arguments: args,
          ),
          transition: Transition.rightToLeftWithFade,
          duration: Duration(milliseconds: 400),
        );
      }
    });
  }

  Future<void> registerDevice() async {
    final userId = widget.userId == null
        ? args["data"]["user_id"]
        : widget.userId.toString();

    isVerifiedOtp = true;
    FocusManager.instance.primaryFocus?.unfocus();

    CustomDialog().loadingDialog(Get.context!);

    final devKey = await Functions().getUniqueDeviceId();
    Map<String, String> postParamRegDev = {
      "user_id": userId.toString(),
      "device_key": devKey.toString()
    };

    final response = await HttpRequest(
            api: ApiKeys.postRegDevice, parameters: postParamRegDev)
        .postBody();

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
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("Device Registration"),
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
      backgroundColor: AppColor.bodyColor,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
            CustomParagraph(
              text:
                  "Register your device to get started and access your wallet securely.",
              textAlign: TextAlign.center,
            ),
            Container(height: 30),
            CustomButton(
                text: "Register this device",
                onPressed: isVerifiedOtp ? registerDevice : onRegisterDev),
          ],
        ),
      )),
    );
  }
}
