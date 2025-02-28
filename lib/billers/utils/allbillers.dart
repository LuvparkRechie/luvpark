// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/billers/utils/add_favorites.dart';
import 'package:luvpark/billers/utils/templ.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../custom_widgets/alert_dialog.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../http/thirdparty.dart';
import '../controller.dart';

class Allbillers extends GetView<BillersController> {
  Allbillers({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final dataArgs = Get.arguments;

    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: AppColor.primaryColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColor.primaryColor,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
          title: Text("Biller List"),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Get.back();
              controller.filterBillers('');
              searchController.clear();
            },
            child: Icon(
              Iconsax.arrow_left,
              color: Colors.white,
            ),
          ),
        ),
        body: Obx(
          () => Container(
            color: AppColor.bodyColor,
            width: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: SizedBox(
                    height: 54,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                            offset: Offset(0, 0),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(
                            54), // Match TextField border radius
                      ),
                      child: TextField(
                        autofocus: false,
                        style: paragraphStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1, // Ensures single line input
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          hintText: "Search billers",
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(54),
                            borderSide:
                                BorderSide(color: AppColor.primaryColor),
                          ),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(54),
                            borderSide:
                                BorderSide(width: 1, color: Color(0xFFCECECE)),
                          ),
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 15),
                              Icon(LucideIcons.search),
                              Container(width: 10),
                            ],
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: searchController.text.isNotEmpty,
                                child: InkWell(
                                  onTap: () {
                                    searchController.clear();
                                    controller.filterBillers('');
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade300),
                                    child: Icon(
                                      LucideIcons.x,
                                      color: AppColor.headerColor,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          hintStyle: paragraphStyle(
                            color: Color(0xFF646263),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          labelStyle: paragraphStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColor.hintColor,
                          ),
                        ),
                        onChanged: (value) {
                          controller.filterBillers(value);
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: controller.filteredBillers.isEmpty
                      ? NoDataFound(
                          text: "No Billers found",
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.filteredBillers.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 3,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  onTap: () async {
                                    controller.filterBillers('');
                                    searchController.clear();
                                    Map<String, dynamic> billerData = {
                                      'biller_name':
                                          controller.filteredBillers[index]
                                              ["biller_name"],
                                      'biller_id': controller
                                          .filteredBillers[index]["biller_id"],
                                      'biller_code':
                                          controller.filteredBillers[index]
                                              ["bi)ller_code"],
                                      'biller_address':
                                          controller.filteredBillers[index]
                                              ["biller_address"],
                                      'service_fee':
                                          controller.filteredBillers[index]
                                              ["service_fee"],
                                      'posting_period_desc':
                                          controller.filteredBillers[index]
                                              ["posting_period_desc"],
                                      'source': Get.arguments["source"],
                                      'full_url': controller
                                          .filteredBillers[index]["full_url"],
                                    };
                                    if (dataArgs["source"] == "fav") {
                                      Get.to(AddFavoritesWidget(),
                                          transition: Transition.rightToLeft,
                                          duration: Duration(milliseconds: 200),
                                          arguments: billerData);
                                    } else {
                                      controller.getTemplate(billerData);
                                    }
                                  },
                                  title: CustomParagraph(
                                    fontSize: 12,
                                    color: AppColor.headerColor,
                                    fontWeight: FontWeight.w500,
                                    text: controller.filteredBillers[index]
                                            ['biller_name'] ??
                                        'Unknown',
                                  ),
                                  subtitle: CustomParagraph(
                                    fontSize: 10,
                                    text: controller.filteredBillers[index]
                                            ["biller_address"] ??
                                        '',
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ));
  }
}

class ValidateAccount extends StatefulWidget {
  final dynamic billerData;
  const ValidateAccount({
    super.key,
    this.billerData,
  });

  @override
  State<ValidateAccount> createState() => _ValidateAccountState();
}

class _ValidateAccountState extends State<ValidateAccount> {
  Map<String, TextEditingController> controllers2 = {};
  final _formKey = GlobalKey<FormState>();
  List tempData = [];
  final Map<String, RegExp> _filter = {
    'A': RegExp(r'[A-Za-z0-9]'),
    '0': RegExp(r'[0-9]'),
    'N': RegExp(r'[0-9]'),
  };

  @override
  void initState() {
    super.initState();
    initializedData();
  }

  Future<void> _selectDate(BuildContext context, String key) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controllers2[key]!.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void initializedData() async {
    List fieldData = widget.billerData["field"];
    setState(() {
      controllers2.clear();
      tempData = fieldData
          .where((element) => element["is_validation"] == "Y")
          .toList();
    });

    for (var field in tempData) {
      String key = field['key'];
      String value = widget.billerData["details"][key]?.toString() ?? '';
      controllers2[key] = TextEditingController(text: value);
    }

    setState(() {});
  }

  void _verifyAccount() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> formData = {};
      for (var field in tempData) {
        formData[field['key']] = controllers2[field['key']]!.text;
      }

      String paramUrl = widget.billerData["details"]["full_url"];

      Map<String, dynamic> validateParam = {};
      for (var field in tempData) {
        String key = field["key"];
        if (formData.containsKey(key)) {
          field["value"] = formData[key];
        }
      }

      for (var field in tempData) {
        String key = field["key"];
        String value = field["value"];
        validateParam[key] = value;
      }

      Uri fullUri = Uri.parse(paramUrl).replace(queryParameters: validateParam);
      String fullUrl = fullUri.toString();

      CustomDialog().loadingDialog(Get.context!);
      final inatay = await Http3rdPartyRequest(url: fullUrl).getBiller();
      Get.back();

      if (inatay == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });
      } else if (inatay["result"] == "true") {
        Get.back();
        Get.to(arguments: {
          "details": widget.billerData["details"],
          "field": widget.billerData["field"],
          "user_details": inatay["data"]
        }, const Templ());
      } else if (inatay == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
      } else {
        CustomDialog().infoDialog("Invalid request",
            "Please provide the required information or ensure the data entered is valid.",
            () {
          Get.back();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(7),
        ),
        color: Colors.white,
      ),
      child: tempData.isEmpty
          ? PageLoader()
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 40),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTitle(
                          text: "Account Verification",
                          fontSize: 20,
                        ),
                        Container(height: 5),
                        CustomParagraph(
                          text: "Ensure your account information is accurate.",
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(15, 30, 15, 10),
                      itemCount: tempData.length,
                      itemBuilder: (context, i) {
                        final field = tempData[i];

                        List<TextInputFormatter> inputFormatters = [];
                        if (field['input_formatter'] != null &&
                            field['input_formatter'].isNotEmpty) {
                          String mask = field['input_formatter'];
                          inputFormatters = [
                            MaskTextInputFormatter(mask: mask, filter: _filter)
                          ];
                        }

                        if (field['type'] == 'date') {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTitle(fontSize: 14, text: field['label']),
                                CustomTextField(
                                  controller: controllers2[field['key']]!,
                                  isReadOnly: true,
                                  isFilled: false,
                                  suffixIcon: Icons.calendar_today,
                                  onTap: () =>
                                      _selectDate(context, field['key']),
                                  validator: (value) {
                                    if (field['required'] &&
                                        (value == null || value.isEmpty)) {
                                      return '${field['label']} is required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          );
                        } else if (field['type'] == 'number') {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTitle(fontSize: 14, text: field['label']),
                                CustomTextField(
                                  controller: controllers2[field['key']]!,
                                  maxLength: field['maxLength'],
                                  keyboardType: TextInputType.number,
                                  hintText: "Enter ${field['label']}",
                                  inputFormatters: inputFormatters,
                                  validator: (value) {
                                    if (field['required'] &&
                                        (value == null || value.isEmpty)) {
                                      return '${field['label']} is required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTitle(fontSize: 14, text: field['label']),
                                CustomTextField(
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  controller: controllers2[field['key']]!,
                                  maxLength: field['maxLength'],
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (field['required'] &&
                                        (value == null || value.isEmpty)) {
                                      return '${field['label']} is required';
                                    }
                                    return null;
                                  },
                                  inputFormatters: inputFormatters,
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Visibility(
                      visible: MediaQuery.of(context).viewInsets.bottom == 0,
                      child: CustomButton(
                          text: "Proceed",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _verifyAccount();
                            }
                          }),
                    ),
                  ),
                  Container(height: 30),
                ],
              ),
            ),
    );
  }
}

class AutoDecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // Remove non-numeric characters
    final numericValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Format as decimal (e.g., "123" -> "1.23")
    final value = double.tryParse(numericValue) ?? 0.0;
    final formattedValue = (value / 100).toStringAsFixed(2);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
