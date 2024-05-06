import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class PermissionHandlerScreen extends StatefulWidget {
  final bool isLogin;
  final int index;
  final Widget widget;
  const PermissionHandlerScreen(
      {super.key,
      required this.isLogin,
      required this.index,
      required this.widget});

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
      if (checkPermission == LocationPermission.always ||
          checkPermission == LocationPermission.whileInUse) {
        Navigator.pop(context);
        Variables.pageTrans(widget.widget);
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
              child: SingleChildScrollView(
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
                          "With your consent, we may collect precise location data from your mobile device to provide location-based services."
                          "\nluvpark requires access to location in the background to enable \"Share Location feature\" for user to effortlessly"
                          " share their current whereabouts with another luvpark user.\nIt seamlessly utilizes background processes to"
                          " consistently monitors the user's device location, ensuring real-time updates for seamless communication and coordination.",
                      fontSize: 16,
                      color: Colors.black54,
                      letterSpacing: .5,
                      fontWeight: FontWeight.w400,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            CustomButton(
                label:
                    !isOpenSettings ? "Continue Permission" : "Open Settings",
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
          ],
        ),
      ),
    );
  }
}
