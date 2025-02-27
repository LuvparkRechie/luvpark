import 'dart:async';
import 'dart:convert';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/functions/functions.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/routes/routes.dart';
// ignore: depend_on_referenced_packages
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'notification_controller.dart';
import 'routes/pages.dart';
import 'security/app_security.dart';

@pragma('vm:entry-point')
Future<void> backgroundFunc() async {
  await dotenv.load();
  int counter = 0;

  Authentication auth = Authentication();
  List appSecurity = await AppSecurity.checkDeviceSecurity();
  bool isAppSecured = appSecurity[0]["is_secured"];

  if (isAppSecured) {
    var akongId = await auth.getUserId();
    if (akongId == 0) return;

    await Future.wait([
      getParkingTrans(counter),
      getMessNotif(),
    ]);
  } else {
    Variables.bgProcess?.cancel();
    Variables.showSecurityPopUp(appSecurity[0]["msg"]);
  }
}

@pragma('vm:entry-point')
void sessionTimeOut(context) async {
  Timer.periodic(Duration(seconds: 10), (timer) {
    getLogSession(context);
  });
}

void _onUserActivity() async {
  return;
  bool? tmrStat = await Authentication().getTimerStatus();
  if (!tmrStat!) {
    Variables.inactiveTmr?.cancel();
    return;
  }

  if (Variables.inactiveTmr?.isActive ?? false) Variables.inactiveTmr?.cancel();

  Variables.inactiveTmr =
      Timer.periodic(const Duration(minutes: 3), (timer) async {
    final uData = await Authentication().getUserData2();
    FocusManager.instance.primaryFocus?.unfocus(); // Safer approach

    Functions.logoutUser(uData == null ? "" : uData["session_id"].toString(),
        (isSuccess) async {
      if (isSuccess["is_true"]) {
        Variables.snackbarDynamicDialog("Session expired.");
        final userLogin = await Authentication().getUserLogin();
        List userData = [userLogin];
        userData = userData.map((e) {
          e["is_login"] = "N";
          return e;
        }).toList();
        await Authentication().setLogin(jsonEncode(userData[0]));
        final prefs = await SharedPreferences.getInstance();
        prefs.remove("last_booking");
        Authentication().setLogoutStatus(true);
        Variables.inactiveTmr?.cancel();
        Get.offAndToNamed(Routes.login);
      }
    });
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  tz.initializeTimeZones();
  DartPingIOS.register();

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
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
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
    initializedDeviceSecurity();
  }

  void initializedDeviceSecurity() async {
    List appSecurity = await AppSecurity.checkDeviceSecurity();
    bool isAppSecured = appSecurity[0]["is_secured"];

    if (isAppSecured) {
      initializedBgProcess();
      initializedLogStatus();
      sessionTimeOut(context);
    } else {
      Variables.bgProcess?.cancel();
      Variables.showSecurityPopUp(appSecurity[0]["msg"]);
    }
  }

  void initializedBgProcess() async {
    await AndroidAlarmManager.periodic(
      const Duration(seconds: 5),
      0,
      backgroundFunc,
      startAt: DateTime.now(),
    );
  }

  void initializedLogStatus() async {
    final userLogin = await Authentication().getUserLogin();
    List userData = userLogin == null ? [] : [userLogin];

    if (userData.isNotEmpty) {
      userData = userData.map((e) {
        e["is_login"] = "N";
        return e;
      }).toList();
      await Authentication().setLogin(jsonEncode(userData[0]));
      Authentication().setLogoutStatus(true);
    }
    Variables.inactiveTmr?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _onUserActivity(),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: !ApiKeys.isProduction,
        title: 'MyApp',
        theme: ThemeData(useMaterial3: false),
        navigatorObservers: [GetObserver()],
        initialRoute: Routes.splash,
        getPages: AppPages.pages,
      ),
    );
  }
}
