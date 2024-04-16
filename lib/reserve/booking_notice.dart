import 'package:flutter/material.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/http_request/http_request_model.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';

class BookingNotice extends StatefulWidget {
  final Function callBack;
  const BookingNotice({super.key, required this.callBack});

  @override
  State<BookingNotice> createState() => _BookingNoticeState();
}

class _BookingNoticeState extends State<BookingNotice> {
  bool hasInternet = true;
  bool isLoading = true;
  bool isLoadingAction = false;
  List noticeData = [];
  @override
  void initState() {
    super.initState();
    getNotice();
  }

  Future<void> getNotice() async {
    setState(() {
      hasInternet = true;
      isLoading = true;
    });
    String subApi = "${ApiKeys.gApiLuvParkGetNotice}?msg_code=PREBOOKMSG";
    print("subApi $subApi");
    HttpRequest(api: subApi).get().then((retDataNotice) async {
      print("retDataNotice $retDataNotice");
      if (retDataNotice == "No Internet") {
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
          if (mounted) {
            setState(() {
              hasInternet = false;
              isLoading = false;
              noticeData = [];
            });
          }
        });

        return;
      }
      if (retDataNotice == null) {
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
          if (mounted) {
            setState(() {
              hasInternet = true;
              isLoading = false;
              noticeData = [];
            });
          }
        });
      }
      if (retDataNotice["items"].length > 0) {
        if (mounted) {
          setState(() {
            hasInternet = true;
            noticeData = retDataNotice["items"];
            isLoading = false;
          });
        }
      } else {
        showAlertDialog(context, "Error", retDataNotice["items"][0]["msg"], () {
          Navigator.of(context).pop();
          if (mounted) {
            setState(() {
              hasInternet = true;
              noticeData = [];
              isLoading = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Wrap(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              width: MediaQuery.of(context).size.width,
              child: RefreshIndicator(
                onRefresh: getNotice,
                child: isLoading
                    ? Container()
                    : !hasInternet
                        ? NoInternetConnected(onTap: getNotice)
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // const Image(
                                    //   height: 40,
                                    //   width: 40,
                                    //   image: AssetImage(
                                    //       "assets/images/information_icon.png"),
                                    // ),
                                    Container(
                                      width: 10,
                                    ),
                                    CustomDisplayText(
                                      label: noticeData[0]["msg_title"]
                                          .toString()
                                          .toUpperCase(),
                                      color: AppColor.textMainColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                                const Divider(),
                                CustomDisplayText(
                                  label: noticeData[0]["msg"],
                                  fontWeight: FontWeight.w500,
                                  color: const Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: 12,
                                  alignment: TextAlign.center,
                                ),
                                Container(
                                  height: 10,
                                ),
                                Divider(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          Navigator.pop(context);
                                          if (Navigator.canPop(context)) {
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Center(
                                          // child: CustomDisplayText(
                                          //   label: "Cancel",
                                          //   fontWeight: FontWeight.w600,
                                          //   color: Colors.black,
                                          //   fontSize: 14,
                                          // ),
                                          child: CustomButton(
                                              btnHeight: 10,
                                              label: "Cancel",
                                              textColor: Colors.black,
                                              color: Colors.transparent,
                                              onTap: () async {
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                                Navigator.pop(context);
                                              }),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: CustomButton(
                                          btnHeight: 10,
                                          label: "Proceed",
                                          onTap: () async {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                            Navigator.pop(context);
                                          }),
                                    ),
                                  ],
                                ),
                                // Container(
                                //   height: 10,
                                // ),
                              ],
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
