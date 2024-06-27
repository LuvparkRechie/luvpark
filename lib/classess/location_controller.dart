import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:luvpark/bottom_tab/bottom_tab.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/permission/permission_handler.dart';

class LocationService {
  static Location location = Location();

  static Future<void> grantPermission(BuildContext context, Function cb) async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    // Check if location services are enabled

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Check and request location permissions
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        Variables.pageTrans(
            PermissionHandlerScreen(
              isLogin: true,
              index: 1,
              widget: MainLandingScreen(),
            ),
            context);
        return null;
      }
    }

    if (serviceEnabled && permissionGranted == PermissionStatus.granted) {
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
