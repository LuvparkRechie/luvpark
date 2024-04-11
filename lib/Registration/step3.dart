import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/custom_textfield.dart';
import 'package:luvpark/custom_widget/header_title&subtitle.dart';
import 'package:sizer/sizer.dart';

class RegSecurityQuestion extends StatefulWidget {
  final TextEditingController secA1, secA2, secA3, secId1, secId2, secId3;
  final GlobalKey<FormState> formKey;
  final List secData;
  const RegSecurityQuestion({
    super.key,
    required this.secA1,
    required this.secA2,
    required this.secA3,
    required this.secId1,
    required this.secId2,
    required this.secId3,
    required this.formKey,
    required this.secData,
  });

  @override
  State<RegSecurityQuestion> createState() => _SecurityQuestionState();
}

class _SecurityQuestionState extends State<RegSecurityQuestion> {
  String label1 = "Choose a question";
  String label2 = "Choose a question";
  String label3 = "Choose a question";

  List<dynamic> getDropdownData() {
    var data = widget.secData;

    int id1 = int.parse(widget.secId1.text.isEmpty ? "0" : widget.secId1.text);
    int id2 = int.parse(widget.secId2.text.isEmpty ? "0" : widget.secId2.text);
    int id3 = int.parse(widget.secId3.text.isEmpty ? "0" : widget.secId3.text);
    List<int> selectedIds = [id1, id2, id3];

    List filteredObjects = data
        .where((object) => !selectedIds.contains(object["secq_id"]))
        .toList();
    return filteredObjects;
  }

  @override
  void initState() {
    super.initState();
    if (widget.secId1.text.isNotEmpty) {
      label1 = widget.secData
          .where(
              (element) => element["secq_id"] == int.parse(widget.secId1.text))
          .toList()[0]["question"];
    }
    if (widget.secId2.text.isNotEmpty) {
      label2 = widget.secData
          .where(
              (element) => element["secq_id"] == int.parse(widget.secId2.text))
          .toList()[0]["question"];
    }
    if (widget.secId3.text.isNotEmpty) {
      label3 = widget.secData
          .where(
              (element) => element["secq_id"] == int.parse(widget.secId3.text))
          .toList()[0]["question"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const HeaderLabel(
              title: "Security Question",
              subTitle:
                  "Please remember your answers this will be used to recover your account.",
            ),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <InlineSpan>[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: CustomDisplayText(
                      label: "$label1 ",
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      maxLines: 1,
                      presetFontSizes: const [
                        13,
                        10,
                        15,
                      ],
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: InkWell(
                      onTap: () async {
                        showInformationDialog(context, getDropdownData(),
                            (retData) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            widget.secId1.text =
                                retData[0]["secq_id"].toString();

                            label1 = retData[0]["question"];
                          });
                        });
                      },
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomTextField(
              labelText: "seca1",
              controller: widget.secA1,
              isReadOnly: label1 == "Choose a question" ? true : false,
              onChange: (value) {
                if (value.isNotEmpty) {
                  widget.secA1.value = TextEditingValue(
                      text: Variables.capitalizeAllWord(value),
                      selection: widget.secA1.selection);
                }
              },
            ),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <InlineSpan>[
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: CustomDisplayText(
                        label: "$label2 ",
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        maxLines: 1,
                        presetFontSizes: const [
                          13,
                          10,
                          15,
                        ],
                      )),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: InkWell(
                      onTap: () async {
                        //getDropdownData("label2", 5);
                        showInformationDialog(context, getDropdownData(),
                            (retData) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            widget.secId2.text =
                                retData[0]["secq_id"].toString();
                            label2 = retData[0]["question"];
                          });
                        });
                      },
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomTextField(
              labelText: "seca2",
              controller: widget.secA2,
              isReadOnly: label2 == "Choose a question" ? true : false,
              onChange: (value) {
                if (value.isNotEmpty) {
                  widget.secA2.value = TextEditingValue(
                      text: Variables.capitalizeAllWord(value),
                      selection: widget.secA2.selection);
                }
              },
            ),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <InlineSpan>[
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: CustomDisplayText(
                        label: "$label3 ",
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        maxLines: 1,
                        presetFontSizes: const [
                          13,
                          10,
                          15,
                        ],
                      )),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: InkWell(
                      onTap: () async {
                        showInformationDialog(context, getDropdownData(),
                            (retData) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            widget.secId3.text =
                                retData[0]["secq_id"].toString();
                            label3 = retData[0]["question"];
                          });
                        });
                      },
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomTextField(
              labelText: "seca3",
              controller: widget.secA3,
              isReadOnly: label3 == "Choose a question" ? true : false,
              onChange: (value) {
                if (value.isNotEmpty) {
                  widget.secA3.value = TextEditingValue(
                      text: Variables.capitalizeAllWord(value),
                      selection: widget.secA3.selection);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future showInformationDialog(
      BuildContext context, data, ValueChanged<List> callback) {
    return showDialog(
        context: context,
        builder: (context) {
          return ViewSecurityQuestion(data: data, cb: callback);
        });
  }
}

class ViewSecurityQuestion extends StatefulWidget {
  final List data;
  final ValueChanged<List> cb;
  const ViewSecurityQuestion({super.key, required this.data, required this.cb});

  @override
  State<ViewSecurityQuestion> createState() => _ViewSecurityQuestionState();
}

class _ViewSecurityQuestionState extends State<ViewSecurityQuestion> {
  @override
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
                width: MediaQuery.of(context).size.width * .80,
                decoration: BoxDecoration(
                  color: AppColor.bodyColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: AppColor.primaryColor,
                                        size: 30,
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                    ),
                                    CustomDisplayText(
                                      label: "Select a question",
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    )
                                  ],
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
                        child: Scrollbar(
                          child: ListView.builder(
                            itemCount: widget.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context);

                                  widget.cb([widget.data[index]]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.data[index]["question"],
                                        style: GoogleFonts.varela(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Divider()
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        height: 10,
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
}
