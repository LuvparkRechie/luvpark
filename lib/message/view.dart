// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:luvpark_get/custom_widgets/no_data_found.dart';

import '../custom_widgets/app_color.dart';
import '../custom_widgets/custom_button.dart';
import '../sqlite/pa_message_model.dart';
import '../sqlite/pa_message_table.dart';
import 'controller.dart';

class MessageScreen extends GetView<MessageScreenController> {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Messages",
      ),
      body: StretchingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        child: RefreshIndicator(
          onRefresh: controller.refresher,
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: Obx(
              () {
                if (controller.messages.isEmpty) {
                  return NoDataFound(text: "No messages found");
                } else {
                  return ListView.builder(
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: message["is_read"] == "N"
                                ? Color(0xFFedf7ff)
                                : null,
                            border: Border.all(color: Color(0xFFE9E9E9)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: InkWell(
                            onTap: () async {
                              Object json = {
                                PaMessageDataFields.pushMsgId:
                                    message["push_msg_id"],
                                PaMessageDataFields.userId: message["user_id"],
                                PaMessageDataFields.message: message["message"],
                                PaMessageDataFields.createdDate:
                                    message["created_on"],
                                PaMessageDataFields.status:
                                    message["push_status"],
                                PaMessageDataFields.runOn: message["run_on"],
                                PaMessageDataFields.isRead: "Y",
                              };

                              PaMessageDatabase.instance
                                  .insertUpdate(json)
                                  .then((value) {
                                Get.dialog(PopScope(
                                  canPop: true,
                                  child: Scaffold(
                                    backgroundColor: Colors.transparent,
                                    body: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Container(
                                              padding: EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                color: Colors.white,
                                              ),
                                              width: MediaQuery.of(Get.context!)
                                                  .size
                                                  .width,

                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CustomTitle(
                                                    text: "Message",
                                                    color: Color(0xFF0D0E0E),
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                    maxlines: 1,
                                                  ),
                                                  const SizedBox(height: 15),
                                                  // Paragraph
                                                  CustomParagraph(
                                                    text: message["message"]
                                                        .toString()
                                                        .replaceAll(".", ".\n")
                                                        .trim(),
                                                    fontWeight: FontWeight.w600,
                                                    textAlign: TextAlign.left,
                                                  ),

                                                  // Buttons
                                                  Container(height: 25),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Container(),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child:
                                                            CustomDialogButton(
                                                          btnColor: AppColor
                                                              .primaryColor,
                                                          txtColor:
                                                              Colors.white,
                                                          borderColor: AppColor
                                                              .primaryColor,
                                                          text: "Close",
                                                          onTap: () {
                                                            Get.back();
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),

                                              // Column(
                                              //   crossAxisAlignment:
                                              //       CrossAxisAlignment.start,
                                              //   children: [
                                              //     CustomTitle(
                                              //         text: "PA Message"),
                                              //     Container(height: 10),
                                              //     Expanded(
                                              //         child:
                                              //             SingleChildScrollView(
                                              //       child: CustomParagraph(
                                              //           text:
                                              //               message["message"]),
                                              //     )),
                                              //     Container(height: 5),
                                              //     Align(
                                              //       alignment:
                                              //           Alignment.bottomRight,
                                              //       child: TextButton(
                                              //           onPressed: () {
                                              //             Get.back();
                                              //           },
                                              //           child: CustomLinkLabel(
                                              //               text: "Okay")),
                                              //     )
                                              //   ],
                                              // ),
                                            ),
                                          )
                                        ]),
                                  ),
                                ));
                              });
                            },
                            onLongPress: () {
                              controller.deleteMessage(index);
                            },
                            child: ListTile(
                              title: CustomTitle(
                                fontWeight: FontWeight.w600,
                                maxlines: 1,
                                fontSize: 16,
                                color: Colors.black,
                                //  overflow: TextOverflow.ellipsis,
                                text:
                                    message["message"] ?? "No message content",
                              ),
                              leading: Image.asset(
                                  height: 30,
                                  "assets/images/message_alert.png"),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomParagraph(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black45,
                                      text: DateFormat('MMM dd, yyyy')
                                          .format(DateTime.parse(
                                              message["created_on"]))
                                          .toUpperCase(),
                                    ),
                                    CustomParagraph(
                                      fontSize: 12,
                                      color: Colors.black45,
                                      text: DateFormat('hh:mm a').format(
                                          DateTime.parse(
                                              message["created_on"])),
                                    ),
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
              },
            ),
          ),
        ),
      ),
    );
  }
}
