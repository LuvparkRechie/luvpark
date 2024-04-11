import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/account_details/update_account.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountDetails extends StatefulWidget {
  const AccountDetails({super.key});

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  var widgetP = [];
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
    var sexuality = "";
    if (jsonDecode(akongP!)['gender'].toString() == "M") {
      setState(() {
        sexuality = "Mr";
      });
    } else {
      setState(() {
        sexuality = "Ms";
      });
    }
    setState(() {
      isLoading = false;
      fullName =
          "${jsonDecode(akongP!)['last_name'].toString()} ${jsonDecode(akongP!)['first_name'].toString()} ${jsonDecode(akongP!)['middle_name'].toString()[0]}";
      personName =
          "$sexuality ${jsonDecode(akongP!)['first_name'].toString()} ${jsonDecode(akongP!)['last_name'].toString()[0]}. ";
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            child: isLoading
                ? Container()
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              color: AppColor.primaryColor,
                              size: 30,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const UpdateAccount(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));

                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ));
                            },
                            child: const Icon(
                              Icons.edit,
                              color: Colors.grey,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                  backgroundColor: const Color(0xFFffffff),
                                  radius: 60,
                                  backgroundImage: akongP != null
                                      ? MemoryImage(
                                          const Base64Decoder().convert(
                                              jsonDecode(
                                                      akongP!)['image_base64']
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
                            height: 10,
                          ),
                          Text(
                            personName,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.normal,
                              fontFamily: "Open Sans",
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 30,
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          children: [
                            info("Fullname", fullName),
                            info("Email",
                                jsonDecode(akongP!)['email'].toString()),
                            info("Mobile No",
                                "+${jsonDecode(akongP!)['mobile_no'].toString()}"),
                            info(
                                "Birthday",
                                DateFormat.yMMMEd().format(DateTime.parse(
                                    jsonDecode(akongP!)['birthday']
                                        .toString()))),
                            info("Gender",
                                jsonDecode(akongP!)['gender'].toString()),
                          ],
                        ),
                      ))
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget info(label, value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
