import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/routes/routes.dart';

import '../../http/api_keys.dart';
import '../../http/http_request.dart';

class UpdateProfileController extends GetxController {
  UpdateProfileController();

  final parameters = Get.arguments;
  final GlobalKey<FormState> formKeyStep1 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyStep2 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyStep3 = GlobalKey<FormState>();
  final FocusNode focusNode = FocusNode();
  PageController pageController = PageController();
  RxBool isLoading = true.obs;
  RxInt currentPage = 0.obs;
  late DateTime dateTime;
  DateTime? selectedDate;
  DateTime? minimumDate;
  String parsedDate(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
  }

  //Step 1 variable
  RxList suffixes = [].obs;
  RxList civilData = [].obs;
  RxString gender = "M".obs;

  var selectedSuffix = Rx<String?>(null);
  var selectedCivil = Rx<String?>(null);

  TextEditingController firstName = TextEditingController();
  TextEditingController middleName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController bday = TextEditingController();

  //step 2 variable
  RxList regionData = [].obs;
  RxList provinceData = [].obs;
  RxList cityData = [].obs;
  RxList brgyData = [].obs;
  var selectedRegion = Rx<String?>(null);
  var selectedProvince = Rx<String?>(null);
  var selectedCity = Rx<String?>(null);
  var selectedBrgy = Rx<String?>(null);

  TextEditingController address1 = TextEditingController();
  TextEditingController address2 = TextEditingController();
  TextEditingController zipCode = TextEditingController();

  //Step 3
  RxList questionData = [].obs;

  RxString question1 = "Choose a question".obs;
  RxString question2 = "Choose a question".obs;
  RxString question3 = "Choose a question".obs;

  RxInt seq1 = 0.obs;
  RxInt seq2 = 0.obs;
  RxInt seq3 = 0.obs;

  TextEditingController answer1 = TextEditingController();
  TextEditingController answer2 = TextEditingController();
  TextEditingController answer3 = TextEditingController();

  @override
  // ignore: unnecessary_overrides
  void onInit() {
    pageController = PageController();
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSuffixes();
      for (dynamic datas in parameters) {
        regionData.add(
          {"text": datas["region_name"], "value": datas["region_id"]},
        );
      }
      for (dynamic item in Variables.civilStatusData) {
        civilData.add({"text": item["status"], "value": item["value"]});
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    pageController.dispose();
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? datePicker = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 80),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
    );
    if (datePicker != null && datePicker != DateTime.now()) {
      bday.clear();

      selectedDate = datePicker;

      final today = DateTime.now();
      final age = today.year -
          selectedDate!.year -
          (today.month > selectedDate!.month ||
                  (today.month == selectedDate!.month &&
                      today.day >= selectedDate!.day)
              ? 0
              : 1);

      if (age < 12) {
        // ignore: use_build_context_synchronously
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Age Restriction'),
              content:
                  const Text('You must be at least 12 years old to proceed.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        dateTime = datePicker;
        bday.text = parsedDate(dateTime.toString());
      }
    }
  }

  void getSuffixes() {
    suffixes.value = [
      {"text": "Jr", "value": "jr"},
      {"text": "Sr", "value": "sr"},
      {"text": "II", "value": "II"},
      {"text": "III", "value": "III"}
    ];
    getQuestionData();
  }

  void getQuestionData() {
    const HttpRequest(api: ApiKeys.gApiSubFolderGetDD)
        .get()
        .then((returnData) async {
      isLoading.value = false;
      questionData.value = [];
      if (returnData == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
      }
      if (returnData == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      } else {
        questionData.value = returnData["items"];
      }
    });
  }

  void getProvinceData(id) async {
    selectedProvince.value = null;
    selectedCity.value = null;
    selectedBrgy.value = null;
    provinceData.value = [];
    cityData.value = [];
    brgyData.value = [];
    CustomDialog().loadingDialog(Get.context!);
    var returnData = await HttpRequest(
            api: "${ApiKeys.gApiSubFolderGetProvince}?p_region_id=$id")
        .get();
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
      provinceData.value = returnData["items"];
      update();
      return;
    } else {
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
    }
  }

  void getCityData(id) async {
    selectedCity.value = null;
    selectedBrgy.value = null;
    cityData.value = [];
    brgyData.value = [];
    CustomDialog().loadingDialog(Get.context!);
    var returnData = await HttpRequest(
            api: "${ApiKeys.gApiSubFolderGetCity}?p_province_id=$id")
        .get();
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
      cityData.value = returnData["items"];
      update();
      return;
    } else {
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
    }
  }

  void getBrgyData(id) async {
    selectedBrgy.value = null;
    brgyData.value = [];
    CustomDialog().loadingDialog(Get.context!);
    var returnData =
        await HttpRequest(api: "${ApiKeys.gApiSubFolderGetBrgy}?p_city_id=$id")
            .get();
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
      brgyData.value = returnData["items"];
      update();
      return;
    } else {
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
    }
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    update();
  }

  void onNextPage() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    switch (currentPage.value) {
      case 0:
        if (formKeyStep1.currentState!.validate()) {
          pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        }
        break;
      case 1:
        if (formKeyStep2.currentState!.validate()) {
          pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        }
        break;
      case 2:
        if (formKeyStep3.currentState!.validate()) {
          onSubmit();
        }
        break;
    }
  }

  void onSubmit() async {
    final data = await Authentication().getUserData2();
    Map<String, dynamic> submitParam = {
      "mobile_no": data["mobile_no"].toString(),
      "last_name": lastName.text,
      "first_name": firstName.text,
      "middle_name": middleName.text,
      "birthday": bday.text,
      "gender": gender.value,
      "civil_status": selectedCivil.value,
      "address1": address1.text,
      "address2": address2.text,
      "brgy_id": selectedBrgy.value.toString(),
      "city_id": selectedCity.value.toString(),
      "province_id": selectedProvince.value.toString(),
      "region_id": selectedRegion.value.toString(),
      "zip_code": zipCode.text,
      "email": email.text,
      "secq_id1": seq1.toString(),
      "secq_id2": seq2.toString(),
      "secq_id3": seq3.toString(),
      "seca1": answer1.text,
      "seca2": answer2.text,
      "seca3": answer3.text,
      "image_base64": "",
    };

    CustomDialog().confirmationDialog(Get.context!, "Update profile",
        "Are you sure you want to proceed?", "No", "Okay", () {
      Get.back();
    }, () {
      Get.back();
      CustomDialog().loadingDialog(Get.context!);
      Map<String, dynamic> parameters = {
        "mobile_no": data["mobile_no"].toString(),
      };

      HttpRequest(
              api: ApiKeys.gApiSubFolderPostReqOtpShare, parameters: parameters)
          .post()
          .then(
        (retvalue) {
          Get.back();
          if (retvalue == "No Internet") {
            CustomDialog().internetErrorDialog(Get.context!, () {
              Get.back();
            });
          }
          if (retvalue == null) {
            CustomDialog().serverErrorDialog(Get.context!, () {
              Get.back();
            });
          } else {
            if (retvalue["success"] == "Y") {
              List otpData = [
                {
                  "mobile_no": data["mobile_no"],
                  "otp": int.parse(retvalue["otp"].toString()),
                }
              ];
              dynamic args = {"otp_data": otpData, "parameter": submitParam};

              Get.toNamed(
                Routes.otpUpdProfile,
                arguments: args,
              );
            } else {
              CustomDialog()
                  .errorDialog(Get.context!, "luvpark", retvalue["msg"], () {
                Get.back();
              });
            }
          }
        },
      );
    });
  }

  void showBottomSheet(
    Widget child,
  ) {
    Get.bottomSheet(child, isScrollControlled: true);
  }

  List<dynamic> getDropdownData() {
    var data = questionData;
    int id1 = seq1.value;
    int id2 = seq2.value;
    int id3 = seq3.value;
    List<int> selectedIds = [id1, id2, id3];
    List filteredObjects = data
        .where((object) => !selectedIds.contains(object["secq_id"]))
        .toList();
    return filteredObjects;
  }
}
