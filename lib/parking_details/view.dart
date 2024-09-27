import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/no_internet.dart';
import 'package:luvpark_get/parking_details/controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_widgets/variables.dart';

class ParkingDetails extends GetView<ParkingDetailsController> {
  const ParkingDetails({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: !controller.btnLoading.value,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: !controller.isNetConnected.value
              ? const CustomAppbar()
              : AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  toolbarHeight: 0,
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarBrightness: Brightness.light,
                    statusBarIconBrightness: Brightness.dark,
                  ),
                ),
          body: !controller.isNetConnected.value
              ? NoInternetConnected(
                  onTap: controller.refreshAmenData,
                )
              : controller.isLoading.value
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .80,
                          height: MediaQuery.of(context).size.width * .80,
                          child: const Image(
                            image: AssetImage(
                                "assets/area_details/create_route.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const CustomTitle(
                            text: "Calculating route please wait..."),
                        Container(height: 10),
                        SizedBox(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.grey.shade400,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ),
                        )
                      ],
                    )
                  : GetBuilder<ParkingDetailsController>(
                      init: ParkingDetailsController(),
                      builder: (control) {
                        LatLng destLocation = LatLng(
                            controller.dataNearest["pa_latitude"],
                            controller.dataNearest["pa_longitude"]);
                        LatLngBounds bounds = LatLngBounds(
                          southwest: LatLng(
                            controller.currentLocation.value.latitude <
                                    destLocation.latitude
                                ? controller.currentLocation.value.latitude
                                : destLocation.latitude,
                            controller.currentLocation.value.longitude <
                                    destLocation.longitude
                                ? controller.currentLocation.value.longitude
                                : destLocation.longitude,
                          ),
                          northeast: LatLng(
                            controller.currentLocation.value.latitude >
                                    destLocation.latitude
                                ? controller.currentLocation.value.latitude
                                : destLocation.latitude,
                            controller.currentLocation.value.longitude >
                                    destLocation.longitude
                                ? controller.currentLocation.value.longitude
                                : destLocation.longitude,
                          ),
                        );

                        LatLng center = LatLng(
                          (bounds.southwest.latitude +
                                  bounds.northeast.latitude) /
                              2,
                          (bounds.southwest.longitude +
                                  bounds.northeast.longitude) /
                              2,
                        );
                        controller.polyline.value = Polyline(
                          polylineId: const PolylineId('polylineId'),
                          color: Colors.blue,
                          width: 5,
                          points: controller.etaData[0]['poly_line'],
                        );
                        final String isPwd =
                            controller.dataNearest["is_pwd"] ?? "N";
                        final String vehicleTypes =
                            controller.dataNearest["vehicle_types_list"];
                        String iconAsset;

                        if (isPwd == "Y") {
                          iconAsset = controller.getIconAssetForPwdDetails(
                              controller.dataNearest["parking_type_code"],
                              vehicleTypes);
                        } else {
                          iconAsset = controller.getIconAssetForNonPwdDetails(
                              controller.dataNearest["parking_type_code"],
                              vehicleTypes);
                        }
                        return Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  GoogleMap(
                                    mapType: MapType.normal,
                                    onMapCreated:
                                        (GoogleMapController mapCtlr) {
                                      controller.googleMapController.value =
                                          mapCtlr;
                                      DefaultAssetBundle.of(context)
                                          .loadString(
                                              'assets/custom_map_style/map_style.json')
                                          .then((String style) {
                                        mapCtlr.setMapStyle(style);
                                      });

                                      controller.googleMapController.value!
                                          .animateCamera(
                                              CameraUpdate.newLatLngBounds(
                                        bounds,
                                        120, // Adjust padding as needed
                                      ));
                                    },
                                    initialCameraPosition: CameraPosition(
                                      target: center,
                                    ),
                                    zoomGesturesEnabled: true,
                                    mapToolbarEnabled: false,
                                    zoomControlsEnabled: false,
                                    myLocationEnabled: false,
                                    myLocationButtonEnabled: false,
                                    compassEnabled: false,
                                    buildingsEnabled: false,
                                    tiltGesturesEnabled: true,
                                    markers: Set<Marker>.of(controller.markers),
                                    polylines: <Polyline>{
                                      Polyline(
                                        polylineId:
                                            const PolylineId('polylineId'),
                                        color: Colors.blue,
                                        width: 5,
                                        points: controller.etaData[0]
                                            ['poly_line'],
                                      ),
                                    },
                                  ),
                                  DraggableScrollableSheet(
                                      initialChildSize: 0.4,
                                      minChildSize: 0.15,
                                      maxChildSize: 0.8,
                                      controller: controller.dragController,
                                      builder: (BuildContext context,
                                          ScrollController scrollController) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(15),
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      width: 1,
                                                      // strokeAlign: BorderSide
                                                      //     .strokeAlignCenter,
                                                      color: Color(0xFFF3EAEA),
                                                    ),
                                                  ),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 15,
                                                  horizontal: 15,
                                                ),
                                                child: SingleChildScrollView(
                                                    controller:
                                                        scrollController,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        CustomTitle(
                                                          text:
                                                              "Parking Details",
                                                          fontSize: 14,
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: InkWell(
                                                            onTap: () {
                                                              Get.back();
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  ShapeDecoration(
                                                                color: Color(
                                                                    0xFFF6F5F5),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              37.39),
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                child: Icon(
                                                                  Icons.close,
                                                                  color: Color(
                                                                      0xFF747579),
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
                                                  behavior: ScrollBehavior()
                                                      .copyWith(
                                                          overscroll: false),
                                                  child:
                                                      StretchingOverscrollIndicator(
                                                    axisDirection:
                                                        AxisDirection.down,
                                                    child:
                                                        SingleChildScrollView(
                                                      padding: EdgeInsets.zero,
                                                      controller:
                                                          scrollController,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(15,
                                                                    10, 15, 0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          CustomTitle(
                                                                            text:
                                                                                controller.dataNearest["park_area_name"],
                                                                            fontSize:
                                                                                20,
                                                                          ),
                                                                          CustomParagraph(
                                                                            text:
                                                                                controller.dataNearest["address"],
                                                                            maxlines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                        width:
                                                                            10),
                                                                    LayoutBuilder(
                                                                      builder:
                                                                          ((context,
                                                                              constraints) {
                                                                        return iconAsset.contains(
                                                                                "png")
                                                                            ? Image(
                                                                                image: AssetImage(iconAsset),
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
                                                                Container(
                                                                    height: 20),
                                                                Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: controller.isOpen.value
                                                                            ? "Open"
                                                                            : "Close",
                                                                        style:
                                                                            paragraphStyle(
                                                                          color: controller.isOpen.value
                                                                              ? const Color(0xFF7BB56C)
                                                                              : Colors.red,
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            ' ● ${Variables.timeFormatter(controller.dataNearest["opened_time"].toString())} - ${Variables.timeFormatter(controller.dataNearest["closed_time"]).toString()} ● ',
                                                                        style:
                                                                            paragraphStyle(),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            '${int.parse(controller.dataNearest["ps_vacant_count"].toString())} ${int.parse(controller.dataNearest["ps_vacant_count"].toString()) > 1 ? "Slots" : "Slot"}',
                                                                        style: paragraphStyle(
                                                                            color:
                                                                                const Color(0xFFE03C20)),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            ' ● ',
                                                                        style:
                                                                            paragraphStyle(),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            ' ${controller.dataNearest["distance_display"]} away',
                                                                        style: paragraphStyle(
                                                                            color:
                                                                                AppColor.primaryColor),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  maxLines: 1,
                                                                ),
                                                                Container(
                                                                    height: 12),
                                                                CustomTitle(
                                                                  text:
                                                                      "Available Vehicle Slots",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 14,
                                                                ),
                                                                Container(
                                                                    height: 10),
                                                                _vehicles(),
                                                                Container(
                                                                    height: 15),
                                                                Container(
                                                                    height: 50,
                                                                    width: double
                                                                        .infinity,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border:
                                                                          Border(
                                                                        bottom:
                                                                            BorderSide(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              Color(0xFFEAEBF3),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Obx(() {
                                                                      return TabBar(
                                                                        controller:
                                                                            controller.tabController,
                                                                        padding:
                                                                            EdgeInsets.zero,
                                                                        labelPadding:
                                                                            EdgeInsets.only(right: 15),
                                                                        isScrollable:
                                                                            true,
                                                                        onTap:
                                                                            (index) {
                                                                          controller
                                                                              .tabIndex
                                                                              .value = index;
                                                                        },
                                                                        tabs: [
                                                                          CustomParagraph(
                                                                            text:
                                                                                "Parking Amenities",
                                                                            maxlines:
                                                                                1,
                                                                            fontStyle:
                                                                                FontStyle.normal,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color: controller.tabIndex.value == 0
                                                                                ? AppColor.primaryColor
                                                                                : Color(0xFF666666),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                          CustomParagraph(
                                                                            text:
                                                                                "Parking Rates",
                                                                            maxlines:
                                                                                1,
                                                                            fontStyle:
                                                                                FontStyle.normal,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color: controller.tabIndex.value == 1
                                                                                ? AppColor.primaryColor
                                                                                : Color(0xFF666666),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        ],
                                                                      );
                                                                    })),
                                                                SizedBox(
                                                                  height: 300,
                                                                  child:
                                                                      TabBarView(
                                                                    physics:
                                                                        NeverScrollableScrollPhysics(),
                                                                    controller:
                                                                        controller
                                                                            .tabController,
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
                                            ],
                                          ),
                                        );
                                      })
                                ],
                              ),
                            ),
                            Container(height: 10),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
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
                                            "${destLocation.latitude},${destLocation.longitude}";
                                        if (Platform.isIOS) {
                                          mapUrl =
                                              'https://maps.apple.com/?daddr=$dest';
                                        } else {
                                          mapUrl =
                                              'https://www.google.com/maps/search/?api=1&query=$dest';
                                        }
                                        Future.delayed(
                                            const Duration(seconds: 2),
                                            () async {
                                          Get.back();
                                          if (await canLaunchUrl(
                                              Uri.parse(mapUrl))) {
                                            await launchUrl(Uri.parse(mapUrl),
                                                mode: LaunchMode
                                                    .externalApplication);
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
                            if (Platform.isIOS) Container(height: 20),
                          ],
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _vehicles() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: ShapeDecoration(
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
      padding: EdgeInsets.only(top: 20),
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
              child: Padding(
                padding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 10),
            CustomParagraph(
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
        padding: EdgeInsets.only(top: 20, left: 10, right: 10),
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
