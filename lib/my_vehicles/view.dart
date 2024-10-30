import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/no_data_found.dart';
import 'package:luvpark_get/custom_widgets/no_internet.dart';
import 'package:luvpark_get/custom_widgets/page_loader.dart';

import '../custom_widgets/custom_text.dart';
import 'controller.dart';

class MyVehicles extends GetView<MyVehiclesController> {
  const MyVehicles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: CustomAppbar(
        title: "My Vehicles",
        bgColor: AppColor.primaryColor,
        textColor: Colors.white,
        titleColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Iconsax.add,
            color: Colors.white,
          ),
          onPressed: () async {
            controller.getVehicleDropDown();
          }),
      body: Obx(
        () => controller.isLoadingPage.value
            ? const PageLoader()
            : !controller.isNetConn.value
                ? NoInternetConnected(
                    onTap: controller.onRefresh,
                  )
                : Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: RefreshIndicator(
                      onRefresh: controller.onRefresh,
                      child: controller.vehicleData.isEmpty
                          ? const NoDataFound()
                          : StretchingOverscrollIndicator(
                              axisDirection: AxisDirection.down,
                              child: ScrollConfiguration(
                                behavior: ScrollBehavior()
                                    .copyWith(overscroll: false),
                                child: ListView.builder(
                                  itemCount: controller.vehicleData.length,
                                  itemBuilder: (context, index) {
                                    print(
                                        "inataya ${controller.vehicleData[index]["image"].isEmpty}");
                                    String removeInvalidCharacters(
                                        String input) {
                                      final RegExp validChars =
                                          RegExp(r'[^A-Za-z0-9+/=]');

                                      return input.replaceAll(validChars, '');
                                    }

                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: ListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            CustomTitle(
                                              text:
                                                  controller.vehicleData[index]
                                                      ["vehicle_brand_name"],
                                              maxlines: 1,
                                            ),
                                          ],
                                        ),
                                        subtitle: CustomParagraph(
                                            minFontSize: 10,
                                            text:
                                                'Plate number: ${controller.vehicleData[index]["vehicle_plate_no"]}',
                                            maxlines: 1),
                                        leading: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              fit: BoxFit.contain,
                                              image: controller.vehicleData[
                                                              index]["image"] ==
                                                          null ||
                                                      controller
                                                          .vehicleData[index]
                                                              ["image"]
                                                          .isEmpty
                                                  ? AssetImage(
                                                          "assets/images/no_image.png")
                                                      as ImageProvider
                                                  : MemoryImage(
                                                      base64Decode(
                                                        removeInvalidCharacters(
                                                            controller
                                                                    .vehicleData[
                                                                index]["image"]),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        trailing: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFF9D9D9),
                                          ),
                                          padding: const EdgeInsets.all(5.0),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Color(0xFFD34949),
                                            size: 15.0,
                                          ),
                                        ),
                                        onTap: () {
                                          controller.onDeleteVehicle(
                                              controller.vehicleData[index]
                                                  ["vehicle_plate_no"]);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ),
                  ),
      ),
    );
  }
}
