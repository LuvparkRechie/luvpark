// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_appbar.dart';
import 'package:luvpark/custom_widgets/custom_tciket_style.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/wallet_qr/myqr/controller.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shimmer/shimmer.dart';

class myQR extends GetView<myQRController> {
  const myQR({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Receive with QR"),
      backgroundColor: AppColor.bodyColor,
      body: Column(
        children: [
          Expanded(
            child: ReceiveQr(),
          ),
        ],
      ),
    );
  }
}

class ReceiveQr extends GetView<myQRController> {
  const ReceiveQr({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => !controller.isInternetConn.value
          ? NoInternetConnected(onTap: controller.getQrData)
          : Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColor.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 1,
                          spreadRadius: 1,
                          offset: Offset(0, 1),
                          color: AppColor.bodyColor.withOpacity(.5),
                        ),
                      ],
                    ),
                    child: controller.isLoading.value
                        ? _buildLoadingState()
                        : _buildLoadedState(),
                  ),
                  _buildBottomNav(),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(15, 17, 15, 0),
          child: Row(
            children: [
              const SizedBox(width: 10),
              _buildShimmerAvatar(),
              const SizedBox(width: 10),
              _buildShimmerText(),
            ],
          ),
        ),
        TicketStyle(dtColor: AppColor.bodyColor),
        _buildShimmerQr(),
      ],
    );
  }

  Widget _buildLoadedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(15, 17, 15, 0),
          child: Row(
            children: [
              const SizedBox(width: 10),
              controller.userImage.isEmpty
                  ? _buildDefaultAvatar()
                  : _buildUserAvatar(),
              const SizedBox(width: 10),
              _buildUserDetails(),
            ],
          ),
        ),
        TicketStyle(dtColor: AppColor.bodyColor),
        _buildQrCode(),
      ],
    );
  }

  Widget _buildShimmerAvatar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      period: Duration(seconds: 2),
      direction: ShimmerDirection.ltr,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildShimmerText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerContainer(width: 120, height: 12),
        const SizedBox(height: 5),
        _buildShimmerContainer(width: 90, height: 10),
      ],
    );
  }

  Widget _buildShimmerContainer(
      {required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      period: Duration(seconds: 2),
      direction: ShimmerDirection.ltr,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildShimmerQr() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.white,
            period: Duration(seconds: 2),
            direction: ShimmerDirection.ltr,
            child: Container(
              width: double.infinity,
              height: 200,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      padding: EdgeInsets.all(2),
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: const Icon(
        Icons.person,
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      padding: EdgeInsets.all(2),
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundImage: MemoryImage(base64Decode(controller.userImage.value)),
      ),
    );
  }

  Widget _buildUserDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomParagraph(
          text: controller.fullName.value,
          textAlign: TextAlign.start,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 14,
        ),
        const SizedBox(height: 5),
        CustomParagraph(
          fontSize: 12,
          text: controller.mono.value,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildQrCode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: PrettyQrView(
            decoration: const PrettyQrDecoration(
              background: Colors.white,
              image: PrettyQrDecorationImage(
                image: AssetImage("assets/images/logo.png"),
              ),
            ),
            qrImage: QrImage(
              QrCode.fromData(
                data: controller.mobNum.value,
                errorCorrectLevel: QrErrorCorrectLevel.H,
              ),
            ),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.bodyColor,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      width: double.infinity,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.save, "Save QR", controller.saveQr),
          _buildNavItem(Icons.share, "Share QR", controller.shareQr),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String text, VoidCallback onTap) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: AppColor.primaryColor),
        ),
        CustomParagraph(
          text: text,
          fontSize: 12,
          color: AppColor.primaryColor,
        ),
      ],
    );
  }
}
