import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      height: MediaQuery.of(context).size.height * .54,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      child: Obx(() => !ct.isInternetConn.value
          ? NoInternetConnected(
              onTap: controller.getNotice,
            )
          : ct.isLoadingPage.value
              ? const PageLoader()
              : Obx(
                  () => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.back();
                              Get.back();
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 15,
                                  width: 200,
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(56)),
                                  ),
                                ),
                                Container(
                                  height: 6,
                                  width: 71,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD9D9D9),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(56)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Container(height: 21),
                      Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTitle(
                                text: ct.noticeData[0]["msg_title"],
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.48,
                                color: const Color(0xFF475467),
                                fontStyle: FontStyle.normal,
                              ),
                              CustomParagraph(
                                text: Variables.convertDateFormat(
                                  ct.noticeData[0]["updated_date"],
                                ),
                                color: const Color(0xFF101828),
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(height: 10),
                      Expanded(
                        child: StretchingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          child: SingleChildScrollView(
                            child: CustomParagraph(
                              text: ct.noticeData[0]["msg"],
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF101828),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      CustomButton(
                          text: "Proceed Booking",
                          onPressed: () {
                            Get.back();
                          }),
                    ],
                  ),
                )),
    );
  }
}
