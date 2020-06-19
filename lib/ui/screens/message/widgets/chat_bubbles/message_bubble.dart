import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/decorations.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/core.dart';

class MessageBubble extends StatelessWidget {
  final bool isSent;
  final String message;
  final int timestamp;
  final ParticipantInfo info;
  final bool isGroupMessage;

  const MessageBubble({
    Key key,
    this.isSent,
    this.message,
    this.timestamp,
    this.info,
    this.isGroupMessage,
  })  : assert(isGroupMessage != null),
        assert(isGroupMessage ? info != null : info == null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.topRight : Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Container(
            decoration: isSent
                ? MessageDecoration.sendDecoration()
                : MessageDecoration.receiveDecoration(),
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                isGroupMessage && !isSent
                    ? Text(
                        info.name,
                        style: TextStyle(
                          color: info.color,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Container(),
                Linkify(
                    text: message,
                    onOpen: (link) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SevaWebView(
                            AboutMode(
                                title: "External Url", urlToHit: link.url),
                          ),
                        ),
                      );
                    }),
                Text(
                  formatChatDate(
                    timestamp,
                    SevaCore.of(context).loggedInUser.timezone,
                  ),
                  style: TextStyle(fontSize: 10, color: Colors.grey[700]),
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
          AboutMode(title: "External Url", urlToHit: url),
        ),
      ),
    );
  }
}
