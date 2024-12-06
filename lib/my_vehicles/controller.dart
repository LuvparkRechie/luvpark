import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/my_vehicles/utils/add_vehicle.dart';
import 'package:luvpark/my_vehicles/utils/sub_details.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../custom_widgets/variables.dart';
import '../sqlite/vehicle_brands_table.dart';

enum AppState {
  free,
  picked,
  cropped,
}

class MyVehiclesController extends GetxController {
  final GlobalKey<FormState> formVehicleReg = GlobalKey<FormState>();
  final TextEditingController plateNo = TextEditingController();
  final TextEditingController vehicleBrand = TextEditingController();
  final ImagePicker picker = ImagePicker();

  RxString orImageBase64 = "".obs;
  RxString crImageBase64 = "".obs;
  AppState? state;
  File? imageFile;

  RxBool isLoadingPage = true.obs;
  RxBool isBtnLoading = false.obs;
  RxBool isNetConn = true.obs;

  String? ddVhType;
  var ddVhBrand = Rx<String?>(null);

  RxList vehicleData = <Map<String, dynamic>>[].obs;
  RxList vehicleDdData = <Map<String, dynamic>>[].obs;
  RxList vehicleBrandData = <Map<String, dynamic>>[].obs;

  RxList subDetailsData = [].obs;
  RxBool isLoadingsubDetails = true.obs;

  RxString hintTextLabel = "Plate No".obs;
  final Map<String, RegExp> _filter = {
    'A': RegExp(r'[A-Za-z0-9]'),
    '#': RegExp(r'[A-Za-z0-9]'),
  };

  Rx<MaskTextInputFormatter?> maskFormatter = Rx<MaskTextInputFormatter?>(null);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMaskFormatter("");
      getMyVehicle();
    });
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

  void getMyVehicle() async {
    List data = await VehicleBrandsTable.instance.readAllVHBrands();
    if (data.isNotEmpty) {
      for (dynamic dataRow in data) {
        Variables.gVBrand.add(dataRow);
      }
    }

    final userId = await Authentication().getUserId();
    String api =
        "${ApiKeys.gApiLuvParkPostGetVehicleReg}?user_id=$userId&vehicle_types_id_list=";

    HttpRequest(api: api).get().then((myVehicles) async {
      print("myvehicles: $myVehicles");
      if (myVehicles == "No Internet") {
        isLoadingPage.value = false;
        isNetConn.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (myVehicles == null || myVehicles["items"].isEmpty) {
        isLoadingPage.value = false;
        isNetConn.value = true;
        vehicleData.clear();
        return;
      }
      vehicleData.clear();
      isLoadingPage.value = false;
      isNetConn.value = true;

      for (var row in myVehicles["items"]) {
        List dataVBrand = await Functions.getBranding(
            row["vehicle_type_id"], row["vehicle_brand_id"]);

        vehicleData.add({
          "vehicle_type_id": row["vehicle_type_id"],
          "vehicle_brand_id": row["vehicle_brand_id"],
          "vehicle_brand_name": dataVBrand[0]["vehicle_brand_name"],
          "vehicle_plate_no": row["vehicle_plate_no"],
          "image": dataVBrand[0]["imageb64"]
        });
      }

      _updateMaskFormatter("");
    });
  }

  void getVehicleDropDown() {
    CustomDialog().loadingDialog(Get.context!);
    HttpRequest(api: ApiKeys.gApiLuvParkDDVehicleTypes)
        .get()
        .then((returnData) async {
      Get.back();
      if (returnData == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (returnData == null || returnData["items"].isEmpty) {
        CustomDialog().errorDialog(Get.context!, "luvpark", "No data found",
            () {
          Get.back();
        });
        return;
      }

      vehicleDdData.clear();
      orImageBase64.value = "";
      crImageBase64.value = "";
      ddVhType = null;
      ddVhBrand.value = null;
      plateNo.clear();
      vehicleBrand.clear();
      vehicleBrandData.clear();

      for (var items in returnData["items"]) {
        vehicleDdData.add({
          "value": items["value"].toString(),
          "text": items["text"].toString(),
          "format": items["input_format"],
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.to(const AddVehicles());
      });
    });
  }

  void getFilteredBrand(vtId) async {
    List dataInatay = [];
    CustomDialog().loadingDialog(Get.context!);
    final maeMae = await VehicleBrandsTable.instance.readAllVHBrands();
    if (maeMae.isNotEmpty) {
      dataInatay = maeMae.where((e) {
        return int.parse(e["vehicle_type_id"].toString()) ==
            int.parse(vtId.toString());
      }).map((item) {
        return {
          "text": item["vehicle_brand_name"],
          "value": item["vehicle_brand_id"],
        };
      }).toList();
      await Future.delayed(Duration(seconds: 2), () {
        vehicleBrandData.value = dataInatay;
        Get.back();
      });
    }
    Get.back();
  }

  void onChangedType(value) async {
    CustomDialog().loadingDialog(Get.context!);
    ddVhType = value;
    ddVhBrand.value = null;
    vehicleBrandData.clear();
    plateNo.clear();

    var dataList = vehicleDdData.firstWhere((e) {
      return int.parse(e["value"].toString()) == int.parse(ddVhType.toString());
    });

    _updateMaskFormatter(dataList["format"]);
    getFilteredBrand(ddVhType);
  }

  void onChangedBrand(value) {
    ddVhBrand.value = value;
  }

  void _updateMaskFormatter(String? mask) {
    hintTextLabel.value = mask ?? "Plate No.";
    maskFormatter.value = MaskTextInputFormatter(
      mask: mask,
      filter: _filter,
    );
    update();
  }

  void showBottomSheetCamera(bool isOr) {
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
              Get.back();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        );
      },
    );
  }

  void takePhoto(ImageSource source, bool isOr) async {
    final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: Platform.isIOS ? 18 : 20,
        maxWidth: Platform.isIOS ? 300 : 400,
        requestFullMetadata: true);

    imageFile = pickedFile != null ? File(pickedFile.path) : null;

    if (imageFile != null) {
      state = AppState.picked;
      final data = await imageFile!.readAsBytes();
      if (isOr) {
        orImageBase64.value = base64.encode(data);
      } else {
        crImageBase64.value = base64.encode(data);
      }
    } else {
      if (isOr) {
        orImageBase64.value = "";
      } else {
        crImageBase64.value = "";
      }
    }
  }

  void onDeleteVehicle(String plateNo) async {
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
        Get.back();
        if (retDelete == "No Internet") {
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
        } else if (retDelete == "Success") {
          CustomDialog().successDialog(
              Get.context!, "Success", "Successfully deleted", "Okay", () {
            Get.back();
            onRefresh();
          });
        } else {
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        }
      });
    });
  }

  void onSubmitVehicle() async {
    CustomDialog().confirmationDialog(Get.context!, "Register Vehicle",
        "Are you sure you want to register this vehicle?", "No", "Okay", () {
      Get.back();
    }, () async {
      Get.back();
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
        FocusManager.instance.primaryFocus?.unfocus();
        isBtnLoading.value = false;

        if (returnPost == "No Internet") {
          CustomDialog().internetErrorDialog(Get.context!, () {
            Get.back();
          });
        } else if (returnPost == null) {
          CustomDialog().serverErrorDialog(Get.context!, () {
            Get.back();
          });
        } else {
          if (returnPost["success"] == 'Y') {
            onRefresh();
            CustomDialog().successDialog(Get.context!, "Success",
                "Successfully registered vehicle.", "Okay", () {
              Get.back();
              Get.back();
            });
          } else {
            CustomDialog().errorDialog(Get.context!, "Error", returnPost["msg"],
                () {
              Get.back();
            });
          }
        }
      });
    });
  }

  void subscrbeVh(String scQr, String plateNo, String brandId) async {
    CustomDialog().loadingDialog(Get.context!);
    int? lpId = await Authentication().getUserId();
    dynamic param = {
      "qr_code": scQr,
      "luvpay_id": lpId,
      "vehicle_plate_no": plateNo,
      "vehicle_brand_id": brandId,
    };
    final returnPost =
        await HttpRequest(api: ApiKeys.gApiSubscribeVh, parameters: param)
            .postBody();
    if (returnPost == "No Internet") {
      Get.back();
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
    } else if (returnPost == null) {
      Get.back();
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
    } else if (returnPost["success"] == 'N') {
      Get.back();
      CustomDialog().errorDialog(Get.context!, "Error", returnPost["msg"], () {
        Get.back();
      });
    } else {
      Get.back();
      onRefresh();
      CustomDialog().successDialog(
          Get.context!, "Success", returnPost["msg"], "Okay", () {
        Get.back();
      });
    }
  }

  Future<void> getVhSubscriptionDetails(int index) async {
    String vehiclePlateNo = vehicleData[index]["vehicle_plate_no"];

    CustomDialog().loadingDialog(Get.context!);
    subDetailsData.value = [];
    print("vehiclePlateNo $vehiclePlateNo");
    try {
      final objData = await HttpRequest(
        api:
            "${ApiKeys.gApiGetSubscriptionDetails}?vehicle_plate_no=$vehiclePlateNo",
      ).get();
      print("objData $objData");
      Get.back();
      if (objData == "No Internet") {
        isLoadingsubDetails.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (objData == null) {
        isLoadingsubDetails.value = false;
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      } else {
        subDetailsData.value = objData['items'];
        Get.bottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(7),
            ),
          ),
          backgroundColor: Colors.white,
          SubscriptionDetails(
            data: subDetailsData,
          ),
        );
      }
    } catch (e) {
      isLoadingsubDetails.value = false;
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
    } finally {
      isLoadingsubDetails.value = false;
    }
  }
}
