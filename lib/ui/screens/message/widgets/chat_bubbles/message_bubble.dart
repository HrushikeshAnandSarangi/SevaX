import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/decorations.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/core.dart';

class MessageBubble extends StatelessWidget {
  final bool isSent;
  final String message;
  final int timestamp;
  final ParticipantInfo? info;
  final bool isGroupMessage;

  const MessageBubble({
    Key? key,
    required this.isSent,
    required this.message,
    required this.timestamp,
    this.info,
    required this.isGroupMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.topRight : Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          constraints: BoxConstraints.loose(
            Size.fromWidth(MediaQuery.of(context).size.width * 0.6),
          ),
          decoration: isSent
              ? MessageDecoration.sendDecoration()
              : MessageDecoration.receiveDecoration(),
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (isGroupMessage && !isSent)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      info?.name ?? '',
                      style: TextStyle(
                        color: info?.color ?? Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Linkify(
                  text: message,
                  onOpen: (link) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SevaWebView(
                          AboutMode(
                              title: S.of(context).external_url_text,
                              urlToHit: link.url),
                        ),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatChatDate(
                      timestamp,
                      SevaCore.of(context).loggedInUser.timezone ?? 'UTC',
                      S.of(context).localeName,
                    ),
                    style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openUrl(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SevaWebView(
          AboutMode(title: S.of(context).external_url_text, urlToHit: url),
        ),
      ),
    );
  }
}
