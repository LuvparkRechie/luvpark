import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:luvpark/Registration/registration.dart';
import 'package:luvpark/bottom_tab/bottom_tab.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/login/login.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:luvpark/notification_controller/notification_controller.dart';
import 'package:luvpark/pa_message/pa_message.dart';
import 'package:luvpark/sqlite/map_sharing_table.dart';
import 'package:luvpark/sqlite/pa_message_table.dart';
import 'package:luvpark/sqlite/reserve_notification_table.dart';
import 'package:luvpark/sqlite/share_location_table.dart';
// ignore: depend_on_referenced_packages
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:upgrader/upgrader.dart';

@pragma('vm:entry-point')
Future<void> backgroundFunc() async {
  int counter = 0;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    var akongId = prefs.getString('myId');
    if (akongId == null) return;
    await getParkingTrans(counter);
    await getSharingData(counter);

    await getMessNotif();
  });
}

void main() async {
  tz.initializeTimeZones();
  DartPingIOS.register();
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  final packageInfo = await PackageInfo.fromPlatform();
  Variables.version = packageInfo.version;

  final status = await Permission.notification.status;
  if (status.isDenied) {
    await Permission.notification.request();
  }
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  NotificationController.initializeLocalNotifications();
  NotificationController.initializeIsolateReceivePort();

  // ForegroundNotif.initializeForeground();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => NavigationProvider(),
        child: MyApp(),
      ),
    );
  });
}

// navigation_provider.dart`
class NavigationProvider with ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int totalPages = 3;

  @override
  void initState() {
    super.initState();
    backgroundFunc();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.bodyColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: AppColor.bodyColor,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: GetMaterialApp(
        navigatorKey: MyApp.navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                  builder: (context) => UpgradeAlert(
                        showReleaseNotes: false,
                        dialogStyle: Platform.isIOS
                            ? UpgradeDialogStyle.cupertino
                            : UpgradeDialogStyle.material,
                        child: const SplashScreen(isLogin: false),
                      ));
            case '/custom_Screen':
              return MaterialPageRoute(builder: (context) {
                return const MainLandingScreen(
                  index: 1,
                  parkingIndex: 1,
                );
              });
            case '/walletScreen':
              return MaterialPageRoute(builder: (context) {
                return const MainLandingScreen(
                  index: 2,
                );
              });
            case '/message':
              return MaterialPageRoute(builder: (context) {
                return const PaMessage();
              });
            // case '/sharing_location':
            //   return MaterialPageRoute(builder: (context) {
            //     return MapSharingScreen();
            //   });

            default:
              assert(false, 'Page ${settings.name} not found');
              return null;
          }
        },
        debugShowCheckedModeBanner: false,
        color: AppColor.primaryColor,
        theme: ThemeData(
          useMaterial3: false,
          primaryColor: Colors.blue, // Set the primary color to blue
          scaffoldBackgroundColor: AppColor.bodyColor,
          focusColor: Colors.blue,
          brightness: Brightness.light,
          textTheme: TextTheme(
            bodyMedium: TextStyle(
              fontFamily: Platform.isIOS ? 'SFProText' : 'DefaultAndroidFont',
              fontSize: 16.0,
              // Add other default text style properties
            ),
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final bool isLogin;
  const SplashScreen({super.key, required this.isLogin});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool isInternetConnected = true;

  /// ANIMATION CONTROLLER
  late AnimationController _controller;

  /// ANIMATION
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    /// INITIALING THE CONTROLLER
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    /// INITIALING THE ANIMATION
    _animation = CurvedAnimation(
        parent: _controller, curve: Curves.fastEaseInToSlowEaseOut);

    /// STARTING THE ANIMATION
    _controller.forward();
    NotificationController.startListeningNotificationEvents();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      onBoarding();
    });
  }

  @override
  void dispose() {
    // Cancel the stream subscription when the widget is disposed
    super.dispose();
  }

  void onBoarding() async {
    final prefs = await SharedPreferences.getInstance();

    var logData = prefs.getString(
      'loginData',
    );

    /// TIMER FOR SPLASH DURATION

    if (logData == null) {
      Timer(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const WelcomeSplashScreen(),
          ),
        );
      });
    } else {
      var mappedLogData = [jsonDecode(logData)];
      if (mappedLogData[0]["is_active"] == "Y") {
        Timer(const Duration(seconds: 3), () {
          /// NAVIAGTING TO LOGIN SCREEN
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainLandingScreen()),
          );
        });
      } else {
        // ignore: use_build_context_synchronously
        Timer(const Duration(seconds: 3), () {
          /// NAVIAGTING TO LOGIN SCREEN
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(
                index: 1,
              ),
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Variables.init(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppbarWidget(
          appbarColor: AppColor.primaryColor,
        ),
        backgroundColor: AppColor.primaryColor,
        body: ScaleTransition(
          scale: _animation,
          child: Container(
            color: !isInternetConnected
                ? AppColor.bodyColor
                : AppColor.primaryColor,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: !isInternetConnected
                ? NoInternetConnected(
                    onTap: () {
                      setState(() {
                        isInternetConnected = true;
                      });
                      onBoarding();
                    },
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Hero(
                          tag: "luvpark",
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/luvpark_logo.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class WelcomeSplashScreen extends StatefulWidget {
  const WelcomeSplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<WelcomeSplashScreen> createState() => _WelcomeSplashScreenState();
}

class _WelcomeSplashScreenState extends State<WelcomeSplashScreen>
    with WidgetsBindingObserver {
  bool isLoading = true;
  int currentPage = 0;
  bool isStarted = false;
  PageController? _pageController;
  List sliderData = [
    {
      "title": "Find",
      "subTitle":
          "Looking for parking? Our app helps you find available parking spaces in real-time."
              " Simply enter your destination, and we'll show you the nearest spot based on your current location.",
      "icon": "step1",
    },
    {
      "title": "Book",
      "subTitle":
          "No more driving around in circles! Once you find a spot you like, "
              "you can book it right from our app.",
      "icon": "step2",
    },
    {
      "title": "Park",
      "subTitle":
          "Luvpark seamlessly integrates with Google Maps, enabling you to easily obtain directions and distance from your current location to your chosen parking spot, ensuring a smooth driving experience.",
      "icon": "step3",
    },
    {
      "title": "Find my Vehicle",
      "subTitle":
          "Need help finding where you parked your vehicle? Worry no more – Luvpark has you covered. Our app can pinpoint your parked car from your current location by utilizing your active parking transaction.",
      "icon": "step4",
    }
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    clearSharedPreferences();
    _pageController = PageController(initialPage: 0);
    //  locatePosition();
  }

  @override
  void dispose() {
    _pageController!.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void clearSharedPreferences() async {
    await NotificationDatabase.instance.deleteAll();
    await PaMessageDatabase.instance.deleteAll();
    await ShareLocationDatabase.instance.deleteAll();
    await MapSharingTable.instance.deleteAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This clears all data in SharedPreferences.
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
      appbarColor: Colors.white,
      onPop: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    currentPage = page;
                  });
                },
                children: <Widget>[
                  for (int i = 0; i < sliderData.length; i++)
                    CustomSlider(
                      title: sliderData[i]["title"],
                      subTitle: sliderData[i]["subTitle"],
                      icon: sliderData[i]["icon"],
                    ),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  sliderData.length,
                  (index) => buildDot(index, context),
                ),
              ),
            ),
            Container(
              height: 20,
            ),
            CustomButton(
              color: AppColor.primaryColor,
              label: "Create Account",
              onTap: () async {
                Variables.pageTrans(RegistrationPage(), context);
              },
            ),
            const SizedBox(height: 16.0),
            CustomButtonCancel(
              color: AppColor.btnSubColor,
              textColor: Colors.black,
              label: "Login",
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                Variables.pageTrans(
                    LoginScreen(
                      index: 0,
                    ),
                    context);
              },
            ),
            Container(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentPage == index
            ? AppColor.primaryColor
            : const Color.fromARGB(255, 171, 204, 242),
      ),
    );
  }
}

//Slider 1

class CustomSlider extends StatefulWidget {
  final String title;
  final String subTitle;
  final String icon;
  const CustomSlider({
    required this.title,
    required this.subTitle,
    required this.icon,
    super.key,
  });

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image(
          height: MediaQuery.of(context).size.height * 0.30,
          width: MediaQuery.of(context).size.width * 90,
          image: AssetImage("assets/images/${widget.icon}.png"),
        ),
        Container(
          height: 10,
        ),
        CustomDisplayText(
          label: widget.title,
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 0,
        ),
        Container(
          height: 10,
        ),
        SizedBox(
          width: Variables.screenSize.width * .90,
          child: CustomDisplayText(
            label: widget.subTitle,
            fontWeight: FontWeight.normal,
            color: Colors.black54,
            alignment: TextAlign.center,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
