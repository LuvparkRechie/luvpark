import 'dart:async';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/about_luvpark/about_us.dart';
import 'package:luvpark/background_process/android_background.dart';
import 'package:luvpark/change_pass/change_pass.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/biometric_login.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/faq/faq.dart';
import 'package:luvpark/location_sharing/fore_grount_task.dart';
import 'package:luvpark/location_sharing/map_display.dart';
import 'package:luvpark/login/login.dart';
import 'package:luvpark/notification_controller/notification_controller.dart';
import 'package:luvpark/pa_message/pa_message.dart';
import 'package:luvpark/profile/profile_details.dart';
import 'package:luvpark/settings/more_security_screen.dart';
import 'package:luvpark/sqlite/reserve_notification_table.dart';
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
  bool hasInternetPage = true;
  bool? isActiveMpin;
  bool isAllowMPIN = false;
  String myProfilePic = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAccountStatus();
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

    if (jsonDecode(akongP!)['first_name'] != null) {
      setState(() {
        fullName =
            "${jsonDecode(akongP!)['first_name'].toString()} ${jsonDecode(akongP!)['middle_name'].toString() == "null" ? "" : jsonDecode(akongP!)['middle_name'].toString()[0]} ${jsonDecode(akongP!)['last_name'].toString()}";
      });
    }
    setState(() {
      loading = false;
    });
    // HttpRequest(
    //         api:
    //             "${ApiKeys.gApiSubFolderGetLoginAttemptRecord}?mobile_no=${jsonDecode(akongP!)["mobile_no"]}")
    //     .get()
    //     .then((objData) {
    //   if (objData == "No Internet") {
    //     setState(() {
    //       hasInternetPage = false;
    //       loading = false;
    //     });
    //     Navigator.of(context).pop();
    //     showAlertDialog(context, "Error",
    //         "Please check your internet connection and try again.", () {
    //       Navigator.of(context).pop();
    //     });
    //     return;
    //   }
    //   if (objData == null) {
    //     setState(() {
    //       hasInternetPage = true;
    //       loading = false;
    //     });
    //     Navigator.of(context).pop();
    //     showAlertDialog(context, "Error",
    //         "Error while connecting to server, Please try again.", () {
    //       Navigator.of(context).pop();
    //     });

    //     return;
    //   } else {
    //     Navigator.of(context).pop();

    //     setState(() {
    //       if (objData["items"][0]["is_mpin"] == null) {
    //         isActiveMpin = null;
    //         isAllowMPIN = false;
    //       } else {
    //         isActiveMpin = objData["items"][0]["is_mpin"] == "Y" ? true : false;
    //         isAllowMPIN = true;
    //       }
    //       hasInternetPage = true;
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
        appbarColor: AppColor.primaryColor,
        child: Container(
          color: Color(0xFFF1F1F1),
          //color: const Color(0xFFF1F1F1),
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: 20, right: 20, left: 20, bottom: 0),
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomDisplayText(
                                  label: "Settings",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showModalConfirmation(
                                    context,
                                    "Confirmation",
                                    "Are you sure you want to logout?",
                                    "Cancel",
                                    () {
                                      Navigator.of(context).pop();
                                    },
                                    () async {
                                      Navigator.pop(context);
                                      CustomModal(context: context).loader();
                                      SharedPreferences pref =
                                          await SharedPreferences.getInstance();

                                      // final service =
                                      //     FlutterBackgroundService();

                                      await NotificationDatabase.instance
                                          .readAllNotifications()
                                          .then((notifData) async {
                                        if (notifData.isNotEmpty) {
                                          for (var nData in notifData) {
                                            NotificationController
                                                .cancelNotificationsById(
                                                    nData["reserved_id"]);
                                          }
                                          // NotificationDatabase.instance
                                          //     .deleteAll();
                                          // PaMessageDatabase.instance
                                          //     .deleteAll();
                                          // ShareLocationDatabase.instance
                                          //     .deleteAll();
                                          // pref.remove('myId');
                                          // pref.clear();
                                        }
                                        var logData =
                                            pref.getString('loginData');
                                        var mappedLogData = [
                                          jsonDecode(logData!)
                                        ];
                                        mappedLogData[0]["is_active"] = "N";
                                        pref.setString("loginData",
                                            jsonEncode(mappedLogData[0]!));
                                        AwesomeNotifications().cancel(0);
                                        AwesomeNotifications().dismiss(0);

                                        ForegroundNotifTask
                                            .stopForegroundTask();
                                        AndroidBackgroundProcess
                                            .isRunBackground(false);
                                        AndroidBackgroundProcess
                                            .initilizeBackgroundService();

                                        BiometricLogin().clearPassword();
                                        Timer(const Duration(seconds: 1), () {
                                          Navigator.of(context).pop(context);
                                          Variables.pageTrans(
                                              const LoginScreen(index: 1));
                                        });
                                      });
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Transform.rotate(
                                    angle: 3.12, // 90 degrees in radians
                                    child:
                                        Icon(Iconsax.logout, color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Variables.pageTrans(ProfileDetails(callBack: () {
                                getAccountStatus();
                              }));
                            },
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFf8f8fb),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
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
                                          color: AppColor.primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: myProfilePic != 'null'
                                          ? CircleAvatar(
                                              radius: 25,
                                              backgroundColor:
                                                  const Color(0xFFffffff),
                                              backgroundImage: MemoryImage(
                                                const Base64Decoder().convert(
                                                    myProfilePic.toString()),
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
                                                  fontWeight: FontWeight.w700,
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
                                          const CustomDisplayText(
                                            label: 'View Profile',
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
                            height: 20,
                          ),
                          if (fullName == "Not specified")
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColor.primaryColor,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CustomDisplayText(
                                          label: "Starter Plan",
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                        Container(
                                          height: 10,
                                        ),
                                        const CustomDisplayText(
                                          label: "Complete your profile",
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                        Container(
                                          height: 5,
                                        ),
                                        const CustomDisplayText(
                                          label: "to unlock all features!",
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ],
                                    ),
                                    const Positioned(
                                      right: -5,
                                      top: 5,
                                      child: Image(
                                        height: 100,
                                        width: 100,
                                        image: AssetImage(
                                            "assets/images/complete_prof.png"),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          if (fullName == "Not specified")
                            Container(
                              height: 20,
                            ),

                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFf8f8fb),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 11),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomDisplayText(
                                    label: 'Account Management',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  Divider(color: Colors.grey),
                                  listColumn(
                                      Image.asset('assets/images/password.png'),
                                      "Change Password", () {
                                    Variables.pageTrans(
                                        const ChangePasswordScreen());
                                  }),
                                  listColumn(
                                      Image.asset(
                                          'assets/images/transport.png'),
                                      "My Vehicles", () {
                                    Variables.pageTrans(const MyVehicles());
                                  }),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 20,
                          ),
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFf8f8fb),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 11),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomDisplayText(
                                    label: 'Features',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  Divider(color: Colors.grey),
                                  listColumn(
                                      Image.asset(
                                          'assets/images/share-location.png'),
                                      "Active sharing", () async {
                                    CustomModal(context: context).loader();
                                    String id = await Variables.getUserId();
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();

                                    print("id $id");

                                    await Functions.getSharedData(id,
                                        (sharedData) async {
                                      // print("Fetching data... $sharedData");
                                      Navigator.pop(context);

                                      if (sharedData["data"].isEmpty &&
                                          sharedData["msg"] == "No Internet") {
                                        if (mounted) {
                                          setState(() {
                                            hasInternetPage = false;
                                          });
                                        }
                                      } else {
                                        if (mounted) {
                                          setState(() {
                                            hasInternetPage = true;
                                          });
                                        }
                                        if (sharedData["data"].isNotEmpty) {
                                          List myData = sharedData["data"];
                                          int existDataLength = myData
                                              .where((element) {
                                                return int.parse(
                                                        element["user_id"]
                                                            .toString()) ==
                                                    int.parse(id.toString());
                                              })
                                              .toList()
                                              .length;

                                          if (existDataLength > 0) {
                                            FlutterForegroundTask.stopService();
                                            Variables.pageTrans(
                                                const MapSharingScreen());
                                          } else {
                                            prefs.remove('geo_connect_id');
                                            showAlertDialog(context, "LuvPark",
                                                "You don't have active sharing.",
                                                () {
                                              Navigator.of(context).pop();
                                            });
                                          }
                                        } else {
                                          prefs.remove('geo_connect_id');
                                          showAlertDialog(context, "LuvPark",
                                              "You don't have active sharing.",
                                              () {
                                            Navigator.of(context).pop();
                                          });
                                        }
                                      }
                                    });
                                  }),
                                  listColumn(
                                      Image.asset('assets/images/chat.png'),
                                      "Messages", () async {
                                    Variables.pageTrans(const PaMessage());
                                  }),
                                  // listColumn(
                                  //     Image.asset(
                                  //         'assets/images/queue_parking.png'),
                                  //     "Queued Parking", () async {
                                  //   Variables.pageTrans(const QueueList());
                                  // }),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 20,
                          ),
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFf8f8fb),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 11),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomDisplayText(
                                    label: 'Information',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                  ),

                                  listColumn(
                                      Image.asset('assets/images/faq.png'),
                                      "FAQ", () async {
                                    Variables.pageTrans(const FaqsLuvPark());
                                  }),
                                  listColumn(
                                      Image.asset('assets/images/contract.png'),
                                      "Terms of use", () async {
                                    Variables.pageTrans(const WebviewPage(
                                      urlDirect:
                                          "https://luvpark.ph/terms-of-use/",
                                      label: "Terms of use",
                                      isBuyToken: false,
                                    ));
                                  }),
                                  listColumn(
                                      Image.asset(
                                          'assets/images/compliant.png'),
                                      "Privacy Policy", () async {
                                    Variables.pageTrans(const WebviewPage(
                                      urlDirect:
                                          "https://luvpark.ph/privacy-policy/",
                                      label: "Privacy Policy",
                                      isBuyToken: false,
                                    ));
                                  }),
                                  listColumn(
                                      Image.asset('assets/images/about.png'),
                                      "About luvpark", () {
                                    Variables.pageTrans(const AboutLuvPark());
                                  }),

                                  // listColumn(Icons.policy_outlined, "Help",
                                  //     () async {
                                  //   // Variables.pageTrans(
                                  //   //     const CustomerSupport());
                                  //   CustomModal(context: context).loader();
                                  //   try {
                                  //     dynamic conversationObject = {
                                  //       'appId':
                                  //           '2792f6be0648bd34f5480da60d7aec7d8'
                                  //     };
                                  //     dynamic result =
                                  //         await KommunicateFlutterPlugin
                                  //             .buildConversation(
                                  //                 conversationObject);

                                  //     print("Conversation builder success : " +
                                  //         result.toString());
                                  //     Navigator.of(context).pop();
                                  //   } on Exception catch (e) {
                                  //     print(
                                  //         "Conversation builder error occurred : " +
                                  //             e.toString());
                                  //     Navigator.of(context).pop();
                                  //   }
                                  // }),
                                ],
                              ),
                            ),
                          ),

                          // const Divider(),
                          // if (isAllowMPIN && isActiveMpin! && !loading)
                          //   listColumn(
                          //       CupertinoIcons.checkmark_shield, "Change MPIN", () {
                          //     Variables.pageTrans(UpdateMpin(
                          //       headerLabel: "Update MPIN",
                          //       callback: getAccountStatus,
                          //     ));
                          //   }),
                          // if (isAllowMPIN && isActiveMpin! && !loading)
                          //   const Divider(),

                          // listColumn(Icons.security, "Security Preferences",
                          //     () async {
                          //   showModalBottomSheet(
                          //     context: context,
                          //     isDismissible: false,
                          //     enableDrag: false,
                          //     isScrollControlled: true,
                          //     // This makes the sheet full screen
                          //     shape: const RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.vertical(
                          //         top: Radius.circular(
                          //             15.0), // Adjust the radius as needed
                          //       ),
                          //     ),
                          //     builder: (BuildContext context) {
                          //       return UsersSecurityVerification(
                          //           callback: getAccountStatus);
                          //     },
                          //   );
                          // }),
                          // const Divider(),
                          // listColumn(Icons.timer_outlined, "User Inactivity", () {
                          //   Variables.pageTrans(const IdleScreen());
                          // }),

                          // listColumn(Icons.policy_outlined, "Privacy Policy",
                          //     () async {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: ((context) =>
                          //           const TermsConditions(title: "Privacy Policy")),
                          //     ),
                          //   );
                          // }),
                          // const Divider(),

                          Container(
                            height: 20,
                          ),
                          // InkWell(
                          //   onTap: () {
                          //     showModalConfirmation(
                          //         context,
                          //         "Confirmation",
                          //         "Are you sure you want to logout?",
                          //         "Cancel", () {
                          //       Navigator.of(context).pop();
                          //     }, () async {
                          //       Navigator.pop(context);
                          //       CustomModal(context: context).loader();
                          //       SharedPreferences pref =
                          //           await SharedPreferences.getInstance();

                          //       final service = FlutterBackgroundService();

                          //       await NotificationDatabase.instance
                          //           .readAllNotifications()
                          //           .then((notifData) async {
                          //         if (notifData.isNotEmpty) {
                          //           for (var nData in notifData) {
                          //             NotificationController
                          //                 .cancelNotificationsById(
                          //                     nData["reserved_id"]);
                          //           }
                          //           NotificationDatabase.instance.deleteAll();
                          //         }
                          //         var logData = pref.getString(
                          //           'loginData',
                          //         );
                          //         var mappedLogData = [jsonDecode(logData!)];
                          //         mappedLogData[0]["is_active"] = "N";
                          //         pref.setString("loginData",
                          //             jsonEncode(mappedLogData[0]!));
                          //         service.invoke("stopService");
                          //         pref.remove('myId');
                          //         BiometricLogin().clearPassword();
                          //         Timer(const Duration(seconds: 1), () {
                          //           Navigator.of(context).pop(context);
                          //           Variables.pageTrans(
                          //             const LoginScreen(index: 1),
                          //           );
                          //         });
                          //       });
                          //     });
                          //   },
                          //   child: Container(
                          //     clipBehavior: Clip.antiAlias,
                          //     decoration: ShapeDecoration(
                          //       color: const Color(0xFFf8f8fb),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(11),
                          //       ),
                          //     ),
                          //     child: Padding(
                          //       padding: const EdgeInsets.symmetric(
                          //           horizontal: 10, vertical: 8),
                          //       child: Padding(
                          //         padding:
                          //             const EdgeInsets.symmetric(vertical: 10),
                          //         child: Row(
                          //           mainAxisAlignment:
                          //               MainAxisAlignment.spaceBetween,
                          //           children: [
                          //             Expanded(
                          //               child: Row(
                          //                 children: [
                          //                   const Icon(
                          //                     Icons.logout_outlined,
                          //                     color: Colors.red,
                          //                   ),
                          //                   Container(
                          //                     width: 20,
                          //                   ),
                          //                   const CustomDisplayText(
                          //                     label: "Logout",
                          //                     fontSize: 14,
                          //                     fontWeight: FontWeight.bold,
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //             const Icon(
                          //               Icons.keyboard_arrow_right,
                          //               color: Colors.black54,
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
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

  Widget listColumn(dynamic icon, String title, Function onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (icon is IconData)
                    Icon(
                      icon,
                      color: title.toLowerCase() == "logout"
                          ? Colors.red
                          : const Color.fromARGB(255, 95, 95, 95),
                    ),
                  if (icon is Image)
                    Container(
                      width: 27,
                      height: 27,
                      child: icon,
                    ),
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
            const Icon(
              Icons.keyboard_arrow_right,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}

class UsersSecurityVerification extends StatefulWidget {
  final Function callback;
  const UsersSecurityVerification({super.key, required this.callback});

  @override
  State<UsersSecurityVerification> createState() =>
      _UsersSecurityVerificationState();
}

class _UsersSecurityVerificationState extends State<UsersSecurityVerification> {
  TextEditingController password = TextEditingController();
  bool? passwordVisibility = true;
  bool isVerified = false;
  bool isShowKeyboard = false;
  //variables
  // ignore: prefer_typing_uninitialized_variables
  var akongP;
  // ignore: prefer_typing_uninitialized_variables
  var myProfilePic;
  List usersLogin = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getPreferences();
    });
  }

  void getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var getLoginData = prefs.getString(
      'loginData',
    );

    setState(() {
      usersLogin = [jsonDecode(getLoginData!)];
    });
  }

  void userVerification() async {
    var postParam = {
      "mobile_no": usersLogin[0]["mobile_no"],
      "pwd": password.text,
    };
    CustomModal(context: context).loader();

    HttpRequest(api: ApiKeys.gApiSubFolderPostLogin, parameters: postParam)
        .post()
        .then((returnPost) {
      if (returnPost == "No Internet") {
        setState(() {
          isVerified = false;
        });

        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.pop(context);
        });
        return;
      }

      if (returnPost == null) {
        setState(() {
          isVerified = false;
        });

        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      } else {
        if (returnPost["success"] == "N") {
          setState(() {
            isVerified = false;
          });
          Navigator.pop(context);
          showAlertDialog(context, "Error", "Invalid Password", () {
            Navigator.pop(context);
          });
          return;
        }
        if (returnPost["success"] == 'Y') {
          Navigator.pop(context);
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Variables.pageTrans(MoreSecurityOptions(callback: widget.callback));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    isShowKeyboard = MediaQuery.of(context).viewInsets.bottom == 0;
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Wrap(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15),
            ),
          ),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: CustomDisplayText(
                    label: "Cancel",
                    fontWeight: FontWeight.w600,
                    color: AppColor.primaryColor,
                  ),
                ),
                Container(
                  height: 20,
                ),
                const HeaderLabel(
                    title: "User Verification",
                    subTitle:
                        "To enhance security and verify your identity, we kindly request that you input your password to confirm it's you and prevent unauthorized access by potential hackers."),
                LabelText(text: "Password"),
                CustomTextField(
                  labelText: "Password",
                  controller: password,
                  isObscure: passwordVisibility! ? true : false,
                  suffixIcon: passwordVisibility!
                      ? Icons.visibility
                      : Icons.visibility_off,
                  onIconTap: () {
                    setState(() {
                      passwordVisibility = !passwordVisibility!;
                    });
                  },
                  onChange: (value) async {},
                ),
                Container(
                  height: 10,
                ),
                CustomButton(
                    label: "Confirm",
                    onTap: () {
                      FocusManager.instance.primaryFocus!.unfocus();
                      userVerification();
                    }),
                Container(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastEaseInToSlowEaseOut,
          height: keyboardHeight,
        )
      ],
    );
  }
}
