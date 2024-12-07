// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/custom_button.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/custom_textfield.dart';
import 'package:luvpark/custom_widgets/variables.dart';
import 'package:luvpark/custom_widgets/vertical_height.dart';
import 'package:luvpark/routes/routes.dart';

import '../security/app_security.dart';
import 'controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginScreenController controller = Get.put(LoginScreenController());

  @override
  void initState() {
    super.initState();
    if (Variables.inactiveTmr != null) {
      Variables.inactiveTmr!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          elevation: 0,
          toolbarHeight: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColor.primaryColor,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: Container(
          width: double.infinity,
          color: AppColor.primaryColor,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30))),
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              children: [
                Expanded(
                  child: StretchingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    child: ScrollConfiguration(
                      behavior:
                          const ScrollBehavior().copyWith(overscroll: false),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(height: 20),
                            const Image(
                              image: AssetImage(
                                  "assets/images/onboardluvpark.png"),
                              width: 100,
                              fit: BoxFit.contain,
                            ),
                            Image(
                              image: const AssetImage(
                                  "assets/images/onboardlogin.png"),
                              width:
                                  MediaQuery.of(Get.context!).size.width * .55,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                            const CustomTitle(
                              text: "Login",
                              color: Colors.black,
                              maxlines: 1,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              textAlign: TextAlign.center,
                              letterSpacing: -.1,
                            ),
                            Container(height: 10),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: CustomParagraph(
                                textAlign: TextAlign.center,
                                text: "Enter your mobile number to log in",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            VerticalHeight(height: 10),
                            CustomMobileNumber(
                              labelText: "10 digit mobile number",
                              controller: controller.mobileNumber,
                              inputFormatters: [Variables.maskFormatter],
                              keyboardType: TextInputType.number,
                            ),
                            Obx(
                              () => CustomTextField(
                                title: "Password",
                                labelText: "Enter your password",
                                controller: controller.password,
                                isObscure: !controller.isShowPass.value,
                                suffixIcon: !controller.isShowPass.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                onIconTap: () {
                                  controller.visibilityChanged(
                                      !controller.isShowPass.value);
                                },
                              ),
                            ),
                            Container(height: 10),
                            Align(
                                alignment: Alignment.centerRight,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Forgot Password',
                                        style: paragraphStyle(
                                          color: AppColor.primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = controller.isLoading.value
                                              ? () {}
                                              : () async {
                                                  Get.toNamed(
                                                      Routes.forgotPass);
                                                },
                                      ),
                                    ],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )),
                            const SizedBox(
                              height: 20,
                            ),
                            if (MediaQuery.of(context).viewInsets.bottom == 0)
                              Obx(
                                () => CustomButton(
                                  loading: controller.isLoading.value,
                                  text: "Log in",
                                  onPressed: () {
                                    controller.counter++;
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    if (controller.isLoading.value) return;
                                    controller.toggleLoading(
                                        !controller.isLoading.value);

                                    if (controller.mobileNumber.text.isEmpty) {
                                      controller.toggleLoading(
                                          !controller.isLoading.value);
                                      CustomDialog().snackbarDialog(
                                          context,
                                          "Mobile number is empty",
                                          Colors.red,
                                          () {});
                                      return;
                                    } else if (controller
                                            .mobileNumber.text.length !=
                                        12) {
                                      controller.toggleLoading(
                                          !controller.isLoading.value);
                                      CustomDialog().snackbarDialog(
                                          context,
                                          "Incorrect mobile number",
                                          Colors.red,
                                          () {});
                                      return;
                                    }
                                    if (controller.password.text.isEmpty) {
                                      controller.toggleLoading(
                                          !controller.isLoading.value);
                                      CustomDialog().snackbarDialog(
                                          context,
                                          "Password is empty",
                                          Colors.red,
                                          () {});
                                      return;
                                    }
                                    Map<String, dynamic> postParam = {
                                      "mobile_no":
                                          "63${controller.mobileNumber.text.toString().replaceAll(" ", "")}",
                                      "pwd": controller.password.text,
                                    };

                                    controller.postLogin(context, postParam,
                                        (data) {
                                      controller.toggleLoading(
                                          !controller.isLoading.value);

                                      if (data[0]["items"].isNotEmpty) {
                                        Get.offAndToNamed(Routes.map);
                                      }
                                    });
                                  },
                                ),
                              ),
                            Container(
                              height: 30,
                            ),
                            Obx(
                              () => Visibility(
                                visible: controller.isToggle.value,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Divider()),
                                        Container(width: 10),
                                        CustomParagraph(text: "Or"),
                                        Container(width: 10),
                                        Expanded(child: Divider())
                                      ],
                                    ),
                                    IconButton(
                                      splashColor: Colors.red,
                                      highlightColor: Colors.green,
                                      onPressed: () async {
                                        String? mpass = await Authentication()
                                            .getPasswordBiometric();
                                        final mmobile = await Authentication()
                                            .getUserData2();

                                        bool isGG =
                                            await AppSecurity.authenticateBio();

                                        if (isGG) {
                                          CustomDialog().loadingDialog(context);
                                          Map<String, dynamic> postParam = {
                                            "mobile_no":
                                                "${mmobile["mobile_no"]}",
                                            "pwd": mpass,
                                          };

                                          controller.postLogin(
                                              context, postParam, (data) {
                                            Get.back();

                                            if (data[0]["items"].isNotEmpty) {
                                              Get.offAndToNamed(Routes.map);
                                            }
                                          });
                                        }
                                      },
                                      icon: Icon(
                                        Platform.isIOS
                                            ? LucideIcons.scanFace
                                            : LucideIcons.fingerprint,
                                        color: Colors.blue,
                                        size: 40,
                                      ),
                                    ),
                                    Container(
                                      height: 20,
                                    ),
                                    //login
                                    CustomParagraph(
                                      text: Platform.isIOS
                                          ? "Login with Face ID"
                                          : "Login with biometric",
                                      fontSize: 8,
                                      fontWeight: FontWeight.w400,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(height: 20),
                Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "New to luvpark? ",
                          style: paragraphStyle(
                              color: AppColor.paragraphColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: 'Create Account',
                          style: paragraphStyle(
                            color: AppColor.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = controller.isLoading.value
                                ? () {}
                                : () async {
                                    Get.offAndToNamed(Routes.landing);
                                  },
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Container(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class LoginScreen extends GetView<LoginScreenController> {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       child: Scaffold(
//         appBar: AppBar(
//           leading: null,
//           elevation: 0,
//           toolbarHeight: 0,
//           systemOverlayStyle: SystemUiOverlayStyle(
//             statusBarColor: AppColor.primaryColor,
//             statusBarBrightness: Brightness.light,
//             statusBarIconBrightness: Brightness.light,
//           ),
//         ),
//         body: Container(
//           width: double.infinity,
//           color: AppColor.primaryColor,
//           child: Container(
//             width: double.infinity,
//             height: MediaQuery.of(context).size.height,
//             decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                     topRight: Radius.circular(30),
//                     topLeft: Radius.circular(30))),
//             padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: StretchingOverscrollIndicator(
//                     axisDirection: AxisDirection.down,
//                     child: ScrollConfiguration(
//                       behavior:
//                           const ScrollBehavior().copyWith(overscroll: false),
//                       child: SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Container(height: 20),
//                             const Image(
//                               image: AssetImage(
//                                   "assets/images/onboardluvpark.png"),
//                               width: 100,
//                               fit: BoxFit.contain,
//                             ),
//                             Image(
//                               image: const AssetImage(
//                                   "assets/images/onboardlogin.png"),
//                               width:
//                                   MediaQuery.of(Get.context!).size.width * .55,
//                               fit: BoxFit.contain,
//                               filterQuality: FilterQuality.high,
//                             ),
//                             const CustomTitle(
//                               text: "Login",
//                               color: Colors.black,
//                               maxlines: 1,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w700,
//                               textAlign: TextAlign.center,
//                               letterSpacing: -.1,
//                             ),
//                             Container(height: 10),
//                             const Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 20),
//                               child: CustomParagraph(
//                                 textAlign: TextAlign.center,
//                                 text: "Enter your mobile number to log in",
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             VerticalHeight(height: 10),
//                             CustomMobileNumber(
//                               labelText: "10 digit mobile number",
//                               controller: controller.mobileNumber,
//                               inputFormatters: [Variables.maskFormatter],
//                               keyboardType: TextInputType.number,
//                             ),
//                             Obx(
//                               () => CustomTextField(
//                                 title: "Password",
//                                 labelText: "Enter your password",
//                                 controller: controller.password,
//                                 isObscure: !controller.isShowPass.value,
//                                 suffixIcon: !controller.isShowPass.value
//                                     ? Icons.visibility_off
//                                     : Icons.visibility,
//                                 onIconTap: () {
//                                   controller.visibilityChanged(
//                                       !controller.isShowPass.value);
//                                 },
//                               ),
//                             ),
//                             Container(height: 10),
//                             Align(
//                                 alignment: Alignment.centerRight,
//                                 child: Text.rich(
//                                   TextSpan(
//                                     children: [
//                                       TextSpan(
//                                         text: 'Forgot Password',
//                                         style: paragraphStyle(
//                                           color: AppColor.primaryColor,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                         recognizer: TapGestureRecognizer()
//                                           ..onTap = controller.isLoading.value
//                                               ? () {}
//                                               : () async {
//                                                   Get.toNamed(
//                                                       Routes.forgotPass);
//                                                 },
//                                       ),
//                                     ],
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 1,
//                                 )),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             if (MediaQuery.of(context).viewInsets.bottom == 0)
//                               Obx(
//                                 () => CustomButton(
//                                   loading: controller.isLoading.value,
//                                   text: "Log in",
//                                   onPressed: () {
//                                     controller.counter++;
//                                     FocusScope.of(context)
//                                         .requestFocus(FocusNode());
//                                     if (controller.isLoading.value) return;
//                                     controller.toggleLoading(
//                                         !controller.isLoading.value);

//                                     if (controller.mobileNumber.text.isEmpty) {
//                                       controller.toggleLoading(
//                                           !controller.isLoading.value);
//                                       CustomDialog().snackbarDialog(
//                                           context,
//                                           "Mobile number is empty",
//                                           Colors.red,
//                                           () {});
//                                       return;
//                                     } else if (controller
//                                             .mobileNumber.text.length !=
//                                         12) {
//                                       controller.toggleLoading(
//                                           !controller.isLoading.value);
//                                       CustomDialog().snackbarDialog(
//                                           context,
//                                           "Incorrect mobile number",
//                                           Colors.red,
//                                           () {});
//                                       return;
//                                     }
//                                     if (controller.password.text.isEmpty) {
//                                       controller.toggleLoading(
//                                           !controller.isLoading.value);
//                                       CustomDialog().snackbarDialog(
//                                           context,
//                                           "Password is empty",
//                                           Colors.red,
//                                           () {});
//                                       return;
//                                     }
//                                     Map<String, dynamic> postParam = {
//                                       "mobile_no":
//                                           "63${controller.mobileNumber.text.toString().replaceAll(" ", "")}",
//                                       "pwd": controller.password.text,
//                                     };

//                                     controller.postLogin(context, postParam,
//                                         (data) {
//                                       controller.toggleLoading(
//                                           !controller.isLoading.value);

//                                       if (data[0]["items"].isNotEmpty) {
//                                         Get.offAndToNamed(Routes.map);
//                                       }
//                                     });
//                                   },
//                                 ),
//                               ),
//                             Container(
//                               height: 30,
//                             ),
//                             Obx(
//                               () => Visibility(
//                                 visible: controller.isToggle.value,
//                                 child: Column(
//                                   children: [
//                                     IconButton(
//                                       splashColor: Colors.red,
//                                       highlightColor: Colors.green,
//                                       onPressed: () async {
//                                         String? mpass = await Authentication()
//                                             .getPasswordBiometric();
//                                         final mmobile = await Authentication()
//                                             .getUserData2();

//                                         bool isGG =
//                                             await AppSecurity.authenticateBio();

//                                         if (isGG) {
//                                           CustomDialog().loadingDialog(context);
//                                           Map<String, dynamic> postParam = {
//                                             "mobile_no":
//                                                 "${mmobile["mobile_no"]}",
//                                             "pwd": mpass,
//                                           };

//                                           controller.postLogin(
//                                               context, postParam, (data) {
//                                             Get.back();

//                                             if (data[0]["items"].isNotEmpty) {
//                                               Get.offAndToNamed(Routes.map);
//                                             }
//                                           });
//                                         }
//                                       },
//                                       icon: Icon(
//                                         LucideIcons.fingerprint,
//                                         color: Colors.blue,
//                                         size: 40,
//                                       ),
//                                     ),
//                                     Container(
//                                       height: 20,
//                                     ),
//                                     CustomParagraph(
//                                       text: "Login with biometric",
//                                       fontSize: 8,
//                                       fontWeight: FontWeight.w400,
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(height: 20),
//                 Center(
//                   child: Text.rich(
//                     TextSpan(
//                       children: [
//                         TextSpan(
//                           text: "New to luvpark? ",
//                           style: paragraphStyle(
//                               color: AppColor.paragraphColor,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500),
//                         ),
//                         TextSpan(
//                           text: 'Create Account',
//                           style: paragraphStyle(
//                             color: AppColor.primaryColor,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           recognizer: TapGestureRecognizer()
//                             ..onTap = controller.isLoading.value
//                                 ? () {}
//                                 : () async {
//                                     Get.offAndToNamed(Routes.landing);
//                                   },
//                         ),
//                       ],
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//                 Container(height: 15),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
