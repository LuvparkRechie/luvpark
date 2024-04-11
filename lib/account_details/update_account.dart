import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateAccount extends StatefulWidget {
  const UpdateAccount({super.key});

  @override
  State<UpdateAccount> createState() => _UpdateAccountState();
}

class _UpdateAccountState extends State<UpdateAccount> {
  TextEditingController firstName = TextEditingController();
  TextEditingController middleName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController bday = TextEditingController();
  TextEditingController mobile = TextEditingController();
  // ignore: prefer_typing_uninitialized_variables
  var akongP;
  String personName = "";
  String fullName = "";
  bool isLoading = true;
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

    setState(() {
      isLoading = false;
      firstName.text = jsonDecode(akongP!)['first_name'].toString();
      lastName.text = jsonDecode(akongP!)['last_name'].toString();
      mobile.text = jsonDecode(akongP!)['mobile_no'].toString();
      email.text = jsonDecode(akongP!)['email'].toString();
      gender.text = jsonDecode(akongP!)['gender'].toString();
      bday.text = DateFormat.yMMMEd()
          .format(DateTime.parse(jsonDecode(akongP!)['birthday'].toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: size.height,
          width: size.width,
          color: AppColor.bodyColor,
          child: isLoading
              ? Container()
              : Column(
                  children: [
                    Container(
                      color: const Color(0xFFffffff),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  color: AppColor.primaryColor,
                                  size: 30,
                                ),
                              ),
                              Container(
                                width: 30,
                              ),
                              const Text(
                                "Edit Profile",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Container(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                      backgroundColor: const Color(0xFFffffff),
                                      radius: 40,
                                      backgroundImage: akongP != null
                                          ? MemoryImage(
                                              const Base64Decoder().convert(
                                                  jsonDecode(akongP!)[
                                                          'image_base64']
                                                      .toString()),
                                            )
                                          : const AssetImage(
                                                  "assets/images/profIcon.png")
                                              as ImageProvider),
                                  Positioned(
                                    left: 10,
                                    bottom: 20,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green,
                                      ),
                                      height: 12,
                                      width: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 20,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextField(
                                      controller: firstName,
                                      decoration: InputDecoration(
                                          //labelText: "Phone number",

                                          contentPadding: const EdgeInsets.all(
                                              10), //  <- you can it to 0.0 for no space
                                          isDense: true,
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey)),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: AppColor.primaryColor))
                                          //border: InputBorder.none
                                          ),
                                    ),
                                    TextField(
                                      controller: lastName,
                                      decoration: InputDecoration(
                                          //labelText: "Phone number",
                                          hintText: "Phone number",
                                          contentPadding: const EdgeInsets.all(
                                              10), //  <- you can it to 0.0 for no space
                                          isDense: true,
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey)),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.red.shade400))
                                          //border: InputBorder.none
                                          ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                    Expanded(
                        child: Container(
                      width: size.width,
                      color: const Color(0xFFffffff),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 30,
                            ),
                            info("Mobile No", mobile),
                            info("Email", email),
                            info("Gender", gender),
                            info("Birthday", bday),
                            Container(
                              height: 30,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: SizedBox(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  textColor: AppColor.primaryColor,
                                  color: AppColor.primaryColor,
                                  padding: const EdgeInsets.all(10),
                                  onPressed: () async {},
                                  child: const Text(
                                    "Continue",
                                    style: TextStyle(
                                      color: Color(0xFFffffff),
                                      fontWeight: FontWeight.normal,
                                      fontFamily: "Open Sans",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                  ],
                ),
        ),
      ),
    );
  }

  Widget info(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, right: 20, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                  //labelText: "Phone number",

                  contentPadding: const EdgeInsets.all(
                      10), //  <- you can it to 0.0 for no space
                  isDense: true,
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColor.primaryColor))
                  //border: InputBorder.none
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
