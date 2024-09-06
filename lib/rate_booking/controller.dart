import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';

class RateBookingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  RateBookingController();
  bool isInternetConnected = true;
  RxDouble myRate = 3.0.obs;
  TextEditingController commentController = TextEditingController();
  StateMachineController? riveController;

  @override
  void onInit() {
    super.onInit();
  }

  void onRiveInit(Artboard artboard) {
    riveController = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
      onStateChange: (stateMachineName, stateName) {
        //  myRate.value = double.tryParse(stateName) ?? myRate;
      },
    );
    artboard.addController(riveController!);
  }

  void postRatingComments() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var objInfoData = prefs.getString(
    //   'userData',
    // );
    // var myData = jsonDecode(objInfoData!);
    // CustomModal(context: context).loader();

    // Map<String, dynamic> param = {
    //   'user_id': myData["user_id"],
    //   'reservation_id': widget.reservationId!,
    //   'rating': myRate.round(),
    //   'comments': commentController.text,
    // };

    // HttpRequest(api: ApiKeys.gApiLuvParkPostRating, parameters: param)
    //     .post()
    //     .then((returnData) async {
    //   if (returnData == "No Internet") {
    //     Navigator.pop(context);
    //     showAlertDialog(context, "Error",
    //         "Please check your internet connection and try again.", () {
    //       Navigator.of(context).pop();
    //     });

    //     return;
    //   }
    //   if (returnData == null) {
    //     Navigator.pop(context);
    //     showAlertDialog(context, "Error",
    //         "Error while connecting to server, Please contact support.", () {
    //       Navigator.pop(context);
    //       return;
    //     });
    //   } else {
    //     if (returnData["success"] == "Y") {
    //       Navigator.of(context).pop();

    //       showAlertDialog(context, "Success", "Thank you for your feedback.",
    //           () {
    //         Navigator.of(context).pop();
    //         if (Navigator.canPop(context)) {
    //           Navigator.of(context).pop();
    //         }
    //         widget.callBack();
    //       });
    //     } else {
    //       Navigator.of(context).pop();
    //       showAlertDialog(context, "LuvPark", returnData["msg"], () {
    //         Navigator.of(context).pop();
    //       });
    //     }
    //   }
    // });
  }

  @override
  void onClose() {
    super.onClose();
  }
}
