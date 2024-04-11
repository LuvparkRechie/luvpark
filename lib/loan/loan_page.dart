import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/classess/color_component.dart';

class LoanPage extends StatefulWidget {
  const LoanPage({
    super.key,
  });

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          title: AutoSizeText(
            "Loan",
            style: GoogleFonts.prompt(
              color: Colors.black87,
              fontSize: 20,
              letterSpacing: 1,
            ),
          ),
          centerTitle: false,
          elevation: 1,
          backgroundColor: AppColor.bodyColor,
        ),
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: AppColor.bodyColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.30,
                        child: const Image(
                            image: AssetImage(
                                "assets/images/under_construction.png")),
                      ),
                    ),
                    const AutoSizeText(
                      "Dear User,",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        letterSpacing: 1,
                      ),
                      softWrap: true,
                      maxLines: 2,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    AutoSizeText(
                      "We're sorry to inform you that this features is in the process. Thank you for your patience and understanding.",
                      style: GoogleFonts.prompt(
                        color: Colors.black54,
                        fontSize: 15,
                        letterSpacing: 1,
                      ),
                      softWrap: true,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget cardBox(String label, String images, Function onTap) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2.3,
      child: GestureDetector(
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.10,
                width: MediaQuery.of(context).size.width,
                child: Image(
                  image: AssetImage("assets/images/$images"),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        onTap: () {
          onTap();
        },
      ),
    );
  }
}
