import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:luvpark/classess/DbProvider.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/biometric_login.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/mpin/mpin.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class MoreSecurityOptions extends StatefulWidget {
  final Function? callback;
  const MoreSecurityOptions({super.key, this.callback});

  @override
  State<MoreSecurityOptions> createState() => _MoreSecurityOptionsState();
}

class _MoreSecurityOptionsState extends State<MoreSecurityOptions> {
  bool secured = false;
  bool isMpin = false;
  bool enableBioTrans = false;
  bool isAuth = false;
  bool? isActiveMpin;
  bool isLoadingPage = false;
  bool hasInternetPage = true;
  var akongP;
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState supportState = _SupportState.unknown;

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );

    DbProvider().getAuthState().then((value) {
      setState(() {
        secured = value;
      });
    });
    DbProvider().getAuthTransaction().then((value) async {
      setState(() {
        enableBioTrans = value;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //  getCurrentUserEmail();
      getAccountStatus();
    });
  }

  void getAccountStatus() async {
    CustomModal(context: context).loader();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    akongP = prefs.getString(
      'userData',
    );

    HttpRequest(
            api:
                "${ApiKeys.gApiSubFolderGetLoginAttemptRecord}?mobile_no=${jsonDecode(akongP!)["mobile_no"]}")
        .get()
        .then((objData) {
      if (objData == "No Internet") {
        setState(() {
          hasInternetPage = false;
        });
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (objData == null) {
        setState(() {
          hasInternetPage = true;
        });
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });

        return;
      } else {
        Navigator.of(context).pop();

        setState(() {
          if (objData["items"][0]["is_mpin"] == null) {
            isActiveMpin = null;
            isMpin = false;
          } else {
            isActiveMpin = objData["items"][0]["is_mpin"] == "Y" ? true : false;
            isMpin = isActiveMpin!;
          }
          hasInternetPage = true;
        });
      }
    });
  }

  void _authenticateWithBiometrics(isTransaction) async {
    // ignore: unused_local_variable
    setState(() {
      isAuth = true;
    });

    final LocalAuthentication auth = LocalAuthentication();
    // ignore: unused_local_variable
    bool canCheckBiometrics = false;

    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      debugPrint("$e");
    }

    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Touch your finger on the sensor',
        options: const AuthenticationOptions(
          stickyAuth: true,
          sensitiveTransaction: false,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint("$e");
    }

    setState(() {
      isAuth = authenticated ? true : false;
    });

    if (isAuth) {
      if (isTransaction) {
        setState(() {
          enableBioTrans = false;
        });
        DbProvider().saveAuthTransaction(false);
      } else {
        setState(() {
          secured = false;
        });
        DbProvider().saveAuthState(false);
      }
    } else {
      if (isTransaction) {
        setState(() {
          enableBioTrans = true;
        });
        DbProvider().saveAuthTransaction(true);
      } else {
        setState(() {
          secured = true;
        });
        DbProvider().saveAuthState(true);
      }
    }
  }

  Color getSwitchColor(bool isEnable) {
    if (isEnable) {
      return AppColor.primaryColor;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
      appBarheaderText: "Security Preference",
      appBarIconClick: () {
        Navigator.of(context).pop();
        widget.callback!();
      },
      child: !hasInternetPage
          ? Center(
              child: NoInternetConnected(onTap: () {
                getAccountStatus();
              }),
            )
          : Column(
              children: [
                Container(
                  height: 10,
                ),
                Row(
                  children: [
                    securityOptions(CupertinoIcons.checkmark_shield),
                    Container(
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDisplayText(
                            label: "MPIN",
                            color: Colors.black,
                            fontSize: 14.0,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w700,
                          ),
                          Container(
                            height: 1,
                          ),
                          CustomDisplayText(
                            label: "Uses number combination to login",
                            color: Colors.black,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            overflow: TextOverflow.visible,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    CustomSwitch(
                      value: isMpin,
                      enableColor: getSwitchColor(isMpin),
                      disableColor: getSwitchColor(isMpin),
                      onChanged: (bool value) async {
                        if (isActiveMpin == null) {
                          showModalConfirmation(
                              context,
                              "Attention",
                              "Your MPIN has not been configured yet. Would you like to create one?",
                              "Cancel", () {
                            Navigator.of(context).pop();
                          }, () async {
                            Navigator.of(context).pop();
                            Variables.pageTrans(MpinSetup(
                                headerLabel: "Create MPIN",
                                callback: getAccountStatus));

                            return;
                          });
                        } else {
                          CustomModal(context: context).loader();
                          var mPinParams = {
                            "user_id": jsonDecode(akongP!)["user_id"],
                            "is_on": value ? 'Y' : 'N'
                          };

                          HttpRequest(
                                  api: ApiKeys.gApiSubFolderPutSwitch,
                                  parameters: mPinParams)
                              .put()
                              .then((returnData) async {
                            if (returnData == null) {
                              Navigator.of(context).pop();
                              showAlertDialog(context, "Error",
                                  "Error while connecting to server, Please try again.",
                                  () {
                                Navigator.of(context).pop();
                              });

                              return;
                            }

                            if (returnData["success"] == 'Y') {
                              Navigator.of(context).pop();

                              setState(() {
                                isMpin = value;
                              });
                            } else {
                              Navigator.of(context).pop();
                              showAlertDialog(
                                  context, "Error", returnData["msg"], () {
                                Navigator.of(context).pop();
                              });
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
                Container(
                  height: 21,
                ),
                Row(
                  children: [
                    securityOptions(Icons.fingerprint_outlined),
                    Container(
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDisplayText(
                            label: "Login Security",
                            color: Colors.black,
                            fontSize: 14.0,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w700,
                          ),
                          Container(
                            height: 1,
                          ),
                          CustomDisplayText(
                            label: "Uses biometric to login",
                            color: Colors.black,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            overflow: TextOverflow.visible,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    CustomSwitch(
                      value: secured,
                      enableColor: getSwitchColor(secured),
                      disableColor: getSwitchColor(secured),
                      onChanged: (bool value) async {
                        setState(() {
                          secured = value;
                        });
                        final localAuth = LocalAuthentication();

                        if (secured) {
                          BiometricLogin()
                              .checkBiometrics()
                              .then((canCheckBiometrics) async {
                            if (canCheckBiometrics) {
                              List<BiometricType> availableBiometrics =
                                  await localAuth.getAvailableBiometrics();

                              if (availableBiometrics.isNotEmpty) {
                                DbProvider().saveAuthState(value);
                              } else {
                                // ignore: use_build_context_synchronously
                                showAlertDialog(context, "Fingerprint required",
                                    "Fingerprint is not set up on your device. Go to 'Settings > Security' to add your fingerprint.",
                                    () async {
                                  Navigator.of(context).pop();
                                });
                                DbProvider().saveAuthState(false);
                                setState(() {
                                  secured = false;
                                });
                              }
                            } else {
                              showAlertDialog(context, "Error",
                                  "Fingerprint is not available on this device.",
                                  () {
                                Navigator.of(context).pop();
                              });
                              DbProvider().saveAuthState(false);
                              setState(() {
                                secured = false;
                              });
                            }
                          });
                        } else {
                          // DbProvider().saveAuthState(false);
                          _authenticateWithBiometrics(false);
                        }
                      },
                    ),
                  ],
                ),
                Container(
                  height: 21,
                ),
                Row(
                  children: [
                    securityOptions(Icons.fingerprint_outlined),
                    Container(
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDisplayText(
                            label: "Transaction Security",
                            color: Colors.black,
                            fontSize: 14.0,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w700,
                          ),
                          Container(
                            height: 1,
                          ),
                          CustomDisplayText(
                            label: "Makes your transaction safe",
                            color: Colors.black,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            overflow: TextOverflow.visible,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    CustomSwitch(
                        value: enableBioTrans,
                        enableColor: getSwitchColor(enableBioTrans),
                        disableColor: getSwitchColor(enableBioTrans),
                        onChanged: (bool value) async {
                          setState(() {
                            enableBioTrans = value;
                          });
                          final localAuth = LocalAuthentication();

                          if (enableBioTrans) {
                            BiometricLogin()
                                .checkBiometrics()
                                .then((canCheckBiometrics) async {
                              if (canCheckBiometrics) {
                                List<BiometricType> availableBiometrics =
                                    await localAuth.getAvailableBiometrics();

                                if (availableBiometrics.isNotEmpty) {
                                  DbProvider().saveAuthTransaction(value);
                                } else {
                                  // ignore: use_build_context_synchronously
                                  showAlertDialog(
                                      context,
                                      "Fingerprint required",
                                      "Fingerprint is not set up on your device. Go to 'Settings > Security' to add your fingerprint.",
                                      () async {
                                    Navigator.of(context).pop();
                                  });
                                  DbProvider().saveAuthTransaction(false);
                                  setState(() {
                                    enableBioTrans = false;
                                  });
                                }
                              } else {
                                showAlertDialog(context, "Error",
                                    "Fingerprint is not available on this device.",
                                    () {
                                  Navigator.of(context).pop();
                                });
                                DbProvider().saveAuthTransaction(false);
                                setState(() {
                                  enableBioTrans = false;
                                });
                              }
                            });
                          } else {
                            _authenticateWithBiometrics(true);
                          }
                        })
                  ],
                )
              ],
            ),
    );
  }

  Widget securityOptions(IconData icons) {
    return SizedBox(
      width: 44.0,
      height: 44.0,
      child: CircleAvatar(
        backgroundColor: AppColor.primaryColor,
        child: Icon(icons),
      ),
    );
  }
}

class CustomSwitch extends StatefulWidget {
  final bool? value;
  final Color? enableColor;
  final Color? disableColor;
  final double? width;
  final double? height;
  final double? switchHeight;
  final double? switchWidth;
  final ValueChanged<bool>? onChanged;

  const CustomSwitch(
      {Key? key,
      this.value,
      this.enableColor,
      this.disableColor,
      this.width,
      this.height,
      this.switchHeight,
      this.switchWidth,
      this.onChanged})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late Animation _circleAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 60));
    _circleAnimation = AlignmentTween(
            begin: widget.value! ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.value! ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
            widget.value == false
                ? widget.onChanged!(true)
                : widget.onChanged!(false);
          },
          child: Container(
            width: widget.width ?? 48.0,
            height: widget.height ?? 24.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              color: _circleAnimation.value == Alignment.centerLeft
                  ? widget.disableColor
                  : widget.enableColor,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 2.0, bottom: 2.0, right: 2.0, left: 2.0),
              child: Container(
                alignment: widget.value!
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: widget.switchWidth ?? 20.0,
                  height: widget.switchHeight ?? 20.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
