import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:luvpark/dashboard/dashboard3.dart';
import 'package:luvpark/parking_trans/parking_transaction.dart';
import 'package:luvpark/settings/settings.dart';
import 'package:luvpark/wallet/my_wallet.dart';

// ignore: must_be_immutable
class MainLandingScreen extends StatefulWidget {
  final int index;
  final int? parkingIndex;
  const MainLandingScreen({
    super.key,
    this.parkingIndex,
    this.index = 0,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MainLandingScreenState createState() =>
      // ignore: no_logic_in_create_state
      _MainLandingScreenState();
}

class _MainLandingScreenState extends State<MainLandingScreen> {
  bool isCenterDocked = false;
  int _currentIndex = 0;
  bool isRating = false;
  final List<Widget> _pages = <Widget>[];
  @override
  void initState() {
    super.initState();
    _pages.add(const Dashboard3());
    _pages.add(ParkingActivity(
      tabIndex: widget.parkingIndex ?? 0,
    ));
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
      child: PopScope(
        canPop: false,
        child: Scaffold(
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 5.0,
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildNavBarItem(0, "home", 'Home'),
                    buildNavBarItem(1, "parking", 'My Parking'),
                    buildNavBarItem(2, "wallet", 'Wallet'),
                    buildNavBarItem(3, "settings", 'Settings'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNavBarItem(int index, String iconData, String title) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
          isCenterDocked = false;
          isRating = false;
        });
      },
      child: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              height: 28,
              width: 28,
              fit: BoxFit.cover,
              image: AssetImage(
                  "assets/images/${_currentIndex == index ? '${iconData}_active' : "${iconData}_inactive"}.png"),
            ),
            const SizedBox(
              height: 12,
            ),
            CustomDisplayText(
              label: title,
              color: _currentIndex == index
                  ? AppColor.primaryColor
                  : Color(0xFF666666),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 0.16,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
