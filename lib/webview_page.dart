


import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  const WebviewPage({super.key});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {

  late final WebViewController webViewController;

  @override
  void initState() {
    super.initState();

    webViewController=WebViewController()..loadRequest(Uri.parse('https://kdrc.ru/novosti'));
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        if(await webViewController.canGoBack()){
          webViewController.goBack();
          return false;
        }else{
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: WebViewWidget(controller: webViewController),
        floatingActionButton: FloatingActionButton(onPressed: (){
          webViewController.reload();
        }),
      ),
    );
  }
}
