import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AboutUsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  AboutUsController();

  var attachments = <String>[].obs;
  var isHTML = false.obs;
  final recipientController = TextEditingController(text: 'support@luvpark.ph');
  final subjectController = TextEditingController(text: 'luvpark');
  final bodyController = TextEditingController();

  var isSubjectValid = true.obs;
  var isBodyValid = true.obs;

  RxBool isLoading = false.obs;
  RxBool isInternetConn = true.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> refresher() async {
    isLoading.value = true;
    isInternetConn.value = true;
    bodyController.clear();
    subjectController.value;
  }

  Future<void> getData() async {
    ();
  }

  Future<void> send() async {
    if (subjectController.text.trim().isEmpty) {
      isSubjectValid.value = false;
    } else {
      isSubjectValid.value = true;
    }

    if (bodyController.text.trim().isEmpty) {
      isBodyValid.value = false;
    } else {
      isBodyValid.value = true;
    }

    if (isSubjectValid.value && isBodyValid.value) {
      final Email email = Email(
        body: bodyController.text,
        subject: subjectController.text,
        recipients: [recipientController.text],
        attachmentPaths: attachments,
        isHTML: isHTML.value,
      );

      try {
        await FlutterEmailSender.send(email);
      } catch (error) {}
    }
  }

  void addAttachment(String path) {
    if (attachments.length < 5 && !attachments.contains(path)) {
      attachments.add(path);
    } else if (attachments.length >= 5) {
      Get.snackbar("Limit Reached", "You can only attach up to 5 files.");
    } else {
      Get.snackbar("Duplicate Attachment", "This file is already attached.");
    }
  }

  void removeAttachment(int index) {
    attachments.removeAt(index);
  }

  Future<void> attachFileFromAppDocumentsDirectory() async {
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDocumentDir.path}/file.txt';
      final file = File(filePath);
      await file.writeAsString('Text file in app directory');

      addAttachment(filePath);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create file in application directory');
    }
  }

  Future<void> openImagePicker() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      addAttachment(pickedFile.path);
    }
  }

  Future<void> clearFields() async {
    subjectController.clear();
    bodyController.clear();
  }
}
