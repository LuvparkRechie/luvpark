import 'package:flutter/material.dart';
import 'package:luvpark_get/custom_widgets/custom_text.dart';
import 'package:rive/rive.dart';

class NoInternetConnected extends StatefulWidget {
  final Function? onTap;
  final double? width;
  final double? height;

  const NoInternetConnected({
    super.key,
    this.onTap,
    this.width = 220,
    this.height = 300,
  });

  @override
  _NoInternetConnectedState createState() => _NoInternetConnectedState();
}

class _NoInternetConnectedState extends State<NoInternetConnected> {
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller with the desired timeline
    _controller = SimpleAnimation('Timeline 1');
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 20,
          ),
          Center(
            child: SizedBox(
              height: 300,
              width: 300,
              child: RiveAnimation.asset(
                'assets/nointernet.riv',
                controllers: [_controller],
                onInit: (_) {
                  setState(() {});
                },
              ),
            ),
          ),
          Container(
            height: widget.height == null ? 55 : widget.height! * .30,
          ),
          const CustomParagraph(
            text: "No Internet Connection",
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Color(0xFF1E1E1E),
            letterSpacing: -0.408,
          ),
          Container(
            height: 10,
          ),
          const CustomParagraph(
              text: "Seems like you’ve lost connection.",
              fontWeight: FontWeight.w400,
              letterSpacing: -0.408,
              fontSize: 14),
          Container(
            height: 25,
          ),
          if (widget.onTap != null)
            TextButton(
                onPressed: () {
                  widget.onTap!();
                },
                child: const CustomLinkLabel(text: "Reconnect")),
        ],
      ),
    );
  }
}
