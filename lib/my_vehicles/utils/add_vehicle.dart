import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/my_vehicles/controller.dart';

import '../../custom_widgets/app_color.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../custom_widgets/variables.dart';

class AddVehicles extends GetView<MyVehiclesController> {
  const AddVehicles({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MyVehiclesController());
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: controller.formVehicleReg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 10),
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                              padding: const EdgeInsets.all(10),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: Color(0xFF0078FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(43),
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: Color(0x0C000000),
                                    blurRadius: 15,
                                    offset: Offset(0, 5),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: Icon(
                                LucideIcons.arrowLeft,
                                color: Colors.white,
                                size: 16,
                              )),
                        ),
                        Container(height: 20),
                        Text(
                          "Vehicle Registration",
                          style: GoogleFonts.openSans(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: AppColor.headerColor,
                          ),
                        ),
                        Container(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                          child: customDropdown(
                            labelText: "Vehicle type",
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
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                          child: customDropdown(
                            labelText: "Vehicle brand",
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
                            if (controller.maskFormatter.value == null) {
                              String trimmedValue = value
                                  .toUpperCase()
                                  .replaceFirst(RegExp(r'[^a-zA-Z0-9. ]'), '');
                              validateText(value, controller.plateNo);
                              if (trimmedValue.isNotEmpty) {
                                controller.plateNo.value = TextEditingValue(
                                  text:
                                      Variables.capitalizeAllWord(trimmedValue),
                                  selection: controller.plateNo.selection,
                                );
                              } else {
                                controller.plateNo.value = TextEditingValue(
                                  text: "",
                                  selection: TextSelection.collapsed(offset: 0),
                                );
                              }
                            } else {
                              String capitalizeWords(String input) {
                                return input.toUpperCase();
                              }

                              String text = capitalizeWords(value);
                              controller.plateNo.value = TextEditingValue(
                                text: text,
                              );
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Plate no. is required";
                            }
                            if (value.length > 15) {
                              return "Plate no. should not exceed 15 characters";
                            }
                            if (value.startsWith('-') || value.endsWith('-')) {
                              return "Plate no. should not start or end with a dash";
                            }
                            if ((value.endsWith(' ') ||
                                value.endsWith('-') ||
                                value.endsWith('.'))) {
                              return "Plate no. should not contain space, hyphen, or period";
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
                              controller.showBottomSheetCamera(true);
                            },
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade500,
                                ),
                              ),
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
                            trailing: Icon(
                              LucideIcons.chevronRight,
                              size: 20,
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
                              controller.showBottomSheetCamera(false);
                            },
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              child: Icon(
                                Icons.photo_outlined,
                                color: Colors.grey,
                              ),
                            ),
                            title: CustomTitle(
                              text: controller.crImageBase64.isEmpty
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
                            trailing: Icon(
                              LucideIcons.chevronRight,
                              size: 20,
                            ),
                          ),
                        ),
                        // Container(
                        //   height: 10,
                        // ),
                        // const CustomTitle(text: "Original Receipt (OR)"),
                        // Container(
                        //   height: 10,
                        // ),
                        // InkWell(
                        //   onTap: () {
                        //     controller.showBottomSheetCamera(true);
                        //   },
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(12),
                        //       color: Colors.grey.shade200,
                        //       border: Border.all(
                        //         color: Colors.black.withOpacity(0.2),
                        //         width: 1,
                        //       ),
                        //     ),
                        //     child: controller.orImageBase64.isNotEmpty
                        //         ? Image(
                        //             fit: BoxFit.cover,
                        //             image: MemoryImage(
                        //               const Base64Decoder().convert(controller
                        //                   .orImageBase64.value
                        //                   .toString()),
                        //             ))
                        //         : Center(
                        //             child: Row(
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             children: [
                        //               CustomParagraph(text: "Tap to upload"),
                        //               Container(width: 5),
                        //               Icon(
                        //                 Icons.photo_outlined,
                        //                 color: Colors.grey,
                        //               )
                        //             ],
                        //           )),
                        //     height: 120,
                        //     width: MediaQuery.of(context).size.width,
                        //   ),
                        // ),
                        // Container(
                        //   height: 30,
                        // ),
                        // Container(height: 10),
                        // const CustomTitle(
                        //     text: "Certificate of Registration (CR)"),
                        // Container(
                        //   height: 10,
                        // ),
                        // InkWell(
                        //   onTap: () {
                        //     controller.showBottomSheetCamera(false);
                        //   },
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(12),
                        //       color: Colors.grey.shade200,
                        //       border: Border.all(
                        //         color: Colors.black.withOpacity(0.2),
                        //         width: 1,
                        //       ),
                        //     ),
                        //     child: controller.crImageBase64.isNotEmpty
                        //         ? Image(
                        //             fit: BoxFit.cover,
                        //             image: MemoryImage(
                        //               const Base64Decoder().convert(controller
                        //                   .crImageBase64.value
                        //                   .toString()),
                        //             ))
                        //         : Center(
                        //             child: Row(
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             children: [
                        //               CustomParagraph(text: "Tap to upload"),
                        //               Container(width: 5),
                        //               Icon(
                        //                 Icons.photo_outlined,
                        //                 color: Colors.grey,
                        //               )
                        //             ],
                        //           )),
                        //     height: 120,
                        //     width: MediaQuery.of(context).size.width,
                        //   ),
                        // ),

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
