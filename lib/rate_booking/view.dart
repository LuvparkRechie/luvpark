import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/rate_booking/controller.dart';
import 'package:rive/rive.dart';

import '../custom_widgets/custom_button.dart';

class RateBooking extends GetView<RateBookingController> {
  RateBooking({Key? key}) : super(key: key) {
    Get.put(RateBookingController(), permanent: true);
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
                      child: CustomTitle(
                        text: "How's your Experience?".toUpperCase(),
                        maxlines: 1,
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    Container(
                      height: 10,
                    ),
                    const CustomParagraph(
                      text:
                          "Your feedback is important to us, please rate your experience.",
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: CustomParagraph(
                        text: "Rating (${controller.myRate.round()}/5)",
                        fontWeight: FontWeight.w800,
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: SizedBox(
                        height: 60,
                        width: 500,
                        child: RiveAnimation.asset(
                          'assets/rating_animation.riv',
                          onInit: controller.onRiveInit,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: CustomParagraph(
                        text: "Comments and Suggestions",
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      style: paragraphStyle(),
                      minLines: 4,
                      maxLines: null,
                      controller: controller.commentController,
                      keyboardType: Platform.isIOS
                          ? const TextInputType.numberWithOptions(
                              signed: true, decimal: false)
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
                              },
                              child: const Center(
                                child: CustomParagraph(
                                  text: "Cancel",
                                ),
                              )),
                        ),
                        Container(
                          width: 10,
                        ),
                        Expanded(
                          child: CustomButton(
                            text: "Post",
                            onPressed: controller.postRatingComments,
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

class CustomTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue;
  }
}
