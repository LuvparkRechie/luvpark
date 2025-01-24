// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/billers/utils/paybill.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';

import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_textfield.dart';
import '../../functions/functions.dart';
import '../controller.dart';
import 'templ.dart';

class Allbillers extends GetView<BillersController> {
  Allbillers({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    return Scaffold(
        appBar: CustomAppbar(
          onTap: () {
            Get.back();
            controller.filterBillers('');
            searchController.clear();
          },
          title: "Biller List",
        ),
        body: Obx(
          () => Container(
            color: AppColor.bodyColor,
            width: double.infinity,
            child: Column(
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(15),
                //   child: SearchBar(
                //     padding: MaterialStateProperty.all(
                //       EdgeInsets.only(left: 15),
                //     ),
                //     elevation: MaterialStateProperty.all(.2),
                //     controller: searchController,
                //     side: MaterialStateProperty.all(
                //       BorderSide(
                //         color: Color(0x232563EB), // Border color
                //         width: 1.0, // Border width
                //       ),
                //     ),
                //     trailing: [
                //       Visibility(
                //         visible: searchController.text.isNotEmpty,
                //         child: IconButton(
                //             onPressed: () {
                //               searchController.clear();
                //               controller.filterBillers('');
                //             },
                //             icon: Icon(
                //               LucideIcons.xCircle,
                //               color: AppColor.paragraphColor,
                //             )),
                //       )
                //     ],
                //     leading: Icon(
                //       LucideIcons.search,
                //       color: AppColor.primaryColor,
                //     ),
                //     hintStyle: MaterialStateProperty.resolveWith<TextStyle?>(
                //         (Set<MaterialState> states) {
                //       return paragraphStyle(
                //           fontWeight: FontWeight.w500,
                //           color: AppColor.hintColor);
                //     }),
                //     hintText: "Search billers",
                //     onChanged: (value) {
                //       controller.filterBillers(value);
                //     },
                //   ),
                // ),
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
                                    controller.getTemplate(billerData);
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
  const ValidateAccount({
    super.key,
  });

  @override
  State<ValidateAccount> createState() => _ValidateAccountState();
}

class _ValidateAccountState extends State<ValidateAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(7),
        ),
        color: Colors.white,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 20),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.iconBgColor),
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Iconsax.bill,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        Container(width: 10),
                        CustomTitle(
                          text: "GCC hydra",
                          fontSize: 18,
                        )
                      ],
                    ),
                    Container(height: 15),
                    CustomParagraph(
                      text: "Bacolod city",
                    ),
                    Container(height: 20),
                    CustomParagraph(
                      text: "Amount",
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    CustomTextField(
                      hintText: "Enter payment amount",
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      controller: amountController,
                      inputFormatters: [AutoDecimalInputFormatter()],
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: MediaQuery.of(context).viewInsets.bottom == 0,
              child: CustomButton(text: "Proceed", onPressed: () {}),
            ),
            Container(height: 20),
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
