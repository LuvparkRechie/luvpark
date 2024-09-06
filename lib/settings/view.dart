import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_body.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/settings/controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.primaryColor, // Set status bar color
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));
    final SettingsController ct = Get.put(SettingsController());
    ct.onInit();
    return CustomScaffold(
        children: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.primaryColor,
                AppColor.primaryColor.withOpacity(.6)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: CustomTitle(
                      text: "Settings",
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  CustomParagraph(
                    text: "Version 1.3.3",
                    fontSize: 10,
                    color: Colors.white60,
                  )
                ],
              ),
              Container(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTitle(
                          text: "Rechie Arnado",
                          fontSize: 16,
                          maxlines: 1,
                          letterSpacing: -0.41,
                          color: Colors.white,
                        ),
                        CustomParagraph(
                          text: "rechkings20@gmail.com",
                          fontSize: 14,
                          maxlines: 1,
                          color: Colors.white60,
                        )
                      ],
                    ),
                  ),
                  Container(width: 1),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("assets/images/rech.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              Container(height: 10),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              for (int i = 0; i < ct.tabName.length; i++)
                Expanded(
                  child: GestureDetector(
                      onTap: () {
                        ct.onTap(i);
                      },
                      child: Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              ct.tabName[i]["icon"],
                              size: 18,
                              color: ct.tabIndex.value == i
                                  ? AppColor.primaryColor
                                  : Colors.black,
                            ),
                            Container(width: 5),
                            CustomTitle(
                              text: ct.tabName[i]["name"],
                              fontSize: 14,
                              color: ct.tabIndex.value == i
                                  ? AppColor.primaryColor
                                  : Colors.black,
                            ),
                          ],
                        ),
                      )),
                ),
            ],
          ),
        ),
        Expanded(
          child: StretchingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                child: Obx(
                    () => ct.tabIndex.value == 0 ? _settings() : _personal())),
          ),
        )
      ],
    ));
  }

  Widget _parking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomTitle(
          text: "Parking",
          fontSize: 16,
        ),
        Container(height: 10),
        ListTile(
          dense: true, // Makes the ListTile more compact
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const CustomTitle(
            text: "Vehicles",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          trailing: Icon(
            CupertinoIcons.chevron_right,
            color: AppColor.primaryColor,
            size: 14,
          ),
        ),
        const Divider(height: 1),
        ListTile(
          dense: true, // Makes the ListTile more compact
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          minVerticalPadding: 1,

          title: const CustomTitle(
            text: "Parking History",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          trailing: Icon(
            CupertinoIcons.chevron_right,
            color: AppColor.primaryColor,
            size: 14,
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _accountInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomTitle(
          text: "Account",
          fontSize: 16,
        ),
        Container(height: 10),
        ListTile(
          dense: true, // Makes the ListTile more compact
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const CustomTitle(
            text: "Change Password",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          trailing: Icon(
            CupertinoIcons.chevron_right,
            size: 14,
            color: AppColor.primaryColor,
          ),
        ),
        const Divider(height: 1),
        ListTile(
          dense: true, // Makes the ListTile more compact
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const CustomTitle(
            text: "Update Profile",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          trailing: Icon(
            CupertinoIcons.chevron_right,
            size: 14,
            color: AppColor.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _appInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomTitle(
          text: "App Support",
          fontSize: 16,
        ),
        Container(height: 10),
        ListTile(
          dense: true, // Makes the ListTile more compact
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const CustomTitle(
            text: "Faq",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          trailing: Icon(
            CupertinoIcons.chevron_right,
            color: AppColor.primaryColor,
            size: 14,
          ),
        ),
        const Divider(height: 1),
        ListTile(
          dense: true, // Makes the ListTile more compact
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const CustomTitle(
            text: "Terms of Use",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          trailing: Icon(
            CupertinoIcons.chevron_right,
            color: AppColor.primaryColor,
            size: 14,
          ),
        ),
        const Divider(height: 1),
        ListTile(
          dense: true, // Makes the ListTile more compact
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const CustomTitle(
            text: "Privacy Policy",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          trailing: Icon(
            color: AppColor.primaryColor,
            CupertinoIcons.chevron_right,
            size: 14,
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  //Settings Tab
  Column _settings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 15),
        _accountInfo(),
        Container(height: 15),
        _parking(),
        Container(height: 15),
        _appInfo(),
        const ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          title: CustomTitle(
            text: "Logout",
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
          trailing: Icon(
            CupertinoIcons.chevron_right,
            color: Colors.red,
            size: 14,
          ),
        ),
      ],
    );
  }

  //PERSONAL
  Column _personal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 15),
        Stack(
          children: [
            const ListTile(
              dense: true, // Makes the ListTile more compact
              contentPadding: EdgeInsets.zero,
              title: CustomTitle(
                text: "Account Name",
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              subtitle: CustomParagraph(
                text: "Rhea Lee R. Arnado",
                fontSize: 14,
              ),
            ),
            Positioned(
                right: 10,
                top: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CustomParagraph(
                      text: 'Verified',
                      fontSize: 14,
                      color: Colors.green,
                    ),
                    Container(
                      width: 5,
                    ),
                    const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 15,
                    ),
                  ],
                ))
          ],
        ),
        const Divider(height: 1),
        const ListTile(
          dense: true, // Makes the ListTile more compact
          contentPadding: EdgeInsets.zero,
          title: CustomTitle(
            text: "Gender",
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          subtitle: CustomParagraph(
            text: "Male",
            fontSize: 14,
          ),
        ),
        const Divider(height: 1),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true, // Makes the ListTile more compact
          title: CustomTitle(
            text: "Civil Status",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          subtitle: CustomParagraph(
            text: "Married",
            fontSize: 14,
          ),
        ),
        const Divider(height: 1),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true, // Makes the ListTile more compact
          title: CustomTitle(
            text: "Birthday",
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          subtitle: CustomParagraph(
            text: "August 16,1998",
            fontSize: 14,
          ),
        ),
        const Divider(height: 1),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true, // Makes the ListTile more compact
          title: CustomTitle(
            text: "Address",
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          subtitle: CustomParagraph(
            text: "Libaong San Remigio Cebu",
            fontSize: 14,
          ),
        ),
        const Divider(height: 1),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true, // Makes the ListTile more compact
          title: CustomTitle(
            text: "Province",
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          subtitle: CustomParagraph(
            text: "Cebu",
            fontSize: 14,
          ),
        ),
        const Divider(height: 1),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true, // Makes the ListTile more compact
          title: CustomTitle(
            text: "Zip Code",
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          subtitle: CustomParagraph(
            text: "6011",
            fontSize: 14,
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
