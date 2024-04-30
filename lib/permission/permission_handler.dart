import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/main.dart';

class PermissionHandlerScreen extends StatefulWidget {
  final bool isLogin;
  final int index;
  const PermissionHandlerScreen(
      {super.key, required this.isLogin, required this.index});

  @override
  State<PermissionHandlerScreen> createState() =>
      _PermissionHandlerScreenState();
}

class _PermissionHandlerScreenState extends State<PermissionHandlerScreen>
    with WidgetsBindingObserver {
  bool isOpenSettings = false;
  int ctr = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      LocationPermission checkPermission = await Geolocator.checkPermission();
      print("checkPermission $checkPermission");
      if (checkPermission == LocationPermission.always ||
          checkPermission == LocationPermission.whileInUse) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/',
          (route) => (route.settings.name != '/'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
      appbarColor: AppColor.bodyColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image(
                        height: MediaQuery.of(context).size.height * 0.20,
                        image: const AssetImage(
                            'assets/images/location_permission.png')),
                  ),
                  Center(
                    child: CustomDisplayText(
                      label: "Use your location",
                      color: AppColor.textMainColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomDisplayText(
                    label:
                        "With your consent, we may collect precise location data from your"
                        " mobile device to provide location-based services within the App such as;",
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 20),
                  CustomDisplayText(
                    label: "Identifying and finding nearby parking zones.",
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 10),
                  CustomDisplayText(
                    label: "Used map to get direction of the parking zone.",
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 10),
                  CustomDisplayText(
                    label:
                        "Share location feature where user can share his/her location to another luvpark user.",
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 20),
                  CustomDisplayText(
                    label:
                        'You need to give this permission from the system settings.',
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
            CustomButton(
                label: !isOpenSettings ? "Request Permission" : "Open Settings",
                onTap: !isOpenSettings
                    ? () async {
                        final statusReq = await Geolocator.checkPermission();

                        if (statusReq == LocationPermission.denied) {
                          await Geolocator.requestPermission();
                          setState(() {
                            ctr++;
                          });
                          if (ctr == 2) {
                            setState(() {
                              isOpenSettings = true;
                            });
                          }
                        } else if (statusReq ==
                            LocationPermission.deniedForever) {
                          setState(() {
                            isOpenSettings = true;
                          });
                        }
                      }
                    : () {
                        setState(() {
                          isOpenSettings = true;
                        });

                        AppSettings.openAppSettings();
                      }),
            const SizedBox(height: 16.0),
            CustomButtonCancel(
                label: "Cancel",
                color: Colors.grey.shade200,
                textColor: Colors.black,
                onTap: () async {
                  exit(0);
                }),
            Container(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
