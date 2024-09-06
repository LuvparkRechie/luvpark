import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_button.dart';
import 'package:luvpark_get/custom_widgets/custom_tciket_style.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/routes/routes.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingDialog extends StatelessWidget {
  final List data;
  const BookingDialog({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 20,
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: AppColor.primaryColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColor.primaryColor,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: Column(
          children: [
            Center(
              child: SizedBox(
                width: 53,
                height: 53,
                child: Image.asset("assets/images/success_booking.png"),
              ),
            ),
            Container(height: 18),
            const CustomParagraph(
              text: "Parking booked successfully!",
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            Container(height: 26),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(height: 30),
                        Center(
                          child: QrImageView(
                            data: "",
                            size: 180,
                          ),
                        ),
                        Container(height: 12),
                        const CustomParagraph(
                          text: "Scan QR Code to verify your payment",
                          maxlines: 1,
                        ),
                        Container(height: 20),
                        TicketStyle(
                          dtColor: AppColor.primaryColor,
                        ),
                        Container(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTitle(text: data[0]["parkArea"]),
                              Container(height: 10),
                              CustomParagraph(
                                text: data[0]["address"],
                              ),
                              Container(height: 20),
                              const CustomTitle(text: "Parking Details"),
                              Container(height: 10),
                              Row(
                                children: [
                                  const Expanded(
                                    child: CustomParagraph(
                                      text: "Duration",
                                    ),
                                  ),
                                  CustomLinkLabel(
                                      text:
                                          "${data[0]["hours"]} ${int.parse(data[0]["hours"].toString()) > 1 ? "Hours" : "Hour"}")
                                ],
                              ),
                              Container(height: 10),
                              Row(
                                children: [
                                  const Expanded(
                                    child: CustomParagraph(
                                      text: "Total",
                                    ),
                                  ),
                                  CustomLinkLabel(
                                      text: toCurrencyString(data[0]["amount"]))
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomButton(
                btnColor: Colors.white,
                textColor: AppColor.primaryColor,
                bordercolor: Colors.white,
                text: "Go to parking",
                onPressed: () {
                  Get.offAllNamed(Routes.parking, arguments: "B");
                },
              ),
            ),
            Container(height: 20),
          ],
        ),
      ),
    );
  }
}
