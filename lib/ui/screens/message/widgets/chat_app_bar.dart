import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/chat_model.dart';

enum MessageMenu {
  BLOCK,
  CLEAR_CHAT,
}

class ChatAppBar extends PreferredSize {
  final ParticipantInfo recieverInfo;
  final VoidCallback clearChat;
  final VoidCallback blockUser;
  final bool isTimebankMessage;

  ChatAppBar({
    this.recieverInfo,
    this.clearChat,
    this.blockUser,
    this.isTimebankMessage,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Theme.of(context).primaryColor,
      titleSpacing: 0,
      title: Row(
        children: <Widget>[
          Container(
            height: 36,
            width: 36,
            decoration: ShapeDecoration(
              shape: CircleBorder(
                side: BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  recieverInfo.photoUrl ?? defaultUserImageURL,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              recieverInfo.name,
              style: TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        chatMoreOptions(context),
      ],
    );
  }

  Widget chatMoreOptions(BuildContext context) {
    return PopupMenuButton<MessageMenu>(
      onSelected: (MessageMenu value) {
        switch (value) {
          case MessageMenu.BLOCK:
            showCustomDialog(
              context,
              AppLocalizations.of(context).translate('chat', 'block') +
                  " ${recieverInfo.name.split(' ')[0]}.",
              "${recieverInfo.name.split(' ')[0]} ${AppLocalizations.of(context).translate('chat', 'block_warn')}",
              AppLocalizations.of(context).translate('chat', 'block'),
              AppLocalizations.of(context).translate('shared', 'cancel'),
            ).then((value) {
              if (value != "CANCEL") {
                blockUser();
              }
            });
            break;
          case MessageMenu.CLEAR_CHAT:
            showCustomDialog(
              context,
              AppLocalizations.of(context).translate('chat', 'delete_title'),
              AppLocalizations.of(context).translate('chat', 'delete_desc'),
              AppLocalizations.of(context).translate('chat', 'delete_title'),
              AppLocalizations.of(context).translate('shared', 'cancel'),
            ).then((value) {
              if (value != "CANCEL") {
                clearChat();
              }
            });
            break;
        }
      },
      itemBuilder: (BuildContext _context) {
        return [
          PopupMenuItem(
            child: Text(
              AppLocalizations.of(context).translate('chat', 'delete_title'),
            ),
            value: MessageMenu.CLEAR_CHAT,
          ),
          ...!isTimebankMessage
              ? [
                  PopupMenuItem(
                    child: Text(
                      AppLocalizations.of(context).translate('chat', 'block'),
                    ),
                    value: MessageMenu.BLOCK,
                  )
                ]
              : [],
        ];
      },
    );
  }

  Future<String> showCustomDialog(BuildContext viewContext, String title,
      String content, String buttonLabel, String cancelLabel) {
    return showDialog(
      context: viewContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: new Text(content),
          actions: <Widget>[
            new FlatButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              child: new Text(
                buttonLabel,
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop("SUCCESS");
              },
            ),
            new FlatButton(
              child: new Text(
                cancelLabel,
                style: TextStyle(fontSize: dialogButtonSize, color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop("CANCEL");
              },
            ),
          ],
        );
      },
    );
  }
}
