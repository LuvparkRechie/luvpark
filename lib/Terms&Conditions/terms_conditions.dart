import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/api_keys.dart';
import 'package:luvpark/classess/http_request.dart';
import 'package:luvpark/custom_widget/custom_loader.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class TermsConditions extends StatefulWidget {
  final String title;
  const TermsConditions({super.key, required this.title});

  @override
  State<TermsConditions> createState() => _TermsConditionsState();
}

class _TermsConditionsState extends State<TermsConditions> {
  var parentWidget = <Widget>[];
  bool isInternetConnected = true;
  bool isLoading = true;
  String escapedText = "";
  @override
  void initState() {
    super.initState();
    parentWidget = <Widget>[];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getData();
    });
  }

  void getData() {
    CustomModal(context: context).loader();
    HttpRequest(
      api: widget.title == "Terms & Conditions"
          ? ApiKeys.gApiSubFolderPolicy
          : ApiKeys.gApiSubFolderPrivacyPolicy,
    ).get().then((returnData) async {
      if (returnData == "No Internet") {
        setState(() {
          isInternetConnected = false;
          isLoading = false;
        });
        Navigator.of(context).pop();
      }
      if (returnData == null) {
        setState(() {
          isInternetConnected = true;
          parentWidget = <Widget>[];
          isLoading = false;
        });
        Navigator.of(context).pop();
      }
      if (returnData["items"].length != 0) {
        Navigator.of(context).pop();
        setState(() {
          isLoading = false;

          isInternetConnected = true;
          parentWidget.add(Column(
            children: [
              CustomDisplayText(
                label: returnData["items"][0]["description"]
                    .toString()
                    .replaceAll("â", '"'),
                fontWeight: FontWeight.normal,
              ),
            ],
          ));
        });
      } else {
        Navigator.of(context).pop();
        setState(() {
          parentWidget = <Widget>[];
          isInternetConnected = true;
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomParent1Widget(
        appBarheaderText: widget.title,
        appBarIconClick: () {
          Navigator.of(context).pop();
        },
        child: isLoading
            ? Container()
            : !isInternetConnected
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: InkWell(
                      onTap: () {
                        getData();
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Image(
                            height: 70,
                            width: 50,
                            image: AssetImage(
                                "assets/images/no_internet_connection.png"),
                          ),
                          Text(
                            "Unable to connect to our server,\nPlease check your internet connection.",
                            style: GoogleFonts.varela(),
                          ),
                          Container(
                            height: 20,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh),
                              Text(" Tap to retry"),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        height: 10,
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          children: parentWidget,
                        ),
                      ))
                    ],
                  ));
  }
}
