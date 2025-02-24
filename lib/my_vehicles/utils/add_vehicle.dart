import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/my_vehicles/controller.dart';

import '../../custom_widgets/app_color.dart';
import '../../custom_widgets/custom_textfield.dart';
import 'preview_image.dart';

class AddVehicles extends GetView<MyVehiclesController> {
  const AddVehicles({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MyVehiclesController());
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(overscroll: false),
          child: StretchingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Obx(
                  () => Form(
                    key: controller.formVehicleReg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 20),
                        CustomButtonClose(onTap: () {
                          Get.back();
                        }),
                        Container(height: 20),
                        CustomTitle(
                          text: "Vehicle Registration",
                          fontSize: 20,
                        ),
                        Container(height: 10),
                        CustomParagraph(
                          text:
                              "Register your vehicle to access seamless parking.",
                        ),
                        Container(height: 20),
                        CustomParagraph(
                          text: "Vehicle type",
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                          child: customDropdown(
                            labelText: "Select Vehicle Type",
                            isDisabled: false,
                            items: controller.vehicleDdData,
                            selectedValue: controller.ddVhType,
                            onChanged: (String? newValue) {
                              controller.onChangedType(newValue!);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Vehicle type is required";
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(height: 10),
                        CustomParagraph(
                          text: "Vehicle brand",
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                          child: customDropdown(
                            labelText: "Select Vehicle brand",
                            isDisabled: false,
                            items: controller.vehicleBrandData,
                            selectedValue: controller.ddVhBrand.value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Vehicle brand is required";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              controller.onChangedBrand(value!);
                            },
                          ),
                        ),
                        Container(height: 10),
                        CustomParagraph(
                          text: "Plate No",
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        CustomTextField(
                          isReadOnly: controller.ddVhType == null ||
                              controller.ddVhBrand.value == null,
                          hintText: "Enter Plate No",
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                            FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z0-9]+|\s ")),
                          ],
                          filledColor: Colors.grey.shade200,
                          isFilled: controller.ddVhType == null ||
                              controller.ddVhBrand.value == null,
                          controller: controller.plateNo,
                          onChange: (value) {
                            final selection = controller.plateNo.selection;
                            controller.plateNo.text = value.toUpperCase();
                            controller.plateNo.selection = selection;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Plate no. is required";
                            }
                            if ((value.endsWith(' ') ||
                                value.endsWith('-') ||
                                value.startsWith(" ") ||
                                value.endsWith('.'))) {
                              return "Invalid Plate no. format";
                            }

                            return null;
                          },
                        ),
                        Container(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xfff0f3fa),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: ListTile(
                            onTap: () {
                              if (controller.orImageBase64.isNotEmpty) {
                                Get.to(() => ImageViewer(
                                    base64Image:
                                        controller.orImageBase64.value));
                              } else {
                                controller.showBottomSheetCamera(true);
                              }
                            },
                            contentPadding: EdgeInsets.zero,
                            leading: controller.orImageBase64.isNotEmpty
                                ? Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade300,
                                      image: DecorationImage(
                                        filterQuality: FilterQuality.high,
                                        fit: BoxFit.cover,
                                        image: MemoryImage(
                                          base64Decode(
                                            controller.orImageBase64.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 50,
                                    width: 50,
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade300),
                                    child: Icon(
                                      Icons.photo_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                            title: CustomTitle(
                              text: controller.orImageBase64.isEmpty
                                  ? "No receipt"
                                  : "or.png",
                              color: Color(0xFF131122),
                            ),
                            subtitle: CustomParagraph(
                              text: "Original Receipt (OR)",
                              fontSize: 12,
                              maxlines: 1,
                              minFontSize: 12,
                            ),
                            trailing: InkWell(
                              onTap: () {
                                controller.showBottomSheetCamera(true);
                              },
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        Container(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xfff0f3fa),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: ListTile(
                            onTap: () {
                              if (controller.crImageBase64.isNotEmpty) {
                                Get.to(() => ImageViewer(
                                    base64Image:
                                        controller.crImageBase64.value));
                              } else {
                                controller.showBottomSheetCamera(false);
                              }
                            },
                            contentPadding: EdgeInsets.zero,
                            leading: controller.crImageBase64.isNotEmpty
                                ? Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade300,
                                      image: DecorationImage(
                                        filterQuality: FilterQuality.high,
                                        fit: BoxFit.cover,
                                        image: MemoryImage(
                                          base64Decode(
                                            controller.crImageBase64.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 50,
                                    width: 50,
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade300),
                                    child: Icon(
                                      Icons.photo_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                            title: CustomTitle(
                              text: controller.crImageBase64.value.isEmpty
                                  ? "No certificate"
                                  : "cr.png",
                              color: Color(0xFF131122),
                            ),
                            subtitle: CustomParagraph(
                              text: "Certificate of Registration (CR)",
                              fontSize: 12,
                              maxlines: 1,
                              minFontSize: 12,
                            ),
                            trailing: InkWell(
                              onTap: () {
                                controller.showBottomSheetCamera(false);
                              },
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                size: 20,
                              ),
                            ),
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
      ),
    );
  }

  String validateText(String inputText, TextEditingController txtController) {
    // Check if the first character is a space or special character
    if (inputText.isNotEmpty && !RegExp(r'^[a-zA-Z0-9]').hasMatch(inputText)) {
      return 'Text must not start with a space or special character';
    }

    // Replace multiple spaces with a single space
    String formattedText = inputText.replaceAll(RegExp(r'\s+'), ' ');

    // Update error message if input is not valid
    if (formattedText != inputText) {
      txtController.text = formattedText;

      txtController.selection = TextSelection.fromPosition(
        TextPosition(offset: formattedText.length),
      );
    }

    return ''; // Return an empty string if valid
  }
}
