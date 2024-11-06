import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';

class LocationService {
  static Location location = Location();

  static Future<void> grantPermission(BuildContext context, Function cb) async {
    PermissionStatus permissionGranted;
    bool serviceEnabled;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        CustomDialog().locationDialog("Location Services",
            "We need your location to display nearby parking options and give you accurate directions.",
            () {
          cb(false);
          AppSettings.openAppSettings(type: AppSettingsType.location);
        });

        return;
      }
    }

    // Check and request location permissions
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        cb(false);
        return;
      }
    }

    if (permissionGranted == PermissionStatus.granted) {
      cb(true);
    } else {
      cb(false);
    }
  }

  static Future<void> getLocations(BuildContext context, Function cb) async {
    LocationData? loc = await location.getLocation();
    if (loc.latitude != null) {
      cb(LatLng(loc.latitude!, loc.longitude!));
    }
  }
}
