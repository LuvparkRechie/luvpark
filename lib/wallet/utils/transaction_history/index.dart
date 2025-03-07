// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:luvpark/custom_widgets/alert_dialog.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';
import 'package:luvpark/custom_widgets/no_data_found.dart';
import 'package:luvpark/custom_widgets/no_internet.dart';
import 'package:luvpark/custom_widgets/page_loader.dart';
import 'package:luvpark/http/api_keys.dart';
import 'package:luvpark/http/http_request.dart';

import '../../../auth/authentication.dart';
import '../../../custom_widgets/app_color.dart';
import '../transaction_details.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final TextEditingController filterfromDate = TextEditingController();
  final TextEditingController filtertoDate = TextEditingController();
  bool isLoadingPage = true;
  bool isNetConn = true;

  DateTime _fromDate = DateTime.now().subtract(Duration(days: 15));
  DateTime _toDate = DateTime.now();

  List filterLogs = [];
  @override
  void initState() {
    DateTime timeNow = DateTime.now();
    filtertoDate.text = timeNow.toString().split(" ")[0];
    filterfromDate.text =
        timeNow.subtract(const Duration(days: 29)).toString().split(" ")[0];
    getFilteredLogs();
    super.initState();
  }

  //GEt filtered logs
  Future<void> getFilteredLogs() async {
    setState(() {
      isLoadingPage = true;
    });
    final userId = await Authentication().getUserId();

    String subApi =
        "${ApiKeys.getTransLogs}?user_id=$userId&tran_date_from=${filterfromDate.text}&tran_date_to=${filtertoDate.text}";

    HttpRequest(api: subApi).get().then((response) {
      setState(() {
        isLoadingPage = false;
      });
      if (response == "No Internet") {
        setState(() {
          isNetConn = false;
        });
        filterLogs = [];
        CustomDialog().internetErrorDialog(Get.context!, () => Get.back());
        return;
      }
      if (response == null) {
        setState(() {
          isNetConn = true;
        });
        filterLogs = [];
        CustomDialog().errorDialog(
          Get.context!,
          "luvpark",
          "Error while connecting to server, Please contact support.",
          () => Get.back(),
        );
        return;
      }
      setState(() {
        isNetConn = true;
      });
      filterLogs = response["items"];
    });
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
                labelStyle: GoogleFonts.openSans(color: Colors.black)),
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: const Color.fromRGBO(255, 255, 255, 1),
              onSurface: Colors.green,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Theme.of(context).primaryColor,
                statusBarIconBrightness: Brightness.light,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
        filterfromDate.text = _fromDate.toString().split(" ")[0];
        filtertoDate.text = _toDate.toString().split(" ")[0];
      });
      getFilteredLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              selectDateRange(context);
            },
            icon: SvgPicture.asset(
              color: Colors.white,
              "assets/images/wallet_filter.svg",
              height: 14,
            ),
          )
        ],
        elevation: 1,
        backgroundColor: AppColor.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("Transaction History"),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Iconsax.arrow_left,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoadingPage
          ? PageLoader()
          : !isNetConn
              ? NoInternetConnected(
                  onTap: getFilteredLogs,
                )
              : filterLogs.isEmpty
                  ? NoDataFound(
                      text: "No transaction found",
                    )
                  : StretchingOverscrollIndicator(
                      axisDirection: AxisDirection.down,
                      child: ScrollConfiguration(
                        behavior: ScrollBehavior().copyWith(overscroll: false),
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          itemCount: filterLogs.length,
                          itemBuilder: (context, index) {
                            String trans = filterLogs[index]["tran_desc"]
                                .toString()
                                .toLowerCase();
                            String img = "";
                            if (trans.contains("share")) {
                              img = "wallet_sharetoken";
                            } else if (trans.contains("received")) {
                              img = "wallet_receivetoken";
                            } else if (trans.contains("credit")) {
                              img = "wallet_receivetoken";
                            } else {
                              img = "wallet_payparking";
                            }
                            return GestureDetector(
                              onTap: () {
                                Get.dialog(
                                  TransactionDetails(
                                    index: index,
                                    data: filterLogs,
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey.shade100),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: CustomTitle(
                                    text: filterLogs[index]["tran_desc"],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    maxlines: 1,
                                    letterSpacing: -.5,
                                    color: AppColor.headerColor,
                                  ),
                                  subtitle: CustomParagraph(
                                    text: DateFormat('MMM d, yyyy h:mm a')
                                        .format(DateTime.parse(
                                            filterLogs[index]["tran_date"])),
                                    fontSize: 12,
                                    maxlines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: CustomTitle(
                                    text: filterLogs[index]["amount"],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: double.parse(
                                                filterLogs[index]["amount"]) <
                                            0
                                        ? const Color(0xFFFF0000)
                                        : const Color(0xFF0078FF),
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 1,
                          ),
                        ),
                      ),
                    ),
    );
  }
}
