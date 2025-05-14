import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ResilientWebView extends StatefulWidget {
  final String initialUrl;

  const ResilientWebView({Key? key, required this.initialUrl}) : super(key: key);

  @override
  _ResilientWebViewState createState() => _ResilientWebViewState();
}

class _ResilientWebViewState extends State<ResilientWebView> {
  late InAppWebViewController _webViewController;
  final GlobalKey _webViewKey = GlobalKey();

  // Данные для восстановления
  String? _lastUrl;
  WebHistory? _history ;
  int _scrollY = 0;

  // Флаг для пересоздания WebView
  bool _recreateWebView = false;

  @override
  Widget build(BuildContext context) {
    if (_recreateWebView) {
      // Пересоздаем WebView с сохраненными данными
      return _buildWebView(restore: true);
    } else {
      // Обычное создание WebView
      return _buildWebView();
    }
  }

  Widget _buildWebView({bool restore = false}) {
    return InAppWebView(
      key: _webViewKey,
      initialUrlRequest: URLRequest(
        url: WebUri(restore ? _lastUrl ?? widget.initialUrl : widget.initialUrl),
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        useShouldOverrideUrlLoading: true,
        useOnRenderProcessGone: true
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;

        if (restore) {
          // Восстанавливаем историю после пересоздания
          WidgetsBinding.instance.addPostFrameCallback((_) async {

            if (_history!.list!.isNotEmpty) {
              await _webViewController.goTo(historyItem: _history!.list!.last);
            }

            // Восстанавливаем позицию скролла
            if (_scrollY > 0) {
              _webViewController.scrollTo(x: 0, y: _scrollY.toInt());
            }
          });
        }
      },
      onLoadStart: (controller, url) async {
        // Сохраняем текущий URL
        _lastUrl = url?.toString();
      },
      onLoadStop: (controller, url) async {
        // Обновляем историю после загрузки страницы
        _history = await controller.getCopyBackForwardList();

      },
      onScrollChanged: (controller, x, y) {
        // Сохраняем позицию скролла
        _scrollY = y;
      },
      onRenderProcessGone: (controller, detail) async {
        // Сохраняем текущее состояние перед пересозданием
        _lastUrl = await controller.getUrl().toString();
        _history = await controller.getCopyBackForwardList();

        // Получаем текущую позицию скролла
        final scrollOffset = await controller.getScrollY();
        _scrollY = scrollOffset ?? 0;

        // Пересоздаем WebView
        setState(() {
          _recreateWebView = true;
        });

      },
    );
  }
}