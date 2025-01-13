// ignore_for_file: unused_import, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_cutter.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/main.dart';
import 'package:screenshot/screenshot.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../custom_widgets/alert_dialog.dart';

class MerchantQRRController extends GetxController
    with GetSingleTickerProviderStateMixin {
  MerchantQRRController();
  final parameter = Get.arguments;

  void initializeTimezone() {
    tz.initializeTimeZones();
  }

  String formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
  }
}
