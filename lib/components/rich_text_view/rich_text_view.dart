import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

///TODO: check performance impact bro !!!
class LinkTextSpan extends TextSpan {
  LinkTextSpan({TextStyle? style, String? url, String? text})
      : super(
            style: style,
            text: text ?? url,
            recognizer: TapGestureRecognizer()
              ..onTap = () => launcher.launch(url!));
}

class RichTextView extends StatelessWidget {
  final String text;

  // RichTextView({Key key, this.text}) : super(key: key);

  RichTextView({required this.text});

  bool _isLink(String input) {
    final matcher = RegExp(
        r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");
    return matcher.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    final _style = Theme.of(context).textTheme.bodyMedium;
    final words = text.split(' ');
    List<TextSpan> span = [];
    words.forEach((word) {
      span.add(_isLink(word)
          ? LinkTextSpan(
              text: ' $word  ',
              url: word,
              style: _style?.copyWith(color: Colors.blue))
          : TextSpan(text: '$word ', style: _style));
    });
    if (span.length > 0) {
      return RichText(
        text: TextSpan(text: '', children: span),
      );
    } else {
      return Text(text, style: TextStyle(fontWeight: FontWeight.w600));
    }
  }
}
