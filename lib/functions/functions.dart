import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as gmp;
import 'package:http/http.dart' as http;
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';
import 'package:luvpark_get/location_auth/location_auth.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:luvpark_get/sqlite/pa_message_table.dart';
import 'package:luvpark_get/sqlite/reserve_notification_table.dart';
import 'package:luvpark_get/sqlite/share_location_table.dart';
import 'package:luvpark_get/sqlite/vehicle_brands_table.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../notification_controller.dart';

class Functions {
  static GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
  static Future<Uint8List> getSearchMarker(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static Future<void> getUserBalance(context, Function cb) async {
    Authentication().getUserData().then((userData) {
      if (userData == null) {
        cb([
          {"has_net": true, "success": false, "items": []}
        ]);
        CustomDialog().errorDialog(context, "", "No data found.", () {
          Get.back();
        });
      } else {
        var user = jsonDecode(userData);

        String subApi =
            "${ApiKeys.gApiSubFolderGetBalance}?user_id=${user["user_id"]}";

        HttpRequest(api: subApi).get().then((returnBalance) async {
          if (returnBalance == "No Internet") {
            cb([
              {"has_net": false, "success": false, "items": []}
            ]);
            CustomDialog().internetErrorDialog(context, () {
              Get.back();
            });
            return;
          }
          if (returnBalance == null) {
            cb([
              {"has_net": true, "success": false, "items": []}
            ]);

            CustomDialog().errorDialog(
              context,
              "Error",
              "Error while connecting to server, Please try again.",
              () {
                Get.back();
              },
            );

            return;
          }
          if (returnBalance["items"].isEmpty) {
            CustomDialog().errorDialog(context, "Error",
                "There ase some changes made in your account. please contact support.",
                () async {
              SharedPreferences pref = await SharedPreferences.getInstance();
              Navigator.pop(context);

              await NotificationDatabase.instance
                  .readAllNotifications()
                  .then((notifData) async {
                if (notifData.isNotEmpty) {
                  for (var nData in notifData) {
                    NotificationController.cancelNotificationsById(
                        nData["reserved_id"]);
                  }
                }
                var logData = pref.getString('loginData');
                var mappedLogData = [jsonDecode(logData!)];
                mappedLogData[0]["is_active"] = "N";
                pref.setString("loginData", jsonEncode(mappedLogData[0]!));
                pref.remove('myId');
                NotificationDatabase.instance.deleteAll();
                PaMessageDatabase.instance.deleteAll();
                ShareLocationDatabase.instance.deleteAll();
                NotificationController.cancelNotifications();
                //  ForegroundNotif.onStop();
                Authentication().clearPassword();
                Get.offAndToNamed(Routes.login);
              });
            });
          } else {
            cb([
              {
                "has_net": true,
                "success": true,
                "items": returnBalance["items"]
              }
            ]);
          }
        });
      }
    });
  }

  static Future<void> getUserBalance2(context, Function cb) async {
    void logoutAccount() async {
      CustomDialog().errorDialog(context, "Error",
          "There ase some changes made in your account. please contact support.",
          () async {
        SharedPreferences pref = await SharedPreferences.getInstance();
        Navigator.pop(context);

        await NotificationDatabase.instance
            .readAllNotifications()
            .then((notifData) async {
          if (notifData.isNotEmpty) {
            for (var nData in notifData) {
              NotificationController.cancelNotificationsById(
                  nData["reserved_id"]);
            }
          }
          var logData = pref.getString('loginData');
          var mappedLogData = [jsonDecode(logData!)];
          mappedLogData[0]["is_active"] = "N";
          pref.setString("loginData", jsonEncode(mappedLogData[0]!));
          pref.remove('myId');
          NotificationDatabase.instance.deleteAll();
          PaMessageDatabase.instance.deleteAll();
          ShareLocationDatabase.instance.deleteAll();
          NotificationController.cancelNotifications();
          //  ForegroundNotif.onStop();
          Authentication().clearPassword();
          Get.offAndToNamed(Routes.login);
        });
      });
    }

    Authentication().getUserData().then((userData) {
      if (userData == null) {
        cb([
          {"has_net": true, "success": false, "items": []}
        ]);
        logoutAccount();
      } else {
        var user = jsonDecode(userData);

        String subApi =
            "${ApiKeys.gApiSubFolderGetBalance}?user_id=${user["user_id"]}";

        HttpRequest(api: subApi).get().then((returnBalance) async {
          if (returnBalance == "No Internet") {
            cb([
              {"has_net": false, "success": false, "items": []}
            ]);

            return;
          }
          if (returnBalance == null) {
            cb([
              {"has_net": true, "success": false, "items": []}
            ]);

            return;
          }
          if (returnBalance["items"].isEmpty) {
            logoutAccount();
          } else {
            cb([
              {
                "has_net": true,
                "success": true,
                "items": returnBalance["items"]
              }
            ]);
          }
        });
      }
    });
    // final prefs = await SharedPreferences.getInstance();
    // var myData = prefs.getString(
    //   'userData',
    // );
  }

  Future<void> loginFunc(pass, mobile, context, Function cb) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> postParam = {
      "mobile_no": mobile,
      "pwd": pass,
    };
    HttpRequest(api: ApiKeys.gApiSubFolderPostLogin, parameters: postParam)
        .post()
        .then((returnPost) {
      if (returnPost == "No Internet") {
        CustomDialog().internetErrorDialog(context, () {
          cb("No Internet");
          Get.back();
        });

        return;
      }

      if (returnPost == null) {
        CustomDialog().errorDialog(
          context,
          "Error",
          "Error while connecting to server, Please try again.",
          () {
            cb("null");
            Get.back();
          },
        );

        return;
      } else {
        if (returnPost["success"] == "N") {
          CustomDialog().errorDialog(
            context,
            "Error",
            "${returnPost["msg"]}",
            () {
              cb("null");
              Get.back();
            },
          );
          return;
        }
        if (returnPost["success"] == 'Y') {
          var getApi =
              "${ApiKeys.gApiSubFolderLogin}?mobile_no=$mobile&auth_key=${returnPost["auth_key"].toString()}";
          HttpRequest(api: getApi).get().then((objData) async {
            if (objData == "No Internet") {
              CustomDialog().internetErrorDialog(context, () {
                cb("No Internet");
                Get.back();
              });

              return;
            }

            if (objData == null) {
              //   Navigator.of(context).pop();
              CustomDialog().errorDialog(
                context,
                "Error",
                "Error while connecting to server, Please try again.",
                () {
                  cb("null");
                  Get.back();
                },
              );

              return;
            } else {
              if (objData["items"].length == 0) {
                CustomDialog().errorDialog(
                  context,
                  "Error",
                  objData["items"]["msg"],
                  () {
                    cb("null");
                    Get.back();
                  },
                );

                return;
              } else {
                if (objData["items"][0]["msg"] == 'Y') {
                  //    final service = FlutterBackgroundService();
                  prefs.remove('loginData');
                  prefs.remove('userData');
                  prefs.remove('geo_connect_id');
                  var items = objData["items"][0];

                  var logData = prefs.getString(
                    'loginData',
                  );
                  var myId = prefs.getString(
                    'myId',
                  );
                  prefs.setBool('isLoggedIn', true);

                  //   service.invoke("stopService");
                  tz.initializeTimeZones();

                  if (logData == null) {
                    Map<String, dynamic> parameters = {
                      "mobile_no": mobile,
                      "is_active": "Y",
                    };
                    await prefs.setString('loginData', jsonEncode(parameters));
                    Authentication().setPasswordBiometric(pass);
                  } else {
                    var logData2 = prefs.getString(
                      'loginData',
                    );

                    var mappedLogData = [jsonDecode(logData2!)];
                    mappedLogData[0]["is_active"] = "Y";
                    await prefs.setString(
                        'loginData', jsonEncode(mappedLogData[0]));

                    Authentication().setPasswordBiometric(pass);
                  }

                  // ignore: use_build_context_synchronously
                  if (myId != null) {
                    if (int.parse(myId.toString()) !=
                        int.parse(items['user_id'].toString())) {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      await NotificationDatabase.instance.deleteAll();
                      NotificationController.cancelNotifications();
                      NotificationDatabase.instance.deleteAll();
                      PaMessageDatabase.instance.deleteAll();
                      ShareLocationDatabase.instance.deleteAll();
                      pref.remove('myId');
                      pref.clear();
                      var mPinParams = {
                        "user_id": items['user_id'].toString(),
                        "is_on": "N"
                      };

                      HttpRequest(
                              api: ApiKeys.gApiSubFolderPutSwitch,
                              parameters: mPinParams)
                          .put();
                    }
                  }

                  await prefs.setString('myId', items['user_id'].toString());
                  await prefs.setString('userData', jsonEncode(items));
                  await prefs.setString(
                      'myProfilePic', jsonEncode(items["image_base64"]));

                  cb([true, "Success"]);
                  prefs.remove(
                    'provinceData',
                  );
                  prefs.remove(
                    'cityData',
                  );
                  prefs.remove(
                    'brgyData',
                  );

                  //Variables.pageTrans(const MainLandingScreen(), context);
                } else {
                  if (objData["items"][0]["msg"] == 'Not Yet Registered') {
                    CustomDialog().confirmationDialog(
                        context,
                        "Inactive Account",
                        "Your account is currently inactive. Would you like to activate it now?",
                        "No",
                        "Yes", () {
                      cb([false, "No"]);
                      Get.back();
                    }, () {
                      cb([false, "No"]);
                      Get.back();
                    });

                    return;
                  } else {
                    CustomDialog().errorDialog(
                      context,
                      "Error",
                      objData["items"][0]["msg"],
                      () {
                        cb([false, "No"]);
                        Get.back();
                      },
                    );

                    return;
                  }
                }
              }
            }
          });
        }
      }
    });
  }

  static Future<void> getLocation(BuildContext context, Function cb) async {
    try {
      List ltlng = await Functions.getCurrentPosition();

      if (ltlng.isNotEmpty) {
        Map<String, dynamic> firstItem = ltlng[0];
        if (firstItem.containsKey('lat') && firstItem.containsKey('long')) {
          double lat = double.parse(firstItem['lat'].toString());
          double long = double.parse(firstItem['long'].toString());
          cb(LatLng(lat, long));
        } else {
          cb(null);
        }
      } else {
        cb(null);
      }
    } catch (e) {
      cb(null);
    }
  }

  static Future<List> getCurrentPosition() async {
    final position = await geolocatorPlatform.getCurrentPosition();

    return [
      {"lat": position.latitude, "long": position.longitude}
    ];
  }

  static hasInternetConnection(Function callBack) async {
    try {
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final ping = Ping('google.com', count: 1);

        ping.stream.listen((event) {
          if (event.summary == null) {
          } else {
            if (event.summary!.received > 0) {
              callBack(true);
            } else {
              callBack(false);
            }
          }
        });
      } else {
        callBack(false);
      }
    } on SocketException catch (_) {
      callBack(false);
    }
  }

  //search place
  static Future<void> searchPlaces(
      context, String query, Function callback) async {
    hasInternetConnection((hasInternet) async {
      if (hasInternet) {
        try {
          final places = gmp.GoogleMapsPlaces(
              apiKey:
                  'AIzaSyCaDHmbTEr-TVnJY8dG0ZnzsoBH3Mzh4cE'); // Replace with your API key
          gmp.PlacesSearchResponse response = await places.searchByText(query);

          if (response.isOkay && response.results.isNotEmpty) {
            callback([
              response.results[0].geometry!.location.lat,
              response.results[0].geometry!.location.lng,
            ]);
            return;
          } else {
            callback([]);
            CustomDialog().errorDialog(context, "luvpark", "No data found", () {
              Get.back();
            });
          }
        } catch (e) {
          callback([]);
          CustomDialog().errorDialog(
              context, "Error", "An error occured while getting data.", () {
            Get.back();
          });
        }
      } else {
        callback([]);
        CustomDialog().internetErrorDialog(context, () {
          Get.back();
        });
      }
    });
  }

  //Checking if open area
  static bool checkAvailability(String startTimeStr, String endTimeStr) {
    // Get the current time
    DateTime currentTime = DateTime.now();

    // Parse start and end times
    List<String> startParts = startTimeStr.split(':');
    List<String> endParts = endTimeStr.split(':');

    int startHour = int.parse(startParts[0]);
    int startMinute = int.parse(startParts[1]);

    int endHour = int.parse(endParts[0]);
    int endMinute = int.parse(endParts[1]);

    DateTime startTime = DateTime(currentTime.year, currentTime.month,
        currentTime.day, startHour, startMinute);
    DateTime endTime = DateTime(currentTime.year, currentTime.month,
        currentTime.day, endHour, endMinute);

    // Check if the current time is between start and end times
    if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
      return true;
    } else {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchETA(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final String apiUrl =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=${Variables.mapApiKey}';

      final response = await http.get(Uri.parse(apiUrl));

      // Check if response status is OK
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if the status of the data is OK
        if (data['status'] == 'OK') {
          final List<dynamic> routes = data['routes'];

          // Ensure that there is at least one route
          if (routes.isNotEmpty) {
            final Map<String, dynamic> route = routes.first;
            final Map<String, dynamic> leg = route['legs'].first;

            final String etaText = leg['duration']['text'];
            final String distanceText = leg['distance']['text'];
            final String? points = route['overview_polyline']?['points'];

            // Decode the polyline points if available
            final List<LatLng> polylineCoordinates =
                points != null ? decodePolyline(points) : [];

            return [
              {
                "distance": distanceText,
                "time": etaText,
                "poly_line": polylineCoordinates
              }
            ];
          }
        }
      }
      // Return an empty list in case of errors or no data
      return [];
    } catch (e) {
      // Return error indicator if an exception occurs
      return [
        {"error": "No Internet"}
      ];
    }
  }

  // Example decodePolyline method (ensure this exists in your code)

  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latDouble = lat / 1e5;
      double lngDouble = lng / 1e5;
      poly.add(LatLng(latDouble, lngDouble));
    }

    return poly;
  }

  static Future<String?> getAddress(double lat, double long) async {
    try {
      final startTime = DateTime.now();

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      Placemark placemark = placemarks[0];
      String locality = placemark.locality.toString();
      String subLocality = placemark.subLocality.toString();
      String street = placemark.street.toString();
      String subAdministrativeArea = placemark.subAdministrativeArea.toString();
      String myAddress =
          "$street,$subLocality,$locality,$subAdministrativeArea.";
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // Use the duration as the delay
      await Future.delayed(duration);

      return myAddress;
    } catch (e) {
      return null;
    }
  }

  static Future<void> computeDistanceResorChckIN(
      context, LatLng dest, Function cb) async {
    LocationService.grantPermission(Get.context!, (isGranted) {
      if (isGranted) {
        Functions.getLocation(context, (location) {
          LatLng ll = location;

          hasInternetConnection((hasInternet) async {
            if (hasInternet) {
              final estimatedData = await Functions.fetchETA(
                  LatLng(ll.latitude, ll.longitude), dest);

              if (estimatedData[0]["error"] == "No Internet") {
                cb({"success": false});

                CustomDialog().internetErrorDialog(context, () {
                  Get.back();
                });
                return;
              }
              if (estimatedData.isEmpty) {
                cb({"success": false});
                CustomDialog().errorDialog(context, "luvpark",
                    Variables.popUpMessageOutsideArea, () {});
                return;
              } else {
                const HttpRequest(api: ApiKeys.gApiLuvParkGetComputeDistance)
                    .get()
                    .then((returnData) async {
                  if (returnData == "No Internet") {
                    cb({"success": false});
                    CustomDialog().internetErrorDialog(context, () {
                      Get.back();
                    });
                    return;
                  }
                  if (returnData == null) {
                    cb({"success": false});
                    CustomDialog().serverErrorDialog(context, () {
                      Get.back();
                    });

                    return;
                  } else {
                    bool canCheckIn = Variables.convertToMeters2(
                                estimatedData[0]["distance"]) >
                            5
                        ? false
                        : true;
                    //COMPUTE DISTANCE BY TIME IF AVAILABLE FOR RESERVATION`
                    if (returnData["items"][0]["user_chk_in_um"] == "TM") {
                      int estimatedMinute = int.parse(
                          estimatedData[0]["time"].toString().split(" ")[0]);
                      // double distanceCanChkIn = Variables.convertToMeters(
                      //     returnData["items"][0]["user_chk_in_within"]
                      //         .toString());
                      //COMPUTE DISTANCE BY TIME IF ABLE TO RESERVE BY 20000 METERS AWAY`
                      if (estimatedMinute >=
                              int.parse(returnData["items"][0]["min_psr_from"]
                                  .toString()) &&
                          estimatedMinute <=
                              int.parse(returnData["items"][0]["max_psr_from"]
                                  .toString())) {
                        cb({
                          "success": true,
                          // "can_checkIn": estimatedMinute <= distanceCanChkIn,
                          "can_checkIn": canCheckIn,
                          "location": ll,
                          "message":
                              "Early check-in is not allowed if you are more than ${returnData["items"][0]["user_chk_in_within"].toString()} minutes away from the selected parking area.",
                        });
                      } else {
                        cb({"success": false});

                        CustomDialog().errorDialog(context, "luvpark",
                            "Early booking is not allowed if you are more than ${returnData["items"][0]["max_psr_from"].toString()} minutes away from the selected parking area.",
                            () {
                          Get.back();
                        });
                      }
                    } else {
                      //COMPUTE DISTANCE BY DISTANCE IN METERS IF AVAILABLE FOR RESERVATION
                      double estimatedDistance = Variables.convertToMeters2(
                          estimatedData[0]["distance"].toString());
                      double minDistance = Variables.convertToMeters2(
                          returnData["items"][0]["min_psr_from"].toString());
                      // double maxDistance = double.parse(
                      //     returnData["items"][0]["max_psr_from"].toString());
                      double distanceCanChkIn = Variables.convertToMeters2(
                          "${returnData["items"][0]["user_chk_in_within"].toString()} km");

                      if (estimatedDistance.toDouble() >=
                              minDistance.toDouble() &&
                          estimatedDistance.toDouble() <=
                              distanceCanChkIn.toDouble()) {
                        cb({
                          "success": true,
                          // "can_checkIn": estimatedDistance <= distanceCanChkIn,
                          "can_checkIn": canCheckIn,
                          "location": ll,
                          "message": "",
                        });
                      } else {
                        cb({"success": false});
                        CustomDialog().errorDialog(context, "luvpark",
                            "Early booking is not allowed if you are more than ${returnData["items"][0]["max_psr_from"].toString()} meters away from the selected parking area.",
                            () {
                          Get.back();
                        });
                      }
                    }
                  }
                });
              }
            } else {
              cb({"success": false});
              CustomDialog().internetErrorDialog(context, () {
                Get.back();
              });
              return;
            }
          });
        });
      } else {
        CustomDialog()
            .errorDialog(context, "luvpark", "No permissions granted.", () {
          Get.back();
        });
      }
    });
  }

  static Future<String> getBrandName(int vtId, int vbId) async {
    final String? brandName =
        await VehicleBrandsTable.instance.readVehicleBrandsByVbId(vtId, vbId);

    return brandName!;
  }
}
