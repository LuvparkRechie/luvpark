import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/functions/functions.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';
import 'package:luvpark_get/my_vehicles/utils/add_vehicle.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../sqlite/vehicle_brands_table.dart';

enum AppState {
  free,
  picked,
  cropped,
}

class MyVehiclesController extends GetxController {
  MyVehiclesController();
  final GlobalKey<FormState> formVehicleReg = GlobalKey<FormState>();
  TextEditingController plateNo = TextEditingController();
  TextEditingController vehicleBrand = TextEditingController();
  final ImagePicker picker = ImagePicker();
  RxString orImageBase64 = "".obs;
  RxString crImageBase64 = "".obs;
  AppState? state;
  File? imageFile;
  RxBool isLoadingPage = true.obs;
  RxBool isLoadingAddVh = true.obs;
  RxBool isBtnLoading = false.obs;
  RxBool isNetConn = true.obs;
  String? ddVhType;
  var ddVhBrand = Rx<String?>(null);
  RxList vehicleData = [].obs;
  RxList vehicleDdData = [].obs;
  RxList vehicleBrandData = [].obs;
  RxString hintTextLabel = "Plate No".obs;
  final Map<String, RegExp> _filter = {
    'A': RegExp(r'[A-Za-z0-9]'),
    '#': RegExp(r'[A-Za-z0-9]')
  };
  Rx<MaskTextInputFormatter?> maskFormatter = Rx<MaskTextInputFormatter?>(null);

  @override
  void onInit() {
    super.onInit();
    hintTextLabel.value = "Plate No";
    _updateMaskFormatter("");
    getMyVehicle();
  }

  @override
  void onClose() {
    plateNo.dispose();
    vehicleBrand.dispose();
    super.onClose();
  }

  Future<void> onRefresh() async {
    getMyVehicle();
  }

  //REgistered vehicle
  void getMyVehicle() async {
    final userId = await Authentication().getUserId();

    String api =
        "${ApiKeys.gApiLuvParkPostGetVehicleReg}?user_id=$userId&vehicle_types_id_list=";

    HttpRequest(api: api).get().then((myVehicles) async {
      if (myVehicles == "No Internet") {
        isLoadingPage.value = false;
        isNetConn.value = false;

        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (myVehicles == null) {
        isLoadingPage.value = false;
        isNetConn.value = true;

        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (myVehicles["items"].isNotEmpty) {
        isLoadingPage.value = false;
        isNetConn.value = true;
        vehicleData.value = [];

        for (var row in myVehicles["items"]) {
          String brandName = await Functions.getBrandName(
              row["vehicle_type_id"], row["vehicle_brand_id"]);

          vehicleData.add({
            "vehicle_type_id": row["vehicle_type_id"],
            "vehicle_brand_id": row["vehicle_brand_id"],
            "vehicle_brand_name": brandName,
            "vehicle_plate_no": row["vehicle_plate_no"],
          });
        }
        isLoadingAddVh.value = false;
        _updateMaskFormatter("");
      } else {
        isLoadingPage.value = false;
        isNetConn.value = true;
        vehicleData.value = [];
        return;
      }
    });
  }

  void getVehicleDropDown() {
    CustomDialog().loadingDialog(Get.context!);
    const HttpRequest(api: ApiKeys.gApiLuvParkDDVehicleTypes)
        .get()
        .then((returnData) async {
      if (returnData == "No Internet") {
        Get.back();
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (returnData == null) {
        Get.back();
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      }
      Get.back();
      if (returnData["items"].isNotEmpty) {
        vehicleDdData.value = [];
        orImageBase64.value = "";
        crImageBase64.value = "";
        ddVhType = null;
        ddVhBrand.value = null;
        plateNo.clear();
        vehicleBrand.clear();

        vehicleBrandData.value = [];

        for (var items in returnData["items"]) {
          vehicleDdData.add({
            "value": items["value"].toString(),
            "text": items["text"].toString(),
            "format": items["input_format"],
          });
        }

        Get.to(const AddVehicles());
      } else {
        CustomDialog().errorDialog(Get.context!, "luvpark", "No data found",
            () {
          Get.back();
        });
        return;
      }
    });
  }

  void getFilteredBrand(vtId) async {
    await VehicleBrandsTable.instance.readAllVHBrands().then((maeMae) {
      if (maeMae.isNotEmpty) {
        List inatay = maeMae.where((e) {
          return int.parse(e["vehicle_type_id"].toString()) ==
              int.parse(vtId.toString());
        }).toList();

        for (dynamic item in inatay) {
          vehicleBrandData.add({
            "text": item["vehicle_brand_name"],
            "value": item["vehicle_brand_id"]
          });
        }

        isLoadingAddVh.value = false;
      }
    });
  }

  void onChangedType(value) {
    isLoadingAddVh.value = true;
    ddVhType = value;
    ddVhBrand.value = "";
    ddVhBrand.value = null;
    vehicleBrandData.value = [];
    plateNo.clear();

    var dataList = vehicleDdData.where((e) {
      return int.parse(e["value"].toString()) == int.parse(ddVhType.toString());
    }).toList()[0];

    _updateMaskFormatter(dataList["format"]);
    getFilteredBrand(ddVhType);
    update();
  }

  void onChangedBrand(value) {
    ddVhBrand.value = value;
  }

  void _updateMaskFormatter(mask) {
    hintTextLabel.value = mask ?? "Plate No.";
    maskFormatter.value = MaskTextInputFormatter(
      mask: mask,
      filter: _filter,
    );
    update();
  }

  void showBottomSheetCamera(isOr) {
    showCupertinoModalPopup(
        context: Get.context!,
        builder: (BuildContext cont) {
          return CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(Get.context!);
                  takePhoto(ImageSource.camera, isOr);
                },
                child: const Text('Use Camera'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(Get.context!);
                  takePhoto(ImageSource.gallery, isOr);
                },
                child: const Text('Upload from files'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                // ignore: unnecessary_statements
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          );
        });
  }

  void takePhoto(ImageSource source, bool isOr) async {
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 25,
      maxHeight: 480,
      maxWidth: 640,
    );

    imageFile = pickedFile != null ? File(pickedFile.path) : null;

    if (imageFile != null) {
      state = AppState.picked;
      imageFile!.readAsBytes().then((data) {
        if (isOr) {
          orImageBase64.value = base64.encode(data);
        } else {
          crImageBase64.value = base64.encode(data);
        }
      });
    } else {
      if (isOr) {
        orImageBase64.value = "";
      } else {
        crImageBase64.value = "";
      }
    }
  }

  void onDeleteVehicle(plateNo) async {
    final userId = await Authentication().getUserId();
    var params = {
      "user_id": userId,
      "vehicle_plate_no": plateNo,
    };

    CustomDialog().confirmationDialog(Get.context!, "Delete Vehicle",
        "Are you sure you want to delete this vehicle?", "No", "Yes", () {
      Get.back();
    }, () {
      Get.back();
      CustomDialog().loadingDialog(Get.context!);
      HttpRequest(api: ApiKeys.gApiLuvParkDeleteVehicle, parameters: params)
          .deleteData()
          .then((retDelete) {
        if (retDelete == "No Internet") {
          Get.back();
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
        if (retDelete == "Success") {
          Get.back();
          CustomDialog().successDialog(
              Get.context!, "Success", "Successfully deleted", "Okay", () {
            Get.back();
            onRefresh();
          });
          return;
        } else {
          Get.back();
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
          return;
        }
      });
    });
  }

  void onSubmitVehicle() async {
    isBtnLoading.value = true;
    final userId = await Authentication().getUserId();
    var parameter = {
      "user_id": userId,
      "vehicle_plate_no": plateNo.text,
      "vehicle_type_id": ddVhType.toString(),
      "vehicle_brand_id": ddVhBrand.value.toString(),
      "vor_image_base64": orImageBase64.value,
      "vcr_image_base64": crImageBase64.value,
    };

    HttpRequest(api: ApiKeys.gApiLuvParkAddVehicle, parameters: parameter)
        .postBody()
        .then((returnPost) async {
      FocusManager.instance.primaryFocus!.unfocus();
      isBtnLoading.value = false;

      if (returnPost == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (returnPost == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      } else {
        if (returnPost["success"] == 'Y') {
          onRefresh();
          CustomDialog().successDialog(
              Get.context!, "Success", "Successfully added vehicle", "Okay",
              () {
            Get.back();
            Get.back();
          });
        } else {
          CustomDialog().errorDialog(Get.context!, "luvpark", "No data found",
              () {
            Get.back();
          });
        }
      }
    });
  }
}
