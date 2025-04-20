import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/ui/utils/editDeleteIconWidget.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

enum MessageMenu {
  BLOCK,
  CLEAR_CHAT,
  EXIT_CHAT,
  EDIT_GROUP,
}

class ChatAppBar extends PreferredSize {
  final ParticipantInfo? recieverInfo;
  final MultiUserMessagingModel? groupDetails;
  final bool? isGroupMessage;
  final VoidCallback? clearChat = () {};
  final VoidCallback? blockUser;
  final VoidCallback? exitGroup;
  final VoidCallback? openGroupInfo;
  final VoidCallback? onProfileImageTap;

  final bool? isBlockEnabled;

  ChatAppBar({
    Key? key,
    this.openGroupInfo,
    this.exitGroup,
    this.groupDetails,
    this.isGroupMessage,
    this.recieverInfo,
    this.blockUser,
    this.isBlockEnabled,
    this.onProfileImageTap,
  }) : super(
            key: key, child: Container(), preferredSize: Size.fromHeight(56.0));

  @override
  Widget build(BuildContext context) {
    final String name = (isGroupMessage! ?? false)
        ? groupDetails!.name ?? ""
        : recieverInfo?.name ?? "";
    final String photoUrl = isGroupMessage!
        ? groupDetails!.imageUrl!
        : recieverInfo?.photoUrl ?? '';
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Theme.of(context).primaryColor,
      titleSpacing: 0,
      title: GestureDetector(
        onTap: openGroupInfo,
        child: Row(
          children: <Widget>[
            photoUrl != null
                ? CustomNetworkImage(
                    photoUrl,
                    size: 36,
                    onTap: onProfileImageTap!,
                  )
                : CustomAvatar(
                    name: name,
                    radius: 18,
                    color: Colors.white,
                    foregroundColor: Colors.black,
                    onTap: onProfileImageTap,
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
              S.of(context).block + " ${recieverInfo!.name!.split(' ')[0]}.",
              "${recieverInfo!.name!.split(' ')[0]} ${S.of(context).chat_block_warning}",
              S.of(context).block,
              S.of(context).cancel,
            ).then((value) {
              if (value != "CANCEL") {
                blockUser!();
              }
            });
            break;
          case MessageMenu.EXIT_CHAT:
            bool isCreator = groupDetails!.admins!.contains(
              SevaCore.of(context).loggedInUser.sevaUserID,
            );
            showCustomDialog(
              context,
              S.of(context).exit_messaging_room,
              isCreator
                  ? S.of(context).exit_messaging_room_admin_confirmation +
                      ' ' +
                      groupDetails!.name!
                  : S.of(context).exit_messaging_room_user_confirmation +
                      ' ' +
                      groupDetails!.name!,
              S.of(context).exit,
              S.of(context).cancel,
            ).then((value) {
              if (value != "CANCEL") {
                if (exitGroup != null) exitGroup!();
              }
            });
            break;
          case MessageMenu.EDIT_GROUP:
            openGroupInfo!();
            break;
          case MessageMenu.CLEAR_CHAT:
            showCustomDialog(
              context,
              S.of(context).delete_chat,
              S.of(context).delete_chat_confirmation,
              S.of(context).delete_chat,
              S.of(context).cancel,
            ).then((value) {
              if (value != "CANCEL") {
                clearChat!();
              }
            });
            break;
        }
      },
      itemBuilder: (BuildContext _context) {
        return [
          PopupMenuItem(
            child: textAndIconWidget(
                Icons.delete, S.of(context).delete_chat, context),
            value: MessageMenu.CLEAR_CHAT,
          ),
          ...!isBlockEnabled!
              ? [
                  PopupMenuItem(
                    child: textAndIconWidget(
                        Icons.block, S.of(context).block, context),
                    value: MessageMenu.BLOCK,
                  )
                ]
              : [],
          ...(isGroupMessage! &&
                  groupDetails!.admins!
                      .contains(SevaCore.of(context).loggedInUser.sevaUserID))
              ? [
                  PopupMenuItem(
                    child: textAndIconWidget(
                        Icons.edit, S.of(context).edit, context),
                    value: MessageMenu.EDIT_GROUP,
                  )
                ]
              : [],
          ...isGroupMessage!
              ? [
                  PopupMenuItem(
                    child: textAndIconWidget(
                        Icons.exit_to_app, S.of(context).exit, context),
                    value: MessageMenu.EXIT_CHAT,
                  )
                ]
              : [],
        ];
      },
    );
  }

  Future<String> showCustomDialog(BuildContext viewContext, String title,
      String content, String buttonLabel, String cancelLabel) {
    return showDialog<String>(
      barrierDismissible: false,
      context: viewContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            CustomTextButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).colorScheme.secondary,
              textColor: Colors.white,
              child: Text(
                buttonLabel,
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop("SUCCESS");
              },
            ),
            CustomTextButton(
              color: HexColor("#d2d2d2"),
              shape: StadiumBorder(),
              child: Text(
                cancelLabel,
                style:
                    TextStyle(fontSize: dialogButtonSize, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop("CANCEL");
              },
            ),
          ],
        );
      },
    ).then((value) => value ?? "CANCEL");
  }
}
