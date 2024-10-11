import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:luvpark_get/sqlite/vehicle_brands_model.dart';
import 'package:luvpark_get/sqlite/vehicle_brands_table.dart';

import '../custom_widgets/variables.dart';

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

  // Future<void> getAccountStatus(context, mobile, Function cb) async {
  //   String apiParam =
  //       "${ApiKeys.gApiSubFolderGetLoginAttemptRecord}?mobile_no=$mobile";

  //   HttpRequest(api: apiParam).get().then((objData) {
  //     print("account status $objData");
  //     if (objData == "No Internet") {
  //       isInternetConnected.value = false;
  //       if (counter.value != 0) {
  //         counter--;
  //       }
  //       cb([
  //         {"has_net": false, "items": []}
  //       ]);

  //       CustomDialog().internetErrorDialog(context, () {
  //         Get.back();
  //       });
  //       return;
  //     }
  //     if (objData == null) {
  //       isInternetConnected.value = false;
  //       if (counter.value != 0) {
  //         counter--;
  //       }
  //       cb([
  //         {"has_net": true, "items": []}
  //       ]);
  //       CustomDialog().serverErrorDialog(context, () {
  //         Get.back();
  //         SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //       });

  //       return;
  //     }
  //     if (objData["items"].isEmpty) {
  //       isInternetConnected.value = true;
  //       if (counter.value != 0) {
  //         counter--;
  //       }
  //       cb([
  //         {"has_net": false, "items": []}
  //       ]);
  //       CustomDialog().errorDialog(context, "luvpark", "Invalid account.", () {
  //         Get.offAllNamed(Routes.login);
  //       });
  //       return;
  //     }
  //     if (objData["items"][0]["login_attempt"] >= 3) {
  //       isLoading.value = false;
  //       mobileNumber.text = "";
  //       password.text = "";
  //       Future.delayed(Duration(milliseconds: 200), () {
  //         Get.offAndToNamed(Routes.lockScreen, arguments: objData["items"]);
  //       });

  //       return;
  //     } else {
  //       cb([
  //         {"has_net": true, "items": objData["items"]}
  //       ]);
  //       return;
  //     }
  //   });
  // }

  //POST LOGIN
  postLogin(context, Map<String, dynamic> param, Function cb) async {
    String apiParam = ApiKeys.gApiLuvParkGetVehicleBrand;

    HttpRequest(api: apiParam).get().then((returnBrandData) async {
      if (returnBrandData == "No Internet") {
        cb([
          {"has_net": false, "items": []}
        ]);
        CustomDialog().internetErrorDialog(context, () {
          Get.back();
        });
        return;
      }
      if (returnBrandData == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
          cb([
            {"has_net": true, "items": []}
          ]);
        });
      } else {
        Variables.gVBrand.value = returnBrandData["items"];
        VehicleBrandsTable.instance.deleteAll();
        for (var dataRow in returnBrandData["items"]) {
          var vbData = {
            VHBrandsDataFields.vhTypeId:
                int.parse(dataRow["vehicle_type_id"].toString()),
            VHBrandsDataFields.vhBrandId:
                int.parse(dataRow["vehicle_brand_id"].toString()),
            VHBrandsDataFields.vhBrandName:
                dataRow["vehicle_brand_name"].toString(),
            VHBrandsDataFields.image: dataRow["imageb64"] == null
                ? ""
                : dataRow["imageb64"].toString().replaceAll("\n", ""),
          };
          await VehicleBrandsTable.instance.insertUpdate(vbData);
        }

        print("param $param");
        HttpRequest(api: ApiKeys.gApiSubFolderPostLogin2, parameters: param)
            .postBody()
            .then((returnPost) async {
          print("returnpost $returnPost");
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
            if (returnPost["login_attempt"] >= 3) {
              mobileNumber.text = "";
              password.text = "";
              List mapData = [returnPost];

              mapData = mapData.map((e) {
                e["mobile_no"] = param["mobile_no"];
                return e;
              }).toList();
              print("mapData $mapData");
              Future.delayed(Duration(milliseconds: 200), () {
                Get.offAndToNamed(Routes.lockScreen, arguments: mapData);
              });
              return;
            } else {
              CustomDialog().errorDialog(context, "Error", returnPost["msg"],
                  () {
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
                  CustomDialog().errorDialog(
                      context, "Error", objData["items"]["msg"], () {
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

                  Authentication().setLogin(jsonEncode(parameters));
                  Authentication().setUserData(jsonEncode(items));
                  Authentication().setPasswordBiometric(param["pwd"]);
                  Authentication().setShowPopUpNearest(false);
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
    });
  }

  @override
  void onInit() {
    mobileNumber = TextEditingController();
    password = TextEditingController();
    print("ataya sulod controller");
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
