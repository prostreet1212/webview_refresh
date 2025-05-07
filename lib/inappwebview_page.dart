import 'dart:io';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InappwebviewPage extends StatefulWidget {
  const InappwebviewPage({super.key});

  @override
  State<InappwebviewPage> createState() => _InappwebviewPageState();
}

class _InappwebviewPageState extends State<InappwebviewPage>
    with WidgetsBindingObserver {
  late InAppWebViewController? inAppWebViewController = null;
  String inAppWebViewKeyString = Uuid().v4().toString();
  String webViewKeyString = Uuid().v4().toString();
  final GlobalKey<_InappwebviewPageState> _webViewKey =
      GlobalKey<_InappwebviewPageState>();
  bool isCrashed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('app resumed');
      //await inAppWebViewController!.resume();
    } else if (state == AppLifecycleState.detached) {
      print('app detached');
    } else if (state == AppLifecycleState.hidden) {
      print('app hidden');
    } else if (state == AppLifecycleState.inactive) {
      print('app inactive');
    } else if (state == AppLifecycleState.paused) {
      print('app paused');
      //await inAppWebViewController!.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await inAppWebViewController!.canGoBack()) {
          inAppWebViewController!.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [SliverAppBar(collapsedHeight: 56, expandedHeight: 256)];
          },
          body: CustomScrollView(
            slivers: [
              SliverToNestedScrollBoxAdapter(
                childExtent: 1491,
                onScrollOffsetChanged: (scrollOffset) {
                  double y = scrollOffset;
                  if (Platform.isAndroid) {
                    y *= View.of(context).devicePixelRatio;
                  }
                  if (inAppWebViewController != null) {
                    inAppWebViewController!.scrollTo(x: 0, y: y.ceil());
                  }
                },
                child: InAppWebView(
                  key: ValueKey(webViewKeyString),
                  // key: _webViewKey,
                  onWebViewCreated: (c) {
                    inAppWebViewController = c;
                    inAppWebViewController!.loadUrl(
                      urlRequest: URLRequest(
                        url: WebUri('https://kdrc.ru/novosti'),
                      ),
                    );
                  },
                  /* initialUrlRequest: URLRequest(
                    url: WebUri('https://kdrc.ru/novosti'),
                  ),*/
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    useOnRenderProcessGone: true,
                  ),

                  onRenderProcessGone: (controller, details) {
                    isCrashed = true;
                  /*  setState(() {
                      webViewKeyString = Uuid().v4().toString();
                    });*/
                    inAppWebViewController?.scrollTo(x: 0, y: 0);
                    /* inAppWebViewController.loadUrl(urlRequest: URLRequest(
                url: WebUri('https://kdrc.ru/novosti')));*/
                    print('рендер ${details.toString()}');
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            inAppWebViewController!.reload();
          },
        ),
      ),
    );
  }
}
