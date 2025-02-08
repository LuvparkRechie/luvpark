import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/my_account/utils/controller.dart';

class UpdateProfile extends GetView<UpdateProfileController> {
  const UpdateProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? const Scaffold(body: PageLoader())
          : PopScope(
              canPop: false,
              onPopInvoked: (pop) {
                FocusScope.of(context).requestFocus(FocusNode());
                if (!pop) {
                  CustomDialog().confirmationDialog(
                      context,
                      "Close Page",
                      "Are you sure you want to close this page?",
                      "No",
                      "Yes", () {
                    Get.back();
                  }, () {
                    Get.back();
                    Get.back();
                  });
                }
              },
              child: Scaffold(
                backgroundColor: AppColor.bodyColor,
                appBar: AppBar(
                  toolbarHeight: 0,
                  elevation: 0,
                  backgroundColor: AppColor.bodyColor,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: AppColor.bodyColor,
                    statusBarBrightness: Brightness.light,
                    statusBarIconBrightness: Brightness.dark,
                  ),
                ),
                body: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(overscroll: false),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 10),
                        CustomButtonClose(onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          CustomDialog().confirmationDialog(
                              context,
                              "Close Page",
                              "Are you sure you want to close this page?",
                              "No",
                              "Yes", () {
                            Get.back();
                          }, () {
                            Get.back();
                            Get.back();
                          });
                        }),
                        Container(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: controller.currentIndex.value == 0
                                      ? AppColor.primaryColor
                                      : Colors.grey.shade300,
                                ),
                                height: 5,
                              ),
                            ),
                            Container(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: controller.currentIndex.value == 1
                                      ? AppColor.primaryColor
                                      : Colors.grey.shade300,
                                ),
                                height: 5,
                              ),
                            ),
                            Container(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: controller.currentIndex.value == 2
                                      ? AppColor.primaryColor
                                      : Colors.grey.shade300,
                                ),
                                height: 5,
                              ),
                            ),
                          ],
                        ),
                        Container(height: 20),
                        Text(
                          controller.currentIndex.value == 0
                              ? "Personal Information"
                              : controller.currentIndex.value == 1
                                  ? "Address"
                                  : "Security Question",
                          style: GoogleFonts.openSans(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: AppColor.headerColor,
                          ),
                        ),
                        Container(height: 10),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: Builder(
                            builder: (context) {
                              if (controller.currentIndex.value == 0) {
                                return CustomParagraph(
                                  text:
                                      "Provide accurate details to help us personalize your experience.",
                                );
                              } else if (controller.currentIndex.value == 1) {
                                return CustomParagraph(
                                  text:
                                      "Enter your complete residential address for verification.",
                                );
                              } else {
                                return CustomParagraph(
                                  text:
                                      "Make sure your answer is memorable but not easily guessable by others.",
                                );
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 100),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            child:
                                controller.pages[controller.currentIndex.value],
                          ),
                        ),
                        if (MediaQuery.of(context).viewInsets.bottom == 0)
                          Row(
                            children: [
                              if (controller.currentIndex.value > 0)
                                Expanded(
                                  child: CustomButton(
                                    text: "Previous",
                                    textColor: AppColor.primaryColor,
                                    btnColor: AppColor.bodyColor,
                                    bordercolor: AppColor.primaryColor,
                                    onPressed: controller.previousPage,
                                  ),
                                ),
                              if (controller.currentIndex.value > 0)
                                Container(width: 10),
                              Expanded(
                                child: CustomButton(
                                  text: controller.currentIndex.value == 2
                                      ? "Submit"
                                      : "Next",
                                  onPressed: controller.nextPage,
                                ),
                              )
                            ],
                          ),
                        Container(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class NumericInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow only numbers
    if (RegExp(r'^\d*$').hasMatch(newValue.text)) {
      return newValue;
    }
    // Ignore changes if the input is invalid
    return oldValue;
  }
}

class SimpleNameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Updated regex to disallow specific sequences
    final regex = RegExp(r'^(|[a-zA-Z][a-zA-Z.-]*( [a-zA-Z.-]*)? ?)$');

    // Count spaces, periods, and hyphens in the new value
    int spaceCount = newValue.text.split(' ').length - 1;
    int periodCount = newValue.text.split('.').length - 1;
    int hyphenCount = newValue.text.split('-').length - 1;

    bool hasDisallowedCombination = newValue.text.contains('. -') ||
        newValue.text.contains('- .') ||
        newValue.text.contains(' .') ||
        newValue.text.contains('-.') ||
        newValue.text.contains('.-') ||
        newValue.text.contains('- ') ||
        newValue.text.contains(' -') ||
        newValue.text.contains('. ');

    // Check for 30-character limit
    if (newValue.text.length <= 30 &&
        regex.hasMatch(newValue.text) &&
        spaceCount <= 1 &&
        periodCount <= 1 &&
        hyphenCount <= 1 &&
        !hasDisallowedCombination) {
      return newValue;
    }
    return oldValue;
  }
}

class Stepp1 extends StatelessWidget {
  const Stepp1({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateProfileController());
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: StretchingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKeyStep1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20),
                  CustomTitle(
                    text: "First Name",
                    fontSize: 14,
                  ),
                  CustomTextField(
                    hintText: "Enter your first name",
                    controller: controller.firstName,
                    onChange: (value) {
                      if (value.isNotEmpty) {
                        controller.firstName.value = TextEditingValue(
                          text: Variables.capitalizeAllWord(value),
                          selection: controller.firstName.selection,
                        );
                      } else {
                        controller.firstName.value = TextEditingValue(
                          text: Variables.capitalizeAllWord(
                              value.substring(0, 30)),
                          selection: TextSelection.collapsed(offset: 0),
                        );
                      }
                      // Manually trigger validation when text is changed
                      // controller.formKeyStep1.currentState?.validate();
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
                      SimpleNameFormatter(), // Add your custom formatter here
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "First name is required";
                      }
                      if ((value.endsWith(' ') ||
                          value.endsWith('-') ||
                          value.endsWith('.'))) {
                        return "First name cannot end with a space, hyphen, or period";
                      }
                      return null;
                    },
                  ),
                  CustomTitle(
                    text: "Middle Name",
                    fontSize: 14,
                  ),
                  CustomTextField(
                    hintText: "Enter your middle name (optional)",
                    controller: controller.middleName,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
                      SimpleNameFormatter(),
                    ],
                    textCapitalization: TextCapitalization.words,
                    onChange: (inputText) {
                      // Manually trigger validation when text is changed

                      // controller.formKeyStep1.currentState?.validate();
                    },
                    validator: (value) {
                      if (value != null &&
                          (value.endsWith(' ') ||
                              value.endsWith('-') ||
                              value.endsWith('.'))) {
                        return "Middle name cannot end with a space, hyphen, or period";
                      }
                      return null;
                    },
                  ),
                  CustomTitle(
                    text: "Last Name",
                    fontSize: 14,
                  ),
                  CustomTextField(
                    hintText: "Enter your last name",
                    controller: controller.lastName,
                    textCapitalization: TextCapitalization.words,
                    onChange: (value) {
                      if (value.isNotEmpty) {
                        controller.lastName.value = TextEditingValue(
                          text: Variables.capitalizeAllWord(value),
                          selection: controller.lastName.selection,
                        );
                      } else {
                        controller.lastName.value = TextEditingValue(
                          text: Variables.capitalizeAllWord(
                              value.substring(0, 30)),
                          selection: TextSelection.collapsed(offset: 0),
                        );
                      }
                      // Manually trigger validation when text is changed
                      // controller.formKeyStep1.currentState?.validate();
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
                      SimpleNameFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Last name is required";
                      }
                      if ((value.endsWith(' ') ||
                          value.endsWith('-') ||
                          value.endsWith('.'))) {
                        return "Last name cannot end with a space, hyphen, or period";
                      }
                      return null;
                    },
                  ),
                  CustomTitle(
                    text: "Email",
                    fontSize: 14,
                  ),
                  CustomTextField(
                    hintText: "Enter your email",
                    controller: controller.email,
                    keyboardType: TextInputType.emailAddress,
                    onChange: (value) {
                      String trimmedValue =
                          value.replaceFirst(RegExp(r'^\s+'), '');
                      if (trimmedValue.isNotEmpty) {
                        // Do something here
                      } else {
                        controller.email.value = TextEditingValue(
                          text: Variables.capitalizeAllWord(
                              trimmedValue.substring(0, 30)),
                          selection: TextSelection.collapsed(offset: 0),
                        );
                      }
                      // Manually trigger validation when text is changed
                      // controller.formKeyStep1.currentState?.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email address is required';
                      }
                      if (!EmailValidator.validate(value) ||
                          !Variables.emailRegex.hasMatch(value)) {
                        controller.focusNode.requestFocus();
                        return "Invalid email format";
                      }
                      return null;
                    },
                  ),
                  CustomTitle(
                    text: "Birthday",
                    fontSize: 14,
                  ),
                  CustomTextField(
                    hintText: "YYYY-MM-DD",
                    isReadOnly: true,
                    controller: controller.bday,
                    onTap: () {
                      controller.selectDate(Get.context!);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Birthday is required";
                      }
                      return null;
                    },
                  ),
                  CustomTitle(
                    text: "Civil status",
                    fontSize: 14,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                    child: customDropdown(
                      labelText: "Select status",
                      isDisabled: false,
                      items: controller.civilData,
                      selectedValue: controller.selectedCivil.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Civil status is required";
                        }
                        return null;
                      },
                      onChanged: (data) {
                        controller.selectedCivil.value = data!;
                      },
                    ),
                  ),
                  Container(height: 10),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          controller.gender.value = "M";
                        },
                        child: Row(
                          children: [
                            Icon(
                              controller.gender.value == "M"
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: controller.gender.value == "M"
                                  ? AppColor.primaryColor
                                  : Colors.grey.shade400,
                            ),
                            Container(width: 5),
                            CustomParagraph(
                              text: "Male",
                              color: AppColor.headerColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                      Container(width: 20),
                      InkWell(
                        onTap: () {
                          controller.gender.value = "F";
                        },
                        child: Row(
                          children: [
                            Icon(
                              controller.gender.value == "F"
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: controller.gender.value == "F"
                                  ? AppColor.primaryColor
                                  : Colors.grey.shade400,
                            ),
                            Container(width: 5),
                            CustomParagraph(
                              text: "Female",
                              color: AppColor.headerColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Stepp2 extends StatelessWidget {
  const Stepp2({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateProfileController());
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: StretchingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Form(
              key: controller.formKeyStep2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20),
                  CustomTitle(
                    text: "Region",
                    fontSize: 14,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: customDropdown(
                      labelText: "Select region",
                      isDisabled: false,
                      items: controller.regionData,
                      selectedValue: controller.selectedRegion.value,
                      onChanged: (String? newValue) {
                        controller.selectedRegion.value = newValue.toString();
                        controller.getProvinceData(newValue);
                        controller.zipCode.clear();
                        // Manually trigger validation when the dropdown is changed
                        // controller.formKeyStep2.currentState?.validate();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Region is required";
                        }
                        return null;
                      },
                    ),
                  ),
                  CustomTitle(
                    text: "Province",
                    fontSize: 14,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 20),
                    child: customDropdown(
                      labelText: "Select province",
                      isDisabled: false,
                      items: controller.provinceData,
                      selectedValue: controller.selectedProvince.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Province is required';
                        }
                        return null;
                      },
                      onChanged: (data) {
                        controller.selectedProvince.value = data.toString();
                        controller.getCityData(data);

                        // Manually trigger validation when the dropdown is changed
                        // controller.formKeyStep2.currentState?.validate();
                      },
                    ),
                  ),
                  CustomTitle(
                    text: "City",
                    fontSize: 14,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 20),
                    child: customDropdown(
                      labelText: "Select city",
                      isDisabled: false,
                      items: controller.cityData,
                      selectedValue: controller.selectedCity.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                      onChanged: (data) {
                        controller.selectedCity.value = data.toString();
                        controller.getBrgyData(data);
                        // Manually trigger validation when the dropdown is changed
                        // controller.formKeyStep2.currentState?.validate();
                      },
                    ),
                  ),
                  CustomTitle(
                    text: "Barangay",
                    fontSize: 14,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 20),
                    child: customDropdown(
                      labelText: "Select barangay",
                      isDisabled: false,
                      items: controller.brgyData,
                      selectedValue: controller.selectedBrgy.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Barangay is required';
                        }
                        return null;
                      },
                      onChanged: (data) {
                        controller.selectedBrgy.value = data.toString();
                        // Manually trigger validation when the dropdown is changed
                        // controller.formKeyStep2.currentState?.validate();
                      },
                    ),
                  ),
                  CustomTitle(
                    text: "Zip Code",
                    fontSize: 14,
                  ),
                  CustomTextField(
                    filledColor: Colors.grey.shade200,
                    isReadOnly: controller.selectedBrgy.value == null ||
                        controller.selectedRegion.value == null ||
                        controller.selectedProvince.value == null ||
                        controller.selectedCity.value == null,
                    isFilled: controller.selectedBrgy.value == null ||
                        controller.selectedRegion.value == null ||
                        controller.selectedProvince.value == null ||
                        controller.selectedCity.value == null,
                    hintText: 'Zip code',
                    controller: controller.zipCode,
                    inputFormatters: [
                      NumericInputFormatter(), // Custom formatter
                      LengthLimitingTextInputFormatter(4),
                    ],
                    keyboardType: Platform.isAndroid
                        ? TextInputType.number
                        : const TextInputType.numberWithOptions(
                            signed: true, decimal: false),
                    onChange: (value) {
                      controller.zipCode.selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.zipCode.text.length));
                      // Manually trigger validation when text is changed
                      controller.formKeyStep2.currentState?.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ZIP code is required';
                      } else if (value.length != 4) {
                        return 'ZIP code must be 4 digits';
                      } else if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                        return 'ZIP code must be numeric';
                      }
                      return null; // Valid input
                    },
                  ),
                  Container(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Stepp3 extends StatelessWidget {
  const Stepp3({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateProfileController());
    return Obx(
      () => StretchingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        child: SingleChildScrollView(
          child: Form(
            key: controller.formKeyStep3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10,
                ),
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(Get.context!).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                controller.showBottomSheet(bottomSheetQuestion(
                                    controller.getDropdownData(), (objData) {
                                  Get.back();
                                  controller.question1.value =
                                      objData["question"];
                                  controller.seq1.value = objData["secq_id"];
                                }));
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomParagraph(
                                      text: controller.question1.value,
                                      maxlines: 2,
                                      color: AppColor.headerColor,
                                    ),
                                  ),
                                  Container(width: 10),
                                  const Icon(Icons.arrow_drop_down_outlined)
                                ],
                              ),
                            ),
                            Container(height: 10),
                            CustomTextField(
                              hintText: "Answer",
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(30),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z\s]')),
                              ],
                              keyboardType: TextInputType.name,
                              controller: controller.answer1,
                              isReadOnly: controller.seq1.value == 0,
                              isObscure: controller.obscureTextAnswer1.value,
                              suffixIcon: controller.obscureTextAnswer1.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              onIconTap: () {
                                controller.onToggleShowAnswer1(
                                    !controller.obscureTextAnswer1.value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Field is required.';
                                }
                                if (value.length < 3) {
                                  return 'Minimum length is 3 characters.';
                                }
                                if (value.length > 30) {
                                  return 'Maximum length is 30 characters.';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Container(height: 20),
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(Get.context!).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                controller.showBottomSheet(bottomSheetQuestion(
                                    controller.getDropdownData(), (objData) {
                                  Get.back();
                                  controller.question2.value =
                                      objData["question"];
                                  controller.seq2.value = objData["secq_id"];
                                }));
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomParagraph(
                                      text: controller.question2.value,
                                      maxlines: 2,
                                      color: AppColor.headerColor,
                                    ),
                                  ),
                                  Container(width: 10),
                                  const Icon(Icons.arrow_drop_down_outlined)
                                ],
                              ),
                            ),
                            Container(height: 10),
                            CustomTextField(
                              hintText: "Answer",
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(30),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z\s]')),
                              ],
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.characters,
                              isReadOnly: controller.seq2.value == 0,
                              controller: controller.answer2,
                              isObscure: controller.obscureTextAnswer2.value,
                              suffixIcon: controller.obscureTextAnswer2.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              onIconTap: () {
                                controller.onToggleShowAnswer2(
                                    !controller.obscureTextAnswer2.value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Field is required.';
                                }
                                if (value.length < 3) {
                                  return 'Minimum length is 3 characters.';
                                }
                                if (value.length > 30) {
                                  return 'Maximum length is 30 characters.';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Container(height: 20),
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(Get.context!).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                await Future.delayed(
                                    Duration(milliseconds: 200));
                                controller.showBottomSheet(bottomSheetQuestion(
                                    controller.getDropdownData(), (objData) {
                                  Get.back();
                                  controller.question3.value =
                                      objData["question"];
                                  controller.seq3.value = objData["secq_id"];
                                }));
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomParagraph(
                                      text: controller.question3.value,
                                      maxlines: 2,
                                      color: AppColor.headerColor,
                                    ),
                                  ),
                                  Container(width: 10),
                                  const Icon(Icons.arrow_drop_down_outlined)
                                ],
                              ),
                            ),
                            Container(height: 10),
                            CustomTextField(
                              hintText: "Answer",
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(30),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z\s]')),
                              ],
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.characters,
                              controller: controller.answer3,
                              isReadOnly: controller.seq3.value == 0,
                              isObscure: controller.obscureTextAnswer3.value,
                              suffixIcon: controller.obscureTextAnswer3.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              onIconTap: () {
                                controller.onToggleShowAnswer3(
                                    !controller.obscureTextAnswer3.value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Field is required.';
                                }
                                if (value.length < 3) {
                                  return 'Minimum length is 3 characters.';
                                }
                                if (value.length > 30) {
                                  return 'Maximum length is 30 characters.';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Container(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomSheetQuestion(dynamic data, Function cb) {
    return Container(
      height: MediaQuery.of(Get.context!).size.height * .60,
      width: MediaQuery.of(Get.context!).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 71,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(56),
                  color: const Color(0xffd9d9d9),
                ),
              ),
            ),
            Container(height: 10),
            const CustomTitle(text: "Choose a question"),
            Container(height: 20),
            Expanded(
              child: StretchingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                child: ListView.separated(
                    padding: const EdgeInsets.all(5),
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          cb(data[index]);
                        },
                        leading: const CircleAvatar(
                          radius: 3,
                          backgroundColor: Colors.black45,
                        ),
                        title: CustomParagraph(
                          text: data[index]["question"],
                          color: Colors.black,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 5),
                    itemCount: data.length),
              ),
            )
          ],
        ),
      ),
    );
  }
}
