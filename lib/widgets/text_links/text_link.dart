import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';

final RegExp linkRegExp =
    RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');

class TextLink extends StatelessWidget {
  final String text;

  const TextLink({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String modified = text;
    List<String> urls = [];
    Iterable<RegExpMatch> matches = linkRegExp.allMatches(text);
    matches.forEach((match) {
      String url = text.substring(match.start, match.end);
      modified = modified.replaceAll(url, '**|**');
      urls.add(url);
    });

    List<String> chunks = modified.split("**|**");
    urls.add('');
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black),
        children: List.generate(
          chunks.length,
          (index) => TextSpan(
            text: chunks[index],
            children: [
              TextSpan(
                text: urls[index],
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => openUrl(context, urls[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openUrl(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SevaWebView(
          AboutMode(title: "External Url", urlToHit: url),
        ),
      ),
    );
  }
}
