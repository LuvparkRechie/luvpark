
// void main() async {
//   tz.initializeTimeZones();
//   DartPingIOS.register();
//   await dotenv.load();
//   WidgetsFlutterBinding.ensureInitialized();
//   await NotificationController.initializeLocalNotifications();
//   await NotificationController.initializeIsolateReceivePort();
//   await NotificationController.executeLongTaskInBackground();
//   final packageInfo = await PackageInfo.fromPlatform();
//   Variables.version = packageInfo.version;
//   final status = await Permission.notification.status;
//   if (status.isDenied) {
//     await Permission.notification.request();
//   }
//   await Geolocator.requestPermission();
//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//   ]).then((_) {
//     runApp(const MyApp());
//   });
// // }
// void main() async {
//   // Initialize time zones
//   tz.initializeTimeZones();

//   // Register DartPing for iOS
//   DartPingIOS.register();

//   // Load environment variables
//   await dotenv.load();

//   // Ensure Flutter is initialized
//   WidgetsFlutterBinding.ensureInitialized();

//   try {
//     // Initialize local notifications
//     await NotificationController.initializeLocalNotifications();

//     // Initialize isolate receive port for notification actions
//     await NotificationController.initializeIsolateReceivePort();

//     // Execute long-running background task
//     await NotificationController.executeLongTaskInBackground();

//     // Get package information
//     final packageInfo = await PackageInfo.fromPlatform();
//     Variables.version = packageInfo.version;

//     // Request notification permission if not granted
//     final status = await Permission.notification.status;
//     if (status.isDenied) {
//       await Permission.notification.request();
//     }

//     // Request geolocation permission
//     await Geolocator.requestPermission();

//     // Set preferred orientations
//     await SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//     ]);

//     // Run the app
//     runApp(const MyApp());
//   } catch (e) {
//     // Handle initialization errors
//     print('Error initializing app: $e');
//     // You can choose to show an error dialog or perform other actions here
//   }
// }

// class MyApp extends StatefulWidget {
//   // The navigator key is necessary to navigate using static methods
//   static final GlobalKey<NavigatorState> navigatorKey =
//       GlobalKey<NavigatorState>();
//   static final GlobalKey<ScaffoldState> scaffoldKey =
//       GlobalKey<ScaffoldState>();

//   const MyApp({
//     Key? key,
//   }) : super(key: key);

//   @override
//   // ignore: library_private_types_in_public_api
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   int totalPages = 3;

//   @override
//   void initState() {
//     super.initState();
//     startService();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   //STArt service
//   Future<void> startService() async {
//     NotificationController.startListeningNotificationEvents();
//     await initializeService();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         systemNavigationBarColor: AppColor.bodyColor,
//         systemNavigationBarIconBrightness: Brightness.dark,
//         statusBarColor: AppColor.bodyColor,
//         statusBarBrightness: Brightness.dark,
//         statusBarIconBrightness: Brightness.dark,
//       ),
//       child: GetMaterialApp(
//         navigatorKey: MyApp.navigatorKey,
//         initialRoute: '/',
//         onGenerateRoute: (settings) {
//           switch (settings.name) {
//             case '/':
//               return MaterialPageRoute(
//                   builder: (context) => UpgradeAlert(
//                         showReleaseNotes: false,
//                         dialogStyle: Platform.isIOS
//                             ? UpgradeDialogStyle.cupertino
//                             : UpgradeDialogStyle.material,
//                         child: const SplashScreen(isLogin: false),
//                       ));
//             case '/custom_Screen':
//               return MaterialPageRoute(builder: (context) {
//                 return const MainLandingScreen(
//                   index: 1,
//                   parkingIndex: 1,
//                 );
//               });
//             case '/walletScreen':
//               return MaterialPageRoute(builder: (context) {
//                 return const MainLandingScreen(
//                   index: 2,
//                 );
//               });
//             case '/sharing_location':
//               return MaterialPageRoute(builder: (context) {
//                 return MapSharingScreen(
//                   scaffoldKey: MyApp.scaffoldKey,
//                 );
//               });
//             default:
//               assert(false, 'Page ${settings.name} not found');
//               return null;
//           }
//         },
//         debugShowCheckedModeBanner: false,
//         color: AppColor.primaryColor,
//         theme: ThemeData(
//           useMaterial3: false,
//           primaryColor: Colors.blue, // Set the primary color to blue
//           scaffoldBackgroundColor: AppColor.bodyColor,
//           focusColor: Colors.blue,
//           brightness: Brightness.light,
//           textTheme: TextTheme(
//             bodyMedium: TextStyle(
//               fontFamily: Platform.isIOS ? 'SFProText' : 'DefaultAndroidFont',
//               fontSize: 16.0,
//               // Add other default text style properties
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SplashScreen extends StatefulWidget {
//   final bool isLogin;
//   const SplashScreen({super.key, required this.isLogin});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   bool isInternetConnected = true;
//   late StreamSubscription<int> _streamSubscription;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       onBoarding();
//     });
//   }

//   @override
//   void dispose() {
//     // Cancel the stream subscription when the widget is disposed
//     _streamSubscription.cancel();
//     super.dispose();
//   }

//   void onBoarding() async {
//     final prefs = await SharedPreferences.getInstance();

//     var logData = prefs.getString(
//       'loginData',
//     );

//     if (logData == null) {
//       Timer(const Duration(seconds: 1), () {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => const WelcomeSplashScreen()));
//       });
//     } else {
//       var mappedLogData = [jsonDecode(logData)];
//       if (mappedLogData[0]["is_active"] == "Y") {
//         Variables.pageTrans(const MainLandingScreen());
//       } else {
//         // ignore: use_build_context_synchronously
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => const LoginScreen(
//                       index: 1,
//                     )));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Variables.init(context);
//     return PopScope(
//       canPop: false,
//       child: Scaffold(
//         appBar: AppbarWidget(
//           appbarColor: AppColor.primaryColor,
//         ),
//         backgroundColor: AppColor.primaryColor,
//         body: Container(
//           color:
//               !isInternetConnected ? AppColor.bodyColor : AppColor.primaryColor,
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           child: !isInternetConnected
//               ? NoInternetConnected(
//                   onTap: () {
//                     setState(() {
//                       isInternetConnected = true;
//                     });
//                     onBoarding();
//                   },
//                 )
//               : Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 84,
//                       height: 84,
//                       decoration: const BoxDecoration(
//                         borderRadius: BorderRadius.all(Radius.circular(15)),
//                         image: DecorationImage(
//                           image: AssetImage("assets/images/luvpark_logo.png"),
//                           fit: BoxFit.fill,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }

// // ignore: must_be_immutable
// class WelcomeSplashScreen extends StatefulWidget {
//   const WelcomeSplashScreen({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<WelcomeSplashScreen> createState() => _WelcomeSplashScreenState();
// }

// class _WelcomeSplashScreenState extends State<WelcomeSplashScreen>
//     with WidgetsBindingObserver {
//   bool isLoading = true;
//   int currentPage = 0;
//   var bodyWidget = <Widget>[];
//   bool isStarted = false;

//   PageController? _pageController;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     clearSharedPreferences();
//     _pageController = PageController(initialPage: 0);
//     //  locatePosition();
//   }

//   @override
//   void dispose() {
//     _pageController!.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   void clearSharedPreferences() async {
//     await NotificationDatabase.instance.deleteAll();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear(); // This clears all data in SharedPreferences.
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomParentWidget(
//       appbarColor: AppColor.bodyColor,
//       onPop: false,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           children: [
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 onPageChanged: (page) {
//                   setState(() {
//                     currentPage = page;
//                   });
//                 },
//                 children: const <Widget>[
//                   CustomSlider(
//                     title: "Find",
//                     subTitle:
//                         "Looking for parking? Our app helps you find available parking spaces in real-time."
//                         " Simply enter your destination, and we'll show you the nearest options.",
//                     icon: "step1",
//                   ),
//                   CustomSlider(
//                     title: "Book",
//                     subTitle:
//                         "No more driving around in circles! Once you find a spot you like, "
//                         "you can book it right from our app.",
//                     icon: "step2",
//                   ),
//                   CustomSlider(
//                     title: "Park",
//                     subTitle:
//                         "Get the best prices at convenient locations throughout  our network of garages of parking.",
//                     icon: "step3",
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   3,
//                   (index) => buildDot(index, context),
//                 ),
//               ),
//             ),
//             Container(
//               height: 20,
//             ),
//             CustomButton(
//               color: AppColor.primaryColor,
//               label: "Create Account",
//               onTap: () async {
//                 bool serviceEnabled;
//                 serviceEnabled = await Geolocator.isLocationServiceEnabled();
//                 if (!serviceEnabled) {
//                   // ignore: use_build_context_synchronously
//                   showAlertDialog(context, "Attention",
//                       "To continue, turn on device location, which uses Google's location service.",
//                       () {
//                     Navigator.of(context).pop();
//                   });
//                 } else {
//                   // ignore: use_build_context_synchronously
//                   DashboardComponent.locatePosition(context, false);
//                 }
//               },
//             ),
//             const SizedBox(height: 16.0),
//             CustomButtonCancel(
//               color: AppColor.btnSubColor,
//               textColor: Colors.black,
//               label: "Login",
//               onTap: () {
//                 FocusScope.of(context).requestFocus(FocusNode());
//                 Variables.pageTrans(const LoginScreen(
//                   index: 0,
//                 ));
//               },
//             ),
//             Container(
//               height: 50,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Container buildDot(int index, BuildContext context) {
//     return Container(
//       height: 10,
//       width: 10,
//       margin: const EdgeInsets.only(right: 5),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: currentPage == index
//             ? AppColor.primaryColor
//             : const Color.fromARGB(255, 171, 204, 242),
//       ),
//     );
//   }
// }

// //Slider 1

// class CustomSlider extends StatefulWidget {
//   final String title;
//   final String subTitle;
//   final String icon;
//   const CustomSlider({
//     required this.title,
//     required this.subTitle,
//     required this.icon,
//     super.key,
//   });

//   @override
//   State<CustomSlider> createState() => _CustomSliderState();
// }

// class _CustomSliderState extends State<CustomSlider> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         Image(
//           height: MediaQuery.of(context).size.height * 0.30,
//           width: MediaQuery.of(context).size.width * 90,
//           image: AssetImage("assets/images/${widget.icon}.png"),
//         ),
//         Container(
//           height: 10,
//         ),
//         CustomDisplayText(
//           label: widget.title,
//           color: AppColor.textMainColor,
//           fontSize: 20,
//           fontWeight: FontWeight.w700,
//           height: 0,
//         ),
//         Container(
//           height: 10,
//         ),
//         SizedBox(
//           width: Variables.screenSize.width * .90,
//           child: CustomDisplayText(
//             label: widget.subTitle,
//             fontWeight: FontWeight.normal,
//             color: Colors.black54,
//             alignment: TextAlign.center,
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }
// }

// }