import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_body.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/routes/routes.dart';

import '../custom_widgets/custom_button.dart';

class PermissionHandlerScreen extends StatefulWidget {
  const PermissionHandlerScreen({super.key});

  @override
  State<PermissionHandlerScreen> createState() =>
      _PermissionHandlerScreenState();
}

class _PermissionHandlerScreenState extends State<PermissionHandlerScreen>
    with WidgetsBindingObserver {
  bool isOpenSettings = false;
  PermissionStatus? permissionGranted;

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
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await checkPermissionAndNavigate();
    }
  }

  Future<void> checkPermissionAndNavigate() async {
    Location location = Location();

    permissionGranted = await location.hasPermission();

    if (permissionGranted == PermissionStatus.granted) {
      Get.offAllNamed(Routes.map);
    } else if (permissionGranted == PermissionStatus.deniedForever) {
      setState(() {
        isOpenSettings = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (d) {
        Get.offAllNamed(Routes.map);
      },
      child: CustomScaffold(
        children: Padding(
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
                              'assets/images/location_permission.png'),
                        ),
                      ),
                      Center(
                        child: CustomTitle(
                          text: "Use your location",
                          color: AppColor.paragraphColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const CustomParagraph(
                        text:
                            "Granting location access is required to use Google Maps services, including finding available parking spots near you.",
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
                text: !isOpenSettings ? "Continue Permission" : "Open Settings",
                onPressed: !isOpenSettings
                    ? () async {
                        Location location = Location();
                        bool serviceEnabled = await location.serviceEnabled();
                        if (!serviceEnabled) {
                          setState(() {
                            isOpenSettings = true;
                          });
                          return;
                        }

                        permissionGranted = await location.hasPermission();
                        if (permissionGranted == PermissionStatus.denied) {
                          permissionGranted =
                              await location.requestPermission();
                          if (permissionGranted == PermissionStatus.granted) {
                            Get.offAllNamed(Routes.map);
                          } else {
                            setState(() {
                              isOpenSettings = true;
                            });
                          }
                        } else if (permissionGranted ==
                            PermissionStatus.deniedForever) {
                          setState(() {
                            isOpenSettings = true;
                          });
                        } else if (permissionGranted ==
                            PermissionStatus.granted) {
                          Get.offAllNamed(Routes.map);
                        }
                      }
                    : () {
                        AppSettings.openAppSettings();
                      },
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
