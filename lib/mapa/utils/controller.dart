import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';

// ignore: deprecated_member_use
class FilterMapController extends GetxController {
  FilterMapController();
  final arguments = Get.arguments;
  final List items = [
    {"text": "Allow", "value": "Y"},
    {"text": "No overnight", "value": "N"},
    {"text": "All", "value": ""},
  ];
  RxDouble currentDistance = 1.0.obs;
  RxString labelDistance = "1km".obs;

  RxBool isLoadingPage = true.obs;
  RxBool isNetConn = true.obs;
  RxList vhTypeData = [].obs;
  RxList parkTypeData = [].obs;
  RxList amenitiesData = [].obs;
  RxList radiusData = [].obs;
  RxList sfPt = [].obs;
  RxList sfAmen = [].obs;
  RxList<Map<String, String>> filterParam = [
    {"ovp": "", "radius": "", "vh_type": "", "park_type": "", "amen": ""}
  ].obs;
  Rx<String?> selectedVehicleType = Rx<String?>(null);
  Rx<int?> selectedOvp = Rx<int?>(null);

  // Dependencies
  @override
  void onInit() {
    super.onInit();
    filterParam.value = filterParam.map((e) {
      e["radius"] = currentDistance.value.roundToDouble().toString();
      return e;
    }).toList();

    loadData();
  }

  Future<void> onPickDistance(value) async {
    currentDistance.value = value;
    if ((currentDistance.value * 1000) > 1000) {
      labelDistance.value =
          "${(currentDistance.value * 1000).toDouble().round() / 1000} km";
    } else {
      labelDistance.value = "${(currentDistance.value * 1000).round()} m";
    }
    update();
  }

  Future<void> loadData() async {
    vhTypeData.value = [];

    const HttpRequest(api: ApiKeys.gApiLuvParkDDVehicleTypes)
        .get()
        .then((returnData) async {
      if (returnData == "No Internet") {
        isNetConn.value = false;
        isLoadingPage.value = false;
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });

        return;
      }
      if (returnData == null) {
        isNetConn.value = true;
        isLoadingPage.value = false;
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      }

      if (returnData["items"].length > 0) {
        vhTypeData.value = returnData["items"];

        loadParkingType();
      } else {
        CustomDialog().errorDialog(Get.context!, "luvpark", "No vehicle found",
            () {
          Get.back();
        });
      }
    });
  }

  Future<void> loadParkingType() async {
    parkTypeData.value = [];
    var returnData =
        await const HttpRequest(api: ApiKeys.gApiSubFolderGetParkingTypes)
            .get();

    if (returnData == "No Internet") {
      isNetConn.value = false;
      isLoadingPage.value = false;
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });

      return;
    }
    if (returnData == null) {
      isNetConn.value = true;
      isLoadingPage.value = false;
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }

    if (returnData["items"].length > 0) {
      parkTypeData.value = returnData["items"];

      loadAmenities();
    } else {
      CustomDialog().errorDialog(Get.context!, "luvpark", "No vehicle found",
          () {
        Get.back();
      });
    }
  }

  Future<void> loadAmenities() async {
    amenitiesData.value = [];
    var returnData =
        await const HttpRequest(api: ApiKeys.gApiSubFolderGetAllAmenities)
            .get();

    if (returnData == "No Internet") {
      isNetConn.value = false;
      isLoadingPage.value = false;
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });

      return;
    }
    if (returnData == null) {
      isNetConn.value = true;
      isLoadingPage.value = false;
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }

    if (returnData["items"].length > 0) {
      amenitiesData.value = returnData["items"];

      loadRadius();
    } else {
      CustomDialog().errorDialog(Get.context!, "luvpark", "No vehicle found",
          () {
        Get.back();
      });
    }
  }

  Future<void> loadRadius() async {
    radiusData.value = [];
    var returnData =
        await const HttpRequest(api: ApiKeys.gApiSubFolderGetDDNearest).get();

    if (returnData == "No Internet") {
      isNetConn.value = false;
      isLoadingPage.value = false;
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    if (returnData == null) {
      isNetConn.value = true;
      isLoadingPage.value = false;
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    isNetConn.value = true;
    isLoadingPage.value = false;
    if (returnData["items"].length > 0) {
      radiusData.value = returnData["items"];
    } else {
      CustomDialog().errorDialog(Get.context!, "luvpark", "No vehicle found",
          () {
        Get.back();
      });
    }
  }

  void onRadioChanged(String value) async {
    selectedVehicleType.value = value;
    update();
  }
}
