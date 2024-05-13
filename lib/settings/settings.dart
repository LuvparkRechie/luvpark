import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:luvpark/about_luvpark/about_us.dart';
import 'package:luvpark/background_process/foreground_notification.dart';
import 'package:luvpark/change_pass/change_pass.dart';
import 'package:luvpark/classess/biometric_login.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/faq/faq.dart';
import 'package:luvpark/location_sharing/map_display.dart';
import 'package:luvpark/login/login.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:luvpark/notification_controller/notification_controller.dart';
import 'package:luvpark/parking_trans/parking_history.dart';
import 'package:luvpark/profile/profile_details.dart';
import 'package:luvpark/profile/update_profile.dart';
import 'package:luvpark/settings/referralcode.dart';
import 'package:luvpark/sqlite/pa_message_table.dart';
import 'package:luvpark/sqlite/reserve_notification_table.dart';
import 'package:luvpark/sqlite/share_location_table.dart';
import 'package:luvpark/vehicle_registration/my_vehicles.dart';
import 'package:luvpark/webview/webview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ignore: prefer_typing_uninitialized_variables
  var widgetP = [];
  // ignore: prefer_typing_uninitialized_variables
  var akongP;
  String personName = "";
  bool loading = true;
  String myImage = "";
  String fullName = "Not specified";
  String email = "Not specified";
  bool hasInternetPage = true;
  bool? isActiveMpin;
  bool isAllowMPIN = false;
  String myProfilePic = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  void getAccountStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    akongP = prefs.getString(
      'userData',
    );
    var myPicData = prefs.getString(
      'myProfilePic',
    );

    setState(() {
      myProfilePic = jsonDecode(myPicData!).toString();
    });

    if (akongP != null) {
      var userData = jsonDecode(akongP!);
      if (userData['first_name'] != null) {
        setState(() {
          fullName =
              "${userData['first_name']} ${userData['middle_name'] != null ? userData['middle_name'][0] : ''} ${userData['last_name']}";
        });
        setState(() {
          if (userData['email'] != null) {
            email = userData['email'];
          }
        });
      }
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> refresh() async {
    getAccountStatus();
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
        appbarColor: AppColor.primaryColor,
        child: Container(
          color: Color.fromARGB(255, 249, 248, 248),
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : !hasInternetPage
                  ? NoInternetConnected(
                      onTap: () {
                        setState(() {
                          loading = true;
                        });
                        Future.delayed(Duration(seconds: 1));
                        getAccountStatus();
                      },
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Visibility(
                                visible: fullName == "Not specified",
                                child: Container(
                                  height: 70,
                                  color: AppColor.primaryColor,
                                  child: verifyAccountList(
                                    'Verify your account',
                                    'Complete your profile to unlock all features!',
                                    () {
                                      Variables.pageTrans(
                                          const UpdateProfile());
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20, right: 20, left: 20, bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CustomDisplayText(
                                  label: "Settings",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ],
                          ),
                        ),
                        Expanded(
                            child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Visibility(
                                visible: fullName != "Not specified",
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: InkWell(
                                    onTap: () {
                                      Variables.pageTrans(ReferralCode());
                                    },
                                    child: Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: Color(0xFFFFCE29),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(11),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 11),
                                        child: Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.black12,
                                                  width: 2,
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: Image.asset(
                                                  "assets/images/gift.png",
                                                  scale: 5,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: CustomDisplayText(
                                                label:
                                                    "Refer and earn free rewards",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.32,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.keyboard_arrow_right,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Variables.pageTrans(
                                    ProfileDetails(
                                      callBack: () {
                                        getAccountStatus();
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 0,
                                        blurRadius: 1,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          child: myProfilePic != 'null'
                                              ? CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor:
                                                      const Color(0xFFffffff),
                                                  backgroundImage: MemoryImage(
                                                    const Base64Decoder()
                                                        .convert(myProfilePic
                                                            .toString()),
                                                  ),
                                                )
                                              : CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor:
                                                      AppColor.primaryColor,
                                                  child: Center(
                                                    child: CustomDisplayText(
                                                      label: loading
                                                          ? ""
                                                          : jsonDecode(akongP!)[
                                                                          'first_name']
                                                                      .toString() ==
                                                                  'null'
                                                              ? "N/A"
                                                              : "${jsonDecode(akongP!)['first_name'].toString()[0]}${jsonDecode(akongP!)['last_name'].toString()[0]}",
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 0,
                                                      letterSpacing: -0.32,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        Container(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomDisplayText(
                                                label: loading ? "" : fullName,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.32,
                                              ),
                                              CustomDisplayText(
                                                label: email,
                                                color: Colors.black54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                height: 0,
                                                letterSpacing: -0.28,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_right,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 10,
                              ),
                              // if (fullName == "Not specified")
                              //   Container(
                              //     width: MediaQuery.of(context).size.width,
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(10),
                              //       color: AppColor.primaryColor,
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.black.withOpacity(0.1),
                              //           spreadRadius: 0,
                              //           blurRadius: 1,
                              //           offset: Offset(0, 2),
                              //         ),
                              //       ],
                              //     ),
                              //     child: Padding(
                              //       padding: const EdgeInsets.symmetric(
                              //         horizontal: 20,
                              //         vertical: 20,
                              //       ),
                              //       child: Stack(
                              //         children: [
                              //           Column(
                              //             crossAxisAlignment:
                              //                 CrossAxisAlignment.start,
                              //             children: [
                              //               const CustomDisplayText(
                              //                 label: "Starter Plan",
                              //                 fontSize: 20,
                              //                 color: Colors.white,
                              //               ),
                              //               Container(
                              //                 height: 10,
                              //               ),
                              //               const CustomDisplayText(
                              //                 label: "Complete your profile",
                              //                 fontSize: 16,
                              //                 color: Colors.white70,
                              //               ),
                              //               Container(
                              //                 height: 5,
                              //               ),
                              //               const CustomDisplayText(
                              //                 label: "to unlock all features!",
                              //                 fontSize: 16,
                              //                 color: Colors.white70,
                              //               ),
                              //             ],
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              // if (fullName == "Not specified")
                              //   Container(
                              //     height: 10,
                              //   ),
                              Container(
                                height: 102,
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: Color(0xFFFFFFFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 0,
                                      blurRadius: 1,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    //horizontal: 20.0,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                child: Container(
                                                  child: Image.asset(
                                                      height: 34,
                                                      width: 34,
                                                      'assets/images/parking_history.png'),
                                                ),
                                                onTap: () async {
                                                  Variables.pageTrans(
                                                      ParkingHistory());
                                                },
                                              ),
                                              Container(height: 5),
                                              CustomDisplayText(
                                                label: 'Parking History',
                                                fontSize: 12,
                                                alignment: TextAlign.center,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      VerticalDivider(
                                        color: Colors.grey,
                                        indent: 20,
                                        endIndent: 20,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                child: Container(
                                                  child: Image.asset(
                                                      height: 34,
                                                      width: 34,
                                                      'assets/images/parkhistory.png'),
                                                ),
                                                onTap: () {
                                                  Variables.pageTrans(
                                                      const MyVehicles());
                                                },
                                              ),
                                              Container(height: 5),
                                              CustomDisplayText(
                                                label: 'My Vehicles',
                                                fontSize: 12,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      VerticalDivider(
                                        color: Colors.grey,
                                        indent: 20,
                                        endIndent: 20,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                child: Container(
                                                  child: Image.asset(
                                                      height: 34,
                                                      width: 34,
                                                      'assets/images/sharelocation.png'),
                                                ),
                                                onTap: () async {
                                                  CustomModal(context: context)
                                                      .loader();
                                                  String id = await Variables
                                                      .getUserId();
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  await Functions.getSharedData(
                                                      id, (sharedData) async {
                                                    Navigator.pop(context);

                                                    if (sharedData["data"]
                                                            .isEmpty &&
                                                        sharedData["msg"] ==
                                                            "No Internet") {
                                                      showAlertDialog(
                                                          context,
                                                          "Error",
                                                          "Please check your internet connection and try again",
                                                          () {
                                                        Navigator.pop(context);
                                                      });
                                                    } else {
                                                      if (sharedData["data"]
                                                          .isNotEmpty) {
                                                        List myData =
                                                            sharedData["data"];
                                                        int existDataLength =
                                                            myData
                                                                .where(
                                                                    (element) {
                                                                  return int.parse(
                                                                          element["user_id"]
                                                                              .toString()) ==
                                                                      int.parse(
                                                                          id.toString());
                                                                })
                                                                .toList()
                                                                .length;

                                                        if (existDataLength >
                                                            0) {
                                                          ForegroundNotif
                                                              .onStop();
                                                          Variables.pageTrans(
                                                              const MapSharingScreen());
                                                        } else {
                                                          prefs.remove(
                                                              "geo_share_id");
                                                          prefs.remove(
                                                              "geo_connect_id");
                                                          showAlertDialog(
                                                              context,
                                                              "LuvPark",
                                                              "You don't have active sharing.",
                                                              () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          });
                                                        }
                                                      } else {
                                                        prefs.remove(
                                                            "geo_share_id");
                                                        prefs.remove(
                                                            "geo_connect_id");
                                                        showAlertDialog(
                                                            context,
                                                            "LuvPark",
                                                            "You don't have active sharing.",
                                                            () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        });
                                                      }
                                                    }
                                                  });
                                                },
                                              ),
                                              Container(height: 5),
                                              CustomDisplayText(
                                                maxLines: 1,
                                                label: 'Active Sharing',
                                                fontSize: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 20,
                              ),
                              CustomDisplayText(
                                label: 'My Account'.toUpperCase(),
                                fontWeight: FontWeight.bold,
                              ),
                              Container(height: 10),
                              Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: Color(0xFFFFFFFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 0,
                                      blurRadius: 1,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      myAccountList(
                                        Image.asset(
                                          'assets/images/lock-open.png',
                                        ),
                                        Color(0xFF0078FF).withOpacity(0.1),
                                        "Change Password",
                                        'Make changes to your account',
                                        () {
                                          Variables.pageTrans(
                                              const ChangePasswordScreen());
                                        },
                                      ),
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      myAccountList(
                                        Image.asset(
                                          'assets/images/log-out.png',
                                        ),
                                        Color(0xFFFF2828).withOpacity(0.1),
                                        "Log out",
                                        '',
                                        () {
                                          showModalConfirmation(
                                            context,
                                            "Confirmation",
                                            "Are you sure you want to logout?",
                                            "",
                                            "Yes",
                                            () {
                                              Navigator.of(context).pop();
                                            },
                                            () async {
                                              SharedPreferences pref =
                                                  await SharedPreferences
                                                      .getInstance();
                                              Navigator.pop(context);
                                              CustomModal(context: context)
                                                  .loader();
                                              await NotificationDatabase
                                                  .instance
                                                  .readAllNotifications()
                                                  .then((notifData) async {
                                                if (notifData.isNotEmpty) {
                                                  for (var nData in notifData) {
                                                    NotificationController
                                                        .cancelNotificationsById(
                                                            nData[
                                                                "reserved_id"]);
                                                  }
                                                }
                                                var logData =
                                                    pref.getString('loginData');
                                                var mappedLogData = [
                                                  jsonDecode(logData!)
                                                ];
                                                mappedLogData[0]["is_active"] =
                                                    "N";
                                                pref.setString(
                                                    "loginData",
                                                    jsonEncode(
                                                        mappedLogData[0]!));
                                                pref.remove('myId');
                                                NotificationDatabase.instance
                                                    .deleteAll();
                                                PaMessageDatabase.instance
                                                    .deleteAll();
                                                ShareLocationDatabase.instance
                                                    .deleteAll();
                                                NotificationController
                                                    .cancelNotifications();
                                                ForegroundNotif.onStop();
                                                BiometricLogin()
                                                    .clearPassword();
                                                Timer(
                                                    const Duration(seconds: 1),
                                                    () {
                                                  Navigator.of(context)
                                                      .pop(context);
                                                  Variables.pageTrans(
                                                      const LoginScreen(
                                                          index: 1));
                                                });
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 20,
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomDisplayText(
                                      label: 'Help and Support'.toUpperCase(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 10,
                              ),
                              Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: Color(0xFFFFFFFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 0,
                                      blurRadius: 1,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      listColumn(
                                        "Frequently Ask Question",
                                        () async {
                                          Variables.pageTrans(
                                              const FaqsLuvPark());
                                        },
                                      ),
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      listColumn("Terms of Use", () async {
                                        Variables.pageTrans(const WebviewPage(
                                          urlDirect:
                                              "https://luvpark.ph/terms-of-use/",
                                          label: "Terms of use",
                                          isBuyToken: false,
                                        ));
                                      }),
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      listColumn("Privacy Policy", () async {
                                        Variables.pageTrans(const WebviewPage(
                                          urlDirect:
                                              "https://luvpark.ph/privacy-policy/",
                                          label: "Privacy Policy",
                                          isBuyToken: false,
                                        ));
                                      }),
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      listColumn("About LuvPark", () {
                                        Variables.pageTrans(
                                            const AboutLuvPark());
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 20,
                              ),
                              CustomDisplayText(
                                label: 'V${Variables.version}',
                                color: const Color(0xFF9C9C9C),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                height: 0,
                              ),
                              Container(
                                height: 20,
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
        ));
  }

  Widget listColumn(String title, Function onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 20,
                  ),
                  CustomDisplayText(
                    label: title,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/images/external-link.png',
              scale: 1.1,
            ),
            Container(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget myAccountList(
    dynamic icon,
    Color color,
    String title,
    String desc,
    Function onTap,
  ) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (icon is Image)
                    Container(
                      width: 38,
                      height: 38,
                      child: CircleAvatar(
                        backgroundColor: color,
                        child: icon,
                      ),
                    ),
                  Container(
                    width: 20,
                  ),
                  Column(
                    children: [
                      if (desc == '')
                        Column(
                          children: [
                            CustomDisplayText(
                              label: title,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDisplayText(
                              label: title,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            CustomDisplayText(
                              label: desc,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          ],
                        )
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_right,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget verifyAccountList(
    String title,
    String desc,
    Function onTap,
  ) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDisplayText(
                            label: title,
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          CustomDisplayText(
                            label: desc,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_right,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
