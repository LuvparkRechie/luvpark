// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/billers/utils/allbillers.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/page_loader.dart';
import '../functions/functions.dart';
import 'controller.dart';
import 'tabContainer.dart';

class Billers extends StatelessWidget {
  const Billers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BillersController controller = Get.put(BillersController());
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.bodyColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("Billers"),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Iconsax.arrow_left,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(
        () => !controller.isNetConn.value
            ? NoInternetConnected(
                onTap: controller.loadFavoritesAndBillers,
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await controller.loadFavoritesAndBillers();
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                  child: Column(
                    children: [
                      TabContainer(
                        tabEdge: TabEdge.top,
                        tabMaxLength: MediaQuery.of(context).size.width / 2.5,
                        borderRadius: BorderRadius.circular(30),
                        tabBorderRadius: BorderRadius.circular(30),
                        childPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                        colors: [Colors.white],
                        tabs: [
                          CustomTitle(
                            text: "Pay Bills",
                            color: AppColor.linkLabel,
                          ),
                        ],
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          controller.getBillers((isSuccess) {
                                            if (isSuccess) {
                                              Get.to(
                                                Allbillers(),
                                                arguments: {
                                                  'source': 'pay',
                                                },
                                              );
                                            }
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.payment_outlined,
                                              color: AppColor.primaryColor,
                                            ),
                                            SizedBox(height: 10),
                                            CustomParagraph(
                                              color: Colors.black,
                                              fontSize: 10,
                                              text: "Select Biller",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      controller.getBillers((isSuccess) {
                                        if (isSuccess) {
                                          Get.to(
                                            Allbillers(),
                                            arguments: {
                                              'source': 'fav',
                                            },
                                          );
                                        }
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Icon(Icons.add_circle_outline,
                                            color: AppColor.primaryColor),
                                        SizedBox(height: 10),
                                        CustomParagraph(
                                            color: Colors.black,
                                            fontSize: 10,
                                            text: "Add Favorite Biller"),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 15),
                      Expanded(
                        child: Stack(
                          alignment: AlignmentDirectional.topEnd,
                          children: [
                            TabContainer(
                              tabEdge: TabEdge.top,
                              tabMaxLength:
                                  MediaQuery.of(context).size.width / 2.5,
                              borderRadius: BorderRadius.circular(30),
                              tabBorderRadius: BorderRadius.circular(30),
                              childPadding:
                                  const EdgeInsets.fromLTRB(15, 0, 15, 15),
                              colors: [
                                Colors.white,
                              ],
                              tabs: [
                                CustomTitle(
                                  text: "Favorites",
                                  color: AppColor.linkLabel,
                                ),
                              ],
                              children: [
                                controller.isLoading.value
                                    ? const PageLoader()
                                    : controller.favBillers.isEmpty
                                        ? NoDataFound()
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: AppColor.scafColor,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  )),
                                              child: ListView.separated(
                                                shrinkWrap: true,
                                                physics:
                                                    BouncingScrollPhysics(),
                                                itemCount: controller
                                                    .favBillers.length,
                                                itemBuilder: (context, index) {
                                                  String accountNo =
                                                      "${controller.favBillers[index]["account_no"]}";

                                                  String maskedAccountNo =
                                                      accountNo.length <= 3
                                                          ? accountNo
                                                          : accountNo.replaceAll(
                                                              RegExp(
                                                                  r'.(?=.{3})'),
                                                              '*');

                                                  return GestureDetector(
                                                    onTap: () {
                                                      Map<String, String>
                                                          billerData = {
                                                        'biller_name': controller
                                                            .favBillers[index]
                                                                ["account_name"]
                                                            .toString(),
                                                        'biller_id': controller
                                                            .favBillers[index]
                                                                ["biller_id"]
                                                            .toString(),
                                                        'biller_code': controller
                                                            .favBillers[index]
                                                                ["biller_code"]
                                                            .toString(),
                                                        'biller_address': controller
                                                            .favBillers[index][
                                                                "biller_address"]
                                                            .toString(),
                                                        'service_fee': controller
                                                            .favBillers[index]
                                                                ["service_fee"]
                                                            .toString(),
                                                        'accountno': controller
                                                            .favBillers[index]
                                                                ["account_no"]
                                                            .toString(),
                                                        'full_url': controller
                                                            .favBillers[index]
                                                                ["full_url"]
                                                            .toString(),
                                                      };

                                                      controller.getTemplate(
                                                          billerData);
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 10),
                                                      padding:
                                                          EdgeInsets.all(15),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey.shade100),
                                                        color:
                                                            Colors.transparent,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  30),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  30),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10),
                                                        ),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SingleChildScrollView(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                CustomParagraph(
                                                                  fontSize: 14,
                                                                  color: AppColor
                                                                      .headerColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  minFontSize:
                                                                      10,
                                                                  text:
                                                                      "${controller.favBillers[index]["biller_name"]}",
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(height: 5),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                LucideIcons
                                                                    .mapPin,
                                                                size: 15,
                                                                color: AppColor
                                                                    .subtitleColor,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    CustomParagraph(
                                                                  fontSize: 10,
                                                                  text:
                                                                      "${controller.favBillers[index]["biller_address"]}",
                                                                  maxlines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          SizedBox(height: 5),
                                                          Visibility(
                                                            visible: controller
                                                                            .favBillers[
                                                                        index][
                                                                    'account_name'] !=
                                                                null,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                CustomParagraph(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  text: controller
                                                                              .favBillers[index]
                                                                          [
                                                                          'account_name'] ??
                                                                      '',
                                                                  maxlines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                SizedBox(
                                                                    height: 5),
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              CustomParagraph(
                                                                color: AppColor
                                                                    .linkLabel,
                                                                fontSize: 14,
                                                                text:
                                                                    maskedAccountNo,
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                maxlines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  controller.deleteFavoriteBiller(int.parse(controller
                                                                      .favBillers[
                                                                          index]
                                                                          [
                                                                          'user_biller_id']
                                                                      .toString()));
                                                                },
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              2,
                                                                          horizontal:
                                                                              5),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .red
                                                                        .shade300,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        size:
                                                                            16,
                                                                        Iconsax
                                                                            .close_circle,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      CustomParagraph(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            12,
                                                                        text:
                                                                            "delete",
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        maxlines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                separatorBuilder:
                                                    (context, index) =>
                                                        SizedBox(height: 5),
                                              ),
                                            ),
                                          ),
                              ],
                            ),
                            Container(
                              width: 150,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(30),
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(5),
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Get.bottomSheet(isDismissible: true,
                                      CustomSort(
                                    onSortSelected: (String sortOption) {
                                      controller.selectedSortOption.value =
                                          sortOption;
                                      controller.sortFavorites();
                                      Get.back();
                                    },
                                  ));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomParagraph(
                                      color: AppColor.primaryColor,
                                      fontSize: 10,
                                      text: "Sort",
                                      textAlign: TextAlign.end,
                                      maxlines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.sort,
                                      color: AppColor.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
      {'text': 'Nickname', 'icon': Icons.account_circle_rounded},
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
