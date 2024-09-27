import 'package:flutter/material.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> addTargetsPage({
  required GlobalKey menubar,
  required GlobalKey wallet,
  required GlobalKey parkinginformation,
  required GlobalKey currentlocation,
}) {
  List<TargetFocus> targets = [];
  //menu bar
  targets.add(
    TargetFocus(
      enableOverlayTab: true,
      keyTarget: menubar,
      alignSkip: Alignment.topRight,
      radius: 10,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return Container(
              alignment: Alignment.bottomLeft,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomParagraph(
                    text: "Menu bar",
                    textAlign: TextAlign.start,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  CustomParagraph(
                    text: "Access settings, \nprofile and parking",
                    textAlign: TextAlign.start,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            );
          },
        )
      ],
    ),
  );
  //wallet
  targets.add(
    TargetFocus(
      enableOverlayTab: true,
      keyTarget: wallet,
      alignSkip: Alignment.bottomRight,
      radius: 10,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return Container(
              alignment: Alignment.bottomRight,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomParagraph(
                    text: "Wallet",
                    textAlign: TextAlign.start,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  CustomParagraph(
                    text: "Send and receive\ntokens for parking",
                    textAlign: TextAlign.end,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    maxlines: 2,
                    color: Colors.white,
                  ),
                ],
              ),
            );
          },
        )
      ],
    ),
  );
  //parking information
  targets.add(
    TargetFocus(
      enableOverlayTab: true,
      keyTarget: parkinginformation,
      alignSkip: Alignment.topRight,
      radius: 10,
      shape: ShapeLightFocus.Circle,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return Container(
              alignment: Alignment.topRight,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomParagraph(
                    text: "Parking Information",
                    textAlign: TextAlign.start,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  CustomParagraph(
                    text:
                        "List of vehicles, parking\ndetails, amenities, price etc.",
                    textAlign: TextAlign.end,
                    fontWeight: FontWeight.normal,
                    maxlines: 2,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            );
          },
        )
      ],
    ),
  );
  //current location
  targets.add(
    TargetFocus(
      enableOverlayTab: true,
      keyTarget: currentlocation,
      alignSkip: Alignment.topRight,
      radius: 10,
      shape: ShapeLightFocus.Circle,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return Container(
              alignment: Alignment.topRight,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomParagraph(
                    text: "Current Location",
                    textAlign: TextAlign.end,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  CustomParagraph(
                    text: "Find nearby parking",
                    textAlign: TextAlign.end,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            );
          },
        )
      ],
    ),
  );

  return targets;
}
