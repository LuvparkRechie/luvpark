import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/variables.dart';
import '../http/api_keys.dart';
import '../http/http_request.dart';
import '../routes/routes.dart';
import '../sqlite/vehicle_brands_model.dart';
import '../sqlite/vehicle_brands_table.dart';

class OnboardingController extends GetxController {
  RxInt currentPage = 0.obs;
  PageController pageController = PageController();
  OnboardingController();
  RxList<Map<String, dynamic>> sliderData = RxList([
    {
      "title": "Need parking?",
      "subTitle":
          "luvpark finds nearby spots in real-time based on your destination and location.",
      "icon": "onboard1",
    },
    {
      "title": "Easy booking",
      "subTitle":
          "Book your parking spot with ease using luvpark's state-of-the-art parking system.",
      "icon": "onboard2",
    },
    {
      "title": "Pick & Park",
      "subTitle":
          "Discover the perfect parking spot with luvpark—tailored just for you!",
      "icon": "onboard3",
    },
  ]);

  void onPageChanged(int index) {
    currentPage.value = index;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    super.onClose();
    pageController.dispose();
  }

  Future<void> getVehicleBrands(bool isLogin) async {
    String apiParam = ApiKeys.gApiLuvParkGetVehicleBrand;
    CustomDialog().loadingDialog(Get.context!);

    HttpRequest(api: apiParam).get().then((returnBrandData) async {
      if (returnBrandData == "No Internet") {
        Get.back();
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }
      if (returnBrandData == null) {
        Get.back();
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      } else {
        Get.back();
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
        if (isLogin) {
          Get.offAndToNamed(Routes.login);
        } else {
          Get.offAndToNamed(Routes.landing);
        }
      }
    });
  }
}
