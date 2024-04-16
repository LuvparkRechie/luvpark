import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class ForegroundNotifTask {
  static ReceivePort? _receivePort;
  static BuildContext? _context;
  // Add a method to set the context
  static void setContext(BuildContext context) {
    _context = context;
  }

  static Future<void> requestPermissionForAndroid() async {
    if (!Platform.isAndroid) {
      return;
    }
    // Android 12 or higher, there are restrictions on starting a foreground service.
    //
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  static void initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        id: 500,
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.orange,
        ),
        // buttons: [
        //   NotificationButton(
        //     id: 'viewSharing',
        //     text: 'View Sharing',
        //     textColor: AppColor.primaryColor,
        //   ),
        // ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> startForegroundTask(context) async {
    // You can save data using the saveData function.

    print("start foreground context $context");

    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = registerReceivePort(receivePort);

    if (!isRegistered) {
      print('Failed to register receivePort!');
      return;
    }

    if (await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.restartService();
    } else {
      FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
  }

  // static void fetchData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var geoConId = prefs.getString('geo_connect_id');
  //   var akongId = prefs.getString('myId');
  //   print("geoConId  updateShareLocation $geoConId > $akongId");
  //   if (geoConId == null) return;
  //   DashboardComponent.getPositionLatLong().then((position) {
  //     var jsonParam = {
  //       "geo_connect_id": geoConId,
  //       "latitude": position.latitude,
  //       "longitude": position.longitude
  //     };

  //     HttpRequest(
  //             api: ApiKeys.gApiLuvParkPutUpdateUsersLoc, parameters: jsonParam)
  //         .put()
  //         .then((returnData) async {
  //       print("returnData updateShareLocation $returnData");
  //       if (returnData == "No Internet") {
  //         return;
  //       }
  //       if (returnData == null) {
  //         return;
  //       }
  //       if (returnData["success"] == "Y") {
  //         return;
  //       } else {
  //         print("Else ataya");
  //         // if (returnData["success"] != 'Y') {
  //         //   ShareLocationDatabase.instance.deleteAll();
  //         //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //         //   prefs.remove('geo_connect_id');
  //         //   prefs.remove('geo_share_id');
  //         // }
  //         //success
  //       }
  //     });
  //   });
  // }

  static Future<bool> stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }

  static bool registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    closeReceivePort();
    _receivePort = newReceivePort;
    _receivePort?.listen((data) async {
      if (data is int) {
      } else if (data is String) {
        if (data == 'onNotificationPressed') {
          Navigator.of(_context!).pushNamed('/sharing_location');
        }
        if (data == 'viewSharing') {
          // if (MapSharingScreen.scaffoldKeys.currentContext != null) {
          //   print("sulod sa if");
          //   Navigator.of(MapSharingScreen.scaffoldKeys.currentContext!).pop();
          // }

          Navigator.of(_context!).pushNamed('/');
          Navigator.of(_context!).pushNamed('/sharing_location');
          stopForegroundTask();
        }
      } else if (data is DateTime) {}
    });

    return _receivePort != null;
  }

  static void closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
  }

  // Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'Location Sharing',
      notificationText: 'You still have active sharing',
    );
    sendPort?.send(_eventCount);
    _eventCount++;
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('onDestroy');
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    if (id == "viewSharing") {
      _sendPort?.send('viewSharing');
    }
    if (id == "endSharing") {
      _sendPort?.send('endSharing');
    }
  }

  // Called when the notification itself on the Android platform is pressed.
  //
  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // this function to be called.
  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/sharing_location");
    _sendPort?.send('onNotificationPressed');
  }
}
