import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AboutMode {
  String title;
  String urlToHit;

  AboutMode({this.title, this.urlToHit});
}

class SevaWebView extends StatefulWidget {
  AboutMode aboutMode;

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
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        actions: <Widget>[],
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return IndexedStack(index: _stackToView, children: [
          WebView(
            initialUrl: widget.aboutMode.urlToHit,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            // TODO(iskakaushik): Remove this when collection literals makes it to stable.
            // ignore: prefer_collection_literals
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
//            setState(() {
//              _stackToView = 1;
//            });
//            showDialogForProgress();
              print('Page started loading: $url');
            },
            onPageFinished: (String url) {
              setState(() {
                _stackToView = 0;
              });
              print('Page finished loading: $url');
//            Navigator.pop(dialogContext);
            },
            gestureNavigationEnabled: true,
          ),
          Container(
              child: Center(
                  child: AlertDialog(
            title: Text('Loading'),
            content: LinearProgressIndicator(),
          )))
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
            title: Text('Loading'),
            content: LinearProgressIndicator(),
          );
        });
  }
}
