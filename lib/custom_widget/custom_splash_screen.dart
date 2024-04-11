import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:luvpark/custom_widget/custom_text.dart';

class CustomSplashScreen extends StatelessWidget {
  const CustomSplashScreen({Key? key, required this.isBuyToken})
      : super(key: key);
  final bool isBuyToken;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFffffff),
            elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Color(0xFFffffff),
              statusBarIconBrightness: Brightness.dark,
            ),
          ),
          //  extendBodyBehindAppBar: true,
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: const Color(0xFFffffff),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (isBuyToken)
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: const Image(
                              image: AssetImage(
                                'assets/images/bankLogo.png',
                              ),
                            ),
                          ),
                          Container(
                            height: 10,
                          ),
                          CustomDisplayText(
                            label: "We are redirecting you to your bank.",
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                          Container(
                            height: 20,
                          ),
                          SizedBox(
                            height: 120,
                            width: 120,
                            child: Lottie.asset(
                              'assets/lottie/loader.json',
                            ),
                          ),
                          Container(
                            height: 20,
                          ),
                          CustomDisplayText(
                            label:
                                "You are permitting us to initiate a payment from your bank account.",
                            fontWeight: FontWeight.normal,
                            color: Colors.black54,
                            letterSpacing: 1,
                          ),
                        ],
                      ),
                    if (!isBuyToken)
                      const Center(
                        child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator()),
                      ),
                    if (!isBuyToken)
                      Container(
                        height: MediaQuery.of(context).size.height * 0.20,
                      ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
