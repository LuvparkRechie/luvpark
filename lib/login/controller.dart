import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/device_registration/device_reg.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:luvpark/sqlite/pa_message_table.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functions/functions.dart';
import '../otp_field/index.dart';
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
          }, () async {
            Get.back();
            CustomDialog().loadingDialog(context);
            DateTime timeNow = await Functions.getTimeNow();
            Get.back();
            String mobileNo = param["mobile_no"].toString();
            Map<String, String> reqParam = {
              "mobile_no": mobileNo,
              "new_pwd": password.text,
            };
            Functions().requestOtp(reqParam, (obj) async {
              DateTime timeExp = DateFormat("yyyy-MM-dd hh:mm:ss a")
                  .parse(obj["otp_exp_dt"].toString());
              DateTime otpExpiry = DateTime(
                  timeExp.year,
                  timeExp.month,
                  timeExp.day,
                  timeExp.hour,
                  timeExp.minute,
                  timeExp.millisecond);

              // Calculate difference
              Duration difference = otpExpiry.difference(timeNow);

              if (obj["success"] == "Y" || obj["status"] == "PENDING") {
                Map<String, String> putParam = {
                  "mobile_no": mobileNo.toString(),
                  "req_type": "NA",
                  "otp": obj["otp"].toString()
                };

                Object args = {
                  "time_duration": difference,
                  "mobile_no": mobileNo.toString(),
                  "req_otp_param": reqParam,
                  "verify_param": putParam,
                  "callback": (otp) {
                    if (otp != null) {
                      Map<String, dynamic> data = {
                        "mobile_no": mobileNo,
                        "pwd": password.text,
                      };
                      final plainText = jsonEncode(data);

                      Authentication().encryptData(plainText);
                      CustomDialog().successDialog(
                          context,
                          "Activate Account",
                          "Your account has been successfully activated! 🎉 You can now enjoy full access to all features.",
                          "Okay", () {
                        Get.back();
                        Get.back();
                      });
                    }
                  }
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
          });
          return;
        }

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
                  Get.back();
                  Functions().verifyAccount(param["mobile_no"], (data) {
                    if (data["success"]) {
                      Get.to(
                        DeviceRegScreen(
                          mobileNo: param["mobile_no"].toString(),
                          userId: data["data"]["user_id"].toString(),
                          sessionId: returnPost["session_id"].toString(),
                          pwd: param["pwd"],
                        ),
                        arguments: {
                          "data": returnPost,
                        },
                        transition: Transition.rightToLeftWithFade,
                        duration: Duration(milliseconds: 400),
                      );
                      return;
                    }
                  });
                });
                return;
              } else {
                CustomDialog().infoDialog(
                    "Account Secure", returnPost["msg"].toString(), () {
                  Get.back();
                });
              }
              return;
            } else {
              CustomDialog().confirmationDialog(context, "Account Secure",
                  returnPost["msg"], "Cancel", "Register device", () {
                Get.back();
              }, () {
                Get.back();
                Get.to(
                  DeviceRegScreen(
                    mobileNo: param["mobile_no"].toString(),
                    pwd: param["pwd"],
                  ),
                  arguments: {"data": returnPost},
                  transition: Transition.rightToLeftWithFade,
                  duration: Duration(milliseconds: 400),
                );
              });
            }
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
                pwd: param["pwd"],
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
              transition: Transition.rightToLeftWithFade,
              duration: Duration(milliseconds: 400),
            );
          });
          return;
        }

        if (returnPost["pwd_days_left"] < 1) {
          CustomDialog().confirmationDialog(
              context,
              "Password Expired",
              "For security reasons, your password has expired. Update your password to continue.",
              "Waive",
              "Update", () {
            Get.back();
            extendPassword((isTrue) {
              if (isTrue) {
                getUserData(param, returnPost, (data) {
                  cb(data);
                });
              }
            });
          }, () {
            Get.back();
            String mobileNo = param["mobile_no"].toString();
            Get.toNamed(Routes.createNewPass, arguments: mobileNo);
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
      CustomDialog()
          .successDialog(Get.context!, "Success", response["msg"], "Okay", () {
        Get.back();
        cb(true);
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
          Get.offAllNamed(Routes.login);
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
