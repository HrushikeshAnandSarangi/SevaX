import 'package:flutter/material.dart';

class Umeshify extends StatefulWidget {
  Umeshify({required this.text, required this.onOpen});

  final String text;
  final Function(String url) onOpen;
  @override
  _UmeshifyState createState() => _UmeshifyState();
}

class _UmeshifyState extends State<Umeshify> {
  var def = <InlineSpan>[];

  @override
  void initState() {
    var exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    var matches = exp.allMatches(widget.text);
    var lastPosition = 0;

    if (matches.isEmpty) {
      def.add(
        TextSpan(
          text: widget.text,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      );
    }

    for (var match in matches) {
      def
        ..add(
          TextSpan(
            text: widget.text.substring(lastPosition, match.start),
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        )
        ..add(
          WidgetSpan(
            child: InkWell(
              onTap: () {
                var link = widget.text.substring(match.start, match.end);
                widget.onOpen(
                  !link.contains('http') ? 'http://$link' : link,
                );
              },
              child: Text(
                widget.text.substring(match.start, match.end),
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );
      lastPosition = match.end;
    }

    if (matches.isNotEmpty)
      def
        ..add(
          TextSpan(
            text: widget.text.substring(lastPosition, widget.text.length),
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        children: def,
      ),
    );
  }
}
