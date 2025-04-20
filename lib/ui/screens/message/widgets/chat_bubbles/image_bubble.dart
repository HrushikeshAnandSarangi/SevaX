import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/message_model.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/decorations.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class ImageBubble extends StatelessWidget {
  final bool isSent;
  final MessageModel messageModel;
  final bool isGroupMessage;
  final ParticipantInfo info;

  const ImageBubble({
    Key? key,
    required this.isSent,
    required this.messageModel,
    required this.isGroupMessage,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(6),
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: isSent
            ? MessageDecoration.sendDecoration()
            : MessageDecoration.receiveDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            isGroupMessage && !isSent
                ? Text(
                    info.name ?? '',
                    style: TextStyle(
                      color: info.color,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Container(),
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: messageModel.data == null
                    ? Center(child: ImageUploading(isSending: isSent))
                    : CustomNetworkImage(
                        messageModel.data ?? '',
                        fit: BoxFit.cover,
                        clipOval: false,
                      ),
              ),
            ),
            Offstage(
              offstage:
                  messageModel.message == null || messageModel.message == '',
              child: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(messageModel.message ?? ''),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formatChatDate(
                  messageModel.timestamp ?? 0,
                  SevaCore.of(context).loggedInUser.timezone ?? '',
                  S.of(context).localeName,
                ),
                style: TextStyle(fontSize: 10, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageUploading extends StatelessWidget {
  final bool isSending;

  const ImageUploading({Key? key, required this.isSending}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LoadingIndicator(),
        SizedBox(height: 4),
        Text(
          isSending ? S.of(context).sending : S.of(context).loading + '...',
        ),
      ],
    );
  }
}
