import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/views/core.dart';

enum MessageMenu {
  BLOCK,
  CLEAR_CHAT,
  EXIT_CHAT,
  EDIT_GROUP,
}

class ChatAppBar extends PreferredSize {
  final ParticipantInfo recieverInfo;
  final MultiUserMessagingModel groupDetails;
  final bool isGroupMessage;
  final VoidCallback clearChat;
  final VoidCallback blockUser;
  final VoidCallback exitGroup;
  final VoidCallback openGroupInfo;

  final bool isBlockEnabled;

  ChatAppBar({
    this.openGroupInfo,
    this.exitGroup,
    this.groupDetails,
    this.isGroupMessage,
    this.recieverInfo,
    this.clearChat,
    this.blockUser,
    this.isBlockEnabled,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final String name = isGroupMessage ? groupDetails.name : recieverInfo.name;
    final String photoUrl =
        isGroupMessage ? groupDetails.imageUrl : recieverInfo.photoUrl;
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Theme.of(context).primaryColor,
      titleSpacing: 0,
      title: GestureDetector(
        onTap: openGroupInfo,
        child: Row(
          children: <Widget>[
            photoUrl != null
                ? CircleAvatar(
                    radius: 18,
                    backgroundImage: CachedNetworkImageProvider(photoUrl),
                  )
                : CustomAvatar(
                    name: name,
                    radius: 18,
                    color: Colors.white,
                    foregroundColor: Colors.black,
                  ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
          case MessageMenu.EXIT_CHAT:
            bool isCreator = groupDetails.admins.contains(
              SevaCore.of(context).loggedInUser.sevaUserID,
            );
            showCustomDialog(
              context,
              "Exit Multi-User Messaging",
              isCreator
                  ? "You are admin of this multi-user messaging, are you sure you want to exit the Multi-User Messaging ${groupDetails.name}"
                  : "Are you sure you want to exit the Multi-User Messaging ${groupDetails.name}",
              "Exit",
              // AppLocalizations.of(context).translate('chat', 'delete_title'),
              // AppLocalizations.of(context).translate('chat', 'delete_desc'),
              // AppLocalizations.of(context).translate('chat', 'delete_title'),
              AppLocalizations.of(context).translate('shared', 'cancel'),
            ).then((value) {
              if (value != "CANCEL") {
                if (exitGroup != null) exitGroup();
              }
            });
            break;
          case MessageMenu.EDIT_GROUP:
            openGroupInfo();
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
          ...!isBlockEnabled
              ? [
                  PopupMenuItem(
                    child: Text(
                      AppLocalizations.of(context).translate('chat', 'block'),
                    ),
                    value: MessageMenu.BLOCK,
                  )
                ]
              : [],
          // ...(isGroupMessage)
          //     ? [
          //         PopupMenuItem(
          //           child: Text("Exit"
          //               // AppLocalizations.of(context).translate('chat', 'block'),
          //               ),
          //           value: MessageMenu.EXIT_CHAT,
          //         )
          //       ]
          //     : [],
          ...(isGroupMessage &&
                  groupDetails.admins
                      .contains(SevaCore.of(context).loggedInUser.sevaUserID))
              ? [
                  PopupMenuItem(
                    child: Text("Edit"
                        // AppLocalizations.of(context).translate('chat', 'block'),
                        ),
                    value: MessageMenu.EDIT_GROUP,
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
