import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import 'package:luvpark/otp/otp_update.dart';
import 'package:luvpark/profile/update_step1.dart';
import 'package:luvpark/profile/update_step2.dart';
import 'package:luvpark/profile/update_step3.dart';
import 'package:luvpark/profile/update_success.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<UpdateProfile> {
  final PageController _pageController = PageController(initialPage: 0);
  final GlobalKey<FormState> page1Key = GlobalKey<FormState>();
  final GlobalKey<FormState> page2Key = GlobalKey<FormState>();
  final GlobalKey<FormState> page3Key = GlobalKey<FormState>();
  bool isValidatedS1 = false;
  bool isValidatedS2 = false;
  bool isValidatedS3 = false;
  int _currentPage = 0;
  int totalPages = 3;
  bool isInternetConnected = true;
  String imageBase64 = "";
  var dataPI = [];
  List secSubData = [];
  //step1 Information
  TextEditingController firstName = TextEditingController();
  TextEditingController middleName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController birthday = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController civilStatus = TextEditingController();
  //step2 Address

  String? ddParamProvince;
  TextEditingController provinceId = TextEditingController();
  TextEditingController regionId = TextEditingController();
  TextEditingController cityId = TextEditingController();
  TextEditingController brgyId = TextEditingController();
  TextEditingController address1 = TextEditingController();
  TextEditingController address2 = TextEditingController();
  TextEditingController zipCode = TextEditingController();
  TextEditingController searchAddress = TextEditingController();
  LatLng? location;
  //step3 Address
  TextEditingController secA1 = TextEditingController();
  TextEditingController secA2 = TextEditingController();
  TextEditingController secA3 = TextEditingController();
  TextEditingController secId1 = TextEditingController();
  TextEditingController secId2 = TextEditingController();
  TextEditingController secId3 = TextEditingController();
  var akongP;
  @override
  void initState() {
    getAccountData();
    super.initState();
  }

  void getAccountData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    akongP = prefs.getString(
      'userData',
    );

    regionId.text = jsonDecode(akongP!)["region_id"].toString();
    provinceId.text = jsonDecode(akongP)["province_id"].toString();
    cityId.text = jsonDecode(akongP)["city_id"].toString();
    brgyId.text = jsonDecode(akongP)["brgy_id"].toString();

    zipCode.text = jsonDecode(akongP)["zip_code"] == null
        ? ""
        : jsonDecode(akongP)["zip_code"].toString();
    secA1.text = jsonDecode(akongP)["seca1"].toString();
    secA2.text = jsonDecode(akongP)["seca2"].toString();
    secA3.text = jsonDecode(akongP)["seca3"].toString();

    secId1.text = jsonDecode(akongP)["secq_id1"].toString();
    secId2.text = jsonDecode(akongP)["secq_id2"].toString();
    secId3.text = jsonDecode(akongP)["secq_id3"].toString();
    lastName.text = jsonDecode(akongP)["last_name"] == null
        ? ""
        : jsonDecode(akongP)["last_name"].toString();
    firstName.text = jsonDecode(akongP)["first_name"] == null
        ? ""
        : jsonDecode(akongP)["first_name"].toString();

    middleName.text = jsonDecode(akongP)["middle_name"] == null
        ? ""
        : jsonDecode(akongP)["middle_name"].toString();

    birthday.text = jsonDecode(akongP)["birthday"] == null
        ? ""
        : jsonDecode(akongP)["birthday"].toString().split("T")[0].toString();

    email.text = jsonDecode(akongP)["email"] == null
        ? ""
        : jsonDecode(akongP)["email"].toString();
    civilStatus.text = jsonDecode(akongP)["civil_status"] ??
        jsonDecode(akongP)["civil_status"].toString();
    gender.text = jsonDecode(akongP)["gender"] == null
        ? "M"
        : jsonDecode(akongP)["gender"].toString();
  }

  Future showInformationDialog(BuildContext context, double lat, double lng,
      ValueChanged<List> callback) {
    return showDialog(
        context: context,
        builder: (context) {
          return ConfirmMapLocation(lat: lat, lng: lng, cb: callback);
        });
  }

  sendOtp(paramInfo) {
    CustomModal(context: context).loader();

    Map<String, dynamic> parameters = {
      "mobile_no": paramInfo['mobile_no'].toString(),
    };

    HttpRequest(
            api: ApiKeys.gApiSubFolderPostReqOtpShare, parameters: parameters)
        .post()
        .then(
      (retvalue) {
        if (retvalue == "No Internet") {
          Navigator.pop(context);
          showAlertDialog(context, "Error",
              "Please check your internet connection and try again.", () {
            Navigator.pop(context);
          });
        }
        if (retvalue == null) {
          Navigator.pop(context);
          showAlertDialog(context, "Error",
              "Error while connecting to server, Please try again.", () {
            Navigator.of(context).pop();
          });
        } else {
          if (retvalue["success"] == "Y") {
            Navigator.of(context).pop();
            Variables.pageTrans(
                OtpTransferScreen(
                  otp: int.parse(retvalue["otp"].toString()),
                  mobileNo: paramInfo["mobile_no"].toString(),
                  onCallbackTap: () {
                    submitInfo(paramInfo);
                  },
                ),
                context);
          } else {
            Navigator.of(context).pop();
            showAlertDialog(context, "Error", retvalue["msg"], () {
              Navigator.of(context).pop();
            });
          }
        }
      },
    );
  }

  void submitInfo(param) {
    CustomModal(context: context).loader();

    HttpRequest(api: ApiKeys.gApiSubFolderPutUpdateProf, parameters: param)
        .put()
        .then((res) async {
      if (res == "No Internet") {
        Navigator.pop(context);
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
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
          SharedPreferences pref = await SharedPreferences.getInstance();
          // await pref.remove('userData');
          await pref.remove('loginData');
          await pref.remove('myProfilePic');
          BiometricLogin().clearPassword();
          // ignore: use_build_context_synchronously
          if (Navigator.canPop(context)) {
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          }
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => const UpdateInfoSuccess()),
            ),
          );
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

  void backEvt() {
    if (_currentPage == 0) {
      Navigator.pop(context);
      return;
    } else {
      FocusScope.of(context).requestFocus(FocusNode());
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isShowKeyboard = MediaQuery.of(context).viewInsets.bottom == 0;
    return CustomParent1Widget(
      appBarheaderText: "Update Profile",
      hasPadding: false,
      canPop: false,
      onPopInvoked: backEvt,
      appBarIconClick: backEvt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: _currentPage == 0 ||
                          _currentPage == 1 ||
                          _currentPage == 2
                      ? AppColor.primaryColor
                      : const Color.fromARGB(255, 206, 231, 252),
                  child: Center(
                    child: Icon(
                      _currentPage == 0 ||
                              _currentPage == 1 ||
                              _currentPage == 2
                          ? Icons.check
                          : Icons.circle,
                      color: _currentPage == 0 ||
                              _currentPage == 1 ||
                              _currentPage == 2
                          ? Colors.white
                          : AppColor.primaryColor,
                      size: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 3,
                    color: _currentPage == 1 || _currentPage == 2
                        ? AppColor.primaryColor
                        : const Color.fromARGB(255, 206, 231, 252),
                  ),
                ),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: _currentPage == 1 || _currentPage == 2
                      ? AppColor.primaryColor
                      : const Color.fromARGB(255, 206, 231, 252),
                  child: Center(
                    child: Icon(
                      _currentPage == 1 || _currentPage == 2
                          ? Icons.check
                          : Icons.circle,
                      color: _currentPage == 1 || _currentPage == 2
                          ? Colors.white
                          : AppColor.primaryColor,
                      size: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 3,
                    color: _currentPage == 2
                        ? AppColor.primaryColor
                        : const Color.fromARGB(255, 206, 231, 252),
                  ),
                ),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: _currentPage == 2
                      ? AppColor.primaryColor
                      : const Color.fromARGB(255, 206, 231, 252),
                  child: Center(
                    child: Icon(
                      _currentPage == 2 ? Icons.check : Icons.circle,
                      color: _currentPage == 2
                          ? Colors.white
                          : AppColor.primaryColor,
                      size: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 20,
          ),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: <Widget>[
                // Page 1
                UpdateProfStep1(
                  firstName: firstName,
                  middleName: middleName,
                  lastName: lastName,
                  bday: birthday,
                  email: email,
                  gender: gender,
                  civil: civilStatus,
                  formKey: page1Key,
                  onNextPage: () {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                ),

                // Page 2
                UpdateProfStep2(
                  ddParamProvince: ddParamProvince,
                  location: location,
                  provinceId: provinceId,
                  regionId: regionId,
                  cityId: cityId,
                  brgyId: brgyId,
                  address1: address1,
                  address2: address2,
                  zipCode: zipCode,
                  formKey: page2Key,
                  searchAddress: searchAddress,
                  onPreviousPage: () {
                    _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  onNextPage: () {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                ),
                // Page 3
                UpdateProfStep3(
                  secA1: secA1,
                  secA2: secA2,
                  secA3: secA3,
                  secId1: secId1,
                  secId2: secId2,
                  secId3: secId3,
                  formKey: page3Key,
                  onPreviousPage: () {
                    _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                ),
                //  RegistrationPage3(data: dataPI),
              ],
            ),
          ),
          if (isShowKeyboard) const SizedBox(height: 20.0),
          if (isShowKeyboard)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: CustomButton(
                label: _currentPage == 2 ? "Submit" : "Continue",
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (_currentPage == 0) {
                    if (page1Key.currentState!.validate()) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  }

                  if (_currentPage == 1) {
                    if (page2Key.currentState!.validate()) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  } else {
                    if (page3Key.currentState!.validate()) {
                      Map<String, dynamic> parameters = {
                        "mobile_no":
                            jsonDecode(akongP!)["mobile_no"].toString(),
                        "last_name": lastName.text,
                        "first_name": firstName.text,
                        "middle_name": middleName.text,
                        "birthday": birthday.text,
                        "gender": gender.text,
                        "civil_status": civilStatus.text,
                        "address1": address1.text,
                        "address2": address2.text,
                        "brgy_id": brgyId.text.toString(),
                        "city_id": cityId.text.toString(),
                        "province_id": provinceId.text.toString(),
                        "region_id": regionId.text.toString(),
                        "zip_code": zipCode.text,
                        "email": email.text,
                        "secq_id1": secId1.text.toString(),
                        "secq_id2": secId2.text.toString(),
                        "secq_id3": secId3.text.toString(),
                        "seca1": secA1.text,
                        "seca2": secA2.text,
                        "seca3": secA3.text,
                        "image_base64": "",
                      };

                      showModalConfirmation(context, "Confirmation",
                          "Are you sure you want to proceed?", "", "Yes", () {
                        Navigator.of(context).pop();
                      }, () async {
                        Navigator.of(context).pop();
                        sendOtp(parameters);
                      });
                    }
                  }
                },
              ),
            ),
          SizedBox(height: Platform.isIOS ? 20.0 : 10),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class UsersPrivacy extends StatefulWidget {
  String dataDesc;
  UsersPrivacy({super.key, required this.dataDesc});

  @override
  State<UsersPrivacy> createState() => _UsersPrivacyState();
}

class _UsersPrivacyState extends State<UsersPrivacy> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1)),
        child: Container(
          // constraints: BoxConstraints(
          //   maxHeight: MediaQuery.of(context).size.height,
          // ),
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Terms & Conditions',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: CustomDisplayText(
                    label: widget.dataDesc.toString().replaceAll("â", '"'),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                height: 10,
              ),
              CustomButton(
                  label: "Agree",
                  onTap: () {
                    Navigator.of(context).pop();
                  }),
              Container(
                height: 10,
              ),
              CustomButtonCancel(
                  label: "Cancel",
                  color: Colors.grey.shade200,
                  textColor: Colors.black,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmMapLocation extends StatefulWidget {
  final double lat, lng;
  final ValueChanged<List> cb;
  const ConfirmMapLocation(
      {super.key, required this.lat, required this.lng, required this.cb});

  @override
  State<ConfirmMapLocation> createState() => _ViewSecurityQuestionState();
}

class _ViewSecurityQuestionState extends State<ConfirmMapLocation> {
  late GoogleMapController mapController;
  late CameraPosition? cameraPositions;
  LatLng? locationAddress;
  bool loading = false;
  List<Marker> markers = <Marker>[];
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    locationAddress = LatLng(widget.lat, widget.lng);
    _addCircle();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  _addCircle() {
    // Create a Circle with specified properties
    setState(() {
      markers = [];
      cameraPositions = null;
      _circles = {};
    });
    cameraPositions = CameraPosition(
      target: locationAddress!,
      zoom: 14,
      tilt: 0,
      bearing: 0,
    );
    markers.add(
      Marker(
          markerId: const MarkerId("My Location"),
          position: locationAddress!,
          visible: true,
          onTap: () async {}),
    );
    _circles.add(
      Circle(
        circleId: const CircleId("myCircle"), // Unique ID for the circle
        center: locationAddress!, // Circle center
        radius: 500, // Radius in meters (adjust as needed)
        fillColor:
            AppColor.primaryColor.withOpacity(0.1), // Fill color of the circle
        strokeColor: AppColor.primaryColor, // Border color of the circle
        strokeWidth: 1, // Border width
      ),
    );
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1)),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                height: MediaQuery.of(context).size.height * .70,
                width: MediaQuery.of(context).size.width * .95,
                decoration: BoxDecoration(
                  color: AppColor.bodyColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomButtonClose(onTap: () {
                        Navigator.of(context).pop();
                      }),
                      Container(
                        height: 5,
                      ),
                      const HeaderLabel(
                          title: "Confirm Location",
                          subTitle: "Is this your correct address?"),
                      Expanded(
                        child: loading
                            ? Container()
                            : GoogleMap(
                                mapType: MapType.normal,
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: cameraPositions!,
                                mapToolbarEnabled: true,
                                zoomControlsEnabled: false,
                                myLocationEnabled: true,
                                myLocationButtonEnabled: false,
                                compassEnabled: false,
                                buildingsEnabled: true,
                                scrollGesturesEnabled: true,
                                markers: Set<Marker>.of(markers),
                                onTap: (LatLng latLng) {
                                  // Handle the map tap here

                                  setState(() {
                                    loading = true;
                                    _circles = {};
                                    locationAddress = LatLng(
                                        latLng.latitude, latLng.longitude);
                                    _addCircle();
                                  });
                                },
                                circles: _circles,
                              ),
                      ),
                      Container(
                        height: 10,
                      ),
                      CustomButton(
                          label: "Confirm",
                          onTap: () {
                            // Navigator.pop(context);
                          })
                    ],
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
