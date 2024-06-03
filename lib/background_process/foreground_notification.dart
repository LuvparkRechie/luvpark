import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luvpark/notification_controller/notification_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class ForegroundNotif {
  static ReceivePort port = ReceivePort();

  static String logStr = '';
  static bool? isRunning;
  static LocationDto? lastLocation;
  static initializeForeground() async {
    onStop();
    if (IsolateNameServer.lookupPortByName(
            LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    port.listen(
      (dynamic data) async {
        await updateUI(data);
      },
    );
    await BackgroundLocator.initialize();

    final _isRunning = await BackgroundLocator.isServiceRunning();

    isRunning = _isRunning;
  }

  static Future<void> updateUI(dynamic data) async {
    LocationDto? locationDto =
        (data != null) ? LocationDto.fromJson(data) : null;

    if (locationDto != null) {
      await updateNotificationText();
    }

    if (data != null) {
      lastLocation = locationDto;
    }
  }

  static Future<void> updateNotificationText() async {
    await BackgroundLocator.updateNotificationText(
        title: "Active Sharing",
        msg: "You still have active sharing",
        bigMsg: "");
  }

  static Future<void> startLocator() async {
    final status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      Map<String, dynamic> data = {'countInit': 1};
      try {
        await BackgroundLocator.registerLocationUpdate(
          LocationCallbackHandler.callback,
          initCallback: LocationCallbackHandler.initCallback,
          initDataCallback: data,
          disposeCallback: LocationCallbackHandler.disposeCallback,
          iosSettings: IOSSettings(
              accuracy: LocationAccuracy.NAVIGATION,
              distanceFilter: 0,
              stopWithTerminate: true),
          autoStop: false,
          androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 5,
            distanceFilter: 0,
            client: LocationClient.google,
          ),
        );
      } catch (e) {
        print('Error: $e');
      }
    } else if (status.isDenied) {
      // Permission denied
      print('Location permission denied');
    }
  }

  static void onStop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    final _isRunning = await BackgroundLocator.isServiceRunning();

    isRunning = _isRunning;
  }
}

@pragma('vm:entry-point')
class LocationCallbackHandler {
  @pragma('vm:entry-point')
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  @pragma('vm:entry-point')
  static Future<void> disposeCallback() async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  @pragma('vm:entry-point')
  static Future<void> callback(LocationDto locationDto) async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.callback(locationDto);
  }

  @pragma('vm:entry-point')
  static Future<void> notificationCallback() async {}
}

class LocationServiceRepository {
  static LocationServiceRepository _instance = LocationServiceRepository._();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  static const String isolateName = 'LocatorIsolate';

  int count = -1;

  Future<void> init(Map<dynamic, dynamic> params) async {
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        count = tmpCount.toInt();
      } else if (tmpCount is String) {
        count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        count = tmpCount;
      } else {
        count = -2;
      }
    } else {
      count = 0;
    }
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> dispose() async {
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    updateLocation(LatLng(double.parse(locationDto.latitude.toString()),
        double.parse(locationDto.longitude.toString())));

    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto.toJson());
    count++;
  }

  static double dp(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  static String formatDateLog(DateTime date) {
    return date.hour.toString() +
        ":" +
        date.minute.toString() +
        ":" +
        date.second.toString();
  }

  static String formatLog(LocationDto locationDto) {
    return dp(locationDto.latitude, 4).toString() +
        " " +
        dp(locationDto.longitude, 4).toString();
  }
}
