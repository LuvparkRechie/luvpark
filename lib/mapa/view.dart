//mapa
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_body.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/no_internet.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/drawer/view.dart';
import 'package:luvpark_get/functions/functions.dart';
import 'package:luvpark_get/mapa/utils/legend/legend_dialog.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:luvpark_get/voice_search/view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'controller.dart';

class DashboardMapScreen extends GetView<DashboardMapController> {
  const DashboardMapScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(DashboardMapController());

    return Obx(() {
      if (!controller.netConnected.value) {
        return const CustomScaffold(children: NoInternetConnected());
      } else if (controller.isLoading.value) {
        return const PopScope(
          canPop: false,
          child: CustomScaffold(
            children: Center(
              child: SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      } else {
        if (double.parse(controller.userBal[0]["amount_bal"].toString()) >=
            double.parse(controller.userBal[0]["min_wallet_bal"].toString())) {
          if (controller.isLoadingMap.value) {
            return CustomScaffold(
                canPop: false,
                children: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                          width: 100,
                          height: 100,
                          image: AssetImage("assets/images/logo.png")),
                      FadeIn(
                        delay: const Duration(milliseconds: 400),
                        child: Shimmer.fromColors(
                          baseColor: Colors.black,
                          highlightColor: Colors.grey[100]!,
                          child: const CustomParagraph(
                              text: 'Getting nearest parking area for you.'),
                        ),
                      ),
                    ],
                  ),
                ));
          } else {
            return PopScope(
              canPop: false,
              child: Scaffold(
                extendBodyBehindAppBar: true,
                key: controller.dashboardScaffoldKey,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  toolbarHeight: 0,
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarBrightness: Brightness.light,
                    statusBarIconBrightness: Brightness.dark,
                  ),
                ),
                drawer: const CustomDrawer(),
                body: Column(
                  children: [
                    Expanded(child: accessMaps(context)),
                    Visibility(
                      visible: controller.isGetNearData.value,
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 100),
                        child: SlidingUpPanel(
                          maxHeight: MediaQuery.of(Get.context!)
                                      .viewInsets
                                      .bottom !=
                                  0
                              ? controller.suggestions.isEmpty
                                  ? (MediaQuery.of(Get.context!)
                                          .viewInsets
                                          .bottom +
                                      20)
                                  : (MediaQuery.of(context).size.height * .70 -
                                      MediaQuery.of(Get.context!)
                                          .viewInsets
                                          .bottom)
                              : controller.suggestions.isEmpty
                                  ? controller.minHeight.value
                                  : MediaQuery.of(context).size.height * .70,
                          minHeight: controller.minHeight.value,
                          parallaxEnabled: true,
                          parallaxOffset: .3,
                          controller: controller.panelController,
                          color: Colors.white,
                          header: Container(
                            key: controller.headerKey,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(7)),
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Builder(
                              builder: (context) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  final RenderBox renderBox = controller
                                      .headerKey.currentContext!
                                      .findRenderObject() as RenderBox;
                                  final double height = renderBox.size.height;
                                  if (controller.headerHeight.value != height) {
                                    controller.headerHeight.value = height;
                                    controller.minHeight.value =
                                        controller.headerHeight.value;
                                  }
                                });
                                return _panel();
                              },
                            ),
                          ),
                          panel: Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(7)),
                              color: Colors.white,
                            ),
                            child: _panelContent(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          return PopScope(
              canPop: false,
              child: CustomScaffold(children: accessList(context)));
        }
      }
    });
  }

  Widget _panelContent() {
    return StretchingOverscrollIndicator(
      axisDirection: AxisDirection.down,
      child: ListView.builder(
          padding: EdgeInsets.fromLTRB(15, controller.minHeight.value, 15, 5),
          itemCount: controller.suggestions.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                    onTap: () async {
                      FocusManager.instance.primaryFocus!.unfocus();
                      await Functions.searchPlaces(context,
                          controller.suggestions[index].split("=Rechie=")[0],
                          (searchedPlace) {
                        if (searchedPlace.isEmpty) {
                          return;
                        } else {
                          controller.searchCoordinates =
                              LatLng(searchedPlace[0], searchedPlace[1]);
                          controller.getUserData(true);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          const Image(
                            image:
                                AssetImage("assets/dashboard_icon/parking.png"),
                            width: 34,
                            height: 34,
                          ),
                          Container(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTitle(
                                  text: controller.suggestions[index]
                                          .split("=structured=")[1]
                                          .contains(",")
                                      ? controller.suggestions[index]
                                          .split("=structured=")[1]
                                          .split(",")[0]
                                      : controller.suggestions[index]
                                          .split("=structured=")[1],
                                  maxlines: 1,
                                  fontSize: 16,
                                ),
                                CustomParagraph(
                                  text: controller.suggestions[index]
                                      .split("=Rechie=")[0],
                                  fontSize: 12,
                                  maxlines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  letterSpacing: -0.41,
                                )
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColor.primaryColor,
                          )
                        ],
                      ),
                    )),
                const Divider()
              ],
            );
          }),
    );
  }

  Widget _panel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
                width: 71,
                height: 6,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(56),
                    color: const Color(0xffd9d9d9))),
          ),
          Container(height: 20),
          Obx(
            () => CustomParagraph(
              text: controller.myName.value.toString().isEmpty
                  ? "Welcome to luvpark"
                  : "${Variables.greeting()}, ${controller.myName.value}",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.41,
            ),
          ),
          const CustomTitle(
            text: "Where do you want to go today?",
            color: Color(0xFF131313),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.41,
          ),
          Container(height: 20),
          Obx(
            () => SizedBox(
              height: 54,
              child: TextField(
                controller: controller.searchCon,
                decoration: InputDecoration(
                  hintText: 'Search parking',
                  hintStyle: paragraphStyle(
                      color: Color(0xFF6A6161),
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                  filled: true,
                  fillColor: const Color(0xFFFBFBFB),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(54),
                    borderSide: BorderSide(color: AppColor.primaryColor),
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(54),
                    borderSide: BorderSide(width: 1, color: Color(0x0C131313)),
                  ),
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 15),
                      SvgPicture.asset("assets/dashboard_icon/search.svg"),
                      Container(width: 10),
                    ],
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 15),
                      if (!controller.isClearSearch.value)
                        InkWell(
                            onTap: () {
                              controller.searchCon.clear();
                              controller.isClearSearch.value = true;
                            },
                            child: SvgPicture.asset(
                                "assets/dashboard_icon/close.svg")),
                      if (controller.isClearSearch.value)
                        Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  Get.toNamed(Routes.mapFilter,
                                      arguments: (data) {
                                    controller.getFilterNearest(data);
                                  });
                                },
                                child: SvgPicture.asset(
                                    "assets/dashboard_icon/filter.svg")),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                Get.dialog(
                                  const VoiceSearchPopup(),
                                  arguments: (data) {
                                    controller.searchCon.text = data;
                                    controller.fetchSuggestions();
                                  },
                                );
                              },
                              child: SvgPicture.asset(
                                  "assets/dashboard_icon/voice.svg"),
                            ),
                          ],
                        ),
                      Container(width: 15),
                    ],
                  ),
                ),
                style: paragraphStyle(color: Colors.black, fontSize: 16),
                onTap: () {
                  controller.panelController.open();
                },
                onChanged: (text) {
                  controller.fetchSuggestions();
                  if (text.isEmpty) {
                    controller.isClearSearch.value = true;
                  } else {
                    controller.isClearSearch.value = false;
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget accessMaps(BuildContext context) {
    return controller.initialCameraPosition == null
        ? const Center(
            child: Text("Loading Map"),
          )
        : Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                buildingsEnabled: false,
                tiltGesturesEnabled: true,
                initialCameraPosition: controller.initialCameraPosition!,
                markers: Set<Marker>.of(controller.markers),
                polylines: {controller.polyline},
                circles: {controller.circle},
                onMapCreated: controller.onMapCreated,
                onCameraMoveStarted: controller.onCameraMoveStarted,
                onCameraIdle: () async {
                  controller.onCameraIdle();
                },
              ),

              Visibility(
                visible: controller.isOpenDial.value &&
                    controller.isGetNearData.value,
                child: Positioned(
                  right: 20,
                  bottom: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildDialItem("info", 'Info', () {
                        Get.dialog(LegendDialogScreen());
                      }),
                      const SizedBox(height: 16),
                      _buildDialItem("list", 'Parking areas', () {
                        Get.toNamed(Routes.parkingAreas,
                            arguments: controller.dataNearest);
                      }),
                      const SizedBox(height: 16),
                      _buildDialItem("gps", 'Current location', () {
                        controller.getCurrentLoc();
                      }),
                    ],
                  ),
                ),
              ),

              Visibility(
                visible: controller.isGetNearData.value,
                child: Positioned(
                  right: 10,
                  left: 10,
                  bottom: 25,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: controller.hasLastBooking.value,
                        child: InkWell(
                          onTap: controller.bookNow,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 1, color: Color(0xFFDFE7EF)),
                                borderRadius: BorderRadius.circular(57),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(),
                                  child: const Image(
                                    image: AssetImage(
                                        "assets/dashboard_icon/car.png"),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Container(width: 5),
                                Obx(
                                  () => CustomTitle(
                                      text: controller.brandName.value,
                                      fontSize: 14),
                                ),
                                Container(width: 5),
                                Obx(() => CustomLinkLabel(
                                      text: controller.plateNo.value,
                                      fontSize: 14,
                                      color: AppColor.primaryColor,
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                      InkWell(
                        onTap: controller.toggleSpeedDial,
                        child: AnimatedBuilder(
                          animation: controller.animationDialController,
                          builder: (context, child) {
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 100),
                              child: SvgPicture.asset(
                                "assets/dashboard_icon/${controller.animationDialController.value > 0.5 ? "close_menu" : "menu"}.svg",
                                key: ValueKey<bool>(
                                    controller.animationDialController.value >
                                        0.5),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              //My balance
              Visibility(
                visible: !controller.isOpenDial.value &&
                        controller.isGetNearData.value
                    ? true
                    : false,
                child: Positioned(
                  top: 40,
                  right: 20,
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(Routes.wallet);
                    },
                    child: Container(
                      width: 178,
                      padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 1, color: Color(0xFFDFE7EF)),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 45,
                            height: 38,
                            child: Image(
                              image: AssetImage("assets/images/logo.png"),
                              width: 37,
                              height: 32,
                            ),
                          ),
                          Container(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomParagraph(
                                  text: "My balance",
                                  maxlines: 1,
                                  fontWeight: FontWeight.w800,
                                ),
                                Obx(() => CustomTitle(
                                      text: toCurrencyString(controller
                                          .userBal[0]["amount_bal"]
                                          .toString()),
                                      maxlines: 1,
                                      letterSpacing: -0.41,
                                      fontWeight: FontWeight.w900,
                                    ))
                              ],
                            ),
                          ),
                          Container(width: 5),
                          Icon(
                            Icons.chevron_right_outlined,
                            color: AppColor.secondaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              //Drawer
              Visibility(
                visible: !controller.isOpenDial.value &&
                        controller.isGetNearData.value
                    ? true
                    : false,
                child: Positioned(
                  top: 40,
                  left: 20,
                  child: Container(
                    width: 45,
                    height: 45,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFFDFE7EF)),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: AnimatedIcon(
                        icon: AnimatedIcons.menu_close,
                        progress: controller.animationController.view,
                        color: Colors.blue,
                        size: 30,
                      ),
                      onPressed: () {
                        controller.dashboardScaffoldKey.currentState
                            ?.openDrawer();
                      },
                    ),
                  ),
                ),
              ),
              //Display when marker tapped
              Visibility(
                visible: controller.isMarkerTapped.value,
                child: Positioned(
                  bottom: 40,
                  right: 15,
                  left: 15,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFFDFE7EF)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 15,
                          offset: Offset(2, 5),
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GetBuilder<DashboardMapController>(
                            builder: (context) {
                          List<String> _biniMae = controller.dialogData[0]
                                  ["parking_schedule"]
                              .toString()
                              .split("-");
                          String mySpecialBiniSched =
                              '  ●  ${_biniMae[0]} ${_biniMae.length > 1 ? "to ${_biniMae[1]}" : ""}  ●   ';
                          String formatTime(String time) {
                            return "${time.substring(0, 2)}:${time.substring(2)}";
                          }

                          String finalSttime = formatTime(
                              controller.dialogData[0]["start_time"]);
                          String finalEndtime =
                              formatTime(controller.dialogData[0]["end_time"]);
                          bool isOpen = Functions.checkAvailability(
                              finalSttime, finalEndtime);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: controller.closeMarkerDialog,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.chevron_left,
                                      color: AppColor.primaryColor,
                                    ),
                                    CustomParagraph(
                                      text: "Back",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColor.primaryColor,
                                    )
                                  ],
                                ),
                              ),
                              Container(height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTitle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      text: controller.dialogData[0]
                                          ["park_area_name"],
                                      maxlines: 1,
                                    ),
                                  ),
                                  CustomParagraph(
                                    text: Variables.gagi(
                                      Variables.convertToMeters(
                                        controller.dialogData[0]["distance"]
                                            .toString(),
                                      ),
                                    ),
                                    color: AppColor.primaryColor,
                                    fontWeight: FontWeight.w700,
                                  )
                                ],
                              ),
                              Container(height: 5),
                              CustomParagraph(
                                text: controller.dialogData[0]["address"],
                                maxlines: 2,
                                fontWeight: FontWeight.w600,
                              ),
                              Container(height: 10),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: isOpen ? "Open" : "Close",
                                      style: paragraphStyle(
                                        color: isOpen
                                            ? const Color(0xFF7BB56C)
                                            : Colors.red,
                                      ),
                                    ),
                                    TextSpan(
                                      text: mySpecialBiniSched,
                                      style: paragraphStyle(),
                                    ),
                                    TextSpan(
                                      text:
                                          '${controller.dialogData[0]["ps_vacant_count"]} ${controller.dialogData[0]["ps_vacant_count"] > 1 ? "Slots" : "Slot"} left',
                                      style: paragraphStyle(
                                          color: const Color(0xFFE03C20)),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow
                                    .ellipsis, // Ensures that if the text is too long, it will be truncated with an ellipsis
                                maxLines: 1,
                              ),
                              Container(height: 15),
                              const Divider(),
                              Container(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      text: "Book Now",
                                      onPressed: () {
                                        controller.bookMarkerNow(
                                            controller.dialogData);
                                      },
                                    ),
                                  ),
                                  Container(width: 10),
                                  Expanded(
                                    child: CustomButton(
                                      btnColor: Colors.white,
                                      bordercolor: AppColor.primaryColor,
                                      textColor: AppColor.primaryColor,
                                      text: "Parking details",
                                      onPressed: () {
                                        Get.toNamed(Routes.parkingDetails,
                                            arguments:
                                                controller.dialogData[0]);
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          );
                        })),
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildDialItem(String icon, String label, Function ontap) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          controller.isOpenDial.value = false;
          controller.animationDialController.value = 0.0;
          ontap();
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(49),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SvgPicture.asset(
                "assets/dashboard_icon/$icon.svg",
                color: Color(0xFF474545),
                height: 24,
              ),
              Container(width: 10),
              CustomParagraph(
                text: label,
                color: const Color(0xFF474545),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget accessList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 20),
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFFFBFBFB),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0x1C2563EB)),
                borderRadius: BorderRadius.circular(48),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                const SizedBox(width: 6),
                Flexible(
                  child: TextField(
                    //  controller: ct.searchCon,
                    decoration: InputDecoration(
                      hintText: 'Search parking',
                      hintStyle: paragraphStyle(),
                      border: InputBorder.none,
                    ),
                    textAlign: TextAlign.center,
                    style: paragraphStyle(color: Colors.black),
                    onChanged: (text) {
                      controller.fetchSuggestions();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 24,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage("assets/dashboard_icon/google_voice.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _panelContent(),
          ),
        ],
      ),
    );
  }
}

class PopUpNearestDialog extends GetView<DashboardMapController> {
  const PopUpNearestDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              clipBehavior: Clip.none,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Column(
                children: [
                  const CustomTitle(text: "Nearby parking found"),
                  Container(height: 10),
                  const CustomParagraph(
                      text:
                          "Here's the nearby parking found in your current position"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
