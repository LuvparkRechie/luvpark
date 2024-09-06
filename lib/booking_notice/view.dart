import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark_get/booking_notice/controller.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/no_internet.dart';
import 'package:luvpark_get/custom_widgets/page_loader.dart';
import 'package:luvpark_get/custom_widgets/variables.dart';

class BookingNotice extends GetView<BookingNoticeController> {
  const BookingNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingNoticeController ct = Get.put(BookingNoticeController());
    return Container(
      height: MediaQuery.of(context).size.height * .80,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      padding: const EdgeInsets.all(15),
      child: Obx(() => !ct.isInternetConn.value
          ? NoInternetConnected(
              onTap: controller.getNotice,
            )
          : ct.isLoadingPage.value
              ? const PageLoader()
              : Obx(
                  () => Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            Get.back();
                            Get.back();
                          },
                          icon: const Icon(
                            Iconsax.close_circle,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: CustomTitle(
                          text: ct.noticeData[0]["msg_title"],
                          fontSize: 20,
                        ),
                        subtitle: CustomParagraph(
                            text: Variables.convertDateFormat(
                                ct.noticeData[0]["updated_date"])),
                      ),
                      Container(height: 10),
                      Expanded(
                        child: StretchingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          child: SingleChildScrollView(
                            child:
                                CustomParagraph(text: ct.noticeData[0]["msg"]),
                          ),
                        ),
                      ),
                      CustomButton(
                          text: "Proceed Booking",
                          onPressed: () {
                            Get.back();
                          }),
                      Container(height: 30),
                    ],
                  ),
                )),
    );
  }
}
