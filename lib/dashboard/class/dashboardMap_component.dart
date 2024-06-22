import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as gmp;
import 'package:http/http.dart' as http;
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';

class DashboardComponent {
  static getNearest(context, String parkType, radius, lat, long, vhId, amenity,
      isAllowOverNight, Function callBack) async {
    var params =
        "${ApiKeys.gApiSubFolderGetNearestSpace}?is_allow_overnight=$isAllowOverNight&parking_type_code=$parkType&latitude=${lat.toString()}&longitude=${long.toString()}&radius=${radius.toString()}&parking_amenity_code=$amenity&vehicle_type_id=$vhId";
    print(params);
    try {
      var returnData = await HttpRequest(api: params).get();
      if (returnData == "No Internet") {
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();

          callBack("No Internet");
        });

        return;
      }

      if (returnData == null) {
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please contact support.", () {
          Navigator.of(context).pop();

          callBack([]);
        });

        return;
      } else {
        if (returnData["items"].isEmpty) {
          bool isDouble = radius.toString().contains(".");
          showAlertDialog(context, "Attention",
              "No parking area found within \n${(isDouble ? double.parse(radius.toString()) : int.parse(radius.toString())) >= 1 ? '${radius.toString()} Km' : '${double.parse(radius.toString()) * 1000} meters'}, please change location.",
              () {
            Navigator.of(context).pop();

            callBack([]);
          });

          return;
        } else {
          callBack(returnData["items"]);
          return;
        }
      }
    } catch (e) {
      return;
    }
  }

  static getNearestRefresh(
      context, String parkType, radius, lat, long, Function callBack) async {
    var params =
        "${ApiKeys.gApiSubFolderGetNearestSpace}?latitude=${lat.toString()}&longitude=${long.toString()}&parking_type_code=$parkType&radius=${radius.toString()}&no_hrs=1&vehicle_type_id=";

    try {
      var returnData = await HttpRequest(api: params).get();

      if (returnData == "No Internet") {
        callBack([]);
        return;
      }

      if (returnData == null) {
        callBack([]);
        return;
      } else {
        if (returnData["items"].length == 0) {
          callBack([]);
          return;
        } else {
          callBack(returnData["items"]);
          return;
        }
      }
    } catch (e) {
      return;
    }
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<Uint8List> getSearchMarker(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  List<String> suggestions = [];

  Future<List<String>> fetchSuggestions(
      String query, double lat, double long, String radius) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&location=$lat,$long&radius=${double.parse(radius.toString())}&key=${Variables.mapApiKey}';

    var links = http.get(Uri.parse(url));
    try {
      final response = await HttpRequest.fetchDataWithTimeout(links);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final predictions = data['predictions'];

        if (predictions != null) {
          List<String> suggestions = [];
          for (var prediction in predictions) {
            suggestions.add(
                "${prediction['description']}=Rechie=${prediction['place_id']}");
          }
          return suggestions;
        } else {
          return []; // Handle empty predictions list
        }
      } else {
        return []; // Handle non-200 status codes
      }
    } catch (e) {
      return ["No Internet"];
    }
  }

  Future<Location?> getCoordinates(String placeName) async {
    try {
      List<Location> locations =
          await locationFromAddress(placeName.toString().replaceAll(",", ""));
      if (locations.isNotEmpty) {
        Location location = locations[0];
        return location;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<LatLng> getCoordinatesFromPlaceName(String placeName) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeName&key=AIzaSyCaDHmbTEr-TVnJY8dG0ZnzsoBH3Mzh4cE');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final results = [data["result"]["geometry"]];

      if (results.isNotEmpty) {
        final location = results[0]['location'];
        return LatLng(location['lat'], location['lng']);
      }
    }

    throw Exception('Failed to get coordinates');
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

  //PURE accurate
  static Future<void> searchPlaces(
      context, String query, Function callback) async {
    Variables.hasInternetConnection((hasInternet) async {
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
            showAlertDialog(context, "Error", "No data found", () {
              Navigator.pop(context);
            });
          }
        } catch (e) {
          callback([]);
          showAlertDialog(context, "Error", "An error occurred", () {
            Navigator.pop(context);
          });
        }
      } else {
        callback([]);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again", () {
          Navigator.pop(context);
        });
      }
    });
  }

  static void getAvailableVehicle(context, vtypes, userId, Function cb) async {
    String api =
        "${ApiKeys.gApiLuvParkPostGetVehicleReg}?user_id=$userId&vehicle_types_id_list=$vtypes";
    CustomModal(context: context).loader();
    HttpRequest(api: api).get().then((myVehicles) async {
      if (myVehicles == "No Internet") {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
          cb("No Internet");
        });

        return;
      }
      if (myVehicles == null) {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Error while connecting to server, Contact support.", () {
          Navigator.of(context).pop();
          cb(null);
        });

        return;
      }

      if (myVehicles["items"].length > 0) {
        Navigator.of(context).pop();
        cb(myVehicles["items"]);
      } else {
        Navigator.of(context).pop();
        cb([]);

        return;
      }
    });
  }

  static Future<String> getBarangayInfo(
      double latitude, double longitude) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=${Variables.mapApiKey}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'OK') {
        final results = json['results'] as List;
        if (results.isNotEmpty) {
          // Extract the relevant information, e.g., barangay name
          final barangayName = results[0]['formatted_address'];
          return barangayName;
        }
      }
    }

    // Handle errors or no results found
    return 'Barangay information not available';
  }

  // static Future<Position> getPositionLatLong() async {
  //   Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  //   return position;
  // }

  static getRadius(context, Function callBack) async {
    try {
      var returnData =
          await const HttpRequest(api: ApiKeys.gApiSubFolderGetDDNearest).get();

      if (returnData == "No Internet") {
        callBack("No Internet");

        return;
      }

      if (returnData == null) {
        callBack("Error");
        return;
      } else {
        if (returnData["items"].length == 0) {
          callBack([]);
          return;
        } else {
          callBack(returnData["items"]);
          return;
        }
      }
    } catch (e) {
      return;
    }
  }

  static getParkingType(context, Function callBack) async {
    try {
      var returnData =
          await const HttpRequest(api: ApiKeys.gApiSubFolderGetParkingTypes)
              .get();

      if (returnData == "No Internet") {
        callBack("No Internet");

        return;
      }

      if (returnData == null) {
        callBack("Error");
        return;
      } else {
        if (returnData["items"].length == 0) {
          callBack([]);
          return;
        } else {
          callBack(returnData["items"]);
          return;
        }
      }
    } catch (e) {
      return;
    }
  }

  // Getting Distance

  static fetchETA(LatLng origin, LatLng destination, Function cb) async {
    try {
      final String apiUrl =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=${Variables.mapApiKey}';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final List<dynamic> routes = data['routes'];

          if (routes.isNotEmpty) {
            final Map<String, dynamic> route = routes.first;
            final Map<String, dynamic> leg = route['legs'].first;
            final String etaText = leg['duration']['text'];
            final String distanceText = leg['distance']['text'];
            if (data['routes'][0]['overview_polyline'] != null &&
                data['routes'][0]['overview_polyline']['points'] != null) {
              String points = data['routes'][0]['overview_polyline']['points'];
              List<LatLng> polylineCoordinates =
                  DashboardComponent.decodePolyline(points);

              cb([
                {
                  "distance": distanceText.toString(),
                  "time": etaText,
                  'poly_line': polylineCoordinates
                }
              ]);
            } else {
              cb([
                {
                  "distance": distanceText.toString(),
                  "time": etaText,
                }
              ]);
            }
          }
        } else {
          cb([]);
        }
      } else {
        cb([]);
      }
    } catch (e) {
      cb("No Internet");
    }
  }

  static Future<List> fetchETAList(LatLng origin, LatLng destination) async {
    try {
      final String apiUrl =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=${Variables.mapApiKey}';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final List<dynamic> routes = data['routes'];

          if (routes.isNotEmpty) {
            final Map<String, dynamic> route = routes.first;
            final Map<String, dynamic> leg = route['legs'].first;
            final String etaText = leg['duration']['text'];
            final String distanceText = leg['distance']['text'];
            if (data['routes'][0]['overview_polyline'] != null &&
                data['routes'][0]['overview_polyline']['points'] != null) {
              String points = data['routes'][0]['overview_polyline']['points'];
              List<LatLng> polylineCoordinates =
                  DashboardComponent.decodePolyline(points);

              return [
                {
                  "distance": distanceText.toString(),
                  "time": etaText,
                  'poly_line': polylineCoordinates
                }
              ];
            } else {
              return [
                {
                  "distance": distanceText.toString(),
                  "time": etaText,
                }
              ];
            }
          }
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
    return [];
  }

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
}

// Define a class for structured place data
class PlaceSearchResult {
  final String formattedAddress;
  final gmp.Location location;
  // Add other relevant properties as needed

  PlaceSearchResult({
    required this.formattedAddress,
    required this.location,
  });
}
