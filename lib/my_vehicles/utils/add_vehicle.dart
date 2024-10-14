import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/my_vehicles/controller.dart';

import '../../custom_widgets/custom_textfield.dart';

class AddVehicles extends GetView<MyVehiclesController> {
  const AddVehicles({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MyVehiclesController());
    return Scaffold(
      appBar: CustomAppbar(
        bgColor: AppColor.primaryColor,
        textColor: Colors.white,
        titleColor: Colors.white,
        title: "Add Vehicle",
      ),
      body: ScrollConfiguration(
        behavior: ScrollBehavior().copyWith(overscroll: false),
        child: StretchingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Obx(
                () => Form(
                  key: controller.formVehicleReg,
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 30),
                      CustomDropdown(
                        labelText: "Vehicle type",
                        ddData: controller.vehicleDdData,
                        ddValue: controller.ddVhType,
                        onChange: (String? newValue) {
                          controller.onChangedType(newValue!);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vehicle type is required";
                          }
                          return null;
                        },
                      ),
                      controller.isLoadingAddVh.value
                          ? CustomTextField(
                              labelText: "Vehicle brand",
                              controller: TextEditingController(),
                              isReadOnly: true,
                            )
                          : CustomDropdown(
                              labelText: "Vehicle brand",
                              ddData: controller.vehicleBrandData,
                              ddValue: controller.ddVhBrand.value,
                              onChange: (String? newValue) {
                                controller.onChangedBrand(newValue!);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Vehicle brand is required";
                                }
                                return null;
                              },
                            ),
                      CustomTextField(
                        labelText: controller.hintTextLabel.value.isEmpty
                            ? "Plate No"
                            : controller.hintTextLabel.value,
                        inputFormatters: [
                          if (controller.maskFormatter.value != null)
                            controller.maskFormatter.value!
                        ],
                        controller: controller.plateNo,
                        onChange: (value) {
                          var newValue = value
                              .toUpperCase()
                              .replaceAll(RegExp(r'[^A-Z0-9-]'), "")
                              .replaceAll(" ", "")
                              .replaceAll(RegExp(r'-{2,}'), '-');

                          if (newValue.length > 15) {
                            controller.plateNo.text = newValue.substring(0, 15);
                            controller.plateNo.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: controller.plateNo.text.length),
                            );
                          } else {
                            controller.plateNo.value = TextEditingValue(
                              text: newValue,
                              selection: controller.plateNo.selection,
                            );
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Plate No. is required";
                          }
                          if (!value.contains(RegExp(r'^[A-Z0-9-]+$'))) {
                            return "Plate No. should only contain letters, numbers, and dashes";
                          }
                          if (value.startsWith('-') || value.endsWith('-')) {
                            return "Plate No. should not start or end with a dash";
                          }
                          // if (value.startsWith('TMP') && value.length != 10) {
                          //   return "Temporary plate number should be 10 characters long";
                          // }
                          return null;
                        },
                      ),
                      Container(height: 10),
                      const CustomTitle(text: "Original Receipt (OR)"),
                      Container(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          controller.showBottomSheetCamera(true);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade200,
                          ),
                          child: controller.orImageBase64.isNotEmpty
                              ? Image(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(
                                    const Base64Decoder().convert(controller
                                        .orImageBase64.value
                                        .toString()),
                                  ))
                              : Center(
                                  child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomParagraph(text: "Tap to upload"),
                                    Container(width: 5),
                                    Icon(
                                      Icons.photo_outlined,
                                      color: Colors.grey,
                                    )
                                  ],
                                )),
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        height: 30,
                      ),
                      Container(height: 10),
                      const CustomTitle(
                          text: "Certificate of Registration (CR)"),
                      Container(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          controller.showBottomSheetCamera(false);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade200,
                          ),
                          child: controller.crImageBase64.isNotEmpty
                              ? Image(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(
                                    const Base64Decoder().convert(controller
                                        .crImageBase64.value
                                        .toString()),
                                  ))
                              : Center(
                                  child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomParagraph(text: "Tap to upload"),
                                    Container(width: 5),
                                    Icon(
                                      Icons.photo_outlined,
                                      color: Colors.grey,
                                    )
                                  ],
                                )),
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        height: 30,
                      ),
                      if (MediaQuery.of(context).viewInsets.bottom == 0)
                        Obx(
                          () => CustomButton(
                            loading: controller.isBtnLoading.value,
                            text: "Submit",
                            onPressed: () {
                              if (controller.formVehicleReg.currentState!
                                  .validate()) {
                                controller.onSubmitVehicle();
                              }
                            },
                          ),
                        ),
                      Container(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
