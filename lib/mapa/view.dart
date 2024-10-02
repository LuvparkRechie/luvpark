//mapa
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_body.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/no_internet.dart';
import 'package:luvpark_get/drawer/view.dart';
import 'package:luvpark_get/functions/functions.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:luvpark_get/voice_search/view.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_widgets/custom_button.dart';
import '../custom_widgets/variables.dart';
import 'controller.dart';
import 'utils/filter_map/view.dart';

class DashboardMapScreen extends GetView<DashboardMapController> {
  const DashboardMapScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Variables.init(context);
    Get.put(DashboardMapController());

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
            body: controller.initialCameraPosition == null
                ? Container()
                : Stack(
                    children: [
                      SlidingUpPanel(
                        maxHeight: controller.getPanelHeight(),
                        minHeight: controller.panelHeightClosed.value,
                        panelSnapping: true,
                        collapsed: Container(
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
                        parallaxEnabled: true,
                        controller: controller.panelController,
                        parallaxOffset: .3,
                        onPanelOpened: () {},
                        body: _mapa(),
                        panelBuilder: (sc) => panelSearchedList(sc),
                        header: LayoutBuilder(builder: (context, constraints) {
                          return Container(
                            width: MediaQuery.of(Get.context!).size.width,
                            padding: const EdgeInsets.symmetric(vertical: 25.0),
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
                                // _buildDialItem("lightbulb", () {
                                //   Get.dialog(LegendDialogScreen());
                                // }),
                                // const SizedBox(width: 10),
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
                            top: 40,
                            right: 20,
                            child: InkWell(
                              key: controller.walletKey,
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
                                        image: AssetImage(
                                            "assets/images/logo.png"),
                                        width: 37,
                                        height: 32,
                                      ),
                                    ),
                                    Container(width: 5),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const CustomParagraph(
                                            text: "My balance",
                                            maxlines: 1,
                                            fontWeight: FontWeight.w800,
                                            minFontSize: 8,
                                          ),
                                          Obx(() => CustomTitle(
                                                text: toCurrencyString(
                                                    controller.userBal
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
                      if (MediaQuery.of(context).viewInsets.bottom == 0)
                        Visibility(
                          visible:
                              controller.isGetNearData.value ? true : false,
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
                                key: controller.menubarKey,
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
                      //Show details
                      Visibility(
                          visible: controller.isHidePanel.value,
                          child: const DraggableDetailsSheet()),
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
                            controller.ddRadius.value = "2";
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
          const CustomTitle(
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
              style: paragraphStyle(color: Colors.black, fontSize: 16),
              maxLines: 1, // Ensures single line input
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                hintText: 'Search parking',
                hintStyle: paragraphStyle(
                  color: Color(0xFF6A6161),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
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
                          child: SvgPicture.asset(
                              "assets/dashboard_icon/close.svg")),
                    if (controller.searchCon.text.isEmpty)
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

                                    return FilterMap(cb: (data) {
                                      controller.getFilterNearest(data);
                                    });
                                  },
                                  isScrollControlled:
                                      true, // Ensure the height is respected
                                );
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
                                  controller.onVoiceGiatay();
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
                    style: paragraphStyle(color: Colors.black),
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

class DraggableDetailsSheet extends GetView<DashboardMapController> {
  const DraggableDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    controller.goingBackToTheCornerWhenIFirstSawYou();
    return DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.27,
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
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            // strokeAlign: BorderSide
                            //     .strokeAlignCenter,
                            color: Color(0xFFF3EAEA),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                      child: SingleChildScrollView(
                          controller: scrollController,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const CustomTitle(
                                text: "Parking Details",
                                fontSize: 14,
                              ),
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
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.close,
                                        color: Color(0xFF747579),
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
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
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 10, 15, 0),
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
                                                  fontSize: 20,
                                                ),
                                                CustomParagraph(
                                                  text: controller.markerData[0]
                                                          ["address"]
                                                      .toString(),
                                                  maxlines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: controller.isOpen.value
                                                  ? "Open"
                                                  : "Close",
                                              style: paragraphStyle(
                                                color: controller.isOpen.value
                                                    ? const Color(0xFF7BB56C)
                                                    : Colors.red,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  ' ● ${Variables.timeFormatter(controller.markerData[0]["opened_time"].toString())} - ${Variables.timeFormatter(controller.markerData[0]["closed_time"]).toString()} ● ',
                                              style: paragraphStyle(),
                                            ),
                                            TextSpan(
                                              text:
                                                  '${int.parse(controller.markerData[0]["ps_vacant_count"].toString())} ${int.parse(controller.markerData[0]["ps_vacant_count"].toString()) > 1 ? "Slots" : "Slot"}',
                                              style: paragraphStyle(
                                                  color:
                                                      const Color(0xFFE03C20)),
                                            ),
                                            TextSpan(
                                              text: ' ● ',
                                              style: paragraphStyle(),
                                            ),
                                            TextSpan(
                                              text:
                                                  ' ${controller.markerData[0]["distance_display"]}',
                                              style: paragraphStyle(
                                                  color: AppColor.primaryColor),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                      ),
                                      Container(height: 12),
                                      const CustomTitle(
                                        text: "Available Vehicle Slots",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                      Container(height: 10),
                                      _vehicles(),
                                      Container(height: 15),
                                      Container(
                                          height: 50,
                                          width: double.infinity,
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEAEBF3),
                                              ),
                                            ),
                                          ),
                                          child: Obx(() {
                                            return TabBar(
                                              controller:
                                                  controller.tabController,
                                              padding: EdgeInsets.zero,
                                              labelPadding:
                                                  const EdgeInsets.only(
                                                      right: 15),
                                              isScrollable: true,
                                              onTap: (index) {
                                                controller.tabIndex.value =
                                                    index;
                                              },
                                              tabs: [
                                                CustomParagraph(
                                                  text: "Parking Amenities",
                                                  maxlines: 1,
                                                  fontStyle: FontStyle.normal,
                                                  fontWeight: FontWeight.w700,
                                                  color: controller
                                                              .tabIndex.value ==
                                                          0
                                                      ? AppColor.primaryColor
                                                      : const Color(0xFF666666),
                                                  textAlign: TextAlign.left,
                                                ),
                                                CustomParagraph(
                                                  text: "Parking Rates",
                                                  maxlines: 1,
                                                  fontStyle: FontStyle.normal,
                                                  fontWeight: FontWeight.w700,
                                                  color: controller
                                                              .tabIndex.value ==
                                                          1
                                                      ? AppColor.primaryColor
                                                      : const Color(0xFF666666),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            );
                                          })),
                                      SizedBox(
                                        height: 300,
                                        child: TabBarView(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          controller: controller.tabController,
                                          children: [
                                            _amenities(),
                                            _parkRates(),
                                          ],
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
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 5, 15, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Go now",
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
                              onPressed: controller.onClickBooking,
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

  Widget _vehicles() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Color(0xFFE8E8E8)),
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int j = 0; j < controller.vehicleTypes.length; j++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Image(
                          image: AssetImage(
                              "assets/dashboard_icon/${controller.vehicleTypes[j]["icon"]}.png"),
                          color: Color(int.parse(
                                  controller.vehicleTypes[j]['color']
                                      .substring(1),
                                  radix: 16) +
                              0xFF000000),
                        ),
                      ),
                      Container(width: 10),
                      CustomParagraph(
                        text: '${controller.vehicleTypes[j]['count']}',
                        color: Color(int.parse(
                                controller.vehicleTypes[j]['color']
                                    .substring(1),
                                radix: 16) +
                            0xFF000000),
                      ),
                      Container(width: 5),
                      CustomParagraph(
                        text: '${controller.vehicleTypes[j]['name']}',
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                        color: Color(int.parse(
                                controller.vehicleTypes[j]['color']
                                    .substring(1),
                                radix: 16) +
                            0xFF000000),
                      ),
                      Container(width: 10),
                    ],
                  ),
                ),
                if (j < controller.vehicleTypes.length - 1)
                  Row(
                    children: [
                      Container(
                        height: 25,
                        width: 2,
                        color: Colors.black12,
                      ),
                      if (j < controller.vehicleTypes.length - 1)
                        Container(width: 10)
                    ],
                  )
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _amenities() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          for (int i = 0; i < controller.amenData.length; i += 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int j = i; j < i + 3; j++)
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

  Widget _buildPlaceholder() {
    return SizedBox(
      width: MediaQuery.of(Get.context!).size.width / 3.5,
      child: Padding(
        padding: const EdgeInsets.all(5), // Padding to ensure spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              child: const Padding(
                padding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 10),
            const CustomParagraph(
              text: "",
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w600,
              maxlines: 2,
              fontSize: 12,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _parkRates() {
    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < controller.vehicleRates.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomParagraph(
                      text: controller.vehicleRates[i]["vehicle_type"],
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    Container(height: 10),
                    Container(
                      width: MediaQuery.of(Get.context!).size.width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 15),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFE2F0FF),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 1, color: Color(0xFF7FB2EC)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildRatesContent(
                                controller.vehicleRates[i]["base_rate"]
                                    .toString(),
                                "Base Rate"),
                            _buildRatesContent(
                                controller.vehicleRates[i]["succeeding_rate"]
                                    .toString(),
                                "Succeeding Rate"),
                            _buildRatesContent(
                                controller.vehicleRates[i]
                                        ["first_hr_penalty_rate"]
                                    .toString(),
                                "Penalty Rate"),
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
      crossFadeState: CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildRatesContent(String title, String name) {
    return SizedBox(
      width: MediaQuery.of(Get.context!).size.width / 3.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomTitle(
            text: title,
            textAlign: TextAlign.center,
            color: const Color(0xFF2563EB),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
          CustomParagraph(
            text: name,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
            maxlines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(String text, String icon) {
    return SizedBox(
      width: MediaQuery.of(Get.context!).size.width / 3.5,
      child: Padding(
        padding: const EdgeInsets.all(5), // Padding to ensure spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: ShapeDecoration(
                color: const Color(0xFFEDF7FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset("assets/area_details/$icon.svg"),
              ),
            ),
            const SizedBox(height: 10),
            CustomParagraph(
              text: text.toUpperCase(),
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w600,
              maxlines: 2,
              fontSize: 12,
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
