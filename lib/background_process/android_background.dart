import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:luvpark/notification_controller/notification_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  DartPluginRegistrant.ensureInitialized();
  int counter = 0;
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
    FlutterBackgroundService().invoke("setAsBackground");
    await getParkingTrans(counter);
    await getSharingData(counter);
    await updateLocation();
    //   await getParkingQueue();
    await getMessNotif();
    // NotificationController.createNewNotification(
    //     0, 0, "title", "body", "payload");
    print(' afdsafadfasdf fasdfas');
    // test using external plugin
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
  // // ignore: avoid_init_to_null
  // static StreamSubscription<int>? timerSubscription;
  // static int counter = 0;

  // static Future<void> isRunBackground(bool isRunBP) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool("is_running", isRunBP);
  // }

  // static backgroundExecution(int alarmId) async {
  //   ServiceInstance? service;
  //   final services = FlutterBackgroundService();
  //   if (await services.isRunning()) {
  //     service!.on('stopService').listen((event) {
  //       service.stopSelf();
  //     });
  //   }

  //   if (timerSubscription != null) {
  //     AndroidBackgroundProcess.timerSubscription!.cancel();
  //   }
  //   print('sulod sa background execution');
  //   FlutterBackgroundService().invoke("setAsBackground");
  //   AndroidAlarmManager.cancel(alarmId);
  //   AndroidAlarmManager.periodic(
  //     const Duration(seconds: 1),
  //     alarmId,
  //     initilizeBackgroundService,
  //     startAt: DateTime.now(),
  //     exact: true,
  //     wakeup: true,
  //   );
  // }

  static void initilizeBackgroundService() async {
    final service = FlutterBackgroundService();
    print('sulod sa initializebackgroundservice');
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: true,
        isForegroundMode: false,
        autoStartOnBoot: true,
        notificationChannelId: 'alerts',
        // initialNotificationTitle: 'AWESOME SERVICE',
        // initialNotificationContent: 'Initializing',
        // foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,

        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,

        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
    // Stream<int> timerStream = Stream.periodic(Duration(seconds: 3), (x) => x);
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var akongId = prefs.getString('myId');
    // print("initilizeBackgroundService $akongId >> $timerSubscription");
    // if (timerSubscription != null) {
    //   timerSubscription!.cancel();
    //   timerSubscription = null;
    //   timerStream.skip(1);

    //   print("is active Stopped");
    //   return;
    // }

    // if (akongId != null) {
    //   timerSubscription = timerStream.listen((event) async {
    //     await getParkingTrans(counter);
    //     await getSharingData(counter);
    //     await updateLocation();
    //     //   await getParkingQueue();
    //     await getMessNotif();
    //   });
    // }
  }
}
