// ignore: import_of_legacy_library_into_null_safe
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/forget_pass/app_text_field.dart';
import 'package:luvpark/forget_pass/reset_password_screen.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// ignore: must_be_immutable
class ForgotPassVerified extends StatefulWidget {
  String mobileNumber;
  String label;
  ForgotPassVerified({
    required this.label,
    required this.mobileNumber,
    super.key,
  });

  @override
  State<ForgotPassVerified> createState() => _ForgotPassVerifiedState();
}

class _ForgotPassVerifiedState extends State<ForgotPassVerified> {
  bool? passwordVisibility = true;
  TextEditingController mobile = TextEditingController();
  TextEditingController sqa = TextEditingController();
  TextEditingController newPass = TextEditingController();
  TextEditingController question = TextEditingController();
  String? ddVal;
  bool isLoading = false;
  bool isShowKeyboard = false;
  bool isEnableBtn = false;
  int? randomNumber;
  // ignore: prefer_typing_uninitialized_variables
  var questionData;
  var maskFormatters = MaskTextInputFormatter(
      mask: '+63 ### ### ####', filter: {"#": RegExp(r'[0-9]')});
  @override
  void initState() {
    passwordVisibility = true;
    mobile = TextEditingController();
    sqa = TextEditingController();
    newPass = TextEditingController();
    question = TextEditingController();

    Random random = Random();
    randomNumber = random.nextInt(3) + 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSecQdata();
    });
    super.initState();
  }

  void getSecQdata() {
    CustomModal(context: context).loader();
    String subApi =
        "${ApiKeys.gApiSubFolderGetDropdownSeq}?mobile_no=${widget.mobileNumber}&secq_no=$randomNumber";

    HttpRequest(api: subApi).get().then((returnData) {
      if (returnData == "No Internet") {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (returnData == null) {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
        return;
      } else {
        if (returnData["items"].length > 0) {
          Navigator.of(context).pop();
          setState(() {
            questionData = returnData["items"][0];
            question.text = questionData["question"];
          });
        } else {
          Navigator.of(context).pop();
          showAlertDialog(context, "Error",
              "Make sure that you've entered the correct phone number.", () {
            Navigator.of(context).pop();
          });

          return;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
        canPop: true,
        appBarheaderText: "Account Recovery",
        appBarIconClick: () {
          Navigator.of(context).pop();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
              ),
              const Image(
                height: 100,
                width: 100,
                fit: BoxFit.contain,
                image: AssetImage(
                  "assets/images/forget_pass_image.png",
                ),
              ),
              Container(
                height: 40,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomDisplayText(
                    label: "Security Question",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  Container(
                    height: 10,
                  ),
                  CustomDisplayText(
                    label: question.text,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppColor.textSubColor,
                  ),
                  Container(
                    height: 20,
                  ),
                  const CustomDisplayText(
                    label: "Answer",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  CustomTextField(
                    labelText: 'Answer',
                    controller: sqa,
                    onChange: (value) {
                      setState(() {
                        if (sqa.text.isEmpty) {
                          isEnableBtn = false;
                        } else {
                          isEnableBtn = true;
                        }
                      });
                      sqa.value = TextEditingValue(
                          text: Variables.capitalizeAllWord(value),
                          selection: sqa.selection);
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
              Container(
                height: 20,
              ),
              CustomButton(
                label: "Submit",
                onTap: !isEnableBtn
                    ? () {
                        showAlertDialog(
                            context, "LuvPark", "Please provide your answer.",
                            () {
                          Navigator.of(context).pop();
                        });
                      }
                    : () async {
                        FocusManager.instance.primaryFocus!.unfocus();
                        // if (isLoading) return;
                        setState(() {
                          isLoading = true;
                        });
                        CustomModal(context: context).loader();
                        var forgotParam = {
                          "secq_no": randomNumber,
                          "mobile_no": widget.mobileNumber,
                          "secq_id": questionData["secq_id"],
                          "seca": sqa.text
                        };

                        HttpRequest(
                                api: ApiKeys.gApiSubFolderPostPutGetResetPass,
                                parameters: forgotParam)
                            .post()
                            .then((returnData) {
                          if (returnData == "No Internet") {
                            Navigator.pop(context);

                            showAlertDialog(context, "Error",
                                "Please check your internet connection and try again.",
                                () {
                              Navigator.of(context).pop();
                            });
                            return;
                          }
                          if (returnData == null) {
                            Navigator.of(context).pop();
                            setState(() {
                              isLoading = false;
                            });

                            showAlertDialog(context, "Error",
                                "Error while connecting to server, Please try again.",
                                () {
                              Navigator.of(context).pop();
                            });

                            return;
                          } else {
                            Navigator.of(context).pop();
                            setState(() {
                              isLoading = false;
                            });
                            if (returnData["success"] == 'Y') {
                              if (Navigator.canPop(context)) {
                                Navigator.of(context).pop();
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: ((context) => ResetPassword(
                                        mobileNo: widget.mobileNumber,
                                        seqId: questionData["secq_id"],
                                        seca: sqa.text,
                                        seqNo: randomNumber,
                                      )),
                                ),
                              );
                            } else {
                              showAlertDialog(
                                  context, "LuvPark", returnData["msg"], () {
                                Navigator.of(context).pop();
                              });
                            }
                          }
                        });
                      },
              ),
            ],
          ),
        ));
  }
}

//securit question
securityQuestionWidget(data, TextEditingController sqa) {
  return Column(
    children: [
      Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              "Q:",
              style: GoogleFonts.prompt(
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                  color: AppColor.primaryColor,
                  letterSpacing: 1),
            ),
          ),
          Expanded(
            child: AutoSizeText(
              "${data.question}",
              textAlign: TextAlign.left,
              maxLines: 3,
              style: GoogleFonts.prompt(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                  color: Colors.blue,
                  letterSpacing: 1),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 15,
      ),
      AppTextField(
        prefix: Text(
          "A: ",
          style: GoogleFonts.prompt(color: Colors.black, fontSize: 20),
        ),
        controller: sqa,
        hint: "",
        textInputAction: TextInputAction.done,
        hasFormatter: false,
        obscureText: false,
        hasReadOnly: false,
      ),
      const SizedBox(
        height: 20,
      ),
    ],
  );
}
