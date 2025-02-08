import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:luvpark/sqlite/pa_message_table.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sqlite/reserve_notification_table.dart';

class LoginScreenController extends GetxController {
  LoginScreenController();
  // final GlobalKey<FormState> formKeyLogin = GlobalKey<FormState>();
  RxBool isAgree = false.obs;
  RxBool isShowPass = false.obs;
  RxBool isLoading = false.obs;
  RxInt counter = 0.obs;

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
    final prefs = await SharedPreferences.getInstance();
    HttpRequest(api: ApiKeys.gApiSubFolderPostLogin2, parameters: param)
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
            Get.toNamed(
              Routes.activateAcc,
              arguments: {
                "mobile_no": "63${mobileNumber.text.replaceAll(" ", "")}",
                "callback": () {
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
              },
            );
          });
          return;
        }
        if (returnPost["login_attempt"] != null &&
            returnPost["login_attempt"] >= 5) {
          mobileNumber.text = "";
          password.text = "";
          List mapData = [returnPost];

          mapData = mapData.map((e) {
            e["mobile_no"] = param["mobile_no"];
            return e;
          }).toList();

          Future.delayed(Duration(milliseconds: 200), () {
            Get.offAndToNamed(Routes.lockScreen, arguments: mapData);
          });
          return;
        } else {
          CustomDialog().errorDialog(context, "Error", returnPost["msg"], () {
            Get.back();
          });
        }

        return;
      } else {
        var getApi =
            "${ApiKeys.gApiSubFolderLogin2}?mobile_no=${param["mobile_no"]}&auth_key=${returnPost["auth_key"].toString()}";

        HttpRequest(api: getApi).get().then((objData) async {
          if (objData == "No Internet") {
            CustomDialog().internetErrorDialog(context, () {
              Get.back();
              cb([
                {"has_net": false, "items": []}
              ]);
            });
            return;
          }
          if (objData == null) {
            CustomDialog().errorDialog(context, "luvpark",
                "Error while connecting to server, Please try again.", () {
              Get.back();
              cb([
                {"has_net": true, "items": []}
              ]);
            });
            return;
          } else {
            if (objData["items"].length == 0) {
              CustomDialog()
                  .errorDialog(context, "Error", objData["items"]["msg"], () {
                Get.back();
                cb([
                  {"has_net": true, "items": []}
                ]);
              });
              return;
            } else {
              var items = objData["items"][0];

              //sms keys
              final data = {
                "sms_username": items["sms_username"],
                "sms_password": items["sms_password"],
                "sms_api_key": items["sms_api_key"]
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
              Authentication().setPasswordBiometric(param["pwd"]);
              Authentication().setLogoutStatus(false);
              Authentication().encryptData(plainText);

              if (items["image_base64"] != null) {
                Authentication()
                    .setProfilePic(jsonEncode(items["image_base64"]));
              } else {
                Authentication().setProfilePic("");
              }

              List dataCb = objData["items"];

              dataCb = dataCb.map((e) {
                e["sms_username"] = "";
                e["sms_password"] = "";
                e["sms_api_key"] = "";
                return e;
              }).toList();

              cb([
                {"has_net": true, "items": dataCb}
              ]);
            }
          }
        });
      }
    });
  }

  void switchAccount() {
    CustomDialog().confirmationDialog(Get.context!, "Switch Account",
        "Are you sure you want to switch Account?", "No", "Yes", () {
      Get.back();
    }, () async {
      Get.back();
      CustomDialog().loadingDialog(Get.context!);
      await Authentication().enableTimer(false);
      await Authentication().setLogoutStatus(true);
      await Authentication().setBiometricStatus(false);
      await Authentication().remove("userData");
      await PaMessageDatabase.instance.deleteAll();
      NotificationDatabase.instance.deleteAll();
      AwesomeNotifications().cancelAllSchedules();
      AwesomeNotifications().cancelAll();

      await Future.delayed(Duration(seconds: 3), () {
        Get.back();
        Get.offAndToNamed(Routes.login);
      });
    });
  }

  Future<bool> userAuth(String mobile) async {
    final data = await Authentication().getUserLogin();
    int mobaNo =
        int.parse(data["mobile_no"].toString().trim().replaceAll(" ", ""));
    int usrMo = int.parse("63${mobile.toString().trim().replaceAll(" ", "")}");
    print("usrMo $mobaNo  == $usrMo");
    print("usrMo ${mobaNo == usrMo}");

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
