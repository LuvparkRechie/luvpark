import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void postRatingComments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var objInfoData = prefs.getString(
      'userData',
    );
    var myData = jsonDecode(objInfoData!);
    CustomModal(context: context).loader();

    Map<String, dynamic> param = {
      'user_id': myData["user_id"],
      'reservation_id': widget.reservationId!,
      'rating': myRate.round(),
      'comments': commentController.text,
    };
    print('hello: $param');
    HttpRequest(api: ApiKeys.gApiLuvParkPostRating, parameters: param)
        .post()
        .then((returnData) async {
      if (returnData == "No Internet") {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });

        return;
      }
      if (returnData == null) {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please contact support.", () {
          Navigator.pop(context);
          return;
        });
      } else {
        if (returnData["success"] == "Y") {
          Navigator.of(context).pop();

          showAlertDialog(context, "Success", "Thank you for your feedback.",
              () {
            Navigator.of(context).pop();
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
            widget.callBack();
          });
        } else {
          Navigator.of(context).pop();
          showAlertDialog(context, "LuvPark", returnData["msg"], () {
            Navigator.of(context).pop();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Wrap(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: CustomDisplayText(
                        label: "How's your Experience?".toUpperCase(),
                        color: AppColor.textMainColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        maxLines: 1,
                      ),
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Container(
                      height: 10,
                    ),
                    CustomDisplayText(
                      label:
                          "Your feedback is important to us, please rate your experience.",
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: CustomDisplayText(
                        label: "Rating (${myRate.round()}/5)",
                        fontWeight: FontWeight.w800,
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        height: 60,
                        width: 500,
                        child: RiveAnimation.asset(
                          'assets/rating_animation.riv',
                          onInit: _onRiveInit,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: CustomDisplayText(
                        label: "Comments and Suggestions",
                        fontWeight: FontWeight.w800,
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: "SFProTextReg",
                      ),
                      minLines: 4,
                      maxLines: null,
                      controller: commentController,
                      keyboardType: Platform.isIOS
                          ? TextInputType.numberWithOptions(
                              signed: false, decimal: false)
                          : TextInputType.text,
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                        hintText: 'Tell us more...',
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
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                              onTap: () {
                                FocusScope.of(context).unfocus();

                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                                widget.callBack();
                              },
                              child: Center(
                                child: CustomDisplayText(
                                  label: "Cancel",
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.primaryColor,
                                  fontSize: 14,
                                ),
                              )),
                        ),
                        Container(
                          width: 10,
                        ),
                        Expanded(
                          child: CustomButton(
                            label: "Post",
                            onTap: postRatingComments,
                            btnHeight: 10,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
