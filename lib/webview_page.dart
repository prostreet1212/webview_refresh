import 'dart:io';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested_scroll_controller/nested_scroll_controller.dart';
import 'package:nested_scroll_view_plus/nested_scroll_view_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  const WebviewPage({super.key});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  late final WebViewController webViewController;
  bool isWeb = false;
  static var httpClient =  HttpClient();

   String kTransparentBackgroundPage = '''
  <!DOCTYPE html>
  <html>
  <head>
    <title>Transparent background test</title>
  </head>
  <style type="text/css">
    body { background: transparent; margin: 0; padding: 0; }
    #container { position: relative; margin: 0; padding: 0; width: 100vw; height: 100vh; }
    #shape { background: red; width: 200px; height: 200px; margin: 0; padding: 0; position: absolute; top: calc(50% - 100px); left: calc(50% - 100px); }
    p { text-align: center; }
  </style>
  <body>
    <div id="container">
      <p>Transparent background test</p>
      <div id="shape"></div>
    </div>
  </body>
  </html>
''';

  Future<File?> _downloadFile(String url, String filename,  ) async {
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      //String dir = (await getApplicationDocumentsDirectory()).path;
      String dir = (await getDownloadsDirectory())!.path;
      File file =  File('$dir/$filename');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      if(context.mounted){
        Navigator.pop(context);
      }

      return null;
      //throw Exception(e);
    }
  }


  @override
  void initState() {
    super.initState();

    try {
      webViewController =
          WebViewController()
            ..setNavigationDelegate(
              NavigationDelegate(
                onNavigationRequest: (request)async{
                  if(request.url.contains('.doc')){
                    File? file = await _downloadFile(
                        request.url, 'file.docx');
                    if (file != null) {
                      OpenFilex.open(file.path);
                    }
                    return NavigationDecision.prevent;
                  }else{
                    return NavigationDecision.navigate;
                  }
                },
                onPageFinished: (url){
                },
                onWebResourceError: (error) {
                  print('aaa');
                },
                onHttpError: (e){
                  print('aaa');
                },
                onHttpAuthRequest: (a){
                  print('aaa');
                }
               /* onHttpError: (error) {
                  print(error.response);
                },*/
               /* onHttpAuthRequest: (a){}*/
              ),
            )..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setOnConsoleMessage((e){
              print('aaa');
            })
           // ..loadRequest(Uri.parse('https://kdrc.ru/novosti'),method: LoadRequestMethod.post)
      ..loadHtmlString(kTransparentBackgroundPage)
      ;
    } catch (e) {
      print('error');
    }
  }

  final NestedScrollController nestedScrollController =
      NestedScrollController();

  @override
  Widget build(BuildContext context) {
    double heightScreen = MediaQuery.of(context).size.height;
    double topPadding = MediaQueryData.fromView(View.of(context)).padding.top;
    double bottomPadding =
        MediaQueryData.fromView(View.of(context)).padding.bottom;
    double heightWebview = heightScreen - topPadding - bottomPadding - 56;
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController.canGoBack()) {
          webViewController.goBack();
         /* String? s = await webViewController.getUserAgent();
          webViewController.setUserAgent(
            'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Mobile Safari/537.36 Edg/136.0.0.0',
          );*/
          return false;
        } else {
          return true;
        }
      },
      child: SafeArea(
          child: Scaffold(
            body: NestedScrollViewPlus(
              controller: nestedScrollController,
              physics: ClampingScrollPhysics(),
              //  pushPinnedHeaderSlivers: true,
              headerSliverBuilder: (
                  BuildContext context,
                  bool innerBoxIsScrolled,
                  ) {
                return [
                  //  NestedScrollView(headerSliverBuilder: headerSliverBuilder, body: body),
                  SliverAppBar(collapsedHeight: 56, expandedHeight: 256),
                ];
              },
              body: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  nestedScrollController.enableScroll(context);
                  nestedScrollController.enableCenterScroll(constraints);
                  return CustomScrollView(
                    slivers: [
                      SliverToNestedScrollBoxAdapter(
                        childExtent: 1491,
                        onScrollOffsetChanged: (scrollOffset) {
                          double y = scrollOffset;
                          if (Platform.isAndroid) {
                            y *= View.of(context).devicePixelRatio;
                          }
                          if (webViewController != null) {
                            webViewController!.scrollTo(0, y.ceil());
                          }
                        },
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 1,
                          itemBuilder: (c, i) {
                            return SizedBox(
                              //width: 500,
                              //height:718.5,
                              //height:1252,
                              height: heightWebview,
                              child: WebViewWidget(controller: webViewController,),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                //webViewController.reload();
                setState(() {
                  isWeb = !isWeb;
                });
              },
            ),
          ),
        ),
    );
  }
}
