import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/message/pages/chat_page.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:timeago/timeago.dart' as timeago;

RegExp exp = RegExp(
    r'[a-zA-Z][a-zA-Z0-9_.%$&]*[@][a-zA-Z0-9]*[.][a-zA-Z.]*[*][0-9]{13,}');

class MessageCard extends StatelessWidget {
  final ChatModel model;
  final bool isAdminMessage;
  final String timebankId;

  const MessageCard({
    Key key,
    this.model,
    this.isAdminMessage = false,
    this.timebankId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (model.participants.length == 2 &&
        model.participants[0] == model.participants[1]) {
      return Container();
    }
    String userId = SevaCore.of(context).loggedInUser.sevaUserID;
    String senderId = model.isTimebankMessage ? timebankId : userId;
    ParticipantInfo info = getSenderInfo(
      isAdminMessage ? timebankId : userId,
      model.participantInfo,
    );
    var chatType =
        model.isGroupMessage ? ChatType.TYPE_MULTI_USER_MESSAGING : info?.type;

    int unreadCount =
        model.unreadStatus.containsKey(isAdminMessage ? senderId : userId)
            ? model.unreadStatus[isAdminMessage ? senderId : userId]
            : 0;

    String photoUrl =
        model.isGroupMessage ? model.groupDetails.imageUrl : info.photoUrl;
    String name = model.isGroupMessage ? model.groupDetails.name : info.name;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: <Widget>[
          InkWell(
            splashColor: Colors.transparent,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  chatModel: model,
                  senderId: isAdminMessage ? timebankId : userId,
                  isAdminMessage: isAdminMessage,
                  timebankId: timebankId,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                photoUrl != null
                    ? CircleAvatar(
                        radius: 30,
                        backgroundImage: CachedNetworkImageProvider(photoUrl),
                      )
                    : CustomAvatar(
                        name: name,
                        radius: 30,
                      ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      isAdminMessage || chatType == ChatType.TYPE_PERSONAL
                          ? Container()
                          : Container(
                              decoration: BoxDecoration(
                                color: getMessageTypeColor(context, chatType),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 3),
                              child: Text(
                                getMessageTypeName(context, chatType),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        exp.hasMatch(model.lastMessage ?? '')
                            ? S.of(context).shared_post
                            : model.lastMessage ?? '',
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
                        DateTime.fromMillisecondsSinceEpoch(model.timestamp),
                        locale: Locale(getLangTag()).toLanguageTag()),
                // "Now 10:00 pm",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getMessageTypeName(BuildContext context, ChatType type) {
    switch (type) {
      case ChatType.TYPE_PERSONAL:
        return "Personal";
        break;
      case ChatType.TYPE_TIMEBANK:
        return S.of(context).timebank;
        break;
      case ChatType.TYPE_GROUP:
        return S.of(context).group;
        break;
      case ChatType.TYPE_MULTI_USER_MESSAGING:
        return S.of(context).messaging_room;
        break;
    }
    return "";
  }

  Color getMessageTypeColor(BuildContext context, ChatType type) {
    switch (type) {
      case ChatType.TYPE_PERSONAL:
        return Colors.grey;
        break;
      case ChatType.TYPE_TIMEBANK:
        return Colors.green;
        break;
      case ChatType.TYPE_GROUP:
        return Theme.of(context).primaryColor;
        break;
      case ChatType.TYPE_MULTI_USER_MESSAGING:
        return Theme.of(context).primaryColor;
        break;
    }
    return Colors.grey;
  }
}
