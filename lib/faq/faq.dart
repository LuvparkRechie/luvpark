import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/http_request/http_request_model.dart';
import 'package:shimmer/shimmer.dart';

class FaqsLuvPark extends StatefulWidget {
  const FaqsLuvPark({Key? key}) : super(key: key);

  @override
  State<FaqsLuvPark> createState() => _FaqsLuvParkState();
}

class _FaqsLuvParkState extends State<FaqsLuvPark> {
  List<dynamic> faqsData = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      fetchFaqsList();
    });
  }

  void fetchFaqsList() {
    CustomModal(context: context).loader();
    const HttpRequest(
      api: ApiKeys.gAPISubFolderFaqList,
    ).get().then((objData) {
      if (objData == "No Internet") {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (objData == null) {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
        return;
      } else {
        Navigator.of(context).pop();
        setState(() {
          faqsData = objData["items"];
          loading = false;
        });
      }
    });
  }

  void fetchFaqsAnswers(int faqid, String faqTitle) {
    CustomModal(context: context).loader();
    HttpRequest(api: '${ApiKeys.gAPISubFolderFaqAnswer}?faq_id=$faqid')
        .get()
        .then((objData) {
      if (objData == "No Internet") {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Please check your internet connection and try again.", () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (objData == null) {
        Navigator.of(context).pop();
        showAlertDialog(context, "Error",
            "Error while connecting to server, Please try again.", () {
          Navigator.of(context).pop();
        });
        return;
      } else {
        Navigator.of(context).pop();
        if (objData["items"].isEmpty) return;
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: CustomDisplayText(
                              label: faqTitle,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ...objData["items"].map<Widget>((dataRow) {
                          return ListTile(
                            // leading: const Icon(Iconsax.minus),
                            leading: const Text(
                              '.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            title: CustomDisplayText(
                              label: dataRow["faq_ans_text"],
                              fontSize: 13,
                              alignment: TextAlign.justify,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: Scaffold(
        body: ColorfulSafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 100,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 200,
                            width: 300,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  width:
                                      MediaQuery.of(context).size.width * .60,
                                  image: const AssetImage(
                                      "assets/images/faq2.jpg"),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Iconsax.arrow_left_34,
                                color: Colors.blue,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: loading
                    ? ListView.builder(
                        itemCount: 5,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 6,
                            margin: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 20,
                            ),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey,
                              highlightColor: Colors.white,
                              child: ListTile(
                                title: Container(
                                  color: Colors.black26,
                                  height: 10,
                                ),
                                leading: Container(
                                  height: 20,
                                  width: 20,
                                  color: Colors.black26,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: faqsData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 6,
                            margin: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 20),
                            child: ListTile(
                              onTap: () {
                                fetchFaqsAnswers(faqsData[index]['faq_id'],
                                    faqsData[index]['faq_text']);
                              },
                              leading: const Icon(
                                Iconsax.message_question,
                              ),
                              title: CustomDisplayText(
                                label: faqsData[index]['faq_text'],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
