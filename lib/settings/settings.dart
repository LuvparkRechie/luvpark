import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:luvpark/about_luvpark/about_us.dart';
import 'package:luvpark/background_process/foreground_notification.dart';
import 'package:luvpark/change_pass/change_pass.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/biometric_login.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/functions.dart';
import 'package:luvpark/classess/http_request.dart';
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
  List regionDatas = [];
  List cityData = [];
  List provinceData = [];
  List brgyData = [];
  String province = "Not specified";
  String municipality = "Not specified";
  String brgy = "Not specified";
  String gender = "Not specified";
  String civilStatus = "Not specified";

  String zipCode = "Not specified";
  String bday = "Not specified";
  String referralcode = "09x21eR";
  String myProfilePic = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  void getAccountData() async {
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
      if (mounted) {
        setState(() {
          fullName =
              "${jsonDecode(akongP!)['first_name'].toString()} ${jsonDecode(akongP!)['middle_name'].toString() == "null" ? "" : jsonDecode(akongP!)['middle_name'].toString()[0]} ${jsonDecode(akongP!)['last_name'].toString()}";
          if (jsonDecode(akongP!)['gender'].toString().isNotEmpty) {
            if (jsonDecode(akongP!)['gender'].toString() == "M") {
              gender = "Male";
            } else {
              gender = "Female";
            }
          }
          if (jsonDecode(akongP!)['civil_status'].toString().isNotEmpty) {
            if (jsonDecode(akongP!)['civil_status'].toString() == "M") {
              civilStatus = "Married";
            }
            if (jsonDecode(akongP!)['civil_status'].toString() == "S") {
              civilStatus = "Single";
            }
            if (jsonDecode(akongP!)['civil_status'].toString() == "W") {
              civilStatus = "Widowed";
            }
            if (jsonDecode(akongP!)['civil_status'].toString() == "D") {
              civilStatus = "Divorced";
            }
          }
          if (jsonDecode(akongP!)['email'].toString().isNotEmpty) {
            email = jsonDecode(akongP!)['email'].toString();
          }
          if (jsonDecode(akongP!)['zip_code'].toString().isNotEmpty) {
            zipCode = jsonDecode(akongP!)['zip_code'].toString();
          }
          if (jsonDecode(akongP!)['birthday'].toString().isNotEmpty) {
            bday = Variables.converDate(
                jsonDecode(akongP!)['birthday'].toString().split("T")[0]);
          }
          loading = false;
        });
      }
      getAccountStatusEdit();
    }
    setState(() {
      loading = false;
    });
  }

  final ImagePicker _picker = ImagePicker();
  String? imageBase64;
  AppState? state;
  File? imageFile;

  void showBottomSheetCamera() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext cont) {
          return CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  takePhoto(ImageSource.camera);
                },
                child: const Text('Use Camera'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  takePhoto(ImageSource.gallery);
                },
                child: const Text('Upload from files'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          );
        });
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 25,
      maxHeight: 480,
      maxWidth: 640,
    );

    setState(() {
      imageFile = pickedFile != null ? File(pickedFile.path) : null;
    });

    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
        imageFile!.readAsBytes().then((data) {
          imageBase64 = base64.encode(data);
          submitInfo();
        });
      });
    } else {
      imageBase64 = null;
    }
  }

  void submitInfo() async {
    CustomModal(context: context).loader();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var objInfoData = prefs.getString(
      'userData',
    );

    var myData = jsonDecode(objInfoData!);
    Map<String, dynamic> parameters = {
      "mobile_no": myData["mobile_no"],
      "last_name": myData["last_name"],
      "first_name": myData["first_name"],
      "middle_name": myData["middle_name"],
      "birthday": myData["birthday"].toString() == 'null'
          ? ''
          : myData["birthday"].toString().split("T")[0],
      "gender": myData["gender"],
      "civil_status": myData["civil_status"],
      "address1": myData["address1"],
      "address2": myData["address2"],
      "brgy_id": myData["brgy_id"] ?? "",
      "city_id": myData["city_id"] ?? "",
      "province_id": myData["province_id"] ?? "",
      "region_id": myData["region_id"] ?? "",
      "zip_code": myData["zip_code"] ?? "",
      "email": myData["email"],
      "secq_id1": myData["secq_id1"] ?? "",
      "secq_id2": myData["secq_id2"] ?? "",
      "secq_id3": myData["secq_id3"] ?? "",
      "seca1": myData["seca1"],
      "seca2": myData["seca2"],
      "seca3": myData["seca3"],
      "image_base64": imageBase64!.toString(),
    };

    HttpRequest(api: ApiKeys.gApiSubFolderPutUpdateProf, parameters: parameters)
        .put()
        .then((res) async {
      if (res == "No Internet") {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            'Please check your internet connection and try again.', () {
          Navigator.pop(context);
        });

        return;
      }
      if (res == null) {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
      } else {
        if (res["success"] == "Y") {
          Navigator.pop(context);
          await prefs.remove('myProfilePic');
          await prefs.setString('myProfilePic', jsonEncode(imageBase64!));
          setState(() {
            myImage = imageBase64!;
          });
          getAccountData();
        } else {
          Navigator.of(context).pop();
          showAlertDialog(context, "Error", res["msg"], () {
            Navigator.of(context).pop();
          });

          return;
        }
      }
    });
  }

  void getAccountStatusEdit() async {
    setState(() {
      loading = false;
      hasInternetPage = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    akongP = prefs.getString(
      'userData',
    );

    if (int.parse(jsonDecode(akongP!)['region_id'].toString()) != 0) {
      // ignore: use_build_context_synchronously
      CustomModal(context: context).loader();
      getLoadAddress(
          jsonDecode(akongP!)['region_id'], ApiKeys.gApiSubFolderGetProvince,
          (returnProvince) {
        if (int.parse(returnProvince.toString()) == 0) {
          return;
        }

        getLoadAddress(
            jsonDecode(akongP!)['province_id'], ApiKeys.gApiSubFolderGetCity,
            (returnCity) {
          if (returnCity == 0) {
            return;
          }
          getLoadAddress(
              jsonDecode(akongP!)['city_id'], ApiKeys.gApiSubFolderGetBrgy,
              (returnBrgy) {
            Navigator.pop(context);
          });
        });
      });
    } else {
      setState(() {
        prefs.setString('provinceData', "null");
        prefs.setString('brgyData', "null");
        prefs.setString('cityData', "null");
      });
      // ignore: use_build_context_synchronously
    }
  }

//GetLoadData
  void getLoadAddress(int id, folder, Function cb) async {
    // ignore: prefer_typing_uninitialized_variables
    String subApi = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (folder == ApiKeys.gApiSubFolderGetProvince) {
      if (mounted) {
        setState(() {
          provinceData = [];
          subApi = "$folder?p_region_id=$id";
        });
      }
    } else if (folder == ApiKeys.gApiSubFolderGetCity) {
      if (mounted) {
        setState(() {
          cityData = [];
          subApi = "$folder?p_province_id=$id";
        });
      }
    } else {
      if (mounted) {
        setState(() {
          subApi = "$folder?p_city_id=$id";
          prefs.remove('brgyData');
        });
      }
    }
    // ignore: prefer_typing_uninitialized_variables

    FocusManager.instance.primaryFocus!.unfocus();

    HttpRequest(api: subApi).get().then((returnData) async {
      if (returnData == "No Internet") {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            'Please check your internet connection and try again.', () {
          Navigator.pop(context);
        });
        cb(0);
        return;
      }
      if (returnData == null) {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please contact support.", () {
          Navigator.of(context).pop();
        });
        cb(0);
        return;
      } else {
        if (returnData["items"].length == 0) {
          Navigator.pop(context);
          showAlertDialog(context, "Error", "No data found.", () {
            Navigator.of(context).pop();
          });
          cb(0);
          return;
        } else {
          if (folder == ApiKeys.gApiSubFolderGetProvince) {
            provinceData = [];
            for (var provRow in returnData["items"]) {
              provinceData.add(
                  {'value': provRow["value"], 'province': provRow["text"]});
            }

            if (mounted) {
              setState(() {
                prefs.setString('provinceData', jsonEncode(provinceData));
                province = provinceData
                    .where((element) {
                      return element["value"].toString() ==
                          jsonDecode(akongP!)['province_id'].toString();
                    })
                    .toList()[0]["province"]
                    .toString();
              });
            }
            cb(1);
            return;
          }
          if (folder == ApiKeys.gApiSubFolderGetCity) {
            cityData = [];

            for (var provRow in returnData["items"]) {
              cityData
                  .add({'value': provRow["value"], 'city': provRow["text"]});
            }
            if (mounted) {
              setState(() {
                prefs.setString('cityData', jsonEncode(cityData));
                municipality = cityData
                    .where((element) {
                      return element["value"].toString() ==
                          jsonDecode(akongP!)['city_id'].toString();
                    })
                    .toList()[0]["city"]
                    .toString();
              });
            }
            cb(2);
            return;
          }
          if (folder == ApiKeys.gApiSubFolderGetBrgy) {
            brgyData = [];
            for (var provRow in returnData["items"]) {
              brgyData
                  .add({'value': provRow["value"], 'brgy': provRow["text"]});
            }

            if (jsonDecode(akongP!)['brgy_id'].toString() != "0") {
              if (mounted) {
                setState(() {
                  prefs.setString('brgyData', jsonEncode(brgyData));
                  brgy = brgyData
                      .where((element) {
                        return element["value"].toString() ==
                            jsonDecode(akongP!)['brgy_id'].toString();
                      })
                      .toList()[0]["brgy"]
                      .toString();
                });
              }
            }

            cb(3);
            return;
          }
        }
      }
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
        appbarColor: AppColor.bodyColor,
        child: Container(
          color: Color(0xFFF8F8F8),
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
                                    () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.remove("provinceData");
                                      prefs.remove("brgyData");
                                      prefs.remove("cityData");
                                      Variables.pageTrans(
                                          const UpdateProfile(), context);
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
                              // Visibility(
                              //   visible: fullName != "Not specified",
                              //   child: Padding(
                              //     padding: const EdgeInsets.only(bottom: 20.0),
                              //     child: InkWell(
                              //       onTap: () {
                              //         Variables.pageTrans(
                              //             ReferralCode(), context);
                              //       },
                              //       child: Container(
                              //         clipBehavior: Clip.antiAlias,
                              //         decoration: ShapeDecoration(
                              //           color: Color(0xFFFFCE29),
                              //           shape: RoundedRectangleBorder(
                              //             borderRadius:
                              //                 BorderRadius.circular(11),
                              //           ),
                              //         ),
                              //         child: Padding(
                              //           padding: const EdgeInsets.symmetric(
                              //               horizontal: 10, vertical: 11),
                              //           child: Row(
                              //             children: [
                              //               Container(
                              //                 decoration: BoxDecoration(
                              //                   shape: BoxShape.circle,
                              //                   border: Border.all(
                              //                     color: Colors.black12,
                              //                     width: 2,
                              //                   ),
                              //                 ),
                              //                 child: CircleAvatar(
                              //                   backgroundColor:
                              //                       Colors.transparent,
                              //                   child: Image.asset(
                              //                     "assets/images/gift.png",
                              //                     scale: 5,
                              //                   ),
                              //                 ),
                              //               ),
                              //               Container(
                              //                 width: 10,
                              //               ),
                              //               Expanded(
                              //                 child: CustomDisplayText(
                              //                   label:
                              //                       "Refer and earn free rewards",
                              //                   fontSize: 16,
                              //                   fontWeight: FontWeight.w700,
                              //                   letterSpacing: -0.32,
                              //                 ),
                              //               ),
                              //               const Icon(
                              //                 Icons.keyboard_arrow_right,
                              //                 color: Colors.black54,
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),

                              InkWell(
                                onTap: () {
                                  Variables.pageTrans(ProfileDetails(
                                    callBack: () {
                                      getAccountStatusEdit();
                                    },
                                  ), context);
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
                                        GestureDetector(
                                          onTap: () async {
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();

                                            if (int.parse(jsonDecode(
                                                        akongP!)['region_id']
                                                    .toString()) !=
                                                0) {
                                              // ignore: use_build_context_synchronously
                                              CustomModal(context: context)
                                                  .loader();
                                              getLoadAddress(
                                                  jsonDecode(
                                                      akongP!)['region_id'],
                                                  ApiKeys
                                                      .gApiSubFolderGetProvince,
                                                  (returnProvince) {
                                                if (int.parse(returnProvince
                                                        .toString()) ==
                                                    0) {
                                                  return;
                                                }

                                                getLoadAddress(
                                                    jsonDecode(
                                                        akongP!)['province_id'],
                                                    ApiKeys
                                                        .gApiSubFolderGetCity,
                                                    (returnCity) {
                                                  if (returnCity == 0) {
                                                    return;
                                                  }
                                                  getLoadAddress(
                                                      jsonDecode(
                                                          akongP!)['city_id'],
                                                      ApiKeys
                                                          .gApiSubFolderGetBrgy,
                                                      (returnBrgy) {
                                                    Navigator.pop(context);
                                                    Variables.pageTrans(
                                                        const UpdateProfile(),
                                                        context);
                                                  });
                                                });
                                              });
                                            } else {
                                              prefs.remove("provinceData");
                                              prefs.remove("brgyData");
                                              prefs.remove("cityData");
                                              Variables.pageTrans(
                                                  const UpdateProfile(),
                                                  context);
                                            }
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        AppColor.primaryColor),
                                                color: AppColor.primaryColor,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(20),
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8.0,
                                                  vertical: 4,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.edit,
                                                      size: 15,
                                                      color: Colors.white,
                                                    ),
                                                    Container(
                                                      width: 5,
                                                    ),
                                                    CustomDisplayText(
                                                      label: 'Edit',
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    )
                                                  ],
                                                ),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 10,
                              ),
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
                                                      'assets/images/parkhistorynew.png'),
                                                ),
                                                onTap: () async {
                                                  Variables.pageTrans(
                                                      ParkingHistory(),
                                                      context);
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
                                                      const MyVehicles(),
                                                      context);
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
                                                              const MapSharingScreen(),
                                                              context);
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
                                        Colors.transparent,
                                        "Change Password",
                                        'Secure your account',
                                        () {
                                          Variables.pageTrans(
                                              const ChangePasswordScreen(),
                                              context);
                                        },
                                      ),
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      myAccountList(
                                        Image.asset(
                                          'assets/images/log-out.png',
                                        ),
                                        Colors.transparent,
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
                                                          index: 1),
                                                      context);
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
                                              const FaqsLuvPark(), context);
                                        },
                                      ),
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      listColumn("Terms of Use", () async {
                                        Variables.pageTrans(
                                            const WebviewPage(
                                              urlDirect:
                                                  "https://luvpark.ph/terms-of-use/",
                                              label: "Terms of use",
                                              isBuyToken: false,
                                            ),
                                            context);
                                      }),
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      listColumn("Privacy Policy", () async {
                                        Variables.pageTrans(
                                            const WebviewPage(
                                              urlDirect:
                                                  "https://luvpark.ph/privacy-policy/",
                                              label: "Privacy Policy",
                                              isBuyToken: false,
                                            ),
                                            context);
                                      }),
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      listColumn("About LuvPark", () {
                                        Variables.pageTrans(
                                            const AboutLuvPark(), context);
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 20,
                              ),
                              Center(
                                child: CustomDisplayText(
                                  label: 'V${Variables.version}',
                                  color: const Color(0xFF9C9C9C),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  height: 0,
                                ),
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
