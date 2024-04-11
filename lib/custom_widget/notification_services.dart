// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:luvpark/bottom_tab/bottom_tab.dart';
// import 'package:timezone/timezone.dart' as tz;

// class NotificationServices {
//   static final GlobalKey<NavigatorState> navigatorKey =
//       GlobalKey<NavigatorState>();
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initNotification() async {
//     AndroidInitializationSettings initializationSettingsAndroid =
//         const AndroidInitializationSettings('ic_launcher');

//     var initializationSettingsIOS = DarwinInitializationSettings(
//         requestAlertPermission: true,
//         requestBadgePermission: true,
//         requestSoundPermission: true,
//         onDidReceiveLocalNotification:
//             (int id, String? title, String? body, String? payload) async {
//           // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
//           //   if (payload != null && payload == 'Custom_Screen') {
//           //     navigatorKey.currentState?.pushNamed('/secondScreen');
//           //   }
//           // });
//           print('Notification Tapped with payload: $payload');

//           // Navigate to another page (replace with your navigation logic)
//           navigatorKey.currentState?.push(
//             MaterialPageRoute(
//                 builder: (context) => const MainLandingScreen(
//                       index: 1,
//                       parkingIndex: 1,
//                     )),
//           );
//         });

//     var initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//     await notificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse:
//             (NotificationResponse notificationResponse) async {
//       // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
//       //   if (notificationResponse.payload != null &&
//       //       notificationResponse.payload == 'Custom_Screen') {
//       //     navigatorKey.currentState?.pushNamed('/secondScreen');
//       //   }
//       // });

//       // Navigate to another page (replace with your navigation logic)
//       navigatorKey.currentState?.push(
//         MaterialPageRoute(
//             builder: (context) => const MainLandingScreen(
//                   index: 1,
//                   parkingIndex: 1,
//                 )),
//       );
//     });
//   }

//   notificationDetails() {
//     return const NotificationDetails(
//         android: AndroidNotificationDetails('channelId', 'channelName',
//             playSound: true, enableVibration: true, importance: Importance.max),
//         iOS: DarwinNotificationDetails());
//   }

//   Future showNotification(
//       {int id = 0, String? title, String? body, String? payLoad}) async {
//     return notificationsPlugin
//         .show(id, title, body, await notificationDetails(), payload: payLoad);
//   }

//   Future<void> scheduleAlarm(
//       int id, String title, String body, String? dateSched) async {
//     final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();
//     print("dateSched $dateSched");
//     final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
//             DateTime.parse(dateSched!), tz.getLocation('Asia/Manila'))
//         .subtract(const Duration(minutes: 55));
//     print("scheduledTime $scheduledTime");
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//         int.parse(id.toString()), // Notification ID
//         title,
//         body,
//         scheduledTime,
//         notificationDetails(),
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         payload: "Custom_Screen");
//   }

//   Future<void> cancelNotification(int id) async {
//     final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();
//     await flutterLocalNotificationsPlugin.cancel(id);
//   }
// }
