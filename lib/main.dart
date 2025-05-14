import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_refresh/inappwebview_page.dart';
import 'package:webview_refresh/stl_inapp.dart';
import 'package:webview_refresh/webview_page.dart';
import 'package:webview_refresh/zxc.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: WebviewPage(),
      //home: InappwebviewPage(),
     /* home: Scaffold(
        appBar: AppBar(title: Text('Resilient WebView')),
        body: ResilientWebView(initialUrl: 'https://flutter.dev'),
      ),*/
      //home:StlInapp(),
    );
  }
}


