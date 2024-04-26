import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/activate_account/activate_account.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/biometric_login.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/forget_pass/forget_pass1.dart';
import 'package:luvpark/forget_pass/forgot_passVerified.dart';
import 'package:luvpark/login/class/login_class.dart';
import 'package:luvpark/sqlite/vehicle_brands_model.dart';
import 'package:luvpark/sqlite/vehicle_brands_table.dart';

class LoginScreen extends StatefulWidget {
  final int index;
  const LoginScreen({super.key, required this.index});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isLogin = false;
  bool isInternetConnected = true;
  bool isLoading = false;
  bool isShowPass = true;
  bool isTappedReg = false;
  var usersLogin = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
      onPop: false,
      appbarColor: AppColor.bodyColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.index == 0)
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_back),
                            CustomDisplayText(
                              label: "Back",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            )
                          ],
                        ),
                      ),
                    if (widget.index != 0) Container(),
                    CustomDisplayText(
                      label: 'V${Variables.version}',
                      color: const Color(0xFF9C9C9C),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  ],
                ),
                Container(
                  height: 10,
                ),
                Center(
                  child: Image(
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.width * .60,
                    image: const AssetImage("assets/images/login_logo.png"),
                  ),
                ),
                Container(
                  height: 20,
                ),
                CustomDisplayText(
                  label: "Login",
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textHeaderLabelColor,
                ),
                CustomDisplayText(
                  label: "Please login to your account",
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColor.textSubColor,
                ),
                Container(
                  height: 20,
                ),
                LabelText(text: "Mobile"),
                CustomMobileNumber(
                  labelText: "10 digit mobile number",
                  controller: mobileNumber,
                  inputFormatters: [Variables.maskFormatter],
                ),
                LabelText(text: "Password"),
                CustomTextField(
                  labelText: "Enter your password",
                  controller: password,
                  isObscure: isShowPass,
                  suffixIcon:
                      isShowPass ? Icons.visibility_off : Icons.visibility,
                  onIconTap: () {
                    setState(() {
                      isShowPass = !isShowPass;
                    });
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () async {
                      showModalBottomSheet(
                        context: context,
                        isDismissible: true,
                        enableDrag: true,
                        isScrollControlled: true,
                        // This makes the sheet full screen
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(
                                15.0), // Adjust the radius as needed
                          ),
                        ),
                        builder: (BuildContext context) {
                          return const ForgotPasswordBottomSheet();
                        },
                      );
                      // SharedPreferences prefs =
                      //     await SharedPreferences.getInstance();
                      // var myData = prefs.getString(
                      //   'userData',
                      // );

                      // if (myData != null &&
                      //     jsonDecode(myData)['last_name'].toString() !=
                      //         'null') {
                      //   Variables.pageTrans(ForgotPassVerified(
                      //     label: "Forgot\nPassword",
                      //   ));
                      // } else {
                      //   Variables.pageTrans(const ForgetPass1());
                      // }
                    },
                    child: CustomDisplayText(
                      label: "Forgot Password?",
                      color: AppColor.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  height: 20,
                ),
                // isLoading
                //     ? Shimmer.fromColors(
                //         baseColor: Colors.grey.shade300,
                //         highlightColor: const Color(0xFFe6faff),
                //         child: CustomButton(
                //           label: "",
                //           onTap: () {},
                //         ),
                //       )
                //     :
                CustomButton(
                    label: "Login",
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      yowo() {
                        // ignore: use_build_context_synchronously
                        LoginComponent().getAccountStatus(
                            context,
                            "63${mobileNumber.text.replaceAll(" ", "")}",
                            password.text, (items) {
                          if (items == "No Internet") {
                            Navigator.of(context).pop();
                            setState(() {
                              isLoading = false;
                              isLogin = false;
                            });
                            return;
                          }
                          if (items.length == 0) {
                            Navigator.of(context).pop();
                            showAlertDialog(
                                context, "Error", "Invalid Account.", () {
                              setState(() {
                                isLoading = false;
                                isLogin = false;
                              });
                              Navigator.of(context).pop();
                            });
                            return;
                          } else {
                            if (items[0]["is_active"] == "N") {
                              Navigator.of(context).pop();
                              showModalConfirmation(
                                  context,
                                  "Inactive Account",
                                  "Your account is currently inactive. Would you like to activate it now?",
                                  "Not now", () {
                                Navigator.of(context).pop();
                                setState(() {
                                  isLoading = false;
                                  isLogin = false;
                                });
                              }, () async {
                                //Activate account
                                setState(() {
                                  isLoading = false;
                                  isLogin = false;
                                });
                                Navigator.pop(context);
                                Variables.pageTrans(
                                  ActivateAccountScreen(
                                      mobileNo:
                                          "63${mobileNumber.text.replaceAll(" ", "")}",
                                      password: password.text),
                                );
                              });
                            } else {
                              LoginComponent().loginFunc(
                                  password.text,
                                  "63${mobileNumber.text.toString().replaceAll(" ", "")}",
                                  context, (callBack) {
                                Navigator.of(context).pop();
                                setState(() {
                                  isLoading = false;
                                  isLogin = false;
                                  if (callBack[1] == "No Internet") {
                                    isInternetConnected = false;
                                  } else {
                                    isInternetConnected = true;
                                  }
                                });
                              });
                            }
                          }
                        });
                      }

                      setState(() {
                        isLogin = false;
                      });
                      if (isLogin) return;

                      BiometricLogin().clearPassword();
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isLogin = true;
                        });
                        CustomModal(context: context).loader();
                        LocationPermission permission =
                            await Geolocator.checkPermission();

                        if (permission == LocationPermission.denied ||
                            permission == LocationPermission.deniedForever) {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                          setState(() {
                            isLogin = false;
                          });
                          // ignore: use_build_context_synchronously
                          DashboardComponent.locatePosition(context, true);
                        } else {
                          if (mounted) {
                            setState(() {
                              isLoading = true;
                            });
                          }

                          String apiParam =
                              "${ApiKeys.gApiLuvParkGetVehicleBrand}";
                          HttpRequest(api: apiParam)
                              .get()
                              .then((returnBrandData) async {
                            if (returnBrandData == "No Internet") {
                              Navigator.of(context).pop();
                              setState(() {
                                isLoading = false;
                                isLogin = false;
                              });
                              showAlertDialog(context, "Error",
                                  "Please check your internet connection and try again.",
                                  () {
                                Navigator.of(context).pop();
                              });
                              return;
                            }
                            if (returnBrandData == null) {
                              Navigator.of(context).pop();
                              setState(() {
                                isLoading = false;
                                isLogin = false;
                              });
                              showAlertDialog(context, "Error",
                                  "Error while connecting to server, Please try again.",
                                  () {
                                Navigator.of(context).pop();
                              });
                            }

                            if (returnBrandData["items"].length > 0) {
                              VehicleBrandsTable.instance.deleteAll();
                              for (var dataRow in returnBrandData["items"]) {
                                var vbData = {
                                  VHBrandsDataFields.vhTypeId: int.parse(
                                      dataRow["vehicle_type_id"].toString()),
                                  VHBrandsDataFields.vhBrandId: int.parse(
                                      dataRow["vehicle_brand_id"].toString()),
                                  VHBrandsDataFields.vhBrandName:
                                      dataRow["vehicle_brand_name"].toString(),
                                };
                                await VehicleBrandsTable.instance
                                    .insertUpdate(vbData);
                              }
                              yowo();
                              return;
                            } else {
                              yowo();
                              return;
                            }
                          });
                        }
                      }
                    }),
                Container(
                  height: 100,
                ),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: "New to luvpark?",
                            style: Platform.isAndroid
                                ? GoogleFonts.dmSans(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  )
                                : TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "SFProTextReg",
                                  ),
                            children: <TextSpan>[
                              TextSpan(
                                text: " Create Account",
                                style: Platform.isAndroid
                                    ? GoogleFonts.dmSans(
                                        color: AppColor.primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      )
                                    : TextStyle(
                                        color: AppColor.primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "SFProTextReg",
                                      ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    if (isTappedReg) return;
                                    bool serviceEnabled;
                                    serviceEnabled = await Geolocator
                                        .isLocationServiceEnabled();
                                    setState(() {
                                      isTappedReg = false;
                                    });
                                    if (!serviceEnabled) {
                                      // ignore: use_build_context_synchronously
                                      showAlertDialog(context, "Attention",
                                          "To continue, turn on device location which uses Google's location service.",
                                          () {
                                        Navigator.of(context).pop();
                                      });
                                    } else {
                                      // ignore: use_build_context_synchronously
                                      DashboardComponent.locatePosition(
                                          context, false);
                                    }
                                  },
                              ),
                            ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordBottomSheet extends StatefulWidget {
  const ForgotPasswordBottomSheet({
    super.key,
  });

  @override
  State<ForgotPasswordBottomSheet> createState() =>
      _ForgotPasswordBottomSheetState();
}

class _ForgotPasswordBottomSheetState extends State<ForgotPasswordBottomSheet> {
  TextEditingController mobileNumber = TextEditingController();
  bool isLoadingBtn = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: Wrap(
        children: [
          Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 7,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFD9D9D9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7)),
                        ),
                      ),
                    ),
                    Container(height: 20),
                    CustomDisplayText(
                      label: "Forgot Password",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textHeaderLabelColor,
                    ),
                    Container(
                      height: 5,
                    ),
                    CustomDisplayText(
                      label:
                          "To proceed please input your registered\nmobile number.",
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: AppColor.textSubColor,
                    ),
                    Container(
                      height: 15,
                    ),
                    CustomMobileNumber(
                      labelText: "Mobile No",
                      controller: mobileNumber,
                      inputFormatters: [Variables.maskFormatter],
                    ),
                    Container(
                      height: 20,
                    ),
                    // isLoadingBtn
                    //     ? Shimmer.fromColors(
                    //         baseColor: Colors.grey.shade300,
                    //         highlightColor: const Color(0xFFe6faff),
                    //         child: CustomButton(
                    //           label: "",
                    //           onTap: () {},
                    //         ),
                    //       )
                    //     :
                    CustomButton(
                        label: "Proceed",
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
                                  Variables.pageTrans(ForgotPassVerified(
                                      label: "Forgot\nPassword",
                                      mobileNumber:
                                          "63${mobileNumber.text.toString().replaceAll(" ", "")}"));
                                } else {
                                  Variables.pageTrans(ForgetPass1(
                                      mobileNumber: mobileNumber.text
                                          .toString()
                                          .replaceAll(" ", "")));
                                }
                              } else {
                                showAlertDialog(
                                    context, "LuvPark", objData["msg"], () {
                                  Navigator.of(context).pop();
                                });
                              }
                            }
                          });
                        }),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
