import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/http_request/http_request_model.dart';
import 'package:luvpark/main.dart';
import 'package:luvpark/sqlite/notification_model.dart';
import 'package:luvpark/sqlite/pa_message_model.dart';
import 'package:luvpark/sqlite/pa_message_table.dart';
// import 'package:luvpark/sqlite/pa_message_controller.dart';
// import 'package:luvpark/sqlite/pa_message_model.dart';
import 'package:luvpark/sqlite/reserve_notification_table.dart';
import 'package:luvpark/sqlite/share_location_model.dart';
import 'package:luvpark/sqlite/share_location_table.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tzz;

class NotificationController {
  static ReceivedAction? initialAction;

  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
      null, //'resource://drawable/res_app_icon',//
      [
        NotificationChannel(
          channelKey: 'alerts',
          channelName: 'Alerts',
          channelDescription: 'Notification tests as alerts',
          playSound: true,
          onlyAlertOnce: true,
          groupAlertBehavior: GroupAlertBehavior.Children,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          defaultColor: Colors.deepPurple,
          ledColor: Colors.deepPurple,
        ),
      ],
      debug: true,
    );

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
          (silentData) => onActionReceivedImplementationMethod(silentData));

    // This initialization only happens on the main isolate
    IsolateNameServer.registerPortWithName(
      receivePort!.sendPort,
      'notification_action_port',
    );
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      await executeLongTaskInBackground();
    } else {
      if (receivePort == null) {
        SendPort? sendPort =
            IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          sendPort.send(receivedAction);
          return;
        }
      }

      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> declineSharing(int id, BuildContext context) async {
    DashboardComponent.getPositionLatLong().then((position) async {
      var endParam = {"geo_connect_id": id};

      HttpRequest(api: ApiKeys.gApiLuvParkPutEndSharing, parameters: endParam)
          .put()
          .then((returnData) async {
        if (returnData == "No Internet") {
          showAlertDialog(
            context,
            "Error",
            'Please check your internet connection and try again.',
            () {
              Navigator.of(context).pop();
            },
          );
          return;
        }
        if (returnData == null) {
          showAlertDialog(
            context,
            "Error",
            "Error while connecting to the server, Please try again.",
            () {
              Navigator.of(context).pop();
            },
          );
          return;
        }
        if (returnData["success"] == 'Y') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove("geo_connect_id");
          prefs.remove("geo_share_id");
          ShareLocationDatabase.instance.deleteAll();
          showAlertDialog(
            context,
            "Success",
            "Live sharing has been rejected.",
            () async {
              if (MyApp.scaffoldKey.currentContext != null) {
                Navigator.of(MyApp.scaffoldKey.currentContext!).pop();
                Navigator.of(context).pop();
                // // redirect();
              } else {
                Navigator.of(context).pop();
              }
            },
          );
        } else {
          showAlertDialog(context, "Error", returnData["msg"], () {
            Navigator.of(context).pop();
          });
        }
      });
    });
  }

  static Future<void> acceptSharing(
      int id, String shareId, BuildContext context, Function callBack) async {
    CustomModal(context: context).loader();
    DashboardComponent.getPositionLatLong().then((position) async {
      var updateParam = {
        "geo_connect_id": id,
        "latitude": position.latitude,
        "longitude": position.longitude,
      };
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('geo_connect_id', "$id");
      prefs.setString('geo_share_id', "$shareId");
      // Share ID
      HttpRequest(
        api: ApiKeys.gApiLuvParkPutAcceptShareLoc,
        parameters: updateParam,
      ).put().then((returnData) async {
        if (returnData == "No Internet") {
          Navigator.of(MyApp.navigatorKey.currentState!.context).pop();
          showAlertDialog(
            MyApp.navigatorKey.currentState!.context,
            "Error",
            'Please check your internet connection and try again.',
            () {
              ShareLocationDatabase.instance.deleteAll();
              callBack(false);
              Navigator.of(MyApp.navigatorKey.currentState!.context).pop();
            },
          );
          return;
        }
        if (returnData == null) {
          Navigator.of(MyApp.navigatorKey.currentState!.context).pop();
          showAlertDialog(
            MyApp.navigatorKey.currentState!.context,
            "Error",
            "Error while connecting to the server, Please try again.",
            () {
              ShareLocationDatabase.instance.deleteAll();
              callBack(false);
              Navigator.of(MyApp.navigatorKey.currentState!.context).pop();
            },
          );
          return;
        }
        if (returnData["success"] == 'Y') {
          Navigator.of(MyApp.navigatorKey.currentState!.context).pop();
          callBack(true);
        } else {
          Navigator.of(MyApp.navigatorKey.currentState!.context).pop();
          showAlertDialog(
            MyApp.navigatorKey.currentState!.context,
            "Error",
            "Invalid OTP code. Please try again.. Please try again.",
            () {
              ShareLocationDatabase.instance.deleteAll();
              Navigator.of(MyApp.navigatorKey.currentState!.context).pop();
              callBack(false);
            },
          );
        }
      });
    });
  }

  static Future<void> executeLongTaskInBackground() async {
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    final re = await http.get(url);
    print(re.body);
  }

  static Future<void> createNewNotification(int id, int geoShareId,
      String? title, String? body, String? payload) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'alerts',
        title: title!,
        body: body!,
        wakeUpScreen: true,
        autoDismissible: false,
        notificationLayout: NotificationLayout.BigPicture,
        payload: {'notificationId': payload!, "geo_share_id": "$geoShareId"},
      ),
      actionButtons: payload == "custom_Screen"
          ? [
              NotificationActionButton(key: 'VIEW', label: 'View Ticket'),
            ]
          : [
              NotificationActionButton(key: 'ACCEPT', label: 'Accept'),
              NotificationActionButton(key: 'DECLINE', label: 'Reject'),
            ],
    );
  }
  //Share token notif

  static Future<void> shareTokenNotification(int id, int geoShareId,
      String? title, String? body, String? payload) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'alerts',
        title: title!,
        body: body!,
        wakeUpScreen: true,
        autoDismissible: true,
        notificationLayout: NotificationLayout.BigPicture,
        payload: {'notificationId': payload!, "geo_share_id": "$geoShareId"},
      ),
    );
  }

//to notify users about  reported damage
  static Future<void> createInformationMessage(int id, int geoShareId,
      String? title, String? body, String? payload) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'alerts',
          title: title!,
          body: body!,
          wakeUpScreen: true,
          autoDismissible: false,
          notificationLayout: NotificationLayout.BigPicture,
          payload: {'notificationId': payload!},
        ),
        actionButtons: [
          NotificationActionButton(key: 'MESSAGE', label: 'View Message'),
        ]);
  }

  // MAKE A FOREGROUND NOTIFICATION
  static Future<void> createForegroundNotif(int id, int geoShareId,
      String? title, String? body, String? payload) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'alerts',
        title: title!,
        body: body!,
        wakeUpScreen: true,
        autoDismissible: false,
        notificationLayout: NotificationLayout.BigPicture,
        payload: {
          'notificationId': payload!,
          "geo_share_id": "$geoShareId",
        },
      ),
      actionButtons: [
        NotificationActionButton(key: 'VIEW_SHARING', label: 'View Sharing'),
      ],
    );
  }

  static Future<void> scheduleNewNotification(int id, String title, String body,
      String? dateSched, String payLoad) async {
    print("dateSched $dateSched");

    try {
      tz.initializeTimeZones();
      // Check if timezone database is initialized, if not initialize it

      final tzz.TZDateTime scheduledTime = tzz.TZDateTime.from(
        DateTime.parse(dateSched!),
        tzz.getLocation('Asia/Manila'),
      ).subtract(const Duration(minutes: 10));

      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

      if (!isAllowed) {
        return;
      }
      print("scheduled time $scheduledTime");
      await myNotifyScheduleInHours(
        id: id,
        title: title,
        msg: body,
        hoursFromNow: scheduledTime,
        repeatNotif: false,
        payLoad: payLoad,
      );
    } catch (e) {
      print("error schedule $e");
    }
  }

  static Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  static Future<void> cancelNotificationsById(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    BuildContext context = MyApp.navigatorKey.currentState!.context;

    void redirect() async {
      MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/${receivedAction.payload!["notificationId"]}',
        (route) =>
            (route.settings.name !=
                '/${receivedAction.payload!["notificationId"]}') ||
            route.isFirst,
        arguments: receivedAction,
      );
    }

    print("receivedAction $receivedAction");

    switch (receivedAction.buttonKeyPressed) {
      case "DECLINE":
        declineSharing(receivedAction.id!, context);
        break;
      case "ACCEPT":
        acceptSharing(
          receivedAction.id!,
          receivedAction.payload!["geo_share_id"]!,
          context,
          (isSuccess) {
            if (isSuccess) {
              print("isSuccess $isSuccess");
              AwesomeNotifications().dismiss(receivedAction.id!);
              if (MyApp.scaffoldKey.currentContext != null) {
                print("sulod sa if");
                Navigator.of(MyApp.scaffoldKey.currentContext!).pop();
              }

              redirect();
            }
          },
        );
        break;
      case "VIEW":
        redirect();
        break;
      case "VIEW_SHARING":
        if (MyApp.scaffoldKey.currentContext != null) {
          Navigator.of(MyApp.scaffoldKey.currentContext!).pop();
        }
        redirect();
        break;
      case "MESSAGE":
        if (MyApp.scaffoldKey.currentContext != null) {
          Navigator.of(MyApp.scaffoldKey.currentContext!).pop();
        }
        redirect();
        break;
      default:
        redirect();
    }
  }

  static Future<void> myNotifyScheduleInHours({
    required tzz.TZDateTime hoursFromNow,
    required String title,
    required String msg,
    required String payLoad,
    required int id,
    bool repeatNotif = false,
  }) async {
    await AwesomeNotifications().createNotification(
      schedule: NotificationCalendar(
        weekday: null,
        hour: hoursFromNow.hour,
        minute: hoursFromNow.minute,
        second: 0,
        repeats: repeatNotif,
        allowWhileIdle: true,
      ),
      content: NotificationContent(
        id: id,
        channelKey: 'alerts',
        title: title,
        body: msg,
        payload: {
          'notificationId': payLoad,
        },
      ),
    );
  }
}

Future<void> updateLocation() async {
  bool isRunning = await FlutterForegroundTask.isRunningService;

  print("isRunning foreground task $isRunning");
  if (isRunning) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var geoConId = prefs.getString('geo_connect_id');

    if (geoConId == null) return;
    DashboardComponent.getPositionLatLong().then((position) {
      var jsonParam = {
        "geo_connect_id": geoConId,
        "latitude": position.latitude,
        "longitude": position.longitude
      };
      print("jsonParam $jsonParam");

      HttpRequest(
              api: ApiKeys.gApiLuvParkPutUpdateUsersLoc, parameters: jsonParam)
          .put()
          .then((returnData) async {
        if (returnData == "No Internet") {
          return;
        }
        if (returnData == null) {
          return;
        }
        if (returnData["success"] == "Y") {
          return;
        }
      });
    });
  }
}

//GET ACCEPT SHARING
Future<void> getSharingData(ctr) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var akongId = prefs.getString('myId');
  if (akongId == null) return;
  HttpRequest(
    api: "${ApiKeys.gApiLuvParkGetShareLoc}?user_id=${akongId.toString()}",
  ).get().then((notificationData) async {
    //  ShareLocationDatabase.instance.deleteAll();
    if (notificationData == "No Internet") {
      return;
    }
    if (notificationData["items"].isEmpty) {
      return;
    } else {
      for (var dataRow in notificationData["items"]) {
        await ShareLocationDatabase.instance
            .readNotificationByMateId(dataRow["geo_connect_id"],
                dataRow["updated_on"] == null ? "" : dataRow["updated_on"])
            .then((returnData) async {
          if (returnData == null) {
            var resData = {
              ShareLocationDataFields.connectMateId:
                  int.parse(dataRow["geo_connect_id"].toString()),
              ShareLocationDataFields.updatedDate: dataRow["updated_on"] == null
                  ? ""
                  : dataRow["updated_on"].toString()
            };
            await ShareLocationDatabase.instance
                .insertUpdate(resData)
                .then((updateProcess) {
              int idParam = int.parse(dataRow["geo_connect_id"].toString());
              int shareIdParam = int.parse(dataRow["geo_share_id"].toString());
              prefs.setString(
                  'geo_share_id', dataRow["geo_share_id"].toString());
              prefs.setString(
                  'geo_connect_id', dataRow["geo_connect_id"].toString());

              NotificationController.cancelNotificationsById(idParam);
              AwesomeNotifications().dismiss(idParam);
              NotificationController.createNewNotification(
                  idParam,
                  shareIdParam,
                  'Sharing Location',
                  "Someone wants to share their location with you",
                  "sharing_location");
            });
          }
        });
      }
    }
  });
}

Future<void> getParkingTrans(int ctr) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var akongId = prefs.getString('myId');
  if (akongId == null) return;
  HttpRequest(
    api:
        "${ApiKeys.gApiSubFolderGetReservations}?user_id=${akongId.toString()}",
  ).get().then((notificationData) async {
    if (notificationData == "No Internet") {
      return;
    }
    if (notificationData != null) {
      for (var dataRow in notificationData["items"]) {
        await NotificationDatabase.instance
            .readNotificationByDateOut(
                dataRow["dt_in"].toString(), dataRow["reservation_id"])
            .then((returnData) async {
          if (returnData == null) {
            // Insert process

            var resData = {
              NotificationDataFields.reservedId:
                  int.parse(dataRow["reservation_id"].toString()),
              NotificationDataFields.userId:
                  int.parse(dataRow["user_id"].toString()),
              NotificationDataFields.description:
                  "Your Parking at ${dataRow["notes"]} is about to expire.",
              NotificationDataFields.notifDate: dataRow["dt_out"].toString(),
              NotificationDataFields.status: dataRow["status"].toString(),
              NotificationDataFields.isActive: dataRow["is_active"].toString(),
              NotificationDataFields.dtIn: dataRow["dt_in"].toString(),
            };

            if (dataRow["is_active"] == "Y" && dataRow["status"] == "U") {
              ctr++;
              print("Insert Process");
              NotificationController.createNewNotification(
                  int.parse(dataRow["reservation_id"].toString()),
                  0,
                  'Check In',
                  "Great! You have successfully checked in to ${dataRow["notes"].toString()} parking area",
                  "custom_Screen");

              NotificationController.scheduleNewNotification(
                  int.parse(dataRow["reservation_id"].toString()),
                  "luvpark",
                  "Your Parking at ${dataRow["notes"]} is about to expire.",
                  dataRow["dt_out"].toString(),
                  "custom_Screen");
              print("Scheduled Process");
              await NotificationDatabase.instance.insertUpdate(resData);
            }
          } else {
            if (DateTime.parse(returnData["notif_date"].toString())
                    .isBefore(DateTime.parse(dataRow["dt_out"].toString())) &&
                dataRow["is_active"] == "Y" &&
                dataRow["status"] == "U") {
              NotificationController.cancelNotificationsById(
                  returnData["reserved_id"]);

              var resData = {
                NotificationDataFields.reservedId:
                    int.parse(dataRow["reservation_id"].toString()),
                NotificationDataFields.userId:
                    int.parse(dataRow["user_id"].toString()),
                NotificationDataFields.description:
                    "Your Parking at ${dataRow["notes"]} is about to expire.",
                NotificationDataFields.notifDate: dataRow["dt_out"].toString(),
                NotificationDataFields.status: dataRow["status"].toString(),
                NotificationDataFields.isActive:
                    dataRow["is_active"].toString(),
                NotificationDataFields.dtIn: dataRow["dt_in"].toString(),
              };
              await NotificationDatabase.instance
                  .insertUpdate(resData)
                  .then((updateProcess) {
                NotificationController.scheduleNewNotification(
                    int.parse(dataRow["reservation_id"].toString()),
                    "Check In",
                    "Your Parking at ${dataRow["notes"]} is about to expire.",
                    dataRow["dt_out"].toString(),
                    "custom_Screen");
              });
            } else {
              if (int.parse(dataRow["reservation_id"].toString()) ==
                      int.parse(returnData["reserved_id"].toString()) &&
                  dataRow["is_active"].toString() == "N") {
                NotificationController.cancelNotificationsById(
                    returnData["reserved_id"]);
                await NotificationDatabase.instance
                    .deleteItem(dataRow["reservation_id"]);
              } else {}
            }
          }
        });
      }
    }
  });
}
//GET PARKING QUE

Future<void> getParkingQueue() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var akongId = prefs.getString('myId');
  if (akongId == null) return;
  HttpRequest(
    api: "${ApiKeys.gApiLuvParkResQueue}?user_id=${akongId.toString()}",
  ).get().then((queueData) async {
    if (queueData == "No Internet") {
      return;
    }
    // if (queueData != null) {}
  });
}

//GET MEssage from PA
Future<void> getMessNotif() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var akongId = prefs.getString('myId');
  print("message notif $akongId");
  if (akongId == null) return;
  HttpRequest(
    api: "${ApiKeys.gApiLuvParkMessageNotif}?user_id=$akongId",
  ).get().then((messageData) async {
    if (messageData == "No Internet" || messageData == null) {
      return;
    }
    if (messageData["items"].isNotEmpty) {
      List<Map<String, dynamic>> convertedItems = [];
      if (messageData["items"] is List<dynamic>) {
        if (messageData["items"]
            .every((item) => item is Map<String, dynamic>)) {
          convertedItems = messageData["items"].cast<Map<String, dynamic>>();
        }
      }

      Map<String, dynamic> lastDatabaseRow = convertedItems.last;
      int lastDatabaseId = int.parse(lastDatabaseRow["push_msg_id"].toString());
      var lsMsgId = prefs.getInt("last_sync_msg_id");

      if (lsMsgId == null || int.parse(lsMsgId.toString()) < lastDatabaseId) {
        prefs.setInt("last_sync_msg_id", lastDatabaseId);
        if (lsMsgId != null) {
          NotificationController.cancelNotificationsById(
              int.parse(lsMsgId.toString()));
          AwesomeNotifications().dismiss(int.parse(lsMsgId.toString()));
        }
        NotificationController.createInformationMessage(
            lastDatabaseId,
            0,
            'Attention',
            "You have ${messageData["items"].length} message from your parking attendant",
            "message");
        for (dynamic dataRow in messageData["items"]) {
          PaMessageDatabase.instance
              .readNotificationById(dataRow["push_msg_id"])
              .then((objData) {
            if (objData == null) {
              Object json = {
                PaMessageDataFields.pushMsgId: dataRow["push_msg_id"],
                PaMessageDataFields.userId: dataRow["user_id"],
                PaMessageDataFields.message: dataRow["message"],
                PaMessageDataFields.createdDate: dataRow["created_on"],
                PaMessageDataFields.status: dataRow["push_status"],
                PaMessageDataFields.runOn: dataRow["run_on"],
              };
              PaMessageDatabase.instance
                  .insertUpdate(json)
                  .then((value) => null);
            }
          });
        }
      }
    }
  });
}

List<dynamic> getLastColumn(List<Map<String, dynamic>> list) {
  List<dynamic> lastColumn = [];

  for (var map in list) {
    // Get all keys of the map
    List<String> keys = map.keys.toList();

    // Get the last key (last column)
    String lastKey = keys.last;

    // Get the value corresponding to the last key
    dynamic lastValue = map[lastKey];

    lastColumn.add(lastValue);
  }

  return lastColumn;
}
