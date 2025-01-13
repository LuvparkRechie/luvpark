// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/billers/utils/allbillers.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/custom_appbar.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/page_loader.dart';
import '../functions/functions.dart';
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
        () => !controller.isNetConn.value
            ? NoInternetConnected(
                onTap: controller.loadFavoritesAndBillers,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTitle(
                          text: "Pay Bills",
                          color: AppColor.linkLabel,
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Get.to(
                              Allbillers(),
                              arguments: {
                                'source': 'pay',
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 3,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Container(height: 15),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTitle(
                          text: "Favorites",
                          color: AppColor.linkLabel,
                        ),
                        IconButton(
                          onPressed: () {
                            Get.bottomSheet(isDismissible: true, CustomSort(
                              onSortSelected: (String sortOption) {
                                controller.selectedSortOption.value =
                                    sortOption;
                                controller.sortFavorites();
                                Get.back();
                              },
                            ));
                          },
                          icon: Icon(
                            Icons.sort,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: controller.isLoading.value
                        ? const PageLoader()
                        : controller.favBillers.isEmpty
                            ? NoDataFound()
                            : Container(
                                color: Colors.white,
                                child: ListView.separated(
                                  padding: EdgeInsets.fromLTRB(15, 20, 15, 5),
                                  physics: BouncingScrollPhysics(),
                                  itemCount: controller.favBillers.length,
                                  itemBuilder: (context, index) {
                                    final color = Colors.grey.shade100;
                                    return GestureDetector(
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
                                            'biller_id': controller
                                                .favBillers[index]["biller_id"],
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
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 5,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomTitle(
                                              text: controller.favBillers[index]
                                                      ['account_name'] ??
                                                  '',
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                CustomParagraph(
                                                    text: "Account Number: "),
                                                Expanded(
                                                  child: CustomParagraph(
                                                    text:
                                                        "${controller.favBillers[index]["account_no"]}",
                                                    textAlign: TextAlign.end,
                                                    maxlines: 1,
                                                    color: AppColor.headerColor,
                                                    fontSize: 13,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                CustomParagraph(
                                                    text: "Account Name: "),
                                                Expanded(
                                                  child: CustomParagraph(
                                                    text:
                                                        "${controller.favBillers[index]["biller_name"]}",
                                                    textAlign: TextAlign.end,
                                                    maxlines: 1,
                                                    color: AppColor.headerColor,
                                                    fontSize: 13,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(height: 15),
                                            Row(
                                              children: [
                                                Icon(
                                                  LucideIcons.mapPin,
                                                  size: 15,
                                                  color: AppColor.primaryColor,
                                                ),
                                                Container(width: 5),
                                                Expanded(
                                                  child: CustomParagraph(
                                                    text:
                                                        "${controller.favBillers[index]["biller_address"]}",
                                                    textAlign: TextAlign.start,
                                                    maxlines: 1,
                                                    color: AppColor.headerColor,
                                                    fontSize: 13,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );

                                    // Container(
                                    //   padding: EdgeInsets.all(10),
                                    //   decoration: BoxDecoration(
                                    //       color: Colors.grey.shade100,
                                    //       borderRadius:
                                    //           BorderRadius.circular(5)),
                                    //   child: ListTile(
                                    //     contentPadding: EdgeInsets.zero,
                                    //     onTap: () {
                                    //       CustomDialog().confirmationDialog(
                                    //           Get.context!,
                                    //           controller.favBillers[index]
                                    //                   ["biller_name"] ??
                                    //               "",
                                    //           "Do you want to pay bills?",
                                    //           "Close",
                                    //           "Pay Bill", () {
                                    //         Get.back();
                                    //       }, () {
                                    //         Map<String, dynamic> fav = {
                                    //           'biller_name':
                                    //               controller.favBillers[index]
                                    //                   ["biller_name"],
                                    //           'biller_id':
                                    //               controller.favBillers[index]
                                    //                   ["biller_id"],
                                    //           'account_no':
                                    //               controller.favBillers[index]
                                    //                   ["account_no"],
                                    //           'biller_address':
                                    //               controller.favBillers[index]
                                    //                   ["biller_address"],
                                    //           'service_fee':
                                    //               controller.favBillers[index]
                                    //                   ["service_fee"],
                                    //           'account_name':
                                    //               controller.favBillers[index]
                                    //                   ["account_name"],
                                    //           'user_biller_id':
                                    //               controller.favBillers[index]
                                    //                   ['user_biller_id'],
                                    //           'source': 'favorites'
                                    //         };
                                    //         Get.back();
                                    //         Get.to(PayBill(), arguments: fav);
                                    //       });
                                    //     },
                                    //     title: Column(
                                    //       crossAxisAlignment:
                                    //           CrossAxisAlignment.start,
                                    //       children: [
                                    //
                                    //         SizedBox(width: 5),
                                    //         Row(
                                    //           children: [
                                    //             Icon(
                                    //                 Icons
                                    //                     .account_balance_wallet_outlined,
                                    //                 size: 18,
                                    //                 color: AppColor
                                    //                     .paragraphColor),
                                    //             SizedBox(width: 5),
                                    //             Container(
                                    //               padding: EdgeInsets.all(3),
                                    //               decoration: BoxDecoration(
                                    //                 borderRadius:
                                    //                     BorderRadius.circular(
                                    //                         5),
                                    //                 color: Colors.grey.shade300,
                                    //               ),
                                    //               child: CustomParagraph(
                                    //                 fontSize: 14,
                                    //                 fontWeight: FontWeight.w800,
                                    //                 color: AppColor.mainColor,
                                    //                 text: controller
                                    //                         .favBillers[index]
                                    //                     ["account_no"],
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //       ],
                                    //     ),
                                    //     subtitle: Row(
                                    //       children: [
                                    //         Icon(Icons.credit_card,
                                    //             size: 18,
                                    //             color: AppColor.paragraphColor),
                                    //         SizedBox(width: 5),
                                    //         CustomParagraph(
                                    //           fontSize: 10,
                                    //           text: controller.favBillers[index]
                                    //                   ['biller_name'] ??
                                    //               '',
                                    //         ),
                                    //         SizedBox(width: 10),
                                    //         Visibility(
                                    //           visible:
                                    //               controller.favBillers[index]
                                    //                       ["biller_address"] !=
                                    //                   null,
                                    //           child: Row(
                                    //             children: [
                                    //               Icon(
                                    //                   Icons.location_on_rounded,
                                    //                   size: 18,
                                    //                   color: AppColor
                                    //                       .paragraphColor),
                                    //               SizedBox(width: 5),
                                    //               CustomParagraph(
                                    //                 fontSize: 10,
                                    //                 text:
                                    //                     "${controller.favBillers[index]["biller_address"]}",
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //     trailing: GestureDetector(
                                    //       onTap: () {
                                    //         controller.deleteFavoriteBiller(
                                    //             int.parse(controller
                                    //                 .favBillers[index]
                                    //                     ['user_biller_id']
                                    //                 .toString()));
                                    //       },
                                    //       child: CircleAvatar(
                                    //         radius: 15,
                                    //         backgroundColor:
                                    //             Colors.red.withOpacity(.1),
                                    //         child: Icon(
                                    //           LucideIcons.trash,
                                    //           color: Colors.red,
                                    //           size: 18,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // );
                                  },
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 5),
                                ),
                              ),
                  ),
                ],
              ),
      ),
    );
  }
}

class CustomSort extends StatefulWidget {
  final Function(String) onSortSelected;

  const CustomSort({Key? key, required this.onSortSelected}) : super(key: key);

  @override
  State<CustomSort> createState() => _CustomSortState();
}

class _CustomSortState extends State<CustomSort> {
  @override
  Widget build(BuildContext context) {
    final ct = Get.put(BillersController());

    final List<Map<String, dynamic>> sortOptions = [
      {'text': 'Account Name', 'icon': Icons.account_circle_rounded},
      {'text': 'Biller Name', 'icon': Icons.credit_card},
      {'text': 'Biller Address', 'icon': Icons.location_on},
    ];

    return Wrap(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            color: Colors.white,
          ),
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomTitle(
                    text: "Sort by ",
                    fontWeight: FontWeight.w600,
                  ),
                  CustomTitle(
                    text: "${ct.selectedSortOption}",
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  CustomParagraph(
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w600,
                    text: ct.isAscending.value ? "(A-Z)" : "(Z-A)",
                  ),
                ],
              ),
              Divider(
                color: AppColor.linkLabel,
              ),
              for (var option in sortOptions)
                InkWell(
                  onTap: () {
                    widget.onSortSelected(option['text']);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(7)),
                      child: Row(
                        children: [
                          Icon(option['icon'],
                              size: 25, color: AppColor.primaryColor),
                          SizedBox(width: 10),
                          Expanded(
                              child: CustomParagraph(text: option['text'])),
                          Icon(
                            Icons.chevron_right,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              CustomButton(
                text: 'Close',
                onPressed: () {
                  Functions.popPage(1);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
