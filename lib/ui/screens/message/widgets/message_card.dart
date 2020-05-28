import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/chatview.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageCard extends StatelessWidget {
  final ChatModel model;
  final bool isAdminMessage;
  const MessageCard({
    Key key,
    this.model,
    this.isAdminMessage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String senderId = model.isTimebankMessage
        ? model.timebankId
        : SevaCore.of(context).loggedInUser.sevaUserID;
    ParticipantInfo info = getSenderInfo(
      senderId,
      model.participantInfo,
    );

    int unreadCount = model.unreadStatus.containsKey(senderId)
        ? model.unreadStatus[senderId]
        : 0;
    return model.lastMessage == null
        ? Container()
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: <Widget>[
                InkWell(
                  splashColor: Colors.transparent,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatView(
                        chatModel: model,
                        senderId: isAdminMessage
                            ? model.timebankId
                            : SevaCore.of(context).loggedInUser.sevaUserID,
                      ),
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
                            isAdminMessage ||
                                    info.type == ChatType.TYPE_PERSONAL
                                ? Container()
                                : Container(
                                    decoration: BoxDecoration(
                                      color: info.type == ChatType.TYPE_TIMEBANK
                                          ? Colors.green
                                          : Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 3),
                                    child: Text(
                                      info.type == ChatType.TYPE_TIMEBANK
                                          ? "Timebank"
                                          : "Group",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
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
                      ),
                      unreadCount == 0
                          ? Container()
                          : CircleAvatar(
                              radius: 10,
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              child: Text(
                                "$unreadCount",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
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
                      model.timestamp == null
                          ? ""
                          : timeago.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  model.timestamp),
                            ),
                      // "Now 10:00 pm",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
