import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
              Routes.activate,
              arguments: "63${mobileNumber.text.replaceAll(" ", "")}",
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
              //refresh the login aft logout
              mobileNumber.clear();
              password.clear();
              var items = objData["items"][0];

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

              if (items["image_base64"] != null) {
                Authentication()
                    .setProfilePic(jsonEncode(items["image_base64"]));
              } else {
                Authentication().setProfilePic("");
              }

              cb([
                {"has_net": true, "items": objData["items"]}
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
      await Authentication().setBiometricStatus(false);
      await Authentication().remove("userData");

      await Future.delayed(Duration(seconds: 3), () {
        Get.back();
        Get.offAndToNamed(Routes.login);
      });
    });
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
