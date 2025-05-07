import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';



class WebviewPlusPage extends StatefulWidget {
  const WebviewPlusPage({super.key});

  @override
  State<WebviewPlusPage> createState() => _WebviewPlusPageState();
}

class _WebviewPlusPageState extends State<WebviewPlusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Webview(url: "https://www.wechat.com/en"),
    );
  }
}
