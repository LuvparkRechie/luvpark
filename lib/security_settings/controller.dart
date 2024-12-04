// import 'dart:convert';

// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:local_auth_android/local_auth_android.dart';
// import 'package:local_auth_darwin/local_auth_darwin.dart';
// import 'package:luvpark/custom_widgets/alert_dialog.dart';
// import 'package:luvpark/login/controller.dart';

// import '../auth/authentication.dart';
// import '../functions/functions.dart';
// import '../http/api_keys.dart';
// import '../http/http_request.dart';
// import '../routes/routes.dart';
// import '../web_view/webview.dart';

// class SecuritySettingsController extends GetxController {
//   SecuritySettingsController();

//   RxString mobileNo = "".obs;
//   RxList userData = [].obs;
//   final LocalAuthentication auth = LocalAuthentication();
//   bool? canCheckBiometrics;
//   List<BiometricType>? availableBiometrics;
//   String authorized = 'Not Authorized';
//   bool isAuthenticating = false;

//   @override
//   void onInit() {
//     super.onInit();
//     auth.isDeviceSupported().then(
//           (bool isSupported) {},
//         );
//   }

//   Future<void> checkBiometrics() async {
//     late bool canCheckBiometrics;
//     try {
//       canCheckBiometrics = await auth.canCheckBiometrics;
//     } on PlatformException catch (e) {
//       canCheckBiometrics = false;
//       print(e);
//     }

//     canCheckBiometrics = canCheckBiometrics;
//   }

//   Future<void> getAvailableBiometrics() async {
//     late List<BiometricType> availableBiometrics;
//     try {
//       availableBiometrics = await auth.getAvailableBiometrics();
//     } on PlatformException catch (e) {
//       availableBiometrics = <BiometricType>[];
//       print(e);
//     }

//     availableBiometrics = availableBiometrics;
//   }

//   Future<void> authenticate() async {
//     bool authenticated = false;
//     try {
//       isAuthenticating = true;
//       authorized = 'Authenticating';
//       authenticated = await auth.authenticate(
//         localizedReason: 'Let OS determine authentication method',
//         options: const AuthenticationOptions(
//           stickyAuth: true,
//         ),
//       );
//       isAuthenticating = false;
//     } on PlatformException catch (e) {
//       print(e);
//       isAuthenticating = false;
//       authorized = 'Error - ${e.message}';
//       return;
//     }

//     authorized = authenticated ? 'Authorized' : 'Not Authorized';
//   }

//   Future<void> authenticateWithBiometrics() async {
//     bool authenticated = false;
//     try {
//       isAuthenticating = true;
//       authorized = 'Authenticating';
//       authenticated = await auth.authenticate(
//           options: const AuthenticationOptions(
//             stickyAuth: true,
//             biometricOnly: true,
//           ),
//           localizedReason: 'Please authenticate to show account balance',
//           authMessages: const <AuthMessages>[
//             AndroidAuthMessages(
//               signInTitle: 'Oops! Biometric authentication required!',
//               cancelButton: 'No thanks',
//             ),
//             IOSAuthMessages(
//               cancelButton: 'No thanks',
//             ),
//           ]);
//       isAuthenticating = false;

//       authorized = 'Authenticating';
//     } on PlatformException catch (e) {
//       print(e);
//       isAuthenticating = false;
//       authorized = 'Error - ${e.message}';
//       return;
//     }

//     final String message = authenticated ? 'Authorized' : 'Not Authorized';
//     authorized = message;
//     print("authorized $authorized");
//   }

//   Future<void> cancelAuthentication() async {
//     await auth.stopAuthentication();
//     isAuthenticating = false;
//   }

//   Future<void> deleteAccount() async {
//     CustomDialog().loadingDialog(Get.context!);
//     try {
//       final mydata = await Authentication().getUserData2();

//       mobileNo.value = mydata["mobile_no"];

//       Map<String, dynamic> param = {
//         "mobile_no": mydata["mobile_no"],
//       };
//       var returnData = await HttpRequest(
//               api: ApiKeys.gApiLuvPayPostDeleteAccount, parameters: param)
//           .post();
//       Get.back();

//       if (returnData == "No Internet") {
//         CustomDialog().internetErrorDialog(Get.context!, () {
//           Get.back();
//         });
//         return;
//       }

//       if (returnData == null) {
//         CustomDialog().serverErrorDialog(Get.context!, () {
//           Get.back();
//         });
//         return;
//       }

//       if (returnData["success"] == "Y") {
//         _showSuccessDialog(returnData);
//       } else {
//         _showErrorDialog("Error on Deleting Account", returnData["msg"]);
//       }
//     } catch (e) {
//       Get.snackbar("Error", "Failed to delete account: $e");
//     }
//   }

//   void _showErrorDialog(String title, String message) {
//     CustomDialog().errorDialog(Get.context!, title, message, () {
//       Get.back();
//     });
//   }

//   void _showSuccessDialog(Map<String, dynamic> returnData) {
//     CustomDialog().successDialog(
//         Get.context!,
//         "Success",
//         "You will be directed to delete account page. Wait for customer support",
//         "Okay", () {
//       Get.back();
//       Get.to(WebviewPage(
//         urlDirect: "https://luvpark.ph/account-deletion/",
//         label: "Account Deletion",
//         isBuyToken: false,
//         callback: () async {
//           CustomDialog().loadingDialog(Get.context!);
//           Get.put(LoginScreenController());

//           final userData = await Authentication().getUserData2();

//           Functions.getAccountStatus(userData["mobile_no"], (obj) {
//             Get.back();
//             final items = obj[0]["items"];

//             if (items.isEmpty || items[0]["is_active"] == "N") {
//               CustomDialog().infoDialog(
//                   "Account status", "Your account might not be active.",
//                   () async {
//                 Get.back();
//                 CustomDialog().loadingDialog(Get.context!);
//                 await Future.delayed(const Duration(seconds: 3));
//                 final userLogin = await Authentication().getUserLogin();
//                 List userData = [userLogin];
//                 userData = userData.map((e) {
//                   e["is_login"] = "N";
//                   return e;
//                 }).toList();

//                 await Authentication().setLogin(jsonEncode(userData[0]));

//                 Get.back();
//                 Get.offAllNamed(Routes.login);
//               });
//             }
//           });
//         },
//       ));
//     });
//   }
// }

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/login/controller.dart';

import '../auth/authentication.dart';
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
  // Add a RxBool to handle the toggle state
  RxBool isBiometricEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("security");
    // _checkBiometricAvailability();
  }

// Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    canCheckBiometrics.value = await auth.canCheckBiometrics;
    isBiometricSupported.value = await auth.isDeviceSupported();
    isLoading.value = false;
  }

  Future<void> authenticateWithBiometrics() async {
    if (isBiometricEnabled.value) {
      bool authenticated = false;
      try {
        isAuthenticating = true;
        authorized = 'Authenticating';
        authenticated = await auth.authenticate(
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
            ),
            localizedReason: 'Please authenticate to show account balance',
            authMessages: const <AuthMessages>[
              AndroidAuthMessages(
                signInTitle: 'Oops! Biometric authentication required!',
                cancelButton: 'No thanks',
              ),
              IOSAuthMessages(
                cancelButton: 'No thanks',
              ),
            ]);
        isAuthenticating = false;

        authorized = 'Authenticating';
      } on PlatformException catch (e) {
        print(e);
        isAuthenticating = false;
        authorized = 'Error - ${e.message}';
        return;
      }

      final String message = authenticated ? 'Authorized' : 'Not Authorized';
      authorized = message;
      print("authorized $authorized");
    } else {
      Get.snackbar(
          "Biometric Disabled", "Please enable biometric authentication.");
    }
  }

  // Toggle method to switch biometric authentication on or off
  void toggleBiometricAuthentication(bool value) {
    isBiometricEnabled.value = value;
    // If biometrics are enabled, try authenticating
    if (isBiometricEnabled.value) {
      authenticateWithBiometrics();
    } else {
      authorized = 'Biometric Authentication Disabled';
    }
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

      Map<String, dynamic> param = {
        "mobile_no": mydata["mobile_no"],
      };
      var returnData = await HttpRequest(
              api: ApiKeys.gApiLuvPayPostDeleteAccount, parameters: param)
          .post();
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
        _showErrorDialog("Error on Deleting Account", returnData["msg"]);
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
          Get.put(LoginScreenController());

          final userData = await Authentication().getUserData2();

          Functions.getAccountStatus(userData["mobile_no"], (obj) {
            Get.back();
            final items = obj[0]["items"];

            if (items.isEmpty || items[0]["is_active"] == "N") {
              CustomDialog().infoDialog(
                  "Account status", "Your account might not be active.",
                  () async {
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
            }
          });
        },
      ));
    });
  }
}
