import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/parking_areas/controller.dart';
import 'package:luvpark_get/routes/routes.dart';

import '../custom_widgets/showup_animation.dart';

class ParkingAreas extends GetView<ParkingAreasController> {
  const ParkingAreas({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.primaryColor, // Set status bar color
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));
    Get.put(ParkingAreasController());
    final ParkingAreasController ct = Get.put(ParkingAreasController());

    return Scaffold(
      appBar: const CustomAppbar(
        title: "Parking Areas",
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 20),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color(0xFFFBFBFB),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0x232563EB)),
                  borderRadius: BorderRadius.circular(54),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/dashboard_icon/search.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: "Search parking zone/address",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(left: 10),
                          hintStyle:
                              paragraphStyle(fontWeight: FontWeight.w600),
                        ),
                        style: paragraphStyle(),
                        onChanged: (String value) async {
                          ct.onSearch(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 20),
            const CustomParagraph(
              text: "Nearest Parking",
              fontWeight: FontWeight.w700,
            ),
            Container(height: 10),
            Obx(
              () => Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    //   color: AppColor.bodyColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(7),
                    ),
                  ),
                  child: StretchingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 2);
                      },
                      itemCount: ct.searchedZone.length,
                      itemBuilder: (context, index) {
                        String getDistanceString() {
                          double kmDist = Variables.convertToMeters(
                              ct.searchedZone[index]["distance"].toString());
                          if (kmDist >= 1000) {
                            double distanceInKilometers = kmDist / 1000;
                            return '${distanceInKilometers.round()} km';
                          } else {
                            return '${kmDist.round()} m';
                          }
                        }

                        final String isPwd =
                            ct.searchedZone[index]["is_pwd"] ?? "N";
                        final String vehicleTypes =
                            ct.searchedZone[index]["vehicle_types_list"];

                        String iconAsset;
                        // Determine the iconAsset based on parking type and PWD status
                        if (isPwd == "Y") {
                          iconAsset = controller.getIconAssetForPwd(
                              ct.searchedZone[index]["parking_type_code"],
                              vehicleTypes);
                        } else {
                          iconAsset = controller.getIconAssetForNonPwd(
                              ct.searchedZone[index]["parking_type_code"],
                              vehicleTypes);
                        }

                        return ShowUpAnimation(
                          delay: 5 * index,
                          child: InkWell(
                            onTap: () {
                              Get.toNamed(Routes.parkingDetails,
                                  arguments: ct.searchedZone[index]);
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 15, 15, 15),
                              width: MediaQuery.of(context).size.width * .88,
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                  color: Colors.grey.shade200,
                                )),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 40,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(),
                                    child: Image(
                                      image: AssetImage(iconAsset),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomTitle(
                                          text: ct.searchedZone[index]
                                              ["park_area_name"],
                                          fontSize: 16,
                                          maxlines: 1,
                                        ),
                                        CustomParagraph(
                                          text: ct.searchedZone[index]
                                              ["address"],
                                          fontSize: 14,
                                          maxlines: 2,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        // Container(height: 10),
                                        // RichText(
                                        //   text: TextSpan(
                                        //     children: [
                                        //       TextSpan(
                                        //         text:
                                        //             "${ct.searchedZone[index]["parking_schedule"]}  ●  ",
                                        //         style: paragraphStyle(
                                        //             fontSize: 12),
                                        //       ),
                                        //       TextSpan(
                                        //         text: isOpen ? "OPEN" : "CLOSE",
                                        //         style: paragraphStyle(
                                        //           fontSize: 12,
                                        //           color: isOpen
                                        //               ? Colors.green
                                        //               : Colors.red,
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  Container(width: 10),
                                  CustomLinkLabel(text: getDistanceString())
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
