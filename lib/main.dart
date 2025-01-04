import 'dart:async';
import 'dart:convert';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/routes/routes.dart';
// ignore: depend_on_referenced_packages
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'custom_widgets/alert_dialog.dart';
import 'http/api_keys.dart';
import 'notification_controller.dart';
import 'routes/pages.dart';
import 'security/app_security.dart';

@pragma('vm:entry-point')
Future<void> backgroundFunc() async {
  int counter = 0;

  List appSecurity = await AppSecurity.checkDeviceSecurity();
  bool isAppSecured = appSecurity[0]["is_secured"];
  if (isAppSecured) {
    // final isLogout = await Authentication().getLogoutStatus();
    // if (isLogout != null && !isLogout) {

    // }
    var akongId = await Authentication().getUserId();
    if (akongId == 0) return;
    await getParkingTrans(counter);
    await getMessNotif();
  } else {
    Variables.bgProcess!.cancel();
    Variables.showSecurityPopUp(appSecurity[0]["msg"]);
  }
}

void _onUserActivity() async {
  bool? tmrStat = await Authentication().getTimerStatus();
  if (!tmrStat!) {
    Variables.inactiveTmr?.cancel();
    return;
  }

  if (Variables.inactiveTmr?.isActive ?? false) Variables.inactiveTmr?.cancel();

  Duration duration = const Duration(minutes: 3);
  Variables.inactiveTmr = Timer(duration, () async {
    FocusManager.instance.primaryFocus!.unfocus();
    CustomDialog().loadingDialog(Get.context!);
    await Future.delayed(const Duration(seconds: 2));
    final userLogin = await Authentication().getUserLogin();
    List userData = [userLogin];
    userData = userData.map((e) {
      e["is_login"] = "N";
      return e;
    }).toList();
    // await NotificationDatabase.instance.deleteAll();
    await Authentication().setLogin(jsonEncode(userData[0]));
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("last_booking");
    Authentication().setLogoutStatus(true);
    AwesomeNotifications().dismissAllNotifications();
    AwesomeNotifications().cancelAll();
    Variables.inactiveTmr!.cancel();
    // Variables.bgProcess!.cancel();

    Get.back();
    Get.offAllNamed(Routes.splash);
  });
}

void main() async {
  tz.initializeTimeZones();
  DartPingIOS.register();
  WidgetsFlutterBinding.ensureInitialized();
  final packageInfo = await PackageInfo.fromPlatform();
  Variables.version = packageInfo.version;
  final status = await Permission.notification.status;
  if (status.isDenied) {
    await Permission.notification.request();
  }

  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  NotificationController.initializeLocalNotifications();
  NotificationController.initializeIsolateReceivePort();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    NotificationController.startListeningNotificationEvents();
    AndroidAlarmManager.initialize();
    initializedPotcha();
  }

  void initializedPotcha() async {
    await AndroidAlarmManager.periodic(
        const Duration(seconds: 5), 0, backgroundFunc,
        startAt: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _onUserActivity(),
      onPointerMove: (_) => _onUserActivity(),
      onPointerCancel: (_) => _onUserActivity(),
      onPointerHover: (_) => _onUserActivity(),
      onPointerUp: (d) {
        _onUserActivity();
      },
      onPointerSignal: (d) {
        _onUserActivity();
      },
      child: GetMaterialApp(
        debugShowCheckedModeBanner: !ApiKeys.isProduction,
        title: 'MyApp',
        theme: ThemeData(
          useMaterial3: false,
        ),
        navigatorObservers: [GetObserver()],
        initialRoute: Routes.splash,
        getPages: AppPages.pages,
      ),
    );
  }
}
