
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class StlInapp extends StatelessWidget {
  const StlInapp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green,),
      body: InAppWebView(
        onWebViewCreated: (c) {
        },
        initialUrlRequest: URLRequest(
          url: WebUri('https://kdrc.ru/novosti'),
        ),
      ),
    );
  }
}
