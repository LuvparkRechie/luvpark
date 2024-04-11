import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:luvpark/background_process/android_background.dart';
import 'package:luvpark/bottom_tab/bottom_tab.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/custom_widget/custom_button.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/custom_widget/snackbar_dialog.dart';
import 'package:luvpark/dashboard/class/dashboardMap_component.dart';
import 'package:luvpark/location_sharing/fore_grount_task.dart';
import 'package:luvpark/location_sharing/map_display.dart';
import 'package:luvpark/login/login.dart';
import 'package:luvpark/no_internet/no_internet_connected.dart';
import 'package:luvpark/notification_controller/notification_controller.dart';
import 'package:luvpark/pa_message/pa_message.dart';
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

void main() async {
  tz.initializeTimeZones();
  DartPingIOS.register();
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  final packageInfo = await PackageInfo.fromPlatform();
  Variables.version = packageInfo.version;
  NotificationController.initializeLocalNotifications();
  NotificationController.initializeIsolateReceivePort();
  final status = await Permission.notification.status;
  if (status.isDenied) {
    await Permission.notification.request();
  }
  //Request permission for background task battery optimization
  ForegroundNotifTask.requestPermissionForAndroid();
  await Geolocator.requestPermission();
  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  } else {
    //IOS Background fetch
  }
  ForegroundNotifTask.initForegroundTask();
  // await initializeService();
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

// navigation_provider.dart
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
    //ForegroundNotifTask.setContext(context);
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
            case '/sharing_location':
              return MaterialPageRoute(builder: (context) {
                return MapSharingScreen();
              });

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

class _SplashScreenState extends State<SplashScreen> {
  bool isInternetConnected = true;

  @override
  void initState() {
    super.initState();
    NotificationController.startListeningNotificationEvents();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      onBoarding();
      AndroidBackgroundProcess.isRunBackground(true);
      AndroidBackgroundProcess.backgroundExecution();
      // ForegroundNotifTask.initForegroundTask();
      // You can get the previous ReceivePort without restarting the service.
      // if (await FlutterForegroundTask.isRunningService) {
      //   final newReceivePort = FlutterForegroundTask.receivePort;
      //   ForegroundNotifTask.registerReceivePort(newReceivePort);
      // }
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

    if (logData == null) {
      Timer(const Duration(seconds: 1), () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const WelcomeSplashScreen()));
      });
    } else {
      var mappedLogData = [jsonDecode(logData)];
      if (mappedLogData[0]["is_active"] == "Y") {
        Variables.pageTrans(const MainLandingScreen());
      } else {
        // ignore: use_build_context_synchronously

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const LoginScreen(
                      index: 1,
                    )));
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
        body: Container(
          color:
              !isInternetConnected ? AppColor.bodyColor : AppColor.primaryColor,
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
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        image: DecorationImage(
                          image: AssetImage("assets/images/luvpark_logo.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
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
  var bodyWidget = <Widget>[];
  bool isStarted = false;

  PageController? _pageController;

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

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This clears all data in SharedPreferences.
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
      appbarColor: AppColor.bodyColor,
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
                children: const <Widget>[
                  CustomSlider(
                    title: "Find",
                    subTitle:
                        "Looking for parking? Our app helps you find available parking spaces in real-time."
                        " Simply enter your destination, and we'll show you the nearest options.",
                    icon: "step1",
                  ),
                  CustomSlider(
                    title: "Book",
                    subTitle:
                        "No more driving around in circles! Once you find a spot you like, "
                        "you can book it right from our app.",
                    icon: "step2",
                  ),
                  CustomSlider(
                    title: "Park",
                    subTitle:
                        "Get the best prices at convenient locations throughout  our network of garages of parking.",
                    icon: "step3",
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
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
                bool serviceEnabled;
                serviceEnabled = await Geolocator.isLocationServiceEnabled();
                if (!serviceEnabled) {
                  // ignore: use_build_context_synchronously
                  showAlertDialog(context, "Attention",
                      "To continue, turn on device location, which uses Google's location service.",
                      () {
                    Navigator.of(context).pop();
                  });
                } else {
                  // ignore: use_build_context_synchronously
                  DashboardComponent.locatePosition(context, false);
                }
              },
            ),
            const SizedBox(height: 16.0),
            CustomButtonCancel(
              color: AppColor.btnSubColor,
              textColor: Colors.black,
              label: "Login",
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                Variables.pageTrans(const LoginScreen(
                  index: 0,
                ));
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
          color: AppColor.textMainColor,
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
