import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/verify_user/verify_user_account.dart';

import '../custom_widget/custom_button.dart';
import '../custom_widget/custom_text.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var listWidget = <Widget>[];

  @override
  void initState() {
    super.initState();
    displayData();
  }

  displayData() {
    setState(() {
      listWidget = <Widget>[];
    });

    for (int i = 0; i < 10; i++) {
      listWidget.add(ListItem());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              expandedHeight: MediaQuery.of(context).size.height * 0.80,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                readOnly: false,
                                enabled: true,
                                autofocus: false,
                                decoration: InputDecoration(
                                  hintText: " Search parking aread ddd",
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 10, top: 5, right: 5, bottom: 5),
                                  alignLabelWithHint: true,
                                  hintStyle: Platform.isAndroid
                                      ? GoogleFonts.dmSans(
                                          color: Color(0x993C3C43),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                          height: 0.08,
                                          letterSpacing: -0.41,
                                        )
                                      : TextStyle(
                                          color: Color(0x993C3C43),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                          height: 0.08,
                                          letterSpacing: -0.41,
                                        ),
                                ),
                                onChanged: (query) async {},
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, right: 10),
                              child: InkWell(
                                onTap: () {},
                                child: const Icon(
                                  Icons.tune_outlined,
                                  color: Color(0xFF9C9C9C),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Text(
                        'Parking Nearby',
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 0.06,
                        ),
                      ),
                    ),
                    Container(height: 10),
                    Column(
                      children: listWidget,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;

  _SliverAppBarDelegate({required this.expandedHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: expandedHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            buildingsEnabled: false,
            tiltGesturesEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962),
              zoom: 15,
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: SpeedDial(
                overlayOpacity: 0,
                animatedIcon: AnimatedIcons.menu_close,
                children: [
                  SpeedDialChild(
                    child: Image.asset(
                      "assets/images/current_location.png",
                      width: 24,
                      height: 24,
                    ),
                    label: 'Current Location',
                    onTap: () {},
                  ),
                  SpeedDialChild(
                    label: 'Share Location',
                    child: Image.asset(
                      "assets/images/share-location.png",
                      width: 24,
                      height: 24,
                    ),
                    onTap: () async {
                      Variables.customBottomSheet(
                          context,
                          VerifyUserAcct(
                            isInvite: true,
                          ));
                    },
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class ListItem extends StatelessWidget {
  const ListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: const BoxDecoration(
          color: Color(0xFFffffff),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 73,
                  height: 90,
                  decoration: ShapeDecoration(
                      color: const Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      image: const DecorationImage(
                          image: AssetImage("assets/images/map_view.png"),
                          fit: BoxFit.cover)),
                ),
                Container(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            top: 1,
                                            left: 8,
                                            right: 7,
                                            bottom: 1),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          color: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(41),
                                          ),
                                        ),
                                        child: Text(
                                          "Vehicle type",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                    Container(width: 5),
                                    InkWell(
                                      onTap: () async {},
                                      child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: ShapeDecoration(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                12,
                                              ),
                                            ),
                                          ),
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: ShapeDecoration(
                                              color: AppColor.primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  12,
                                                ),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.directions,
                                              size: 20,
                                              color: AppColor.bodyColor,
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 5,
                                ),
                                Text(
                                  "Oen Now",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 5,
                      ),
                      Text(
                        "Baranggay bata negros occidental",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 73,
                  child: Center(
                    child: Text(
                      "Oen Now",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                Container(
                  width: 10,
                ),
                Expanded(
                  child: CustomButton(
                      label: "Check Parking Zone", onTap: () async {}),
                )
              ],
            ),

            // Container(
            //   height: 10,
            // ),
            const Divider(
              color: Color.fromARGB(255, 223, 223, 223),
            ),
            Row(
              children: [
                bottomListDetails("time_money", "8:00-9:00"),
                bottomListDetails2("road", "Street PARKING"),
                bottomListDetails3("carpool", "20 AVAILABLE"),
              ],
            ),

            const Divider(
              color: Color.fromARGB(255, 223, 223, 223),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomListDetails(String icon, String label) {
    return Expanded(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image(
          width: 15,
          height: 15,
          fit: BoxFit.fill,
          image: AssetImage("assets/images/$icon.png"),
        ),
        Container(
          width: 5,
        ),
        Expanded(
          child: CustomDisplayText(
            label: label,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            maxLines: 1,
          ),
        )
      ],
    ));
  }

  Widget bottomListDetails2(String icon, String label) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            width: 15,
            height: 15,
            fit: BoxFit.fill,
            image: AssetImage("assets/images/$icon.png"),
          ),
          Container(
            width: 5,
          ),
          Expanded(
            child: CustomDisplayText(
              label: label,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              maxLines: 1,
            ),
          ),
        ],
      ),
    ));
  }

  Widget bottomListDetails3(String icon, String label) {
    return Expanded(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Image(
          width: 15,
          height: 15,
          fit: BoxFit.fill,
          image: AssetImage("assets/images/$icon.png"),
        ),
        Container(
          width: 5,
        ),
        Expanded(
          child: CustomDisplayText(
            label: label,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            maxLines: 1,
          ),
        )
      ],
    ));
  }
}
