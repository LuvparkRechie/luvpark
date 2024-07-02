import 'package:flutter/material.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/forget_pass/forget_pass1.dart';
import 'package:luvpark/forget_pass/forgot_passVerified.dart';
import 'package:luvpark/http_request/http_request_model.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({
    super.key,
  });

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController mobileNumber = TextEditingController();
  bool isLoadingBtn = false;
  // ignore: prefer_typing_uninitialized_variables

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
      appbarColor: AppColor.bodyColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 100,
              ),
              Center(
                child: const Image(
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                  image: AssetImage(
                    "assets/images/forget_pass_image.png",
                  ),
                ),
              ),
              Container(
                height: 20,
              ),
              CustomDisplayText(
                label: "Forgot your Password?",
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 16,
              ),
              Container(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: CustomDisplayText(
                  label:
                      "Enter your phone number below to receive password reset instructions",
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0x75353536),
                  height: 0,
                  letterSpacing: -0.28,
                  maxLines: 2,
                  alignment: TextAlign.center,
                ),
              ),
              Container(
                height: 50,
              ),
              CustomMobileNumber(
                labelText: "10 digit mobile number",
                controller: mobileNumber,
                inputFormatters: [Variables.maskFormatter],
              ),
              Container(
                height: 10,
              ),
              CustomButton(
                  label: "Create a new password",
                  onTap: () async {
                    CustomModal(context: context).loader();
                    FocusManager.instance.primaryFocus!.unfocus();
                    if (isLoadingBtn) return;
                    setState(() {
                      isLoadingBtn = true;
                    });
                    HttpRequest(
                            api:
                                "${ApiKeys.gApiLuvParkGetAcctStat}?mobile_no=63${mobileNumber.text.toString().replaceAll(" ", "")}")
                        .get()
                        .then((objData) {
                      if (objData == "No Internet") {
                        Navigator.pop(context);
                        setState(() {
                          isLoadingBtn = false;
                        });
                        showAlertDialog(context, "Error",
                            "Please check your internet connection and try again.",
                            () {
                          Navigator.of(context).pop();
                        });
                        return;
                      }
                      if (objData == null) {
                        Navigator.pop(context);
                        setState(() {
                          isLoadingBtn = false;
                        });
                        showAlertDialog(context, "Error",
                            "Error while connecting to server, Please try again.",
                            () {
                          Navigator.of(context).pop();
                        });

                        return;
                      } else {
                        setState(() {
                          isLoadingBtn = false;
                        });
                        Navigator.pop(context);

                        if (objData["success"] == "Y") {
                          Navigator.of(context).pop();
                          if (objData["is_verified"] == "Y") {
                            Variables.pageTrans(
                                ForgotPassVerified(
                                    label: "Forgot\nPassword",
                                    mobileNumber:
                                        "63${mobileNumber.text.toString().replaceAll(" ", "")}"),
                                context);
                          } else {
                            Variables.pageTrans(
                                ForgetPass1(
                                    mobileNumber: mobileNumber.text
                                        .toString()
                                        .replaceAll(" ", "")),
                                context);
                          }
                        } else {
                          showAlertDialog(context, "LuvPark", objData["msg"],
                              () {
                            Navigator.of(context).pop();
                          });
                        }
                      }
                    });
                  }),
              Container(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: CustomDisplayText(
                  label: 'Back',
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
