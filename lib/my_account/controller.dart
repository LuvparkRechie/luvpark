import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/routes/routes.dart';

import '../custom_widgets/app_color.dart';

enum AppState {
  free,
  picked,
  cropped,
}

class MyAccountScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
  MyAccountScreenController();
  final ImagePicker _picker = ImagePicker();
  var heroTag = Get.arguments["hero_tag"];
  Function callBack = Get.arguments["callBack"];
  String? imageBase64;
  AppState? state;
  File? imageFile;
  RxList regionData = [].obs;
  RxList userData = [].obs;
  RxString myName = "".obs;
  RxString myAddress = "".obs;
  RxString civilStatus = "".obs;
  RxString province = "".obs;
  RxString gender = "".obs;
  RxString myprofile = "".obs;
  RxBool isLoading = true.obs;
  RxBool isNetConn = true.obs;
  var profWidget = <Widget>[].obs;
  @override
  void onInit() {
    super.onInit();
    getUserData();
  }

  void getUserData() async {
    final profilepic = await Authentication().getUserProfilePic();
    final data = await Authentication().getUserData2();

    myprofile.value = profilepic;

    userData.add(data);
    if (userData[0]["first_name"] == null) {
      myName.value = userData[0]["mobile_no"];
    } else {
      String midName = userData[0]["middle_name"] == null
          ? ""
          : userData[0]["middle_name"].toString();
      myName.value =
          "${userData[0]["first_name"]} ${midName.isEmpty ? "" : "${midName[0]}."} ${userData[0]["last_name"]}";
    }

    if (userData[0]['region_id'] == 0 || userData[0]['region_id'] == null) {
      province.value = "No province provided";
      myAddress.value = "No Address provided";
      isLoading.value = false;
      isNetConn.value = true;
    } else {
      civilStatus.value = userData[0]['civil_status'] == null
          ? ""
          : Variables.civilStatusData.where((element) {
              return element["value"] == userData[0]['civil_status'];
            }).toList()[0]["status"];
      gender.value = userData[0]['gender'] == null
          ? ""
          : userData[0]['gender'] == "F"
              ? "Female"
              : "Male";

      if (userData[0]['province_id'] == 0 ||
          userData[0]['province_id'] == null) {
        province.value = "No province provided";
      } else {
        getProvince(userData[0]['region_id']);
        myAddress.value =
            "Brgy ${userData[0]['brgy_name']}, ${userData[0]['city_name']}";
      }
    }
  }

  void getRegions() async {
    CustomDialog().loadingDialog(Get.context!);
    var returnData = await HttpRequest(api: ApiKeys.getRegion).get();
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
    if (returnData["items"].isNotEmpty) {
      regionData.value = returnData["items"];
      Get.toNamed(
        Routes.updProfile,
        arguments: regionData,
      );
      return;
    } else {
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
    }
  }

  void getProvince(regionId) async {
    String params = "${ApiKeys.getProvince}?p_region_id=$regionId";

    isLoading.value = false;

    var returnData = await HttpRequest(api: params).get();

    if (returnData == "No Internet") {
      isNetConn.value = false;
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    if (returnData == null) {
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      isNetConn.value = true;
      return;
    }
    if (returnData["items"].isNotEmpty) {
      isNetConn.value = true;

      province.value = returnData["items"].where((element) {
        return element["value"] == userData[0]["province_id"];
      }).toList()[0]["text"];

      return;
    } else {
      isNetConn.value = true;

      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
    }
  }

  void showBottomSheetCamera() {
    showCupertinoModalPopup(
        context: Get.context!,
        builder: (BuildContext cont) {
          return CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                  takePhoto(ImageSource.camera);
                },
                child: const Text('Use Camera'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                  takePhoto(ImageSource.gallery);
                },
                child: const Text('Upload from files'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          );
        });
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 25,
      maxHeight: 480,
      maxWidth: 640,
    );

    imageFile = pickedFile != null ? File(pickedFile.path) : null;

    if (imageFile != null) {
      state = AppState.picked;
      imageFile!.readAsBytes().then((data) {
        imageBase64 = base64.encode(data);
        submitProfilePic();
      });
    } else {
      imageBase64 = null;
    }
  }

  void submitProfilePic() async {
    CustomDialog().loadingDialog(Get.context!);
    final myData = await Authentication().getUserData2();

    Map<String, dynamic> parameters = {
      "mobile_no": myData["mobile_no"],
      "last_name": myData["last_name"],
      "first_name": myData["first_name"],
      "middle_name": myData["middle_name"],
      "birthday": myData["birthday"].toString() == 'null'
          ? ''
          : myData["birthday"].toString().split("T")[0],
      "gender": myData["gender"],
      "civil_status": myData["civil_status"],
      "address1": myData["address1"],
      "address2": myData["address2"],
      "brgy_id": myData["brgy_id"] ?? "",
      "city_id": myData["city_id"] ?? "",
      "province_id": myData["province_id"] ?? "",
      "region_id": myData["region_id"] ?? "",
      "zip_code": myData["zip_code"] ?? "",
      "email": myData["email"],
      "secq_id1": myData["secq_id1"] ?? "",
      "secq_id2": myData["secq_id2"] ?? "",
      "secq_id3": myData["secq_id3"] ?? "",
      "seca1": myData["seca1"],
      "seca2": myData["seca2"],
      "seca3": myData["seca3"],
      "image_base64": imageBase64!.toString(),
    };

    HttpRequest(api: ApiKeys.putUpdateUserProf, parameters: parameters)
        .putBody()
        .then((res) async {
      Get.back();
      if (res == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (res == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      } else {
        if (res["success"] == "Y") {
          myprofile.value = imageBase64!;
          setNewUserImg(myprofile.value);
          Authentication().setProfilePic(jsonEncode(imageBase64!));
          getUserData();
        } else {
          CustomDialog().errorDialog(Get.context!, "luvpark", res["msg"], () {
            Get.back();
          });

          return;
        }
      }
    });
  }

  void setNewUserImg(String img) {
    profWidget.clear();
    profWidget.add(Hero(
      tag: "profile_pic",
      createRectTween: (begin, end) {
        // Custom Tween for smoother animation
        return MaterialRectCenterArcTween(begin: begin, end: end);
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          ),
          child: ClipRRect(
            clipBehavior: Clip.none,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              backgroundImage: img.isNotEmpty
                  ? MemoryImage(
                      base64Decode(img),
                    )
                  : null,
              child: img.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 32,
                      color: AppColor.primaryColor,
                    )
                  : null,
            ),
          ),
        ),
      ),
    ));
    heroTag = profWidget;
    update();
  }
}
