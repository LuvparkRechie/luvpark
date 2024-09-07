// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark_get/auth/authentication.dart';
import 'package:luvpark_get/custom_widgets/alert_dialog.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/http/api_keys.dart';
import 'package:luvpark_get/http/http_request.dart';
import 'package:rive/rive.dart';

import '../../custom_widgets/app_color.dart';
import '../../custom_widgets/custom_button.dart';

class RateUs extends StatefulWidget {
  final int? reservationId;
  final Function callBack;
  const RateUs({super.key, this.reservationId, required this.callBack});

  @override
  State<RateUs> createState() => _RateUsState();
}

class _RateUsState extends State<RateUs> {
  double myRate = 3.0;
  TextEditingController commentController = TextEditingController();
  StateMachineController? _controller;
  void _onRiveInit(Artboard artboard) {
    _controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
      onStateChange: (stateMachineName, stateName) {
        setState(() {
          myRate = double.tryParse(stateName) ?? myRate;
        });
      },
    );
    artboard.addController(_controller!);
  }

  Future<void> postRatingComments() async {
    int? userId = await Authentication().getUserId();

    CustomDialog().loadingDialog(Get.context!);
    Map<String, dynamic> param = {
      'user_id': userId,
      'reservation_id': widget.reservationId!,
      'rating': myRate.round(),
      'comments': commentController.text,
    };

    return HttpRequest(api: ApiKeys.gApiLuvParkPostRating, parameters: param)
        .post()
        .then((returnData) async {
      if (returnData == "No Internet") {
        Get.back();
        CustomDialog().errorDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Get.back();
        });

        return;
      }
      if (returnData == null) {
        Get.back();
        CustomDialog().errorDialog(context, "Error",
            "Error while connecting to server, Please contact support.", () {
          Get.back();
          return;
        });
      } else {
        if (returnData["success"] == "Y") {
          Get.back();
          CustomDialog().successDialog(
              context, "Success", "Thank you for your feedback.", "Okay", () {
            Get.back();
            Get.back();
          });
        } else {
          Get.back();
          CustomDialog().errorDialog(context, "LuvPark", returnData["msg"], () {
            Get.back();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Iconsax.close_circle),
                  color: Colors.grey,
                ),
              ),
              Center(
                child: CustomTitle(
                  text: "How's your Experience?".toUpperCase(),
                  color: AppColor.primaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              CustomTitle(
                text:
                    "Your feedback is important to us, please rate your experience.",
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 12,
              ),
              const SizedBox(height: 10),
              Center(
                child: CustomTitle(
                  text: "Rating (${myRate.round()}/5)",
                  fontWeight: FontWeight.w800,
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              Center(
                child: SizedBox(
                  height: 50,
                  width: 500,
                  child: RiveAnimation.asset(
                    'assets/rating_animation.riv',
                    onInit: _onRiveInit,
                  ),
                ),
              ),
              TextFormField(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: "SFProTextReg",
                ),
                minLines: 2,
                maxLines: null,
                controller: commentController,
                keyboardType: Platform.isIOS
                    ? TextInputType.numberWithOptions(
                        signed: true, decimal: false)
                    : TextInputType.text,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  hintText: 'Comments...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: "SFProTextReg",
                  ),
                ),
              ),
              Container(
                height: 20,
              ),
              CustomButton(
                text: "Submit",
                onPressed: postRatingComments,
                btnHeight: 10,
              ),
              Container(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
