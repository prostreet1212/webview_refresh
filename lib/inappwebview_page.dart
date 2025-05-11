import 'dart:io';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_direct_call_plus/flutter_direct_call.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InappwebviewPage extends StatefulWidget {
  const InappwebviewPage({super.key});

  @override
  State<InappwebviewPage> createState() => _InappwebviewPageState();
}

class _InappwebviewPageState extends State<InappwebviewPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late InAppWebViewController? _inAppWebViewController = null;
  InAppWebViewController? get inAppWebViewController => _inAppWebViewController;
  //set inAppWebViewController1(InAppWebViewController c) => _inAppWebViewController = c;


  String inAppWebViewKeyString = Uuid().v4().toString();
  String webViewKeyString = Uuid().v4().toString();
  final GlobalKey<_InappwebviewPageState> _webViewKey =
      GlobalKey<_InappwebviewPageState>();
  bool isCrashed = false;
  late Widget webCopy;


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
    super.build(context);
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
                child:InAppWebView(
                  key: ValueKey(webViewKeyString),
                  // key: _webViewKey,
                  onPageCommitVisible: (c,uri){

                  },
                  onWebViewCreated: (c) {
                      _inAppWebViewController = c;
                    inAppWebViewController!.loadUrl(
                      urlRequest: URLRequest(
                        // url: WebUri('https://kdrc.ru/novosti'),
                        url: WebUri('https://kdrc.ru/novosti'),
                      ),
                    );
                    inAppWebViewController!.addJavaScriptHandler(handlerName: 'onContentHeightChanged', callback:  (args) {
                      final height = args[0] as int;
                      print('Высота контента: $height');
                      // Можно обновить UI
                    },);
                  },
                  /* initialUrlRequest: URLRequest(
                    url: WebUri('https://kdrc.ru/novosti'),
                  ),*/
                  onDownloadStartRequest:(c,r){

                  },

                   initialSettings: InAppWebViewSettings(
                    useOnRenderProcessGone: true,
                     rendererPriorityPolicy: RendererPriorityPolicy(rendererRequestedPriority: RendererPriority.RENDERER_PRIORITY_BOUND,waivedWhenNotVisible: false)
                  ),
                  onLoadStop: (c, uri) {
                    inAppWebViewController!.evaluateJavascript(
                      source: '''     (function() {
          var height = 0;
          function checkAndNotify() {
            var curr = document.body.scrollHeight;
            if (curr !== height) {
              height = curr;
              window.flutter_inappwebview.callHandler('onContentHeightChanged', height);
            }
          }
          if (window.ResizeObserver) {
            new ResizeObserver(checkAndNotify).observe(document.body);
          } else {
            setInterval(checkAndNotify, 200);
          }
        })(); ''',
                    );
                  },
                 // onRenderProcessResponsive: (c,uri){},
                  onRenderProcessGone: (controller, details)async {
                   /* setState(() {
                      webViewKeyString = Uuid().v4().toString();
                    });*/
                    //InAppWebViewController.clearAllCache();
                    await inAppWebViewController?.reload();
                    //await inAppWebViewController!.scrollTo(x: 0, y: 200);
                    print('рендер ${details.toString()}');
                  },
                  onWindowBlur: (c){},
                  onRenderProcessResponsive: (c,u)async{
                     print('onRenderProcessResponsive...');
                     return await WebViewRenderProcessAction.TERMINATE;
                  },
                  onRenderProcessUnresponsive:(c,u)async{
                    print('onRenderProcessUnresponsive...');
                    return await WebViewRenderProcessAction.fromValue(1);
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            //inAppWebViewController!.reload();
            final status1 = await Permission.phone.request();
            if(status1.isGranted){
              await FlutterDirectCall.makeDirectCall("+79210779641");
            }
          },
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
