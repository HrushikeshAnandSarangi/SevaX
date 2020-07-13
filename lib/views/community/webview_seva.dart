import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AboutMode {
  String title;
  String urlToHit;

  AboutMode({this.title, this.urlToHit});
}

class SevaWebView extends StatefulWidget {
  final AboutMode aboutMode;

  SevaWebView(this.aboutMode);

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<SevaWebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  num _stackToView = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.aboutMode.title,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Builder(builder: (BuildContext context) {
        return IndexedStack(index: _stackToView, children: [
          WebView(
            initialUrl: widget.aboutMode.urlToHit,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            javascriptChannels: <JavascriptChannel>[
              _toasterJavascriptChannel(context),
            ].toSet(),
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                print('blocking navigation to $request}');
                return NavigationDecision.prevent;
              }
              print('allowing navigation to $request');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              print('Page started loading: $url');
            },
            onPageFinished: (String url) {
              setState(() {
                _stackToView = 0;
              });
              print('Page finished loading: $url');
            },
            gestureNavigationEnabled: true,
          ),
          Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 4),
                Text(AppLocalizations.of(context)
                    .translate('jointimebank_sub', 'loading')),
              ],
            ),
          ),
        ]);
      }),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  BuildContext dialogContext;

  void showDialogForProgress() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        dialogContext = context;
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)
                .translate('jointimebank_sub', 'loading'),
          ),
          content: CircularProgressIndicator(),
        );
      },
    );
  }
}
