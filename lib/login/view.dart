// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/auth/authentication.dart';
import 'package:luvpark/custom_widgets/app_color.dart';
import 'package:luvpark/custom_widgets/variables.dart';

import '../custom_widgets/alert_dialog.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/custom_text.dart';
import '../custom_widgets/custom_textfield.dart';
import '../custom_widgets/vertical_height.dart';
import '../functions/functions.dart';
import '../routes/routes.dart';
import '../security/app_security.dart';
import 'controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginScreenController controller = Get.put(LoginScreenController());
  bool isEnabledBioLogin = false;
  bool isLoadingPage = true;
  List userData = [];
  Widget? screen;
  @override
  void initState() {
    super.initState();
    if (Variables.inactiveTmr != null) {
      Variables.inactiveTmr!.cancel();
    }
    checkIfEnabledBio();
    getBgTmrStatus();
  }

  void getBgTmrStatus() async {
    await Authentication().enableTimer(false);
  }

  checkIfEnabledBio() async {
    final usd = await Authentication().getUserData2();

    bool? isEnabledBio = await Authentication().getBiometricStatus();

    isEnabledBioLogin = isEnabledBio!;

    if (usd == null) {
      userData.clear();
    } else {
      userData.add(usd);
    }

    if (isEnabledBioLogin && userData.isNotEmpty) {
      setState(() {
        screen = BiometricLoginScreen();
        isLoadingPage = false;
      });

      return;
    } else if (userData.isNotEmpty && !isEnabledBioLogin) {
      setState(() {
        screen = UsePasswordScreen();
        isLoadingPage = false;
      });
      return;
    } else {
      setState(() {
        screen = DefaultLoginScreen();
        isLoadingPage = false;
      });
      return;
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
            statusBarColor: AppColor.bodyColor,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColor.bodyColor,
          child: isLoadingPage
              ? const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  ),
                )
              : screen!,
        ),
      ),
    );
  }
}

class BiometricLoginScreen extends StatelessWidget {
  const BiometricLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginScreenController controller = Get.put(LoginScreenController());
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Center(
                child: Image(
                  image: AssetImage("assets/images/onboardluvpark.png"),
                  width: MediaQuery.of(context).size.width * .50,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              const CustomTitle(
                text: "Welcome to luvpark",
                color: Colors.black,
                fontSize: 18,
              ),
              const SizedBox(height: 20),
              CustomParagraph(
                text:
                    "Use your Touch ID for faster, easier \naccess to your account.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(UsePasswordScreen(
                          appbar: AppBar(
                            toolbarHeight: 0,
                            elevation: 0,
                            backgroundColor: Colors.white,
                            systemOverlayStyle: SystemUiOverlayStyle(
                              statusBarColor: Colors.white,
                              statusBarBrightness: Brightness.light,
                              statusBarIconBrightness: Brightness.dark,
                            ),
                          ),
                        ));
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Colors.white,
                          border: Border.all(color: AppColor.borderColor),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.password_outlined,
                              color: AppColor.primaryColor,
                              size: 30,
                            ),
                            Container(height: 10),
                            CustomParagraph(
                              text: "Password",
                              color: AppColor.headerColor,
                              fontWeight: FontWeight.w500,
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(width: 30),
                    GestureDetector(
                      onTap: () async {
                        String devKey = await Functions().getUniqueDeviceId();

                        Map<String, dynamic> data =
                            await Authentication().getEncryptedKeys();
                        data["device_key"] = devKey.toString();

                        bool isEnabledBio = await AppSecurity.authenticateBio();

                        if (isEnabledBio) {
                          CustomDialog().loadingDialog(context);

                          controller.postLogin(context, data, (data) {
                            Get.back();

                            if (data[0]["items"].isNotEmpty) {
                              Get.offAllNamed(Routes.map);
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Colors.white,
                          border: Border.all(color: AppColor.borderColor),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.fingerprint,
                              color: AppColor.primaryColor,
                              size: 30,
                            ),
                            Container(height: 10),
                            CustomParagraph(
                              text: "Touch ID",
                              color: AppColor.headerColor,
                              fontWeight: FontWeight.w500,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: MediaQuery.of(context).size.height * .20),
              CustomButton(
                text: "Switch Account",
                btnColor: AppColor.bodyColor,
                bordercolor: AppColor.borderColor,
                textColor: Colors.black,
                onPressed: controller.switchAccount,
              ),
              Container(height: 20)
            ],
          ),
        ),

        //Login using password
      ],
    );
  }
}

class DefaultLoginScreen extends StatelessWidget {
  const DefaultLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginScreenController controller = Get.put(LoginScreenController());
    return Obx(() => StretchingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Image(
                    image: AssetImage("assets/images/onboardluvpark.png"),
                    width: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const CustomTitle(
                    text: "Welcome to luvpark",
                    fontSize: 18,
                  ),
                  const SizedBox(height: 10),
                  CustomParagraph(
                    textAlign: TextAlign.start,
                    text: "Enter your mobile number and password to log in",
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                  const VerticalHeight(height: 25),
                  CustomParagraph(
                    text: "Mobile Number",
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  CustomMobileNumber(
                    hintText: "10 digit mobile number",
                    controller: controller.mobileNumber,
                    inputFormatters: [Variables.maskFormatter],
                    keyboardType: TextInputType.number,
                  ),
                  CustomParagraph(
                    text: "Password",
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  CustomTextField(
                    hintText: "Enter your password",
                    controller: controller.password,
                    isObscure: !controller.isShowPass.value,
                    suffixIcon: !controller.isShowPass.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onIconTap: () {
                      controller
                          .visibilityChanged(!controller.isShowPass.value);
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Forgot Password',
                            style: paragraphStyle(
                              color: AppColor.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = controller.isLoading.value
                                  ? () {}
                                  : () async {
                                      Get.toNamed(Routes.forgotPass);
                                    },
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      CustomButton(
                        text: "Login",
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          CustomDialog().loadingDialog(context);

                          if (controller.mobileNumber.text.isEmpty) {
                            Get.back();
                            CustomDialog().snackbarDialog(context,
                                "Mobile number is empty", Colors.red, () {});
                            return;
                          } else if (controller.mobileNumber.text.length !=
                              12) {
                            Get.back();
                            CustomDialog().snackbarDialog(context,
                                "Incorrect mobile number", Colors.red, () {});
                            return;
                          }
                          if (controller.password.text.isEmpty) {
                            Get.back();
                            CustomDialog().snackbarDialog(context,
                                "Password is empty", Colors.red, () {});
                            return;
                          }

                          String devKey = await Functions().getUniqueDeviceId();

                          Map<String, dynamic> postParam = {
                            "mobile_no":
                                "63${controller.mobileNumber.text.toString().replaceAll(" ", "")}",
                            "pwd": controller.password.text,
                            "device_key": devKey.toString(),
                          };
                          controller.postLogin(context, postParam, (data) {
                            Get.back();

                            if (data[0]["items"].isNotEmpty) {
                              Get.offAllNamed(Routes.map);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: "Create Account",
                        btnColor: AppColor.bodyColor,
                        bordercolor: AppColor.borderColor,
                        textColor: Colors.black,
                        onPressed: () {
                          Get.offAndToNamed(Routes.landing);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class UsePasswordScreen extends StatefulWidget {
  final Widget? appbar;
  const UsePasswordScreen({super.key, this.appbar});

  @override
  State<UsePasswordScreen> createState() => _UsePasswordScreenState();
}

class _UsePasswordScreenState extends State<UsePasswordScreen> {
  TextEditingController myPassword = TextEditingController();
  List userData = [];
  @override
  void initState() {
    super.initState();

    myPassword = TextEditingController();
    getUserData();
  }

  void getUserData() async {
    final usd = await Authentication().getUserData2();

    if (usd == null) {
      setState(() {
        userData.clear();
      });
    } else {
      setState(() {
        userData.add(usd);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (widget.appbar == null) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            elevation: 0,
            backgroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.dark,
            ),
          ),
          backgroundColor: AppColor.bodyColor,
          body: bodyWidget(),
        );
      }
      return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: AppColor.primaryColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColor.primaryColor,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
          leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Iconsax.arrow_left,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: AppColor.bodyColor,
        body: bodyWidget(),
      );
    });
  }

  Widget bodyWidget() {
    final LoginScreenController controller = Get.put(LoginScreenController());

    return Container(
      color: AppColor.bodyColor,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: userData.isEmpty
          ? Container()
          : Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: MediaQuery.of(context).size.height * .10),
                    Image(
                      image: const AssetImage("assets/images/onboardlogin.png"),
                      width: MediaQuery.of(Get.context!).size.width * .55,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                    LayoutBuilder(builder: (context, constraints) {
                      if (userData[0]["first_name"] == null ||
                          userData[0]["first_name"].toString().isEmpty) {
                        return Text(
                          "+${Variables.maskMobileNumber(userData[0]["mobile_no"])}",
                          style: GoogleFonts.openSans(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: AppColor.headerColor,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
                      return Text(
                        "Hi, ${userData[0]["first_name"].toString()}",
                        style: GoogleFonts.openSans(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: AppColor.headerColor,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }),
                    const SizedBox(height: 10),
                    CustomParagraph(
                        text: "Use your password to continue login"),
                    Container(height: 40),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomParagraph(
                        text: "Password",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Obx(
                      () => CustomTextField(
                        controller: myPassword,
                        hintText: "Enter your password",
                        isObscure: !controller.isShowPass.value,
                        suffixIcon: !controller.isShowPass.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        onIconTap: () {
                          controller
                              .visibilityChanged(!controller.isShowPass.value);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Forgot Password',
                              style: paragraphStyle(
                                color: AppColor.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  Get.toNamed(Routes.forgotPass);
                                },
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomButton(
                        text: "Login",
                        onPressed: () async {
                          if (myPassword.text.isEmpty) {
                            CustomDialog().snackbarDialog(
                                context,
                                "Password must not be empty",
                                Colors.red,
                                () {});
                            return;
                          }
                          final userData =
                              await Authentication().getUserData2();

                          CustomDialog().loadingDialog(context);
                          String devKey = await Functions().getUniqueDeviceId();

                          Map<String, dynamic> postParam = {
                            "mobile_no": userData["mobile_no"],
                            "pwd": myPassword.text,
                            "device_key": devKey.toString(),
                          };

                          controller.postLogin(context, postParam, (data) {
                            Get.back();

                            if (data[0]["items"].isNotEmpty) {
                              Get.offAllNamed(Routes.map);
                            }
                          });
                        }),
                    Container(height: 20),
                    Visibility(
                      visible: widget.appbar == null,
                      child: CustomButton(
                        text: "Switch Account",
                        btnColor: AppColor.bodyColor,
                        bordercolor: AppColor.borderColor,
                        textColor: Colors.black,
                        onPressed: controller.switchAccount,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
