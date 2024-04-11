import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

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
  // didChangeAppLifecycleState(AppLifecycleState state) async {
  //   if (state == AppLifecycleState.resumed) {
  //     LocationPermission checkPermission = await Geolocator.checkPermission();
  //     if (checkPermission == LocationPermission.whileInUse && isOpenSettings) {
  //       // ignore: use_build_context_synchronously
  //       Navigator.pop(context);
  //       //  ignore: use_build_context_synchronously

  //       if (widget.isLogin) {
  //         // ignore: use_build_context_synchronously
  //       } else {
  //         // ignore: use_build_context_synchronously
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => const RegistrationPage(),
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }

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
                children: [
                  Image(
                      height: MediaQuery.of(context).size.height * 0.30,
                      image: const AssetImage(
                          'assets/images/location_permission.png')),
                  CustomDisplayText(
                    label: "Location",
                    color: AppColor.textMainColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                  const SizedBox(height: 20),
                  CustomDisplayText(
                    label:
                        "Enabling geolocation grants you access to utilize directions to parking spaces.",
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
                label: "Open Settings",
                onTap: () {
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
                onTap: () {
                  if (widget.index == 0) {
                    Navigator.pop(context);
                    setState(() {
                      isOpenSettings = true;
                    });
                  } else {
                    Navigator.pop(context);
                  }
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
