//mapa
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

import 'controller.dart';
import 'utils/filter_map/view.dart';

class DashboardMapScreen extends GetView<DashboardMapController> {
  const DashboardMapScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
        if (double.parse(controller.userBal[0]["amount_bal"].toString()) >=
            double.parse(controller.userBal[0]["min_wallet_bal"].toString())) {
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
                  : Material(
                      child: Stack(
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
                            header:
                                LayoutBuilder(builder: (context, constraints) {
                              return Container(
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
                              );
                            }),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(17.0),
                                topRight: Radius.circular(17.0)),
                            onPanelSlide: (double pos) {
                              controller.onPanelSlide(pos);
                            },
                          ),

                          if (MediaQuery.of(Get.context!).viewInsets.bottom ==
                              0)
                            Positioned(
                              right: 20.0,
                              bottom: controller.fabHeight.value,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // _buildDialItem("lightbulb", () {
                                  //   Get.dialog(LegendDialogScreen());
                                  // }),
                                  // const SizedBox(width: 10),
                                  _buildDialItem("parking", () {
                                    Get.toNamed(Routes.parkingAreas,
                                        arguments: controller.dataNearest);
                                  }),
                                  const SizedBox(width: 10),
                                  _buildDialItem("gps", () {
                                    controller.getCurrentLoc();
                                  }),
                                ],
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
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const CustomParagraph(
                                                text: "My balance",
                                                maxlines: 1,
                                                fontWeight: FontWeight.w800,
                                              ),
                                              Obx(() => CustomTitle(
                                                    text: toCurrencyString(
                                                        controller.userBal[0]
                                                                ["amount_bal"]
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
                                    icon: AnimatedIcon(
                                      icon: AnimatedIcons.menu_close,
                                      progress:
                                          controller.animationController.view,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      controller
                                          .dashboardScaffoldKey.currentState
                                          ?.openDrawer();
                                    },
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          );
        } else {
          return PopScope(
              canPop: false,
              child: CustomScaffold(children: accessList(context)));
        }
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
      markers: Set<Marker>.of(controller.markers),
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
                        controller.panelController.close();
                        CustomDialog().loadingDialog(context);
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
                            controller
                                .bridgeLocation(controller.searchCoordinates);
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
                            controller.searchCon.clear();

                            controller.suggestions.clear();
                            controller.panelController.close();
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
