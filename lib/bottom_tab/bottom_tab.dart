import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luvpark/dashboard/dashboard3.dart';
import 'package:luvpark/parking_trans/parking_transaction.dart';
import 'package:luvpark/settings/settings.dart';
import 'package:luvpark/wallet/my_wallet.dart';

class MainLandingScreen extends StatefulWidget {
  final int index;
  final int? parkingIndex;
  const MainLandingScreen({
    super.key,
    this.parkingIndex,
    this.index = 0,
  });

  @override
  _MainLandingScreenState createState() => _MainLandingScreenState();
}

class _MainLandingScreenState extends State<MainLandingScreen> {
  bool isCenterDocked = false;
  int _currentIndex = 0;
  bool isRating = false;
  final List<Widget> _pages = <Widget>[];

  @override
  void initState() {
    super.initState();
    _pages.add(Dashboard3());
    _pages.add(ParkingActivity(tabIndex: widget.parkingIndex ?? 0));
    _pages.add(const MyWallet());
    _pages.add(const SettingsPage());
    _currentIndex = widget.index;
  }

  @override
  void dispose() {
    super.dispose();
    getIndexPage();
  }

  void getIndexPage() {
    if (widget.index != 0) {
      setState(() {
        _currentIndex = widget.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1)),
      child: Scaffold(
        extendBodyBehindAppBar: _currentIndex == 0,
        appBar: _currentIndex > 0
            ? null
            : AppBar(
                elevation: 0,
                toolbarHeight: 0,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.dark,
                ),
              ),
        body: _pages[_currentIndex],
        bottomNavigationBar: LayoutBuilder(
          builder: (context, constraints) {
            // Get screen width
            double screenWidth = constraints.maxWidth;

            // Define sizes based on screen width
            double imageSize = screenWidth < 360 ? 20 : 24;
            double fontSize = screenWidth < 360 ? 12 : 14;

            return BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              selectedLabelStyle: GoogleFonts.manrope(
                fontSize: fontSize,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.manrope(
                fontSize: fontSize,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  isCenterDocked = false;
                  isRating = false;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Image(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      "assets/images/home_${_currentIndex == 0 ? 'active' : 'inactive'}.png",
                    ),
                    width: imageSize,
                    height: imageSize,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Image(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      "assets/images/parking_${_currentIndex == 1 ? 'active' : 'inactive'}.png",
                    ),
                    width: imageSize,
                    height: imageSize,
                  ),
                  label: 'Parking',
                ),
                BottomNavigationBarItem(
                  icon: Image(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      "assets/images/wallet_${_currentIndex == 2 ? 'active' : 'inactive'}.png",
                    ),
                    width: imageSize,
                    height: imageSize,
                  ),
                  label: 'Wallet',
                ),
                BottomNavigationBarItem(
                  icon: Image(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      "assets/images/settings_${_currentIndex == 3 ? 'active' : 'inactive'}.png",
                    ),
                    width: imageSize,
                    height: imageSize,
                  ),
                  label: 'Settings',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
