// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:luvpark_get/custom_widgets/app_color.dart';
// import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
// import 'package:luvpark_get/custom_widgets/custom_text.dart';
// import 'package:luvpark_get/custom_widgets/park_shimmer.dart';
// import 'package:luvpark_get/custom_widgets/no_data_found.dart';
// import 'package:luvpark_get/transaction_history/utils/filter_screen.dart';
// import 'package:luvpark_get/wallet/utils/transaction_details.dart';

// import '../controller.dart';

// class TransactionHistory extends GetView<WalletController> {
//   const TransactionHistory({super.key});

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarBrightness: Brightness.light,
//       statusBarIconBrightness: Brightness.dark,
//     ));

//     return Scaffold(
//       backgroundColor: AppColor.bodyColor,
//       appBar: CustomAppbar(
//         title: "Transaction History",
//         action: [
//           IconButton(
//             onPressed: () {
//               // Get.bottomSheet(const WalletTransactionFilterTH());
//               controller.getFilteredLogs();
//             },
//             icon: SvgPicture.asset(
//               "assets/images/wallet_filter.svg",
//               height: 14,
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Obx(() {
//               if (controller.isLoading.value) {
//                 return const ParkShimmer();
//               } else if (controller.logs.isEmpty) {
//                 return const NoDataFound();
//               } else {
//                 return ListView.separated(
//                   padding: const EdgeInsets.all(10),
//                   itemCount: controller.logs.length,
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       onTap: () {
//                         showModalBottomSheet(
//                           backgroundColor: Colors.transparent,
//                           context: context,
//                           builder: (context) => TransactionDetails(
//                             index: index,
//                             data: controller.logs,
//                           ),
//                         );
//                       },
//                       child: ListTile(
//                         contentPadding: EdgeInsets.zero,
//                         leading: SvgPicture.asset(
//                           fit: BoxFit.cover,
//                           "assets/images/${controller.logs[index]["tran_desc"] == 'Share a token' ? 'wallet_sharetoken' : controller.logs[index]["tran_desc"] == 'Received token' ? 'wallet_receivetoken' : 'wallet_payparking'}.svg",
//                           height: 50,
//                         ),
//                         title: CustomTitle(
//                           text: controller.logs[index]["tran_desc"],
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         subtitle: CustomParagraph(
//                           text: DateFormat('MMM d, yyyy h:mm a').format(
//                             DateTime.parse(controller.logs[index]["tran_date"]),
//                           ),
//                           fontSize: 12,
//                         ),
//                         trailing: CustomTitle(
//                           text: controller.logs[index]["amount"],
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: (controller.logs[index]["tran_desc"] ==
//                                       'Share a token' ||
//                                   controller.logs[index]["tran_desc"] ==
//                                       'Received token')
//                               ? const Color(0xFF0078FF)
//                               : const Color(0xFFBD2424),
//                         ),
//                       ),
//                     );
//                   },
//                   separatorBuilder: (context, index) => const Divider(
//                     endIndent: 1,
//                     height: 1,
//                   ),
//                 );
//               }
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }
