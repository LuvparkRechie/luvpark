import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:luvpark/custom_widgets/custom_text.dart';

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

class _NoInternetConnectedState extends State<NoInternetConnected>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller with the desired timeline
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Rotation duration
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onRefresh() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey,
        content: const Text(
          'Loading please wait...',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
        margin: EdgeInsets.only(
          bottom: MediaQuery.sizeOf(context).height * 0.89,
          left: 10,
          right: 10,
        ),
      ),
    );

    _controller.repeat();
    Future.delayed(const Duration(seconds: 1), () {
      _controller.stop();
      widget.onTap!();
    });
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
          // Center(
          //   child: SizedBox(
          //     height: 300,
          //     width: 300,
          //     child: RiveAnimation.asset(
          //       'assets/nointernet.riv',
          //       controllers: [_controller],
          //       onInit: (_) {
          //         setState(() {});
          //       },
          //     ),
          //   ),
          // ),
          // Center(
          //   child: Icon(
          //     LucideIcons.wifiOff,
          //     color: AppColor.primaryColor.withOpacity(.7),
          //     size: MediaQuery.of(context).size.width / 5,
          //   ),
          // ),
          Center(
            child: SvgPicture.asset("assets/images/no_net.svg"),
          ),
          Container(
            height: widget.height == null ? 55 : widget.height! * .15,
          ),
          const CustomParagraph(
            text: "No Internet Connection",
            fontWeight: FontWeight.w700,
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
            RotationTransition(
              turns: _controller,
              child: IconButton(
                onPressed: _onRefresh,
                icon: const Icon(Icons.refresh, size: 32),
                color: Colors.grey,
              ),
            ),
          // TextButton(
          //     onPressed: () {
          //       widget.onTap!();
          //     },
          //     child: const CustomLinkLabel(text: "Reconnect")),
        ],
      ),
    );
  }
}
