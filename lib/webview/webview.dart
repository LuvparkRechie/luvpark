import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:luvpark/classess/color_component.dart';
import 'package:luvpark/custom_widget/custom_parent_widget.dart';
import 'package:luvpark/custom_widget/custom_text.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebviewPage extends StatefulWidget {
  final String urlDirect, label;
  final bool isBuyToken;
  final bool? hasAgree;
  final Function? onAgree;
  const WebviewPage(
      {super.key,
      required this.urlDirect,
      this.isBuyToken = true,
      this.hasAgree = false,
      this.onAgree,
      required this.label});
  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };
  WebViewController? _controller;
  final UniqueKey _key = UniqueKey();
  bool isLoading = true;
  bool isRefresh = false;
  bool isDragged = false;
  BuildContext? myContext;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    myContext = context;

    return CustomParent1Widget(
      canPop: true,
      appBarheaderText: widget.label,
      appBarIconClick: () {
        Navigator.of(context).pop();
      },
      hasPadding: false,
      child: isLoading
          ? Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  color: AppColor.primaryColor,
                ),
              ),
            )
          : bodyniya(),
    );
  }

  Widget bodyniya() {
    return Column(
      children: [
        Expanded(
          child: WebViewWidget(
            controller: _controller!,
            key: _key,
            gestureRecognizers: gestureRecognizers,
          ),
        ),
        if (widget.hasAgree!)
          Container(
            height: 20,
          ),
        if (widget.hasAgree!)
          InkWell(
            onTap: () {
              widget.onAgree!();
            },
            child: CustomDisplayText(
              label: "Agree",
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.primaryColor,
            ),
          ),
        Container(
          height: 20,
        ),
      ],
    );
  }

  void initialize() {
    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            print("isRefresh $isRefresh");

            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
        ),
      )
      ..enableZoom(false)
      ..loadRequest(Uri.parse(widget.urlDirect));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    setState(() {
      _controller = controller;
    });
  }
}
