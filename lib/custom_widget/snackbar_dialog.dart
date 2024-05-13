import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

showAlertDialog(
    BuildContext context, String title, String msg, Function onpressed) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1)),
        // ignore: deprecated_member_use
        child: WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: AlertContain(msg: msg, title: title, onpressed: onpressed),
            ),
          ),
        ),
      );
    },
  );
}

showAlertGetVehicleDialog(BuildContext context, String title, String msg,
    Function onpressed, bool isVehicle) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // ignore: deprecated_member_use
      return WillPopScope(
        onWillPop: () async => false,
        child: MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1)),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: AlertContain(
                  msg: msg,
                  title: title,
                  onpressed: onpressed,
                  isVehicle: isVehicle),
            ),
          ),
        ),
      );
    },
  );
}

showModalConfirmation(
    BuildContext context,
    String title,
    String msg,
    String buttonName1,
    String buttonName2,
    Function pressCancel,
    Function pressOk) {
  // set up the buttons

  // show the dialog

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomConfirmationModal(
          title: title,
          msg: msg,
          buttonName1: buttonName1,
          buttonName2: buttonName2,
          pressCancel: pressCancel,
          pressOk: pressOk);
    },
  );
}

class CustomConfirmationModal extends StatefulWidget {
  final String title, msg, buttonName1, buttonName2;
  final Function pressCancel, pressOk;
  const CustomConfirmationModal(
      {super.key,
      required this.title,
      required this.msg,
      required this.buttonName1,
      required this.buttonName2,
      required this.pressCancel,
      required this.pressOk});

  @override
  State<CustomConfirmationModal> createState() =>
      _CustomConfirmationModalState();
}

class _CustomConfirmationModalState extends State<CustomConfirmationModal> {
  bool isAllow = false;

  @override
  void initState() {
    super.initState();
    if (widget.buttonName2.toString().toLowerCase() == "continue") {
      isAllow = false;
    } else {
      isAllow = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: Wrap(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: Colors.white,
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CustomDisplayText(
                              label: widget.title.toUpperCase(),
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF353536),
                              fontSize: 17,
                              height: 0,
                              letterSpacing: -0.36,
                            ),
                          ),
                          Divider(
                            color: Colors.grey,
                          ),
                          Container(
                            height: 10,
                          ),
                          CustomDisplayText(
                            label: widget.msg,
                            fontSize: 14,
                            alignment: TextAlign.center,
                            fontWeight: FontWeight.w500,
                            height: 0,
                            letterSpacing: -0.28,
                          ),
                          Container(
                            height: 10,
                          ),
                          if (widget.buttonName2.toString().toLowerCase() ==
                              "continue")
                            Row(
                              children: [
                                Checkbox(
                                    value: isAllow,
                                    onChanged: (value) {
                                      setState(() {
                                        isAllow = !isAllow;
                                      });
                                    }),
                                Expanded(
                                  child: CustomDisplayText(
                                    label:
                                        "I acknowledge that I have read and understood the notice.",
                                    fontSize: 14,
                                    alignment: TextAlign.left,
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                    letterSpacing: -0.28,
                                  ),
                                )
                              ],
                            ),
                          Divider(
                            color: Colors.grey,
                          ),
                          Row(
                            children: [
                              Expanded(child: cancelButton()),
                              SizedBox(
                                width: 30,
                              ),
                              Expanded(child: continueButton()),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget cancelButton() {
    return SizedBox(
      height: 35,
      width: 100,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        child: CustomDisplayText(
          label: widget.buttonName1.isEmpty ? "No" : widget.buttonName1,
          color: const Color(0xFF353536),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 0,
          letterSpacing: -0.28,
          maxLines: 1,
        ),
        onPressed: () {
          widget.pressCancel();
        },
      ),
    );
  }

  Widget continueButton() {
    return SizedBox(
      height: 35,
      width: 100,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(!isAllow
              ? AppColor.primaryColor.withOpacity(.7)
              : AppColor.primaryColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              // No border needed for primary button
            ),
          ),
        ),
        child: CustomDisplayText(
          label: widget.buttonName2.isEmpty ? "Yes" : widget.buttonName2,
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 0,
          letterSpacing: -0.28,
        ),
        onPressed: !isAllow
            ? null
            : () {
                widget.pressOk();
              },
      ),
    );
  }
}

class AlertContain extends StatefulWidget {
  final String msg, title;
  final Function onpressed;
  final bool? isVehicle;

  const AlertContain(
      {super.key,
      required this.msg,
      required this.title,
      this.isVehicle = false,
      required this.onpressed});

  @override
  State<AlertContain> createState() => _AlertContainState();
}

class _AlertContainState extends State<AlertContain> {
  @override
  void initState() {
    super.initState();
  }

  List getImageType() {
    if (widget.msg.toLowerCase().contains("internet") &&
        widget.title != "Attention") {
      return [
        {"title": "Oh no!", "image": "no_internet"}
      ];
    } else {
      if (widget.title == "Attention") {
        return [
          {"title": "Attention", "image": "warning_popup"}
        ];
      }
      if (widget.title == "Success") {
        return [
          {"title": "Success", "image": "succesfull_transaction"}
        ];
      }
      if (widget.title == "LuvPark") {
        return [
          {"title": "LuvPark", "image": "information"}
        ];
      } else {
        return [
          {"title": "Something went wrong", "image": "something_wrong"}
        ];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * .85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      height: 150,
                      width: MediaQuery.of(context).size.width / 3,
                      image: AssetImage(
                          "assets/images/${getImageType()[0]["image"]}.png"),
                    ),
                    Container(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: CustomDisplayText(
                        label: "${widget.msg} ",
                        color: Colors.black.withOpacity(.7),
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        alignment: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: 15,
                    ),
                    CustomButton(
                        color: AppColor.primaryColor,
                        label: widget.isVehicle! ? "Register now" : "Okay",
                        onTap: () {
                          widget.onpressed();
                        }),
                    Container(
                      height: widget.isVehicle! ? 20 : 10,
                    ),
                    if (widget.isVehicle!)
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Center(
                          child: CustomDisplayText(
                            label: "Cancel",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ),
                    if (widget.isVehicle!)
                      Container(
                        height: 10,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
