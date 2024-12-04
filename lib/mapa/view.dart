//mapa
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_body.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/drawer/view.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/voice_search/view.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_widgets/custom_button.dart';
import '../custom_widgets/variables.dart';
import '../routes/routes.dart';
import 'controller.dart';
import 'utils/filter_map/view.dart';

class DashboardMapScreen extends GetView<DashboardMapController> {
  const DashboardMapScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Variables.init(context);
    return Obx(() {
      if (!controller.netConnected.value) {
        return CustomScaffold(
            children: NoInternetConnected(
          onTap: controller.refresher,
        ));
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
        if (!controller.netConnected.value) {
          return CustomScaffold(
              children: NoInternetConnected(
            onTap: controller.refresher,
          ));
        }
        return PopScope(
          canPop: false,
          onPopInvoked: (pop) {
            if (!pop && controller.isHidePanel.value) {
              controller.filterMarkersData("", "");
            } else {
              if (!pop) {
                if (controller
                    .dashboardScaffoldKey.currentState!.isDrawerOpen) {
                  controller.dashboardScaffoldKey.currentState!.closeDrawer();
                  return;
                }
                CustomDialog().confirmationDialog(
                    context,
                    "Close Application",
                    "Are you sure you want to close application?",
                    "No",
                    "Yes", () {
                  Get.back();
                }, () {
                  Get.back();
                  Future.delayed(Duration(milliseconds: 500), () {
                    FlutterExitApp.exitApp(iosForceExit: true);
                  });
                });
              }
            }
          },
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
            body: controller.initialCameraPosition == null
                ? Container()
                : Stack(
                    children: [
                      SlidingUpPanel(
                        maxHeight: controller.getPanelHeight(),
                        minHeight: controller.panelHeightClosed.value,
                        panelSnapping: true,
                        collapsed: InkWell(
                          onTap: () {
                            controller.panelController.open();
                          },
                          child: Container(
                            decoration: const ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(17),
                                  topRight: Radius.circular(17),
                                ),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Container(
                                width: 71,
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(56),
                                  color: const Color(0xffd9d9d9),
                                ),
                              ),
                            ),
                          ),
                        ),
                        parallaxEnabled: true,
                        controller: controller.panelController,
                        parallaxOffset: .3,
                        onPanelOpened: () {},
                        body: _mapa(),
                        panelBuilder: (sc) => panelSearchedList(sc),
                        header: LayoutBuilder(builder: (context, constraints) {
                          return InkWell(
                            onTap: () {
                              if (MediaQuery.of(Get.context!)
                                      .viewInsets
                                      .bottom ==
                                  0) {
                                controller.panelController.close();
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(Get.context!).size.width,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 25.0),
                              decoration: const ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(17),
                                    topRight: Radius.circular(17),
                                  ),
                                ),
                              ),
                              child: searchPanel(),
                            ),
                          );
                        }),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(17.0),
                            topRight: Radius.circular(17.0)),
                        onPanelSlide: (double pos) {
                          controller.onPanelSlide(pos);
                        },
                      ),
                      if (MediaQuery.of(Get.context!).viewInsets.bottom == 0)
                        Visibility(
                          visible: !controller.isHidePanel.value,
                          child: Positioned(
                            right: 20.0,
                            bottom: controller.fabHeight.value,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  key: controller.parkKey,
                                  child: _buildDialItem("parking", () {
                                    controller.routeToParkingAreas();
                                  }),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  key: controller.locKey,
                                  child: _buildDialItem("gps", () {
                                    controller.getCurrentLoc();
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      //My balance
                      if (MediaQuery.of(context).viewInsets.bottom == 0)
                        Visibility(
                          visible:
                              controller.isGetNearData.value ? true : false,
                          child: Positioned(
                            top: 0,
                            right: 20,
                            child: Padding(
                              padding: MediaQuery.of(context).padding,
                              child: InkWell(
                                key: controller.walletKey,
                                onTap: () {
                                  Get.toNamed(Routes.wallet);
                                },
                                child: Container(
                                  width: 178,
                                  padding:
                                      const EdgeInsets.fromLTRB(7, 5, 7, 5),
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
                                          image: AssetImage(
                                              "assets/images/logo.png"),
                                          width: 37,
                                          height: 32,
                                        ),
                                      ),
                                      Container(width: 5),
                                      Expanded(
                                        child: Obx(
                                          () => Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const CustomParagraph(
                                                text: "My balance",
                                                maxlines: 1,
                                                fontWeight: FontWeight.w500,
                                                minFontSize: 8,
                                              ),
                                              CustomTitle(
                                                text: controller.userBal
                                                        .toString()
                                                        .isEmpty
                                                    ? "Loading..."
                                                    : toCurrencyString(
                                                        controller.userBal
                                                            .toString()),
                                                maxlines: 1,
                                              )
                                            ],
                                          ),
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
                        ),
                      //Drawer
                      if (MediaQuery.of(context).viewInsets.bottom == 0)
                        Visibility(
                          visible:
                              controller.isGetNearData.value ? true : false,
                          child: Positioned(
                            top: 0,
                            left: 20,
                            child: Padding(
                              padding: MediaQuery.of(context).padding,
                              child: InkWell(
                                onTap: () {
                                  controller.dashboardScaffoldKey.currentState
                                      ?.openDrawer();
                                },
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
                                  child: Center(
                                    child: AnimatedIcon(
                                      icon: AnimatedIcons.menu_close,
                                      progress:
                                          controller.animationController.view,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      //Show details
                      Visibility(
                        visible: controller.isHidePanel.value,
                        child: const DraggableDetailsSheet(),
                      ),
                    ],
                  ),
          ),
        );
      }
    });
  }

//start of inatay

  Widget _mapa() {
    return GoogleMap(
      mapType: MapType.normal,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      buildingsEnabled: false,
      tiltGesturesEnabled: true,
      initialCameraPosition: controller.initialCameraPosition!,
      markers: Set<Marker>.of(controller.filteredMarkers),
      polylines: {controller.polyline},
      circles: {controller.circle},
      onMapCreated: controller.onMapCreated,
      onCameraMoveStarted: controller.onCameraMoveStarted,
      onCameraIdle: () async {
        controller.onCameraIdle();
      },
    );
  }

  Widget panelSearchedList(sc) {
    return SizedBox(
      child: StretchingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        child: ListView.builder(
            controller: sc,
            padding: EdgeInsets.fromLTRB(15, 180, 15, 5),
            itemCount: controller.suggestions.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: () async {
                        FocusManager.instance.primaryFocus!.unfocus();
                        CustomDialog().loadingDialog(context);
                        controller.panelController.close();
                        controller.addressText.value = controller
                                .suggestions[index]
                                .split("=structured=")[1]
                                .contains(",")
                            ? controller.suggestions[index]
                                .split("=structured=")[1]
                                .split(",")[0]
                            : controller.suggestions[index]
                                .split("=structured=")[1];
                        await Functions.searchPlaces(context,
                            controller.suggestions[index].split("=Rechie=")[0],
                            (searchedPlace) {
                          Get.back();
                          if (searchedPlace.isEmpty) {
                            return;
                          } else {
                            controller.searchCoordinates =
                                LatLng(searchedPlace[0], searchedPlace[1]);
                            controller.ddRadius.value =
                                '${controller.userProfile["default_search_radius"]}';
                            controller.isSearched.value = true;
                            controller.bridgeLocation(
                                LatLng(searchedPlace[0], searchedPlace[1]));
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                                "assets/dashboard_icon/places.svg"),
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
      ),
    );
  }

  Widget searchPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Container(height: 20),
          const CustomParagraph(
            minFontSize: 8,
            maxlines: 1,
            text: "Where do you want to go today?",
            color: Color(0xFF131313),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.41,
          ),
          Container(height: 20),
          SizedBox(
            height: 54,
            child: TextField(
              controller: controller.searchCon,
              autofocus: false,
              focusNode: controller.focusNode,

              style: paragraphStyle(
                  color: Colors.black, fontWeight: FontWeight.w500),
              maxLines: 1, // Ensures single line input
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                hintText: 'Search parking',
                filled: true,
                fillColor: const Color(0xFFFBFBFB),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(54),
                  borderSide: BorderSide(color: AppColor.primaryColor),
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(54),
                  borderSide: BorderSide(width: 1, color: Color(0xFFCECECE)),
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
                    if (controller.searchCon.text.isNotEmpty)
                      InkWell(
                        onTap: () {
                          FocusManager.instance.primaryFocus!.unfocus();
                          controller.searchCon.text = "";
                          controller.panelController.close();

                          Future.delayed(Duration(milliseconds: 100), () {
                            controller.panelController.open();
                          });
                        },
                        child:
                            SvgPicture.asset("assets/dashboard_icon/close.svg"),
                      ),
                    Container(width: 10),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: Get.context!,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                        20.0)), // Rounded corners
                              ),
                              clipBehavior: Clip.none,
                              builder: (BuildContext context) {
                                // Obtain the screen height

                                List<Map<String, String>> filterParam = [
                                  {
                                    "ovp": controller.isAllowOverNight,
                                    "radius": controller.ddRadius.value,
                                    "vh_type": controller.vtypeId,
                                    "park_type": controller.pTypeCode,
                                    "amen": controller.amenities
                                  }
                                ];

                                return FilterMap(
                                    data: filterParam,
                                    cb: (data) {
                                      if (data.isEmpty) {
                                        controller.resetFilter();
                                      } else
                                        controller.getFilterNearest(data);
                                    });
                              },
                              isScrollControlled:
                                  true, // Ensure the height is respected
                            );
                          },
                          child: SvgPicture.asset(
                              "assets/dashboard_icon/filter.svg"),
                        ),
                        Container(width: 10),
                        if (controller.searchCon.text.isEmpty)
                          InkWell(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Get.dialog(
                                const VoiceSearchPopup(),
                                arguments: (data) {
                                  if (data == "") {
                                    Get.back();
                                    return;
                                  }
                                  controller.searchCon.text = data;
                                  controller.onVoiceGiatay();
                                },
                              );
                            },
                            child: SvgPicture.asset(
                                "assets/dashboard_icon/voice.svg"),
                          ),
                        Container(width: 15),
                      ],
                    ),
                  ],
                ),
                hintStyle: paragraphStyle(
                    color: AppColor.hintColor, fontWeight: FontWeight.w500),
                labelStyle: paragraphStyle(
                    fontWeight: FontWeight.w500, color: AppColor.hintColor),
              ),
              onTap: () {
                controller.panelController.open();
              },
              onChanged: (text) {
                controller.searchCon.text = text;
                controller.onSearchChanged();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialItem(String icon, Function ontap) {
    return GestureDetector(
      onTap: () {
        ontap();
      },
      child: Container(
        width: 48,
        height: 48,
        child: SvgPicture.asset(
          "assets/dashboard_icon/$icon.svg",
          fit: BoxFit.contain,
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
                    style: paragraphStyle(color: AppColor.headerColor),
                    onChanged: (text) {
                      controller.fetchSuggestions(() {});
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
          // Expanded(
          //   child: _panelContent(),
          // ),
        ],
      ),
    );
  }
}

class DraggableDetailsSheet extends GetView<DashboardMapController> {
  const DraggableDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    // Calculate the initial child size as a fraction of the screen height
    final double initialChildSize = 345 / screenHeight;

    // Set minChildSize (as a fraction of the screen height)
    final double minChildSize = 0.30;

    // Ensure initialChildSize is not less than minChildSize
    final double adjustedInitialChildSize =
        initialChildSize < minChildSize ? minChildSize : initialChildSize;

    return DraggableScrollableSheet(
        initialChildSize: adjustedInitialChildSize,
        minChildSize: minChildSize,
        maxChildSize: 0.8,
        controller: controller.dragController,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                color: Colors.white,
              ),
              child: Obx(
                () => Column(
                  children: [
                    Container(height: 10),
                    Container(
                      width: 100,
                      height: 5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey.shade200),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                      child: ScrollConfiguration(
                        behavior: ScrollBehavior().copyWith(overscroll: false),
                        child: SingleChildScrollView(
                            controller: scrollController,
                            child: Row(
                              //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Transform.rotate(
                                  angle:
                                      -1.5708, // Rotate by 90 degrees in radians
                                  child: Icon(
                                    Symbols.arrow_split_rounded,
                                    color: AppColor.primaryColor,
                                    size: 20,
                                    weight: 1000,
                                  ),
                                ),
                                Container(width: 8),
                                CustomParagraph(
                                  text: controller.markerData[0]
                                      ["distance_display"],
                                  color: AppColor.primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                                Expanded(child: SizedBox()),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                    onTap: () {
                                      controller.filterMarkersData("", "");
                                    },
                                    child: Container(
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF6F5F5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(37.39),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Icon(
                                          Symbols.close,
                                          color: AppColor.headerColor,
                                          size: 16,
                                          weight: 1500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior:
                            const ScrollBehavior().copyWith(overscroll: false),
                        child: StretchingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.zero,
                            controller: scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 13, 15, 15),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1, color: Color(0xFFE6EBF0)),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomTitle(
                                                  text: controller.markerData[0]
                                                          ["park_area_name"]
                                                      .toString(),
                                                  fontSize: 18,
                                                ),
                                                Container(height: 5),
                                                CustomParagraph(
                                                  text: controller.markerData[0]
                                                          ["address"]
                                                      .toString(),
                                                  maxlines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 12,
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(width: 10),
                                          LayoutBuilder(
                                            builder: ((context, constraints) {
                                              final String isPwd =
                                                  controller.markerData[0]
                                                          ["is_pwd"] ??
                                                      "N";
                                              final String vehicleTypes =
                                                  controller.markerData[0]
                                                      ["vehicle_types_list"];
                                              String iconAsset;

                                              if (isPwd == "Y") {
                                                iconAsset = controller
                                                    .getIconAssetForPwdDetails(
                                                        controller.markerData[0]
                                                            [
                                                            "parking_type_code"],
                                                        vehicleTypes);
                                              } else {
                                                iconAsset = controller
                                                    .getIconAssetForNonPwdDetails(
                                                        controller.markerData[0]
                                                            [
                                                            "parking_type_code"],
                                                        vehicleTypes);
                                              }
                                              return iconAsset.contains("png")
                                                  ? Image(
                                                      image:
                                                          AssetImage(iconAsset),
                                                      height: 50,
                                                      width: 50,
                                                    )
                                                  : SvgPicture.asset(
                                                      height: 50,
                                                      width: 50,
                                                      iconAsset);
                                            }),
                                          ),
                                        ],
                                      ),
                                      Container(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Visibility(
                                                visible:
                                                    controller.isOpen.value,
                                                child: Container(
                                                  child: Icon(
                                                    LucideIcons.checkCircle2,
                                                    color: Colors.green,
                                                    weight: 1500,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                              Container(width: 10),
                                              CustomParagraph(
                                                text: controller.isOpen.value
                                                    ? "Open"
                                                    : "Close",
                                                fontWeight: FontWeight.w500,
                                                maxlines: 1,
                                                fontSize: 12,
                                                minFontSize: 10,
                                                color: controller.isOpen.value
                                                    ? null
                                                    : Colors.red,
                                              ),
                                            ],
                                          ),
                                          Container(width: 5),
                                          Expanded(
                                            child: _openTime(
                                              Container(
                                                child: Icon(
                                                  LucideIcons.clock2,
                                                  color: Colors.blue,
                                                  weight: 1500,
                                                  size: 20,
                                                ),
                                              ),
                                              " ${Variables.timeFormatter2(controller.markerData[0]["opened_time"].toString())} - ${Variables.timeFormatter2(controller.markerData[0]["closed_time"]).toString()}",
                                            ),
                                          ),
                                          Container(width: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                child: Icon(
                                                  LucideIcons.parkingCircle,
                                                  color: Colors.blue,
                                                  weight: 1500,
                                                  size: 20,
                                                ),
                                              ),
                                              Container(width: 10),
                                              CustomParagraph(
                                                text:
                                                    '${int.parse(controller.markerData[0]["ps_vacant_count"].toString())} ${int.parse(controller.markerData[0]["ps_vacant_count"].toString()) > 1 ? "slots" : "slot"} left',
                                                fontWeight: FontWeight.w500,
                                                maxlines: 1,
                                                fontSize: 12,
                                                minFontSize: 10,
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(height: 15),
                                      CustomParagraph(
                                        text: "Available vehicle slots",
                                        maxlines: 1,
                                        fontStyle: FontStyle.normal,
                                        color: AppColor.headerColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      Container(height: 10),
                                      _vehicles(),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 20, 15, 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomParagraph(
                                        text: "Parking Amenities",
                                        maxlines: 1,
                                        fontStyle: FontStyle.normal,
                                        color: AppColor.headerColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      _amenities(),
                                      Container(height: 20),
                                      CustomParagraph(
                                        text: "Parking Rates",
                                        maxlines: 1,
                                        fontStyle: FontStyle.normal,
                                        color: AppColor.headerColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      _parkRates(),
                                      Container(height: 20)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 5, 15, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Get directions",
                              btnColor: Colors.grey.shade100,
                              textColor: AppColor.primaryColor,
                              bordercolor: AppColor.primaryColor,
                              borderRadius: 25,
                              onPressed: () async {
                                CustomDialog().loadingDialog(context);
                                String mapUrl = "";
                                String dest =
                                    "${controller.markerData[0]["pa_latitude"]},${controller.markerData[0]["pa_longitude"]}";
                                if (Platform.isIOS) {
                                  mapUrl =
                                      'https://maps.apple.com/?daddr=$dest';
                                } else {
                                  mapUrl =
                                      'https://www.google.com/maps/search/?api=1&query=$dest';
                                }
                                Future.delayed(const Duration(seconds: 2),
                                    () async {
                                  Get.back();
                                  if (await canLaunchUrl(Uri.parse(mapUrl))) {
                                    await launchUrl(Uri.parse(mapUrl),
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    throw 'Something went wrong while opening map. Pleaase report problem';
                                  }
                                });
                              },
                            ),
                          ),
                          Container(width: 10),
                          Expanded(
                            child: CustomButton(
                              borderRadius: 25,
                              text: "Book now",
                              onPressed: () {
                                controller.onClickBooking();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
        });
  }

  Widget _openTime(dynamic icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        Container(width: 10),
        Flexible(
          child: CustomParagraph(
            text: text,
            fontWeight: FontWeight.w500,
            maxlines: 1,
            fontSize: 12,
            minFontSize: 10,
          ),
        )
      ],
    );
  }

  Widget _vehicles() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: LayoutBuilder(builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int j = 0; j < controller.vehicleTypes.length; j++) ...[
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 50, 10),
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1.3, color: Color(0xFFE8E8E8)),
                      borderRadius: BorderRadius.all(
                        Radius.circular(7),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomParagraph(
                        text: '${controller.vehicleTypes[j]['name']}',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      Container(height: 5),
                      CustomParagraph(
                        text: '${controller.vehicleTypes[j]['count']} slots',
                        color: AppColor.headerColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _amenities() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20),
      child: controller.amenData.isEmpty
          ? CustomParagraph(text: "No amenities")
          : Column(
              children: [
                for (int i = 0; i < controller.amenData.length; i += 2)
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int j = i; j < i + 2; j++)
                        j < controller.amenData.length
                            ? _buildColumn(
                                controller.amenData[j]["parking_amenity_desc"],
                                controller.amenData[j]["icon"],
                              )
                            : _buildPlaceholder(),
                    ],
                  ),
              ],
            ),
    );
  }

  Widget _parkRates() {
    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: Padding(
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: controller.vehicleTypes.length >= 3
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.start,
                children: [
                  for (int i = 0; i < controller.vehicleTypes.length; i++)
                    Padding(
                      padding: controller.vehicleTypes.length >= 3
                          ? const EdgeInsets.all(0)
                          : EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          controller.denoInd.value = i;
                          controller.getVhRatesData(
                              controller.vehicleTypes[i]["vh_types"]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: ShapeDecoration(
                              color: controller.denoInd.value == i
                                  ? const Color(0xFFEDF7FF)
                                  : Color.fromARGB(255, 242, 245, 247),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: controller.denoInd.value == i
                                      ? AppColor.primaryColor
                                      : Color.fromARGB(255, 242, 245, 247),
                                ),
                                borderRadius: BorderRadius.circular(100),
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
                            child: Row(
                              children: [
                                Image(
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                  color: controller.denoInd.value == i
                                      ? AppColor.primaryColor
                                      : Color(0xFFB6C1CC),
                                  image: AssetImage(
                                      "assets/dashboard_icon/${controller.vehicleTypes[i]["icon"]}.png"),
                                ),
                                Container(width: 5),
                                CustomParagraph(
                                  text: controller.vehicleTypes[i]["name"],
                                  fontSize: 12,
                                  color: controller.denoInd.value == i
                                      ? AppColor.primaryColor
                                      : Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Container(height: 20),
              Column(
                children: [
                  ...controller.ratesWidget.toList(),
                ],
              ),
            ],
          ),
        ),
      ),
      crossFadeState: CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 300),
    );
  }

  String _getSvgForAmenities(String amenText) {
    switch (amenText) {
      case 'ASPHALT FLOOR':
        return 'assets/map_filter/inactive/asphalt_inactive.svg';
      case 'CONCRETE FLOOR':
        return 'assets/map_filter/inactive/concrete_inactive.svg';
      case 'COVERED / SHADED':
        return 'assets/map_filter/inactive/covered_inactive.svg';
      case 'COMPACTED GRAVEL':
        return 'assets/map_filter/inactive/gravel_inactive.svg';
      case 'WITH CCTV':
        return 'assets/map_filter/inactive/cctv_inactive.svg';
      case 'WITH SECURITY':
        return 'assets/map_filter/inactive/security_inactive.svg';
      default:
        return 'assets/area_details/dimension.svg';
    }
  }

  Widget _buildColumn(String text, String icon) {
    return SizedBox(
      width: MediaQuery.of(Get.context!).size.width / 2.2,
      child: Padding(
        padding: const EdgeInsets.all(5), // Padding to ensure spacing
        child: Row(
          children: [
            SvgPicture.asset(
              _getSvgForAmenities(text),
              width: 40.0,
              height: 40.0,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: CustomParagraph(
                text: text.toLowerCase().trim().contains("perpendicular")
                    ? text
                        .trim()
                        .replaceAll("PERPENDICULAR", "\nPERPENDICULAR")
                        .trim()
                    : text.trim().toUpperCase(),
                textAlign: TextAlign.left,
                maxlines: 2,
                fontSize: 12,
                minFontSize: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      width: MediaQuery.of(Get.context!).size.width / 2.2,
      child: Padding(
        padding: const EdgeInsets.all(5), // Padding to ensure spacing
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              child: const Padding(
                padding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: const CustomParagraph(
                text: "",
                textAlign: TextAlign.left,
                maxlines: 2,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
