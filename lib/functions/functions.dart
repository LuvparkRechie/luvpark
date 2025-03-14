import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as gmp;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';
import 'package:luvpark/location_auth/location_auth.dart';
import 'package:luvpark/routes/routes.dart';
import 'package:luvpark/sqlite/pa_message_table.dart';
import 'package:luvpark/sqlite/reserve_notification_table.dart';
import 'package:luvpark/sqlite/share_location_table.dart';
import 'package:luvpark/sqlite/vehicle_brands_table.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../notification_controller.dart';
import '../sqlite/vehicle_brands_model.dart';

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
        String subApi = "${ApiKeys.getUserBalance}${user["user_id"]}";

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
                // Authentication().clearPassword();
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
          // Authentication().clearPassword();
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

        String subApi = "${ApiKeys.getUserBalance}${user["user_id"]}";

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

  // //search place
  // static Future<void> searchPlaces(
  //     context, String query, Function callback) async {
  //   hasInternetConnection((hasInternet) async {
  //     if (hasInternet) {
  //       try {
  //         final places = gmp.GoogleMapsPlaces(
  //             apiKey:
  //                 'AIzaSyCaDHmbTEr-TVnJY8dG0ZnzsoBH3Mzh4cE'); // Replace with your API key
  //         gmp.PlacesSearchResponse response = await places.searchByText(query);

  //         if (response.isOkay && response.results.isNotEmpty) {
  //           callback([
  //             response.results[0].geometry!.location.lat,
  //             response.results[0].geometry!.location.lng,
  //           ]);
  //           return;
  //         } else {
  //           callback([]);
  //           CustomDialog().errorDialog(context, "luvpark", "No data found", () {
  //             Get.back();
  //           });
  //         }
  //       } catch (e) {
  //         callback([]);
  //         CustomDialog().errorDialog(
  //             context, "Error", "An error occured while getting data.", () {
  //           Get.back();
  //         });
  //       }
  //     } else {
  //       callback([]);
  //       CustomDialog().internetErrorDialog(context, () {
  //         Get.back();
  //       });
  //     }
  //   });
  // }

  static Future<void> searchPlaces(
      BuildContext context, String query, Function callback) async {
    try {
      final places = gmp.GoogleMapsPlaces(apiKey: Variables.mapApiKey);
      gmp.PlacesSearchResponse response = await places.searchByText(query);

      if (response.isOkay) {
        if (response.results.isNotEmpty) {
          var location = response.results[0].geometry?.location;

          if (location == null) {
            throw Exception("Invalid location data received");
          }

          callback([location.lat, location.lng]);
          return;
        } else {
          callback([]);
          CustomDialog()
              .errorDialog(context, "luvpark", "No parking areas found.", () {
            Get.back();
          });
          return;
        }
      } else {
        callback([]);
        CustomDialog().errorDialog(
            context, "Error", "Failed to retrieve data. Please try again.", () {
          Get.back();
        });
        return;
      }
    } catch (e) {
      callback([]);
      CustomDialog().errorDialog(context, "Error", "$e", () {
        Get.back();
      });
      return;
    }
  }

  //Checking if open area
  static Future<bool> checkAvailability(
      String startTimeStr, String endTimeStr) async {
    // Get the current time

    // Get the current time
    DateTime currentTime = await Functions.getTimeNow();

    // Parse start and end times
    List<String> startParts = startTimeStr.split(':');
    List<String> endParts = endTimeStr.split(':');

    int startHour = int.parse(startParts[0]);
    int startMinute = int.parse(startParts[1]);
    int endHour = int.parse(endParts[0]);
    int endMinute = int.parse(endParts[1]);

    // Create DateTime objects for start and end times
    DateTime startTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      startHour,
      startMinute,
    );

    DateTime endTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      endHour,
      endMinute,
    );

    // Check if the current time is between start and end times
    return currentTime.isAfter(startTime) && currentTime.isBefore(endTime);
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
      DateTime startTime = await Functions.getTimeNow();

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      Placemark placemark = placemarks[0];
      String locality = placemark.locality.toString();
      String subLocality = placemark.subLocality.toString();
      String street = placemark.street.toString();
      String subAdministrativeArea = placemark.subAdministrativeArea.toString();
      String myAddress =
          "$street,$subLocality,$locality,$subAdministrativeArea.";

      final duration = startTime.difference(startTime);

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
        Functions.getLocation(context, (location) async {
          LatLng ll = location;

          bool hasNet = await Variables.checkInternet();
          if (hasNet) {
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
              CustomDialog().errorDialog(
                  context, "luvpark", Variables.popUpMessageOutsideArea, () {});
              return;
            } else {
              HttpRequest(api: ApiKeys.getComputeDistance)
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
                  bool canCheckIn =
                      Variables.convertToMeters2(estimatedData[0]["distance"]) >
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

  static Future<List> getBranding(int typeId, int brandId) async {
    List data = await VehicleBrandsTable.instance.readAllVHBrands();

    List fData = [];
    fData = data.where((objData) {
      return objData["vehicle_type_id"] == typeId &&
          objData["vehicle_brand_id"] == brandId;
    }).toList();
    return fData;
  }

  //sort json data by key
  static List<dynamic> sortJsonList(List<dynamic> jsonList, String key,
      {bool ascending = true}) {
    jsonList.sort((a, b) {
      final comparison = a[key].compareTo(b[key]);
      return ascending ? comparison : -comparison;
    });
    return jsonList.reversed.toList();
  }

  static Future<DateTime> getTimeNow() async {
    try {
      DateTime timeNow = await NTP.now().timeout(Duration(seconds: 2));
      return timeNow;
    } catch (e) {
      return DateTime.now();
    }
  }

  static Future<dynamic> getVhBrands() async {
    String apiParam = ApiKeys.getVehicleBrands;

    final response = await HttpRequest(api: apiParam).get();
    if (response == "No Internet") {
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return {"response": response, "data": []};
    }
    if (response == null) {
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return {"response": response, "data": []};
    }
    if (response["items"].isEmpty) {
      CustomDialog().infoDialog("lvupark",
          "No data found for vehicle brands. Please contact support.", () {
        Get.back();
      });
      return {"response": "No data", "data": []};
    } else {
      VehicleBrandsTable.instance.deleteAll();
      for (var dataRow in response["items"]) {
        var vbData = {
          VHBrandsDataFields.vhTypeId:
              int.parse(dataRow["vehicle_type_id"].toString()),
          VHBrandsDataFields.vhBrandId:
              int.parse(dataRow["vehicle_brand_id"].toString()),
          VHBrandsDataFields.vhBrandName:
              dataRow["vehicle_brand_name"].toString(),
          VHBrandsDataFields.image: dataRow["imageb64"] == null
              ? ""
              : dataRow["imageb64"].toString().replaceAll("\n", ""),
        };
        await VehicleBrandsTable.instance.insertUpdate(vbData);
      }

      return {"response": "Success", "data": response["items"]};
    }
  }

  static Future<dynamic> generateQr() async {
    int userId = await Authentication().getUserId();
    String apiParam = ApiKeys.generatePayKey;
    dynamic param = {"luvpay_id": userId};

    final response = await HttpRequest(api: apiParam, parameters: param).put();

    Get.back();
    if (response == "No Internet") {
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return {"response": response, "data": []};
    }
    if (response == null) {
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return {"response": response, "data": []};
    }
    if (response["success"] == 'N') {
      CustomDialog().infoDialog(
          "lvupark", "No data found for app version. Please contact support.",
          () {
        Get.back();
      });
      return {"response": "No data", "data": response["items"][0]};
    } else {
      return {"response": "Success", "data": response["payment_hk"]};
    }
  }

  static void popPage([int times = 1]) {
    for (int i = 0; i < times; i++) {
      Get.back();
    }
  }

// tracking if has service fee
  static bool isValidInput(double inputAmount, serviceFee, balance) {
    double totalAmount = inputAmount + serviceFee;
    return totalAmount <= balance;
  }

  // i used this to generate unique secret key
  static Uint8List generateKey(String key, int length) {
    var keyBytes = utf8.encode(key);
    if (keyBytes.length < length) {
      keyBytes = Uint8List.fromList(
          [...keyBytes, ...List.filled(length - keyBytes.length, 0)]);
    } else if (keyBytes.length > length) {
      keyBytes = keyBytes.sublist(0, length);
    }
    return Uint8List.fromList(keyBytes);
  }

  //Logout users
  static Future<void> logoutUser(String sessionId, Function cb) async {
    CustomDialog().loadingDialog(Get.context!);

    if (sessionId.isEmpty) {
      cb({"is_true": true, "data": 0});
      Get.back();
      return;
    }

    DateTime timeNow = await Functions.getTimeNow();
    String formattedDt = DateFormat('yyyy-MM-dd HH:mm:ss').format(timeNow);

    Map<String, dynamic> putLogoutParam = {
      "dt_out": formattedDt,
      "session_id": sessionId
    };

    final response =
        await HttpRequest(api: ApiKeys.putLogout, parameters: putLogoutParam)
            .putBody();

    Get.back();
    if (response == "No Internet") {
      cb({"is_true": false, "data": 0});
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    if (response == null) {
      cb({"is_true": false, "data": 0});
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    if (response["success"] == "Y") {
      cb({"is_true": true, "data": response["user_id"]});

      Authentication().enableTimer(false);
      return;
    } else {
      cb({"is_true": false, "data": 0});
      CustomDialog().errorDialog(Get.context!, "Error", response["msg"], () {
        Get.back();
      });
      return;
    }
  }

  //Logout users
  static Future<void> logoutUserSession(String sessionId, Function cb) async {
    DateTime timeNow = await Functions.getTimeNow();
    String formattedDt = DateFormat('yyyy-MM-dd HH:mm:ss').format(timeNow);

    Map<String, dynamic> putLogoutParam = {
      "dt_out": formattedDt,
      "session_id": sessionId
    };

    final response =
        await HttpRequest(api: ApiKeys.putLogout, parameters: putLogoutParam)
            .putBody();

    if (response == "No Internet") {
      cb({"is_true": false, "data": 0});
      CustomDialog().internetErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    if (response == null) {
      cb({"is_true": false, "data": 0});
      CustomDialog().serverErrorDialog(Get.context!, () {
        Get.back();
      });
      return;
    }
    if (response["success"] == "Y") {
      cb({"is_true": true, "data": response["user_id"]});

      Authentication().enableTimer(false);
      return;
    } else {
      cb({"is_true": false, "data": 0});
      CustomDialog().errorDialog(Get.context!, "Error", response["msg"], () {
        Get.back();
      });
      return;
    }
  }

  Future<String> getUniqueDeviceId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedDeviceId = prefs.getString('device_id');

    if (storedDeviceId == null) {
      var uuid = Uuid();
      storedDeviceId = uuid.v4();
      await prefs.setString('device_id', storedDeviceId);
    }

    return storedDeviceId;
  }

  Future<void> requestOtp(Map<String, String> param, Function cb) async {
    CustomDialog().loadingDialog(Get.context!);

    HttpRequest(api: ApiKeys.postGenerateOtp, parameters: param)
        .postBody()
        .then((returnData) async {
      Get.back();

      if (returnData == "No Internet") {
        cb(returnData);
        CustomDialog().errorDialog(Get.context!, "Error",
            "Please check your internet connection and try again.", () {
          Get.back();
        });

        return;
      }
      if (returnData == null) {
        cb(returnData);
        CustomDialog().errorDialog(Get.context!, "Error",
            "Error while connecting to server, Please try again.", () {
          Get.back();
        });

        return;
      }

      if (returnData["success"] == 'Y') {
        cb(returnData);
        return;
      } else {
        CustomDialog().errorDialog(
            Get.context!, "Security Warning", returnData["msg"], () {
          Get.back();
          if (returnData["status"] == "PENDING") {
            cb(returnData);
            return;
          }
          if (returnData["status"] == "LOCKED") {
            List mapData = [returnData];

            mapData = mapData.map((e) {
              e["mobile_no"] = param["mobile_no"];
              return e;
            }).toList();

            Future.delayed(Duration(milliseconds: 200), () {
              Get.offAllNamed(Routes.lockScreen, arguments: mapData);
            });
          }
        });
        return;
      }
    });
  }
  //check user status

  Future<void> verifyMobile(String mobileNo, Function cb) async {
    CustomDialog().loadingDialog(Get.context!);
        HttpRequest(api: "${ApiKeys.getAcctStatus}$mobileNo/vlevel")
        .get()
        .then((objData) {
      Get.back();
      if (objData == "No Internet") {
        cb({"success": false, "data": {}});
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });

        return;
      }
      if (objData == null) {
        cb({"success": false, "data": {}});
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      } else {
        if (objData["success"] == "Y") {
          cb({"success": true, "data": objData});
        } else {
          cb({"success": true, "data": {}});
          CustomDialog().errorDialog(Get.context!, "luvpark", objData["msg"],
              () {
            Get.back();
          });
          return;
        }
      }
    });
  }

  void getSecQdata(mobile, Function cb) {
    CustomDialog().loadingDialog(Get.context!);
    Random random = Random();
    int myRan = random.nextInt(3) + 1;

    String subApi = "${ApiKeys.getSecQue}?mobile_no=$mobile&secq_no=$myRan";

    HttpRequest(api: subApi).get().then((returnData) {
      Get.back();
      if (returnData == "No Internet") {
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });

        return;
      }
      if (returnData == null) {
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      } else {
        if (returnData["items"].isNotEmpty) {
          List seqData = returnData["items"];
          seqData = seqData.map((e) {
            e["secq_no"] = myRan;
            return e;
          }).toList();

          cb(seqData);
        } else {
          CustomDialog().errorDialog(Get.context!, "luvpark",
              "Make sure that you've entered the correct phone number.", () {
            Get.back();
          });
          return;
        }
      }
    });
  }

  void verifyAccount(String mobileNo, Function cb) async {
    CustomDialog().loadingDialog(Get.context!);
    var params = "${ApiKeys.verifyUserAccount}?mobile_no=$mobileNo";

    HttpRequest(
      api: params,
    ).get().then((objData) async {
      Get.back();
      if (objData == "No Internet") {
        cb({"success": false, "data": {}});
        CustomDialog().internetErrorDialog(Get.context!, () {
          Get.back();
        });

        return;
      }
      if (objData == null) {
        cb({"success": false, "data": {}});
        CustomDialog().serverErrorDialog(Get.context!, () {
          Get.back();
        });
        return;
      } else {
        if (objData["msg"] == "Success") {
          cb({"success": true, "data": objData});
        } else {
          cb({"success": false, "data": {}});
          CustomDialog().errorDialog(Get.context!, "luvpark", objData["msg"],
              () {
            Get.back();
          });
          return;
        }
      }
    });
  }
}
