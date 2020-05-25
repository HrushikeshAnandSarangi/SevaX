import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/new_chat_model.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/chatview.dart';

class MessageCard extends StatelessWidget {
  final ChatModel model;
  const MessageCard({
    Key key,
    this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ParticipantInfo info = getSenderInfo(
      SevaCore.of(context).loggedInUser.sevaUserID,
      model.participantInfo,
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: <Widget>[
          InkWell(
            splashColor: Colors.transparent,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatView(chatModel: model),
              ),
            ),
            child: Row(
              children: <Widget>[
                info.photoUrl != null
                    ? CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            CachedNetworkImageProvider(info.photoUrl),
                      )
                    : CustomAvatar(
                        name: info.name,
                        radius: 30,
                      ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        info.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        model.lastMessage ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Divider(
                  thickness: 1,
                  // color: Colors.grey,
                ),
              ),
              SizedBox(width: 20),
              Text(
                "Now 10:00 pm",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
