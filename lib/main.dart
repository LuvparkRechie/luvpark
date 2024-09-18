import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/routes/pages.dart';
import 'package:luvpark_get/routes/routes.dart';
// ignore: depend_on_referenced_packages
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:upgrader/upgrader.dart';

import 'notification_controller.dart';

@pragma('vm:entry-point')
Future<void> backgroundFunc() async {
  int counter = 0;

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    final isLogout = await Authentication().getLogoutStatus();

    if (isLogout != null && !isLogout) {
      var akongId = await Authentication().getUserId();

      if (akongId == 0) return;
      await getParkingTrans(counter);

      await getMessNotif();
    }
  });
}

void main() async {
  tz.initializeTimeZones();
  DartPingIOS.register();
  await dotenv.load();
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

  // ForegroundNotif.initializeForeground();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(UpgradeAlert(
      showReleaseNotes: false,
      dialogStyle: Platform.isIOS
          ? UpgradeDialogStyle.cupertino
          : UpgradeDialogStyle.material,
      child: const MyApp(),
    ));
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
    backgroundFunc();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyApp',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primaryColor,
          primary: AppColor.primaryColor,
        ),
        textTheme: GoogleFonts.quicksandTextTheme(),
      ),
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
    );
  }
}
