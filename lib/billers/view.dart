// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/billers/utils/allbillers.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';

import '../custom_widgets/custom_appbar.dart';
import '../custom_widgets/page_loader.dart';
import 'controller.dart';
import 'utils/paybill.dart';

class Billers extends StatelessWidget {
  const Billers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BillersController controller = Get.put(BillersController());

    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: CustomAppbar(
          title: "Billers",
          onTap: () {
            Get.back();
          }),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: !controller.isNetConn.value
              ? NoInternetConnected(
                  onTap: controller.loadFavoritesAndBillers,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTitle(
                          text: "Pay Bills",
                          color: AppColor.linkLabel,
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              Get.to(
                                Allbillers(),
                                arguments: {
                                  'source': 'pay',
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.payment_outlined,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 10),
                                      CustomParagraph(
                                          color: Colors.black,
                                          fontSize: 10,
                                          text: "Select Biller"),
                                    ],
                                  ),
                                  Icon(
                                    Iconsax.arrow_right_2,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10)),
                            child: InkWell(
                              onTap: () {
                                Get.to(
                                  Allbillers(),
                                  arguments: {
                                    'source': 'fav',
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColor.hintColor)),
                                    child: Icon(Icons.add,
                                        color: AppColor.hintColor),
                                  ),
                                  SizedBox(width: 10),
                                  CustomParagraph(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      text:
                                          "Save your favorite billers\nfor easier access!")
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    CustomTitle(
                      text: "Favorites",
                      color: AppColor.linkLabel,
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: controller.isLoading.value
                          ? const PageLoader()
                          : controller.favBillers.isEmpty
                              ? NoDataFound()
                              : ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount: controller.favBillers.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: ListTile(
                                          onTap: () {
                                            CustomDialog().confirmationDialog(
                                                Get.context!,
                                                controller.favBillers[index]
                                                        ["biller_name"] ??
                                                    "",
                                                "Do you want to pay bills?",
                                                "Close",
                                                "Pay Bill", () {
                                              Get.back();
                                            }, () {
                                              Map<String, dynamic> fav = {
                                                'biller_name':
                                                    controller.favBillers[index]
                                                        ["biller_name"],
                                                'biller_id':
                                                    controller.favBillers[index]
                                                        ["biller_id"],
                                                'account_no':
                                                    controller.favBillers[index]
                                                        ["account_no"],
                                                'biller_address':
                                                    controller.favBillers[index]
                                                        ["biller_address"],
                                                'service_fee':
                                                    controller.favBillers[index]
                                                        ["service_fee"],
                                                'account_name':
                                                    controller.favBillers[index]
                                                        ["account_name"],
                                                'user_biller_id':
                                                    controller.favBillers[index]
                                                        ['user_biller_id'],
                                                'source': 'favorites'
                                              };
                                              Get.back();
                                              Get.to(PayBill(), arguments: fav);
                                            });
                                          },
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomParagraph(
                                                fontSize: 12,
                                                color: AppColor.headerColor,
                                                fontWeight: FontWeight.w800,
                                                text:
                                                    controller.favBillers[index]
                                                            ['account_name'] ??
                                                        '',
                                              ),
                                              CustomParagraph(
                                                fontSize: 14,
                                                color: AppColor.mainColor,
                                                text:
                                                    controller.favBillers[index]
                                                        ["account_no"],
                                              ),
                                            ],
                                          ),
                                          subtitle: Row(
                                            children: [
                                              CustomParagraph(
                                                fontSize: 10,
                                                text:
                                                    controller.favBillers[index]
                                                            ['biller_name'] ??
                                                        '',
                                              ),
                                              SizedBox(width: 10),
                                              Visibility(
                                                visible: controller
                                                            .favBillers[index]
                                                        ["biller_address"] !=
                                                    null,
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.circle_sharp,
                                                        size: 5),
                                                    SizedBox(width: 10),
                                                    CustomParagraph(
                                                      fontSize: 10,
                                                      text:
                                                          "${controller.favBillers[index]["biller_address"]}",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: GestureDetector(
                                            onTap: () {
                                              controller.deleteFavoriteBiller(
                                                  int.parse(controller
                                                      .favBillers[index]
                                                          ['user_biller_id']
                                                      .toString()));
                                            },
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundColor:
                                                  Colors.red.withOpacity(.1),
                                              child: Icon(
                                                LucideIcons.trash,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
