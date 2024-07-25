import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dart_ping/dart_ping.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pointycastle/export.dart' as crypto;
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tzz;

BuildContext? ctxt;

class Variables {
  static late Size screenSize;
  // ignore: prefer_typing_uninitialized_variables
  static var timerSec;
  static Timer? backgroundTimer;
  static void init(BuildContext context) {
    ctxt = context;
    screenSize = MediaQuery.of(context).size;
  }

  //static void Timer? backgroundTimer
  static final emailRegex = RegExp(
    r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static String mapApiKey = 'AIzaSyCaDHmbTEr-TVnJY8dG0ZnzsoBH3Mzh4cE';
  static String popUpMessageOutsideArea =
      'Booking request denied. Location exceeds service area. Check and update location information.';
  static String popUpMessageOutsideAreas =
      'Location exceeds service area. Check and update location information. Retry booking.';
  static String version = "";
  static int loginAttemptCount = 0;

//Data Encryption

  static Future<Uint8List> encryptData(
      Uint8List secretKey, Uint8List iv, String plainText) async {
    final cipher = crypto.GCMBlockCipher(crypto.AESEngine());
    final keyParams = crypto.KeyParameter(secretKey);
    final cipherParams = crypto.ParametersWithIV(keyParams, iv);
    cipher.init(true, cipherParams);

    final encodedPlainText = utf8.encode(plainText);
    final cipherText = cipher.process(Uint8List.fromList(encodedPlainText));

    return Uint8List.fromList(cipherText);
  }

  static String arrayBufferToBase64(ByteBuffer buffer) {
    var bytes = Uint8List.view(buffer);
    var base64String = base64.encode(bytes);
    return base64String;
  }

  static Uint8List hexStringToArrayBuffer(String hexString) {
    final result = Uint8List(hexString.length ~/ 2);
    for (var i = 0; i < hexString.length; i += 2) {
      result[(i ~/ 2)] = int.parse(hexString.substring(i, i + 2), radix: 16);
    }
    return result;
  }

  static ByteBuffer concatBuffers(Uint8List buffer1, Uint8List buffer2) {
    final tmp = Uint8List(buffer1.length + buffer2.length);
    tmp.setAll(0, buffer1);
    tmp.setAll(buffer1.length, buffer2);
    return tmp.buffer;
  }

  static Uint8List generateRandomNonce() {
    var random = Random.secure();
    var iv = Uint8List(16);
    for (var i = 0; i < iv.length; i++) {
      iv[i] = random.nextInt(256);
    }
    return iv;
  }

  static String capitalize(String value) {
    if (value.trim().isEmpty) return "";
    return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
  }

  static String hideName(String name) {
    if (name.isEmpty) {
      return ''; // Handle empty names as needed
    } else if (name.length == 1) {
      return name; // Show the full name if it's 2 characters or less
    } else if (name.length == 2) {
      return "${name[0]}*"; // Show the full name if it's 2 characters or less
    } else if (name.length == 3) {
      return "${name.substring(0, 2)}*"; // Show the full name if it's 2 characters or less
    } else {
      return '${name.substring(0, 2)}${'*' * (name.length - 2)}'; // Show the first two letters and the rest with asterisks
    }
  }

  static String transformFullName(String fullName) {
    if (fullName.isEmpty) {
      return ''; // Handle empty names as needed
    }

    List<String> nameParts = [];
    if (fullName.contains(" ")) {
      nameParts = fullName.split(" ");
    } else {
      nameParts = [fullName];
    }
    String transformedFullName = '';
    for (var name in nameParts) {
      if (transformedFullName.isNotEmpty) {
        transformedFullName += ' '; // Add space between names
      }
      transformedFullName += hideName(name);
    }

    return transformedFullName;
  }

  static Future<void> pageTrans(Widget param, BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => param),
    );
  }

  static String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  static String convertTime(String time) {
    // Parse the input time string
    DateTime parsedTime = DateFormat("HH:mm:ss").parse(time);
    // Format the time in 12-hour format with AM/PM
    String twelveHourFormat = DateFormat("h:mm a").format(parsedTime);

    return twelveHourFormat;
  }

  static String converDate(String date) {
    DateTime originalDate = DateFormat("yyyy-MM-dd").parse(date);

    // Format the date in a different format
    String formattedDate = DateFormat("MMMM dd, yyyy").format(originalDate);

    return formattedDate;
  }

  static String paMessageTable = 'pa_message';
  static String vhBrands = 'vehicle_brands';
  static String locSharing = 'location_sharing_table';
  static String notifTable = 'notification_table';
  static String shareLocTable = 'share_location_table';
  static EncryptedSharedPreferences encryptedSharedPreferences =
      EncryptedSharedPreferences();
  static var maskFormatter = MaskTextInputFormatter(
      mask: '### ### ####', filter: {"#": RegExp(r'[0-9]')});
  static String capitalizeFirstLetter(String str) =>
      str[0].toUpperCase() + str.substring(1).toLowerCase();
  static String capitalizeAllWord(String value) {
    if (value.isEmpty) return "";
    var result = value[0].toUpperCase();
    for (int i = 1; i < value.length; i++) {
      if (value[i - 1] == " ") {
        result = result + value[i].toUpperCase();
      } else {
        result = result + value[i];
      }
    }
    return result;
  }

  static String formatDateLocal(String dateString) {
    DateTime timestamp = DateTime.parse(dateString);
    String formattedTime = DateFormat('MMM d, yyyy hh:mm a').format(timestamp);
    return formattedTime;
  }

  static String displayLastFourDigitsWithAsterisks(int number) {
    String numberString = number.toString();
    if (numberString.length >= 4) {
      String asterisks = '●' * (numberString.length - 4);
      return '$asterisks${numberString.substring(numberString.length - 4)}';
    } else {
      // Handle cases where the number has less than four digits
      return numberString;
    }
  }

  static var regExpRestrictFormatter =
      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9]+|\s"));

//Password strength validation
  static int getPasswordStrength(String password) {
    if (password.isEmpty) {
      return 0;
    } else if (password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'))) {
      return 4; // Strong
    } else if ((password.length >= 8 && password.contains(RegExp(r'[0-9]'))) ||
        (password.length >= 8 && password.contains(RegExp(r'[A-Z]')))) {
      return 3; // Medium
    } else if (password.length >= 8 ||
        (password.contains(RegExp(r'[0-9]')) ||
            password.contains(RegExp(r'[A-Z]')))) {
      return 2; // Weak
    } else {
      return 1; // Very Weak
    }
  }

//Password strength validation
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 1:
        return 'Very Weak Password';
      case 2:
        return 'Weak Password';
      case 3:
        return 'Medium Password';
      case 4:
        return 'Strong Password';
      default:
        return '';
    }
  }

//Password strength validation
  static Color getColorForPasswordStrength(int strength) {
    switch (strength) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return const Color.fromARGB(255, 248, 224, 13);
      case 4:
        return AppColor.primaryColor;
      default:
        return Colors.black;
    }
  }

  ///get Internet

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

  //Convert to minutes
  static String convertToTime(int totalMinutes) {
    // Calculate hours and minutes
    // int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    // Format the time as HH:MM
    // String formattedTime = '$hours:${minutes.toString().padLeft(2, '0')}';

    return minutes.toString().padLeft(2, '0');
  }

  static double convertToMeters(String distanceString) {
    // Extract numeric part of the string
    String numericPart = distanceString.replaceAll(RegExp(r'[^0-9.]'), '');

    // Parse numeric part to double
    double distanceValue = double.tryParse(numericPart) ?? 0;

    // Check if "km" (kilometers) is present in the string
    bool isKilometers = distanceString.toLowerCase().contains('km');

    // Convert to meters
    return isKilometers ? distanceValue * 1000 : distanceValue;
  }

  //COnvert 12 hours format sample:18:00
  static String convert24HourTo12HourFormat(String time24Hour) {
    List<String> parts = time24Hour.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    String period = hours < 12 ? 'AM' : 'PM';
    hours = hours % 12;
    hours = hours == 0 ? 12 : hours; // Convert 0 to 12 for 12-hour format

    return "$hours:${minutes.toString().padLeft(2, '0')} $period";
  }

  //Split by 2 sample:1800
  static List<String> splitNumberIntoPairs(String numberString, int pairSize) {
    List<String> digitPairs = [];

    for (int i = 0; i < numberString.length; i += pairSize) {
      int end = i + pairSize;
      if (end > numberString.length) {
        end = numberString.length;
      }
      digitPairs.add(numberString.substring(i, end));
    }

    return digitPairs;
  }

  //Generate a list of number  with a specified length
  static List<int> generateNumberList(int length) {
    return List.generate(length, (index) => index + 1);
  }

  //2020-20-20 to 2020/20/20
  static String formatDate(String inputDateString) {
    String _twoDigits(int n) {
      // Helper function to add leading zeros to single-digit numbers
      return n.toString().padLeft(2, '0');
    }

    // Parse the input date string into a DateTime object
    DateTime dateTime = DateTime.parse(inputDateString);

    // Format the DateTime object into the desired string format
    String formattedDateString =
        "${dateTime.year}/${_twoDigits(dateTime.month)}/${_twoDigits(dateTime.day)}";

    return formattedDateString;
  }

  static customBottomSheet(BuildContext context, Widget child) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return child;
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      // Custom animation for smooth transition
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: Duration(milliseconds: 400),
      ),
    );
  }

  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    var myData = prefs.getString('userData');

    if (myData != null) {
      Map<String, dynamic> userData = jsonDecode(myData);
      if (userData.containsKey('user_id')) {
        return userData['user_id'].toString();
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

//GROUP BY KEY
  static Map<K, List<V>> groupBy<K, V>(
      Iterable<V> items, K Function(V) keyFunction) {
    Map<K, List<V>> result = {};
    for (var item in items) {
      var key = keyFunction(item);
      result.putIfAbsent(key, () => []).add(item);
    }
    return result;
  }

  static Future<void> groupByKey(jsonData, Function cb) async {
    List<dynamic> items = json.decode(jsonData);

    List<Map<String, dynamic>> objData = [];

    // Group items by name
    Map<String, List<dynamic>> groupedItems =
        groupBy(items, (item) => item['name']);

    // Create output structure
    groupedItems.forEach((name, itemList) {
      objData.add({"name": name, "data": itemList});
    });
    if (objData.isEmpty) return;
    cb(objData);
  }

  static Future<Uint8List> getMarkerIcon(
      BuildContext context, String base64String, int width) async {
    // tawga ne
    // Uint8List iconBytes =  await _getMarkerIcon(dataRow['profile_pic'], 50);
    //   BitmapDescriptor icon = BitmapDescriptor.fromBytes(iconBytes);
    Uint8List bytes = base64Decode(base64String);
    double targetWidth = MediaQuery.of(context).devicePixelRatio * width;
    ui.Image image = await decodeImageFromList(bytes);
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    canvas.clipRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, targetWidth, targetWidth),
      Radius.circular(targetWidth / 2),
    ));
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(0, 0, targetWidth, targetWidth),
        Paint());

    ui.Picture picture = recorder.endRecording();
    ui.Image encodedImage =
        await picture.toImage(targetWidth.round(), targetWidth.round());
    ByteData? byteData =
        await encodedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static String formatDateWithMonthAndTime(String dateString) {
    // Parse the string into a DateTime object
    DateTime dateTime = DateTime.parse(dateString);

    // Format the date with month abbreviation, day, year, and time
    return DateFormat('MMM dd, yyyy - hh:mm:ss a').format(dateTime);
  }

  static String convertDateFormat(String dateString) {
    // Parse the original date string
    DateTime originalDate = DateTime.parse(dateString);

    // Format the date to "thu 23 jan" format
    DateFormat newDateFormat = DateFormat('E MMM dd');
    String formattedDate = newDateFormat.format(originalDate);

    return formattedDate;
  }

  static String convertToManilaTime(String date) {
    final tzz.TZDateTime scheduledTime = tzz.TZDateTime.from(
      DateTime.parse(date),
      tzz.getLocation('Asia/Manila'),
    );

    // Format the Manila time as a string
    String formattedManilaTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(scheduledTime);

    return formattedManilaTime;
  }

  static String formatTimeTicket(String dateString) {
    // Parse the string into a DateTime object
    DateTime dateTime = DateTime.parse(dateString);

    // Format the date with month abbreviation, day, year, and time
    return DateFormat('hh:mm:ss a').format(dateTime);
  }

  static String formatDateTicket(String dateString) {
    // Parse the string into a DateTime object
    DateTime dateTime = DateTime.parse(dateString);

    // Format the date with month abbreviation, day, year, and time
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  static bool withinOneHourRange(DateTime targetDateTime) {
    DateTime currentDateTime = DateTime.now();
    DateTime oneHourAgo = currentDateTime.subtract(Duration(hours: 1));
    return targetDateTime.isAfter(oneHourAgo) &&
        targetDateTime.isBefore(currentDateTime);
  }

  static String formatTimeLeft(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds} ${duration.inSeconds == 1 ? 'second' : 'seconds'} left';
    } else {
      int hours = duration.inHours;
      int minutes = duration.inMinutes.remainder(60);
      if (hours == 0) {
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} left';
      } else {
        return '$hours ${hours == 1 ? 'hour' : 'hours'} and $minutes ${minutes == 1 ? 'minute' : 'minutes'} left';
      }
    }
  }

  static Future<Uint8List> createOvalImage(
      BuildContext context, String base64String, int width) async {
    Uint8List bytes = base64Decode(base64String);
    double targetWidth = MediaQuery.of(context).devicePixelRatio * width;

    // Compress the image
    Uint8List compressedBytes = await compressImage(bytes);

    // Decode the compressed image as a ui.Image
    ui.Image image = await decodeImageFromList(compressedBytes);

    // Create an oval canvas with the target width
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    Rect ovalRect = Rect.fromLTWH(0, 0, targetWidth,
        targetWidth * 0.5); // Adjust the height ratio to make it oval
    canvas.clipRRect(RRect.fromRectAndRadius(
      ovalRect,
      Radius.circular(targetWidth / 10), // Adjust the radius as needed
    ));
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ovalRect,
      Paint(),
    );

    // Encode the oval image as PNG
    ui.Picture picture = recorder.endRecording();
    ui.Image encodedImage =
        await picture.toImage(targetWidth.round(), (targetWidth * 0.5).round());
    ByteData? byteData =
        await encodedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  //convert widget to image and display on map or capture as png
  static Future<Uint8List> capturePng(
      BuildContext context, Widget printWidget, int size, bool isOval) async {
    Uint8List markerBeytes;
    Uint8List bytes = await ScreenshotController()
        .captureFromWidget(printWidget, delay: Duration(milliseconds: 10));
    Uint8List pngBytes = bytes.buffer.asUint8List();

    markerBeytes = isOval
        ? await Variables.createOvalImage(context, base64Encode(pngBytes), size)
        : await Variables.getMarkerIcon(context, base64Encode(pngBytes), size);

    return markerBeytes;
  }

  //Reduce Image size
  static Future<Uint8List> compressImage(Uint8List imageBytes) async {
    // Compress the image
    List<int> compressedBytes = await FlutterImageCompress.compressWithList(
      imageBytes,
      minHeight: 500, // Set a lower minimum height
      minWidth: 900, // Set a lower minimum width
      quality: 50,
      format: CompressFormat.png, // Specify the desired format
    );

    // Convert compressed bytes to Uint8List
    return Uint8List.fromList(compressedBytes);
  }
}
