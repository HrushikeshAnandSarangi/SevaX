import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class AboutMode {
  String title;
  String urlToHit;

  AboutMode({required this.title, required this.urlToHit}) {
    logger.i("========= Web View " + urlToHit);
  }
}

class SevaWebView extends StatefulWidget {
  final AboutMode aboutMode;

  SevaWebView(this.aboutMode);

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<SevaWebView> {
  int _stackToView = 1;
  late WebViewController _webViewController;
  bool _controllerInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.aboutMode.title,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Builder(builder: (BuildContext context) {
        if (!_controllerInitialized) {
          _webViewController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) {
                setState(() {
                  _stackToView = 0;
                  logger.d("Finished Loading== $url");
                });
              },
            ))
            ..addJavaScriptChannel(
              'Toaster',
              onMessageReceived: (JavaScriptMessage message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message.message)),
                );
              },
            )
            ..loadRequest(Uri.parse(widget.aboutMode.urlToHit));
          _controllerInitialized = true;
        }
        return IndexedStack(
          index: _stackToView,
          children: [
            WebViewWidget(controller: _webViewController),
            Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  LoadingIndicator(),
                  SizedBox(height: 4),
                  Text(S.of(context).loading),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  BuildContext? dialogContext;

  void showDialogForProgress(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        dialogContext = context;
        return AlertDialog(
          title: Text(
            S.of(context).loading,
          ),
          content: CircularProgressIndicator(),
        );
      },
    );
  }
}
