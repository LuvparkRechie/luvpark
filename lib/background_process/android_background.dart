import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:luvpark/notification_controller/notification_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  NotificationController.startListeningNotificationEvents();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  int counter = 0;
  tz.initializeTimeZones();
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // bring to foreground
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    var akongId = prefs.getString('myId');
    print("akongId $akongId");
    // FlutterBackgroundService().invoke("setAsBackground");
    if (akongId == null) return;
    await getParkingTrans(counter);
    await getSharingData(counter);
    await updateLocation();
    await getMessNotif();
    // NotificationController.createNewNotification(
    //     0, 0, "title", "body", "payload");

    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}

class AndroidBackgroundProcess {
  // // static Future<void> setForegroundProcess(bool isForeground) async {
  // //   final service = FlutterBackgroundService();

  // //   service.invoke("stopService");

  // //   SharedPreferences prefs = await SharedPreferences.getInstance();
  // //   prefs.setBool("is_foregroundTask", isForeground);
  // //   print("isForeground $isForeground");
  // //   if (isForeground) {
  // //     service.invoke("setAsForeground");
  // //   } else {
  // //     service.invoke("setAsBackground");
  // //   }

  // //   print("service111 ${service.isRunning()}");
  // //   service.startService();

  // //   print("service2222 ${service.isRunning()}");
  // // }

  // static Future<bool> getForegroundProcess() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool? isForeground = prefs.getBool("is_foregroundTask");
  //   return isForeground == null ? false : isForeground;
  // }

  static void initilizeBackgroundService() async {
    final service = FlutterBackgroundService();
    print('sulod sa initializebackgroundservice');
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: false,
        autoStartOnBoot: true,
        notificationChannelId: 'alerts',
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }
}
