import 'package:flutter/material.dart';
import 'package:luvpark/custom_widgets/custom_separator.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import '../../custom_widgets/app_color.dart';
import '../../custom_widgets/custom_button.dart';

class SubscriptionDetails extends StatelessWidget {
  final List data;

  const SubscriptionDetails({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        children: [
          CustomParagraph(
            minFontSize: 8,
            text: 'Subscription Details',
            fontSize: 20,
            maxlines: 1,
            color: Color(0xFF070707),
            fontWeight: FontWeight.w700,
          ),
          Expanded(
            child: data.isEmpty
                ? NoDataFound(
                    text: "No Subscription",
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(15),
                    itemCount: data.length,
                    itemBuilder: ((context, index) {
                      var subscriptionRate = data[index]["subscription_rate"];
                      var parkareaname = data[index]["park_area_name"];
                      return Column(
                        children: [
                          rowWidget("Park Area", parkareaname.toString()),
                          SizedBox(height: 10),
                          rowWidget(
                              "Subscription Rate", subscriptionRate.toString()),
                          const SizedBox(height: 20),
                          const MySeparator(
                            color: Color(0xFFD9D9D9),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),
                  ),
          ),
          CustomButton(
            text: 'Close',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Container(height: 10)
        ],
      ),
    );
  }

  Row rowWidget(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomParagraph(
          maxlines: 1,
          minFontSize: 8,
          color: const Color(0xFF616161),
          text: label,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: CustomParagraph(
              text: value,
              maxlines: 1,
              fontWeight: FontWeight.w600,
              color: AppColor.headerColor,
              fontSize: 13,
              minFontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
