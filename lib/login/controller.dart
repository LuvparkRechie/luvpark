import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/device_registration/device_reg.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:luvpark/sqlite/pa_message_table.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functions/functions.dart';
import '../sqlite/reserve_notification_table.dart';
import 'change_pass_new_proc/change_pass_new.dart';

class LoginScreenController extends GetxController {
  LoginScreenController();
  // final GlobalKey<FormState> formKeyLogin = GlobalKey<FormState>();
  RxBool isAgree = false.obs;
  RxBool isShowPass = false.obs;
  RxBool isLoading = false.obs;
  RxInt counter = 0.obs;

  final storage = FlutterSecureStorage();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isLogin = false;
  RxBool isInternetConnected = true.obs;

  bool isTappedReg = false;
  var usersLogin = [];

  void toggleLoading(bool value) {
    isLoading.value = value;
  }

  void onPageChanged(bool agree) {
    isAgree.value = agree;
    update();
  }

  void visibilityChanged(bool visible) {
    isShowPass.value = visible;
    update();
  }

  //POST LOGIN
  postLogin(context, Map<String, dynamic> param, Function cb) async {
    HttpRequest(api: ApiKeys.postLogin, parameters: param)
        .postBody()
        .then((returnPost) async {
      print("return post $returnPost");
      if (returnPost == "No Internet") {
        CustomDialog().internetErrorDialog(context, () {
          Get.back();
          cb([
            {"has_net": false, "items": []}
          ]);
        });
        return;
      }
      if (returnPost == null) {
        CustomDialog().errorDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Get.back();
          cb([
            {"has_net": true, "items": []}
          ]);
        });
        return;
      }
      if (returnPost["success"] == "N") {
        cb([
          {"has_net": true, "items": []}
        ]);
        //activate account
        if (returnPost["is_active"] == "N") {
          CustomDialog().confirmationDialog(
              context,
              "Activate account",
              "Your account is currently inactive. Would you like to activate it now?",
              "No",
              "Yes", () {
            Get.back();
          }, () {
            Get.back();
            Get.toNamed(Routes.otpField, arguments: {
              "mobile_no": param["mobile_no"],
              "callback": (otp) async {
                FocusManager.instance.primaryFocus?.unfocus();
                CustomDialog().successDialog(
                  Get.context!,
                  "Congratulations!",
                  "Your account has been activated.\nContinue to log in",
                  "Okay",
                  () {
                    Get.offAllNamed(Routes.login);
                  },
                );
              }
            });
          });
          return;
        }
        //lock account
        if (returnPost["login_attempt"] != null &&
            returnPost["login_attempt"] >= 5) {
          List mapData = [returnPost];

          mapData = mapData.map((e) {
            e["mobile_no"] = param["mobile_no"];
            return e;
          }).toList();

          Future.delayed(Duration(milliseconds: 200), () {
            mobileNumber.text = "";
            password.text = "";
            Get.offAndToNamed(Routes.lockScreen, arguments: mapData);
          });
          return;
        } else {
          if (returnPost["device_valid"] != null) {
            if (returnPost["user_id"] == 0 &&
                returnPost["session_id"] != null &&
                returnPost["device_valid"] == 'N') {
              final uData = await Authentication().getUserData2();

              if (uData == null) {
                CustomDialog().confirmationDialog(
                    context,
                    "Phone Change Detected",
                    "It looks like you changed your phone.",
                    "Later",
                    "Register this phone", () {
                  Get.back();
                }, () {
                  // dapat e return ang user_id logoutUser
                  Functions.logoutUser(
                      uData == null
                          ? returnPost["session_id"].toString()
                          : uData["session_id"].toString(), (isSuccess) async {
                    print("atatata $isSuccess");
                    if (isSuccess["is_true"]) {
                      Get.to(
                          DeviceRegScreen(
                            mobileNo: param["mobile_no"].toString(),
                            userId: isSuccess["data"].toString(),
                          ),
                          arguments: {
                            "data": returnPost,
                          });

                      return;
                    }
                  });
                });
                return;
              } else {
                //if already logged in another device
                CustomDialog().infoDialog(
                    "Account Secure", returnPost["msg"].toString(), () {
                  Get.back();
                });
              }
              return;
            }
            CustomDialog().confirmationDialog(context, "Account Secure",
                returnPost["msg"], "Cancel", "Register device", () {
              Get.back();
            }, () {
              Get.back();
              Get.to(
                  DeviceRegScreen(
                    mobileNo: param["mobile_no"].toString(),
                  ),
                  arguments: {"data": returnPost});
            });
            return;
          }
          CustomDialog().infoDialog("Security Warning", returnPost["msg"], () {
            Get.back();
          });
        }

        return;
      }
      if (returnPost["success"] == "R") {
        Get.back();

        CustomDialog().infoDialog("Account Secure", returnPost["msg"], () {
          Get.back();
          Get.to(
            ChangePassNewProtocol(
                userId: returnPost["user_id"].toString(),
                mobileNo:
                    "63${mobileNumber.text.toString().replaceAll(" ", "")}"),
          );
        });
        return;
      } else {
        Get.back();
        if (returnPost["device_valid"] == "N") {
          CustomDialog().confirmationDialog(context, "Account Secure",
              returnPost["msg"], "Cancel", "Register device", () {
            Get.back();
          }, () {
            Get.back();
            Get.to(
              DeviceRegScreen(
                mobileNo: param["mobile_no"].toString(),
              ),
              arguments: {
                "data": returnPost,
                "cb": (d) {
                  CustomDialog().successDialog(context, "Success",
                      "Device successfully registered.", "Okay", () {
                    getUserData(param, returnPost, (data) {
                      Get.back();

                      if (data[0]["items"].isNotEmpty) {
                        Get.back();
                        cb(data);
                      }
                    });
                  });
                }
              },
            );
          });
          return;
        }

        if (returnPost["pwd_days_left"] < 1) {
          CustomDialog().confirmationDialog(
              context,
              "Password Expired",
              "For security reasons, your password has expired. Please update your password to continue.",
              "Update",
              "Later", () {
            Get.back();
            Get.toNamed(Routes.createNewPass,
                arguments:
                    "63${mobileNumber.text.toString().replaceAll(" ", "")}");
          }, () {
            Get.back();
            extendPassword((isTrue) {
              if (isTrue) {
                getUserData(param, returnPost, (data) {
                  cb(data);
                });
              }
            });
          });
          return;
        }
        getUserData(param, returnPost, (data) {
          cb(data);
        });
      }
    });
  }

  void extendPassword(Function cb) async {
    final uData = await Authentication().getUserData2();
    final putParam = {"extend": "Y", "mobile_no": uData["mobile_no"]};
    CustomDialog().loadingDialog(Get.context!);
    final response =
        await HttpRequest(api: ApiKeys.putLogin, parameters: putParam)
            .putBody();
    Get.back();
    if (response == "No Internet") {
      cb(false);
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    if (response == null) {
      cb(false);
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    if (response["success"] == "Y") {
      cb(true);
      CustomDialog()
          .successDialog(Get.context!, "Success", response["msg"], "Okay", () {
        Get.back();
      });
      return;
    } else {
      cb(false);
      CustomDialog().infoDialog("Unsuccessful", response["msg"], () {
        Get.back();
      });
      return;
    }
  }

  void getUserData(param, returnPost, Function cb) async {
    final prefs = await SharedPreferences.getInstance();
    CustomDialog().loadingDialog(Get.context!);
    var getApi =
        "${ApiKeys.getLogin}?mobile_no=${param["mobile_no"]}&auth_key=${returnPost["auth_key"].toString()}";

    HttpRequest(api: getApi).get().then((objData) async {
      if (objData == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
          cb([
            {"has_net": false, "items": []}
          ]);
        });
        return;
      }
      if (objData == null) {
        CustomDialog().errorDialog(Get.context!, "luvpark",
            "Error while connecting to server, Please try again.", () {
          Get.back();
          cb([
            {"has_net": true, "items": []}
          ]);
        });
        return;
      } else {
        if (objData["items"].isEmpty) {
          CustomDialog()
              .errorDialog(Get.context!, "Error", objData["items"]["msg"], () {
            Get.back();
            cb([
              {"has_net": true, "items": []}
            ]);
          });
          return;
        } else {
          List itemData = objData["items"];
          itemData = itemData.map((e) {
            e["session_id"] = returnPost["session_id"];
            return e;
          }).toList();

          var items = itemData[0];

          //sms keys
          Map<String, dynamic> data = {
            "mobile_no": param["mobile_no"],
            "pwd": param["pwd"],
          };
          final plainText = jsonEncode(data);

          Map<String, dynamic> parameters = {
            "user_id": items['user_id'].toString(),
            "mobile_no": param["mobile_no"],
            "is_active": "Y",
            "is_login": "Y",
          };
          prefs.remove("userData");

          Authentication().setLogin(jsonEncode(parameters));
          Authentication().setUserData(jsonEncode(items));
          Authentication().setLogoutStatus(false);
          Authentication().encryptData(plainText);

          if (items["image_base64"] != null) {
            Authentication().setProfilePic(jsonEncode(items["image_base64"]));
          } else {
            Authentication().setProfilePic("");
          }

          List dataCb = objData["items"];

          cb([
            {"has_net": true, "items": dataCb}
          ]);
        }
      }
    });
  }

  void switchAccount() {
    CustomDialog().confirmationDialog(Get.context!, "Switch Account",
        "Are you sure you want to switch Account?.", "No", "Yes", () {
      Get.back();
    }, () async {
      Get.back();
      final uData = await Authentication().getUserData2();
      Functions.logoutUser(uData == null ? "" : uData["session_id"].toString(),
          (isSuccess) async {
        if (isSuccess["is_true"]) {
          await Authentication().enableTimer(false);
          await Authentication().setLogoutStatus(true);
          await Authentication().setBiometricStatus(false);
          await Authentication().remove("userData");
          await PaMessageDatabase.instance.deleteAll();
          NotificationDatabase.instance.deleteAll();
          AwesomeNotifications().cancelAllSchedules();
          AwesomeNotifications().cancelAll();
          Get.offAndToNamed(Routes.login);
        }
      });
    });
  }

  Future<bool> userAuth(String mobile) async {
    final data = await Authentication().getEncryptedKeys();
    int mobaNo = data == null
        ? 0
        : int.parse(data["mobile_no"].toString().trim().replaceAll(" ", ""));
    int usrMo = int.parse("63${mobile.toString().trim().replaceAll(" ", "")}");

    return mobaNo == usrMo ? false : true;
  }

  @override
  void onInit() {
    mobileNumber = TextEditingController();
    password = TextEditingController();

    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
