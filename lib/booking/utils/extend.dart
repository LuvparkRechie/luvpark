import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/booking/utils/booking_receipt/controller.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';

class ExtendParking extends GetView<BookingReceiptController> {
  const ExtendParking({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomTitle(text: "Extend your parking now"),
                Container(height: 40),
                Row(
                  children: [
                    InkWell(
                      onTap: controller.onMinus,
                      child: SvgPicture.asset(
                        "assets/images/minus_extend.svg",
                        fit: BoxFit.contain,
                      ),
                    ),
                    Expanded(
                        child: Column(
                      children: [
                        Obx(
                          () => CustomLinkLabel(
                            text: "${controller.noHours.value}",
                            fontSize: 44,
                          ),
                        ),
                        const CustomParagraph(
                          text: "Hour",
                          fontSize: 10,
                        )
                      ],
                    )),
                    InkWell(
                      onTap: controller.onAdd,
                      child: SvgPicture.asset(
                        "assets/images/add_extend.svg",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                Container(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: CustomButtonCancel(
                          borderColor: AppColor.primaryColor,
                          textColor: AppColor.primaryColor,
                          color: AppColor.bodyColor,
                          text: "Cancel",
                          onPressed: () {
                            Get.back();
                          }),
                    ),
                    Container(width: 10),
                    Expanded(
                      child: CustomButton(
                        text: "Submit",
                        onPressed: controller.onSubmit,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
