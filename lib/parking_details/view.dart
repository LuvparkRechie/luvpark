import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/no_internet.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/parking_details/controller.dart';
import 'package:url_launcher/url_launcher.dart';

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
                                    myLocationEnabled: true,
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
                                      minChildSize: 0.2,
                                      maxChildSize: 0.8,
                                      controller: controller.dragController,
                                      builder: (BuildContext context,
                                          ScrollController scrollController) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(15),
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            children: [
                                              SingleChildScrollView(
                                                controller: scrollController,
                                                child: SizedBox(
                                                  height: 20,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Center(
                                                    child: Container(
                                                      width: 71,
                                                      height: 6,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(56),
                                                        color: const Color(
                                                            0xffd9d9d9),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(height: 10),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  controller: scrollController,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Row(
                                                      //   children: [
                                                      //     Expanded(
                                                      //       child: Column(
                                                      //         crossAxisAlignment:
                                                      //             CrossAxisAlignment
                                                      //                 .start,
                                                      //         children: [
                                                      //           CustomTitle(
                                                      //             text: controller
                                                      //                     .dataNearest[
                                                      //                 "park_area_name"],
                                                      //             fontSize: 20,
                                                      //           ),
                                                      //           CustomParagraph(
                                                      //             text: controller
                                                      //                     .dataNearest[
                                                      //                 "address"],
                                                      //             fontWeight:
                                                      //                 FontWeight
                                                      //                     .w600,
                                                      //             maxlines: 2,
                                                      //           ),
                                                      //         ],
                                                      //       ),
                                                      //     ),
                                                      //   ],
                                                      // ),
                                                      Row(
                                                        children: [
                                                          LayoutBuilder(
                                                            builder: ((context,
                                                                constraints) {
                                                              return iconAsset
                                                                      .contains(
                                                                          "png")
                                                                  ? Image(
                                                                      image: AssetImage(
                                                                          iconAsset),
                                                                      height:
                                                                          50,
                                                                      width: 50,
                                                                    )
                                                                  : SvgPicture.asset(
                                                                      height:
                                                                          50,
                                                                      width: 50,
                                                                      iconAsset);
                                                            }),
                                                          ),
                                                          Container(width: 10),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                CustomTitle(
                                                                  text: controller
                                                                          .dataNearest[
                                                                      "park_area_name"],
                                                                  fontSize: 20,
                                                                ),
                                                                CustomParagraph(
                                                                  text: controller
                                                                          .dataNearest[
                                                                      "address"],
                                                                  maxlines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  fontSize: 12,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(width: 10),
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
                                                                      0xFFF3F4F6),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
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
                                                      ),
                                                      Container(height: 20),
                                                      Container(height: 15),
                                                      Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: controller
                                                                      .isOpen
                                                                      .value
                                                                  ? "Open"
                                                                  : "Close",
                                                              style:
                                                                  paragraphStyle(
                                                                color: controller
                                                                        .isOpen
                                                                        .value
                                                                    ? const Color(
                                                                        0xFF7BB56C)
                                                                    : Colors
                                                                        .red,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  ' ●  ${Variables.timeFormatter(controller.dataNearest["opened_time"].toString())} - ${Variables.timeFormatter(controller.dataNearest["closed_time"]).toString()}  ●  ',
                                                              style:
                                                                  paragraphStyle(),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  '${int.parse(controller.dataNearest["ps_vacant_count"].toString())} ${int.parse(controller.dataNearest["ps_vacant_count"].toString()) > 1 ? "Slots" : "Slot"} left',
                                                              style: paragraphStyle(
                                                                  color: const Color(
                                                                      0xFFE03C20)),
                                                            ),
                                                          ],
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                      Container(height: 15),
                                                      const CustomTitle(
                                                        text:
                                                            "Available Vehicles",
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16,
                                                      ),
                                                      Container(height: 15),
                                                      Obx(
                                                        () =>
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: controller
                                                                .vehicleTypes
                                                                .map((type) {
                                                              final color = Color(int.parse(
                                                                      type['color']
                                                                          .substring(
                                                                              1),
                                                                      radix:
                                                                          16) +
                                                                  0xFF000000);

                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8.0),
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: color
                                                                        .withOpacity(
                                                                            .2),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            25,
                                                                        height:
                                                                            25,
                                                                        child:
                                                                            Image(
                                                                          image:
                                                                              AssetImage("assets/dashboard_icon/${type["icon"]}.png"),
                                                                          color:
                                                                              color,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              8),
                                                                      CustomParagraph(
                                                                        text:
                                                                            '${type['name']} [ ${type['count']} ]',
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        color:
                                                                            color,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(height: 25),
                                                      const Divider(
                                                        height: 3,
                                                      ),
                                                      Container(height: 15),
                                                      const CustomTitle(
                                                        text:
                                                            "Parking Amenities",
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16,
                                                      ),
                                                      Container(height: 15),
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          children: [
                                                            for (int i = 0;
                                                                i <
                                                                    controller
                                                                        .amenData
                                                                        .length;
                                                                i++)
                                                              _buildColumn(
                                                                  controller
                                                                          .amenData[i]
                                                                      [
                                                                      "parking_amenity_desc"],
                                                                  controller
                                                                          .amenData[i]
                                                                      ["icon"]),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(height: 20),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          AnimatedCrossFade(
                                                            firstChild:
                                                                const SizedBox
                                                                    .shrink(),
                                                            secondChild: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const CustomTitle(
                                                                  text:
                                                                      "Parking Rates",
                                                                  color: Colors
                                                                      .black87,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 16,
                                                                ),
                                                                Container(
                                                                    height: 15),
                                                                for (int i = 0;
                                                                    i <
                                                                        controller
                                                                            .vehicleRates
                                                                            .length;
                                                                    i++)
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        CustomParagraph(
                                                                          text: controller.vehicleRates[i]
                                                                              [
                                                                              "vehicle_type"],
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                        Container(
                                                                            height:
                                                                                10),
                                                                        Container(
                                                                          width: MediaQuery.of(Get.context!)
                                                                              .size
                                                                              .width,
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 5,
                                                                              vertical: 15),
                                                                          decoration:
                                                                              ShapeDecoration(
                                                                            color:
                                                                                const Color(0xFFE2F0FF),
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              side: const BorderSide(width: 1, color: Color(0xFF7FB2EC)),
                                                                              borderRadius: BorderRadius.circular(5),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            scrollDirection:
                                                                                Axis.horizontal,
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                _buildRatesContent(controller.vehicleRates[i]["base_rate"].toString(), "Base Rate"),
                                                                                _buildRatesContent(controller.vehicleRates[i]["succeeding_rate"].toString(), "Succeeding Rate"),
                                                                                _buildRatesContent(controller.vehicleRates[i]["first_hr_penalty_rate"].toString(), "Penalty Rate"),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                            crossFadeState:
                                                                CrossFadeState
                                                                    .showSecond,
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
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
                            // _buildDetails()

                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 1, 15, 20),
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

  Widget moreDetails() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: controller.btnLoading.value
                    ? () {}
                    : () {
                        Get.back();
                      },
                child: Row(
                  children: [
                    Icon(
                      Icons.chevron_left,
                      size: 24,
                      color: AppColor.primaryColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: AppColor.primaryColor,
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CustomParagraph(
              text: controller.dataNearest["distance_display"],
            )
          ],
        ),
        Container(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTitle(
                            text: controller.dataNearest["park_area_name"],
                            fontSize: 20,
                          ),
                          CustomParagraph(
                            text: controller.dataNearest["address"],
                            fontWeight: FontWeight.w600,
                            maxlines: 2,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Iconsax.heart,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
                Container(height: 15),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: controller.isOpen.value ? "Open" : "Close",
                        style: paragraphStyle(
                          color: controller.isOpen.value
                              ? const Color(0xFF7BB56C)
                              : Colors.red,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' ●  ${Variables.timeFormatter(controller.dataNearest["opened_time"].toString())} - ${Variables.timeFormatter(controller.dataNearest["closed_time"]).toString()}  ●  ',
                        style: paragraphStyle(),
                      ),
                      TextSpan(
                        text:
                            '${int.parse(controller.dataNearest["ps_vacant_count"].toString())} ${int.parse(controller.dataNearest["ps_vacant_count"].toString()) > 1 ? "Slots" : "Slot"} left',
                        style: paragraphStyle(color: const Color(0xFFE03C20)),
                      ),
                    ],
                  ),
                  maxLines: 1,
                ),
                Container(height: 15),
                const CustomTitle(
                  text: "Available Vehicles",
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                Container(height: 15),
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller.vehicleTypes.map((type) {
                        final color = Color(
                            int.parse(type['color'].substring(1), radix: 16) +
                                0xFF000000);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(.2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: Image(
                                    image: AssetImage(
                                        "assets/dashboard_icon/${type["icon"]}.png"),
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CustomParagraph(
                                  text: '${type['name']} [ ${type['count']} ]',
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Container(height: 25),
                const Divider(
                  height: 3,
                ),
                Container(height: 15),
                const CustomTitle(
                  text: "Parking Amenities",
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                Container(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < controller.amenData.length; i++)
                        _buildColumn(
                            controller.amenData[i]["parking_amenity_desc"],
                            controller.amenData[i]["icon"]),
                    ],
                  ),
                ),
                Container(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomTitle(
                            text: "Parking Rates",
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          Container(height: 15),
                          for (int i = 0;
                              i < controller.vehicleRates.length;
                              i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomParagraph(
                                    text: controller.vehicleRates[i]
                                        ["vehicle_type"],
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  Container(height: 10),
                                  Container(
                                    width:
                                        MediaQuery.of(Get.context!).size.width,
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
                                              controller.vehicleRates[i]
                                                      ["base_rate"]
                                                  .toString(),
                                              "Base Rate"),
                                          _buildRatesContent(
                                              controller.vehicleRates[i]
                                                      ["succeeding_rate"]
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
                      crossFadeState: CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(height: 20),
        Obx(
          () => CustomButton(
            text: "Book now",
            loading: controller.btnLoading.value,
            onPressed: controller.onClickBooking,
          ),
        ),
        if (Platform.isIOS) Container(height: 20),
      ],
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
    final mediaQuery = MediaQuery.of(Get.context!);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Fixed size in pixels
    const double fixedSizeInPixels = 100.0;
    const double fixedSizeInPixelsW = 80.0;

    // Convert fixed size to a fraction of the screen width or height
    final double widthFraction = fixedSizeInPixelsW / screenWidth;
    final double heightFraction = fixedSizeInPixels / screenHeight;

    // Calculate dimensions based on screen fractions (optional)
    final double widthAsFraction = screenWidth * widthFraction;
    final double heightAsFraction = screenHeight * heightFraction;
    return SizedBox(
      width: widthAsFraction,
      height: heightAsFraction,
      child: Padding(
        padding: const EdgeInsets.only(right: 10), // Padding to ensure spacing
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
          ],
        ),
      ),
    );
  }
}
