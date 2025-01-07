// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/billers/utils/paybill.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';

import '../controller.dart';

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
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: SearchBar(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.only(left: 15),
                    ),
                    elevation: MaterialStateProperty.all(.2),
                    controller: searchController,
                    side: MaterialStateProperty.all(
                      BorderSide(
                        color: Color(0x232563EB), // Border color
                        width: 1.0, // Border width
                      ),
                    ),
                    trailing: [
                      Visibility(
                        visible: searchController.text.isNotEmpty,
                        child: IconButton(
                            onPressed: () {
                              searchController.clear();
                              controller.filterBillers('');
                            },
                            icon: Icon(
                              LucideIcons.xCircle,
                              color: AppColor.paragraphColor,
                            )),
                      )
                    ],
                    leading: Icon(
                      LucideIcons.search,
                      color: AppColor.primaryColor,
                    ),
                    hintStyle: MaterialStateProperty.resolveWith<TextStyle?>(
                        (Set<MaterialState> states) {
                      return paragraphStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColor.hintColor);
                    }),
                    hintText: "Search billers",
                    onChanged: (value) {
                      controller.filterBillers(value);
                    },
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
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10)),
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
                                    };
                                    Get.to(
                                      arguments: billerData,
                                      const PayBill(),
                                    );
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
