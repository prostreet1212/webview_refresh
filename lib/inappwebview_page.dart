import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InappwebviewPage extends StatefulWidget {
  const InappwebviewPage({super.key});

  @override
  State<InappwebviewPage> createState() => _InappwebviewPageState();
}

class _InappwebviewPageState extends State<InappwebviewPage> with WidgetsBindingObserver{

  late final InAppWebViewController inAppWebViewController;
  String inAppWebViewKeyString = Uuid().v4().toString();

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
      inAppWebViewController.resume();
    } else if (state == AppLifecycleState.detached) {
      print('app detached');
    } else if (state == AppLifecycleState.hidden) {
      print('app hidden');
    } else if (state == AppLifecycleState.inactive) {
      print('app inactive');
    } else if (state == AppLifecycleState.paused) {
      print('app paused');
      inAppWebViewController.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(

      onWillPop: () async{
        if(await inAppWebViewController.canGoBack()){
          inAppWebViewController.goBack();
          return false;
        }else{
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: InAppWebView(
          onWebViewCreated: (c){
            inAppWebViewController=c;
          },
          initialSettings: InAppWebViewSettings(
            //useHybridComposition: true,
            //cacheEnabled: false,
            useOnRenderProcessGone: true,
          ),
         initialUrlRequest: URLRequest(
             url: WebUri('https://kdrc.ru/novosti')),
          onRenderProcessGone: (controller, details){
            setState(() {
              inAppWebViewKeyString = Uuid().v4().toString();
            });
            //inAppWebViewController.reload();
           /* inAppWebViewController.loadUrl(urlRequest: URLRequest(
                url: WebUri('https://kdrc.ru/novosti')));*/
            print('рендер ${details.rendererPriorityAtExit}');
          },
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: (){
              inAppWebViewController.reload();
            }),
      ),
    );
  }
}
