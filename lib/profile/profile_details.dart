import 'dart:convert';
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/profile/profile_delete.dart';
import 'package:luvpark/profile/update_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDetails extends StatefulWidget {
  final Function callBack;
  const ProfileDetails({super.key, required this.callBack});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _ProfileDetailsState extends State<ProfileDetails> {
  var widgetP = [];
  // ignore: prefer_typing_uninitialized_variables
  var objInfoData;
  var akongP;
  bool hasInternetPage = true;

  List regionDatas = [];
  List cityData = [];
  List provinceData = [];
  List brgyData = [];
  String province = "Not specified";
  String municipality = "Not specified";
  String brgy = "Not specified";
  String gender = "Not specified";
  String civilStatus = "Not specified";
  String email = "Not specified";
  String zipCode = "Not specified";
  String bday = "Not specified";
  String referralcode = "09x21eR";
  String personName = "";
  String fullName = "Not specified";
  String myImage = "";
  String myProfilePic = "";
  bool? isActiveMpin;
  bool isAllowMPIN = false;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    getAccountData();
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
      getAccountStatus();
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

  void getAccountStatus() async {
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

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
        appbarColor: AppColor.primaryColor,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: AppColor.bodyColor,
          child: Padding(
            padding:
                const EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFf5f5fa),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.arrow_back,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    CustomDisplayText(
                        label: "My Profile",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    Container(
                      width: 10,
                    ),
                  ],
                ),
                Container(
                  height: 20,
                ),
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      loading
                          ? Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColor.primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor:
                                    Color.fromARGB(255, 236, 236, 236),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColor.primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: const Color(0xFFffffff),
                                backgroundImage: myProfilePic != 'null'
                                    ? MemoryImage(
                                        const Base64Decoder().convert(
                                          myImage.isNotEmpty
                                              ? myImage.toString()
                                              : myProfilePic.toString(),
                                        ),
                                      )
                                    : AssetImage(
                                        "assets/images/${gender == "Male" || gender == "Not specified" ? "profIcon" : "gagi"}.png",
                                      ) as ImageProvider,
                              ),
                            ),
                      Positioned(
                        bottom: -10,
                        right: -10,
                        child: InkWell(
                            onTap: () {
                              showBottomSheetCamera();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Icon(
                                Icons.camera_alt,
                                color: AppColor.primaryColor,
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 10,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomDisplayText(
                            label: fullName,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 63, 63, 64),
                          ),
                          CustomDisplayText(
                            label: email,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ]),
                  ),
                ),
                Container(height: 10),
                Center(
                  child: InkWell(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      if (int.parse(
                              jsonDecode(akongP!)['region_id'].toString()) !=
                          0) {
                        // ignore: use_build_context_synchronously
                        CustomModal(context: context).loader();
                        getLoadAddress(jsonDecode(akongP!)['region_id'],
                            ApiKeys.gApiSubFolderGetProvince, (returnProvince) {
                          if (int.parse(returnProvince.toString()) == 0) {
                            return;
                          }

                          getLoadAddress(jsonDecode(akongP!)['province_id'],
                              ApiKeys.gApiSubFolderGetCity, (returnCity) {
                            if (returnCity == 0) {
                              return;
                            }
                            getLoadAddress(jsonDecode(akongP!)['city_id'],
                                ApiKeys.gApiSubFolderGetBrgy, (returnBrgy) {
                              Navigator.pop(context);
                              Variables.pageTrans(const UpdateProfile());
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
                        Variables.pageTrans(const UpdateProfile());
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColor.primaryColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8.0),
                        child: CustomDisplayText(
                          label: "Update Profile",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(height: 10),
                const Divider(
                  color: Colors.black,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        info("Gender", gender),
                        info("Civil Status", civilStatus),
                        info("Birthday", bday),
                        info("Address", "$brgy $municipality"),
                        info("Province", province),
                        info("Zip Code", zipCode),
                        SizedBox(height: 10),
                        ProfileDelete(),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget info(label, value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: MediaQuery.of(context).size.width,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFf8f8fb),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelText(text: label),
                      Row(
                        children: [
                          CustomDisplayText(
                            label: value,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
