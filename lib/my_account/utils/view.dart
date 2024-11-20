import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(overscroll: false),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 10),
                        InkWell(
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            if (controller.currentPage.value == 0) {
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
                              return;
                            } else {
                              controller.pageController.previousPage(
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.easeInOut,
                              );
                            }
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
                          controller.currentPage.value == 0
                              ? "Personal Information"
                              : controller.currentPage.value == 1
                                  ? "Address"
                                  : "Security Question",
                          style: GoogleFonts.openSans(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: AppColor.headerColor,
                          ),
                        ),
                        Container(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: controller.currentPage.value == 0
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
                                  color: controller.currentPage.value == 1
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
                                  color: controller.currentPage.value == 2
                                      ? AppColor.primaryColor
                                      : Colors.grey.shade300,
                                ),
                                height: 5,
                              ),
                            ),
                          ],
                        ),
                        Container(height: 20),
                        Expanded(
                            child: PageView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: controller.pageController,
                          onPageChanged: (value) {
                            controller.onPageChanged(value);
                          },
                          children: [step1(), step2(), step3()],
                        )),
                        if (MediaQuery.of(context).viewInsets.bottom == 0)
                          CustomButton(
                            text: controller.currentPage.value == 2
                                ? "Submit"
                                : "Next",
                            onPressed: () {
                              controller.onNextPage();
                            },
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

  Widget step1() {
    return StretchingOverscrollIndicator(
      axisDirection: AxisDirection.down,
      child: SingleChildScrollView(
        child: Form(
          key: controller.formKeyStep1,
          autovalidateMode: AutovalidateMode
              .onUserInteraction, // Validate on user interaction
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                labelText: "First Name",
                title: "First Name",
                controller: controller.firstName,
                onChange: (value) {
                  String trimmedValue = value.replaceFirst(RegExp(r'^\s+'), '');
                  validateText(value, controller.firstName);
                  if (trimmedValue.isNotEmpty) {
                    controller.firstName.value = TextEditingValue(
                      text: Variables.capitalizeAllWord(trimmedValue),
                      selection: controller.firstName.selection,
                    );
                  } else {
                    controller.firstName.value = TextEditingValue(
                      text: "",
                      selection: TextSelection.collapsed(offset: 0),
                    );
                  }
                  // Manually trigger validation when text is changed
                  controller.formKeyStep1.currentState?.validate();
                },
                inputFormatters: [
                  SimpleNameFormatter(),
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
              CustomTextField(
                labelText: "Middle Name",
                title: "Middle Name",
                controller: controller.middleName,
                inputFormatters: [
                  SimpleNameFormatter(),
                ],
                onChange: (inputText) {
                  validateText(inputText, controller.middleName);
                  // Manually trigger validation when text is changed
                  controller.formKeyStep1.currentState?.validate();
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
              CustomTextField(
                labelText: "Last Name",
                title: "Last Name",
                controller: controller.lastName,
                onChange: (value) {
                  String trimmedValue = value.replaceFirst(RegExp(r'^\s+'), '');
                  validateText(value, controller.lastName);
                  if (trimmedValue.isNotEmpty) {
                    controller.lastName.value = TextEditingValue(
                      text: Variables.capitalizeAllWord(trimmedValue),
                      selection: controller.lastName.selection,
                    );
                  } else {
                    controller.lastName.value = TextEditingValue(
                      text: "",
                      selection: TextSelection.collapsed(offset: 0),
                    );
                  }
                  // Manually trigger validation when text is changed
                  controller.formKeyStep1.currentState?.validate();
                },
                inputFormatters: [
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
              CustomTextField(
                labelText: "Email",
                title: "Email",
                controller: controller.email,
                onChange: (value) {
                  String trimmedValue = value.replaceFirst(RegExp(r'^\s+'), '');
                  if (trimmedValue.isNotEmpty) {
                    // Do something here
                  } else {
                    controller.email.value = TextEditingValue(
                      text: "",
                      selection: TextSelection.collapsed(offset: 0),
                    );
                  }
                  // Manually trigger validation when text is changed
                  controller.formKeyStep1.currentState?.validate();
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
              CustomTextField(
                labelText: "YYYY-MM-DD",
                title: "Birthday",
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
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                child: customDropdown(
                  labelText: "Civil status",
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
                  Container(width: 10),
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
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget step2() {
    return StretchingOverscrollIndicator(
      axisDirection: AxisDirection.down,
      child: SingleChildScrollView(
        child: Form(
          key: controller.formKeyStep2,
          autovalidateMode: AutovalidateMode
              .onUserInteraction, // Validate on user interaction
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                child: customDropdown(
                  labelText: "Region",
                  isDisabled: false,
                  items: controller.regionData,
                  selectedValue: controller.selectedRegion.value,
                  onChanged: (String? newValue) {
                    controller.selectedRegion.value = newValue.toString();
                    controller.getProvinceData(newValue);
                    // Manually trigger validation when the dropdown is changed
                    controller.formKeyStep2.currentState?.validate();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Region is required";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                child: customDropdown(
                  labelText: "Province",
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
                    controller.formKeyStep2.currentState?.validate();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                child: customDropdown(
                  labelText: "City",
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
                    controller.formKeyStep2.currentState?.validate();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                child: customDropdown(
                  labelText: "Barangay",
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
                    controller.formKeyStep2.currentState?.validate();
                  },
                ),
              ),
              CustomTextField(
                labelText: 'Zip Code',
                controller: controller.zipCode,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]*$')),
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
    );
  }

  Widget step3() {
    return StretchingOverscrollIndicator(
      axisDirection: AxisDirection.down,
      child: SingleChildScrollView(
        child: Form(
          key: controller.formKeyStep3,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            labelText: "Answer",
                            textCapitalization: TextCapitalization.characters,
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
                            labelText: "Answer",
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
                            labelText: "Answer",
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
    );
  }

  Widget bottomSheetQuestion(dynamic data, Function cb) {
    return Wrap(
      children: [
        Container(
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
        ),
      ],
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

    if (regex.hasMatch(newValue.text) &&
        spaceCount <= 1 &&
        periodCount <= 1 &&
        hyphenCount <= 1 &&
        !hasDisallowedCombination) {
      return newValue;
    }
    return oldValue;
  }
}
