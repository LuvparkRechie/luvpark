import 'dart:convert';

import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/login/controller.dart';

import '../auth/authentication.dart';
import '../change_password/change_pass_ver.dart';
import '../functions/functions.dart';
import '../http/api_keys.dart';
import '../http/http_request.dart';
import '../routes/routes.dart';
import '../web_view/webview.dart';

class SecuritySettingsController extends GetxController {
  SecuritySettingsController();

  RxString mobileNo = "".obs;
  RxList userData = [].obs;
  final LocalAuthentication auth = LocalAuthentication();
  List<BiometricType>? availableBiometrics;
  String authorized = 'Not Authorized';
  bool isAuthenticating = false;
  RxBool canCheckBiometrics = false.obs;
  RxBool isBiometricSupported = false.obs;
  RxBool isLoading = false.obs;
  RxBool isToggle = false.obs;
  bool isAuth = false;
  int? randomNumber;
  @override
  void onInit() {
    super.onInit();

    _checkBiometricAvailability();
  }

// Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    canCheckBiometrics.value = await auth.canCheckBiometrics;
    isBiometricSupported.value = await auth.isDeviceSupported();

    if (isBiometricSupported.value) {
      checkIfEnabledBio();
      return;
    } else {
      isLoading.value = false;
    }
  }

  checkIfEnabledBio() async {
    bool? isEnabledBio = await Authentication().getBiometricStatus();
    isToggle.value = isEnabledBio!;

    isLoading.value = false;
  }

  void authenticateWithBiometrics(bool enable) async {
    isAuth = true;
    final LocalAuthentication auth = LocalAuthentication();
    // ignore: unused_local_variable
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {}
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
        localizedReason: 'Please authenticate to quick',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Biometric authentication required!',
            cancelButton: 'No thanks',
          ),
          IOSAuthMessages(
            cancelButton: 'No thanks',
          ),
        ],
      );
    } catch (e) {}
    isAuth = authenticated ? true : false;
    if (isAuth) {
      if (enable) {
        isToggle.value = true;
        Authentication().setBiometricStatus(true);
      } else {
        isToggle.value = false;
        Authentication().setBiometricStatus(false);
      }
    }
  }

  // // Toggle method to switch biometric authentication on or off
  void toggleBiometricAuthentication(bool value) {
    authenticateWithBiometrics(value);
  }

  Future<void> cancelAuthentication() async {
    await auth.stopAuthentication();
    isAuthenticating = false;
  }

  Future<void> deleteAccount() async {
    CustomDialog().loadingDialog(Get.context!);
    try {
      final mydata = await Authentication().getUserData2();

      mobileNo.value = mydata["mobile_no"];

      Map<String, String> param = {
        "mobile_no": mydata["mobile_no"].toString(),
      }; 
      var returnData =
          await HttpRequest(api: ApiKeys.postDeleteUserAcct, parameters: param)
              .deleteData();
      Get.back(); 
      if (returnData == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData["success"] == "Y") {
        _showSuccessDialog(returnData);
      } else {
        _showErrorDialog("Delete Account", returnData["msg"]);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to delete account: $e");
    }
  }

  void _showErrorDialog(String title, String message) {
    CustomDialog().errorDialog(Get.context!, title, message, () {
      Get.back();
    });
  }

  void _showSuccessDialog(Map<String, dynamic> returnData) {
    CustomDialog().successDialog(
        Get.context!,
        "Success",
        "You will be directed to delete account page. Wait for customer support",
        "Okay", () {
      Get.back();
      Get.to(WebviewPage(
        urlDirect: "https://luvpark.ph/account-deletion/",
        label: "Account Deletion",
        isBuyToken: false,
        callback: () async {
          CustomDialog().loadingDialog(Get.context!);

          CustomDialog().infoDialog(
              "Account status", "Your account might not be active.", () async {
            Get.back();
            CustomDialog().loadingDialog(Get.context!);
            await Future.delayed(const Duration(seconds: 3));
            final userLogin = await Authentication().getUserLogin();
            List userData = [userLogin];
            userData = userData.map((e) {
              e["is_login"] = "N";
              return e;
            }).toList();

            await Authentication().setLogin(jsonEncode(userData[0]));

            Get.back();
            Get.offAllNamed(Routes.login);
          });
        },
      ));
    });
  }

  void verifyMobile() async {
    final data = await Authentication().getUserData2();
    Functions().verifyMobile(data["mobile_no"], (objData) {
      if (objData["success"]) {
        if (objData["data"]["is_verified"] == "Y") {
          Functions().getSecQdata(data["mobile_no"], (cbData) {
            if (cbData != null) {
              Get.to(
                ChangePasswordVerified(),
                arguments: {"mobile_no": data["mobile_no"], "data": cbData},
              );
            }
          });
        } else {
          Get.toNamed(Routes.createNewPass, arguments: data["mobile_no"]);
        }
      }
    });
  }
}
