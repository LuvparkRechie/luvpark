import 'package:clipboard/clipboard.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class ReferralCode extends StatefulWidget {
  ReferralCode({super.key});

  @override
  State<ReferralCode> createState() => _ReferralCodeState();
}

class _ReferralCodeState extends State<ReferralCode> {
  String referralcode = 'EF8HG21DS';
  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
      canPop: true,
      appBarheaderText: 'Referral Code',
      appBarIconClick: () {
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: 30,
                  left: 10,
                  bottom: 40,
                  top: 40,
                ),
                child: Image.asset(
                  'assets/images/referralgift.png',
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDisplayText(
                      label: 'Refer now & earn up to 100 reward points',
                      maxLines: 2,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomDisplayText(
                      label:
                          'Send a referral link to a friends via SMS \nand link via luvpark App',
                      maxLines: 2,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ],
                ),
              )
            ],
          ),
          Row(
            children: [
              CustomDisplayText(
                label: 'Referral Code'.toUpperCase(),
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          Container(height: 10),
          DottedBorder(
            dashPattern: [8, 2],
            radius: Radius.circular(5),
            borderType: BorderType.RRect,
            color: AppColor.primaryColor,
            child: Container(
              color: AppColor.primaryColor.withOpacity(0.1),
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomDisplayText(
                    label: referralcode,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  GestureDetector(
                    onTap: () {
                      FlutterClipboard.copy(referralcode);
                    },
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 50,
                          child: CustomDisplayText(
                            label: 'Tap to Copy',
                            color: AppColor.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 20),
          Row(
            children: [
              CustomDisplayText(
                label: 'Do you have any referral code?',
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          Container(
            height: 2,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: CustomDisplayText(
                  label: 'Redeem code',
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
