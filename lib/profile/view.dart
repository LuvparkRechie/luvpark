// import 'dart:convert';

// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:lucide_icons/lucide_icons.dart';
// import 'package:luvpark/custom_widgets/app_color.dart';
// import 'package:luvpark/custom_widgets/custom_appbar.dart';
// import 'package:luvpark/custom_widgets/page_loader.dart';
// import 'package:luvpark/profile/controller.dart';
// import 'package:luvpark/routes/routes.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../auth/authentication.dart';
// import '../custom_widgets/alert_dialog.dart';
// import '../custom_widgets/custom_text.dart';
// import '../sqlite/reserve_notification_table.dart';

// class Profile extends GetView<ProfileScreenController> {
//   const Profile({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => Scaffold(
//         extendBodyBehindAppBar: true,
//         appBar: CustomAppbar(
//           elevation: 0,
//           titleSize: 20,
//           textColor: Colors.white,
//           titleColor: Colors.white,
//           bgColor: Colors.transparent,
//           btnColor: null,
//           title: "My Account",
//           onTap: () {
//             Get.back();
//             controller.parameters();
//           },
//         ),
//         body: controller.isLoading.value
//             ? const PageLoader()
//             : Column(
//                 children: [
//                   SizedBox(
//                     height: 200,
//                     child: Stack(
//                       alignment: Alignment.bottomCenter,
//                       fit: StackFit.loose,
//                       clipBehavior: Clip.none,
//                       children: [
//                         Container(
//                           width: MediaQuery.of(context).size.width,
//                           padding: const EdgeInsets.all(15),
//                           decoration: const BoxDecoration(
//                             image: DecorationImage(
//                               fit: BoxFit.cover,
//                               image: AssetImage("assets/images/profile_bg.png"),
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           bottom: -30,
//                           child: Container(
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: AppColor.bodyColor,
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(3.0),
//                               child: CircleAvatar(
//                                 radius: 44.5,
//                                 backgroundColor: Colors.white,
//                                 backgroundImage:
//                                     controller.myprofile.value.isNotEmpty
//                                         ? MemoryImage(
//                                             base64Decode(
//                                                 controller.myprofile.value),
//                                           )
//                                         : null,
//                                 child: controller.myprofile.value.isEmpty
//                                     ? const Icon(Icons.person,
//                                         size: 44, color: Colors.blueAccent)
//                                     : null,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(height: 40),
//                   Column(
//                     children: [
//                       controller.userData[0]['first_name'] != null
//                           ? Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 CustomTitle(
//                                   text: controller.userData[0]['last_name']
//                                                   .length >
//                                               15 ||
//                                           controller.userData[0]['first_name']
//                                                   .length >
//                                               15
//                                       ? '${controller.userData[0]['first_name'].split(" ")[0]}'
//                                       : '${controller.userData[0]['first_name']} ${controller.userData[0]['last_name']}',
//                                   color: Colors.black,
//                                   fontSize: 18,
//                                   fontStyle: FontStyle.normal,
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 Container(width: 5),
//                                 Icon(
//                                   Icons.verified,
//                                   color: AppColor.primaryColor,
//                                 )
//                               ],
//                             )
//                           : CustomTitle(
//                               text: "Not Verified",
//                             ),
//                       Container(height: 2),
//                       Center(
//                         child: CustomParagraph(
//                           text: "+${controller.userData[0]['mobile_no']}",
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       Container(height: 10),
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(20, 20, 15, 20),
//                         child: Container(
//                           decoration: ShapeDecoration(
//                             color: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               side: const BorderSide(
//                                   width: 1, color: Color(0x26616161)),
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Column(
//                               children: <Widget>[
//                                 ListTile(
//                                   leading: Icon(
//                                     Iconsax.personalcard,
//                                     color: AppColor.primaryColor,
//                                   ),
//                                   title: const CustomTitle(
//                                     text: "My Profile",
//                                     fontSize: 14,
//                                   ),
//                                   trailing: Icon(Icons.chevron_right_sharp,
//                                       color: AppColor.primaryColor),
//                                   onTap: () {
//                                     Get.toNamed(Routes.myaccount,
//                                         arguments: () {
//                                       controller.getUserData();
//                                     });
//                                   },
//                                 ),
//                                 const Divider(),
//                                 ListTile(
//                                   leading: Icon(
//                                     Iconsax.car,
//                                     color: AppColor.primaryColor,
//                                   ),
//                                   title: const CustomTitle(
//                                     text: "My Vehicles",
//                                     fontSize: 14,
//                                   ),
//                                   trailing: Icon(Icons.chevron_right_sharp,
//                                       color: AppColor.primaryColor),
//                                   onTap: () {
//                                     Get.toNamed(Routes.myVehicles);
//                                   },
//                                 ),
//                                 const Divider(),
//                                 ListTile(
//                                   leading: Icon(
//                                     Iconsax.setting_2,
//                                     color: AppColor.primaryColor,
//                                   ),
//                                   title: const CustomTitle(
//                                     text: "Security Settings",
//                                     fontSize: 14,
//                                   ),
//                                   trailing: Icon(Icons.chevron_right_sharp,
//                                       color: AppColor.primaryColor),
//                                   onTap: () {
//                                     Get.toNamed(Routes.security);
//                                   },
//                                 ),
//                                 const Divider(),
//                                 ListTile(
//                                   leading: Icon(
//                                     LucideIcons.logOut,
//                                     color: AppColor.primaryColor,
//                                   ),
//                                   title: const CustomTitle(
//                                     text: "Logout",
//                                     fontSize: 14,
//                                   ),
//                                   trailing: Icon(Icons.chevron_right_sharp,
//                                       color: AppColor.primaryColor),
//                                   onTap: () async {
//                                     CustomDialog().confirmationDialog(
//                                         context,
//                                         "Logout",
//                                         "Are you sure you want to logout?",
//                                         "No",
//                                         "Yes", () {
//                                       Get.back();
//                                     }, () async {
//                                       Get.back();
//                                       CustomDialog().loadingDialog(context);
//                                       await Future.delayed(
//                                           const Duration(seconds: 3));
//                                       final userLogin =
//                                           await Authentication().getUserLogin();
//                                       List userData = [userLogin];
//                                       userData = userData.map((e) {
//                                         e["is_login"] = "N";
//                                         return e;
//                                       }).toList();
//                                       await NotificationDatabase.instance
//                                           .deleteAll();
//                                       await Authentication()
//                                           .setLogin(jsonEncode(userData[0]));
//                                       final prefs =
//                                           await SharedPreferences.getInstance();
//                                       prefs.remove("last_booking");
//                                       Authentication().setLogoutStatus(true);
//                                       AwesomeNotifications()
//                                           .dismissAllNotifications();
//                                       AwesomeNotifications().cancelAll();

//                                       Get.back();
//                                       Get.offAllNamed(Routes.login);
//                                     });
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
