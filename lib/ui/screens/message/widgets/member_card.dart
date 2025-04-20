import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/chat_page.dart';
import 'package:sevaexchange/ui/screens/projects/pages/project_chat.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';

class MemberCard extends StatelessWidget {
  final ParticipantInfo? info;
  final bool? isSelected;
  final ChatModel? chatModel;

  const MemberCard(
      {Key? key, this.info, this.isSelected = false, this.chatModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateChatBloc>(context);
    return GestureDetector(
      onTap: () {
        if (_bloc!.isSelectionEnabled!) {
          _bloc.selectMember(info!.id!);
        } else {
          if (chatModel == null) {
            UserModel loggedInUser = SevaCore.of(context).loggedInUser;
            ParticipantInfo sender = ParticipantInfo(
              id: loggedInUser.sevaUserID,
              name: loggedInUser.fullname,
              photoUrl: loggedInUser.photoURL,
              type: ChatType.TYPE_PERSONAL,
            );

            ParticipantInfo reciever = ParticipantInfo(
              id: info!.id!,
              name: info!.name!,
              photoUrl: info!.photoUrl,
              type: ChatType.TYPE_PERSONAL,
            );

            createAndOpenChat(
              context: context,
              communityId: loggedInUser.currentCommunity!,
              sender: sender,
              reciever: reciever,
              timebankId: loggedInUser.currentTimebank!,
              feedId: '',
              showToCommunities: [],
              entityId: '',
              onChatCreate: () {
                Navigator.of(context).pop();
              },
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  key: UniqueKey(),
                  chatModel: chatModel!,
                  senderId: SevaCore.of(context).loggedInUser.sevaUserID!,
                  isAdminMessage: false,
                  chatViewContext: ChatViewContext.MEMBER_CHAT_LIST,
                  timebankId:
                      SevaCore.of(context).loggedInUser.currentTimebank!,
                  feedId: '', // Provide appropriate feedId if needed
                ),
              ),
            );
          }
        }
      },
      child: Container(
        child: Row(
          children: <Widget>[
            info!.photoUrl != null
                ? CustomNetworkImage(
                    info!.photoUrl!,
                    size: 40,
                  )
                : CustomAvatar(
                    name: info!.name,
                    radius: 20,
                  ),
            SizedBox(width: 12),
            Expanded(child: Text(info!.name!)),
            Offstage(
              offstage:
                  !BlocProvider.of<CreateChatBloc>(context)!.isSelectionEnabled,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) {
                  BlocProvider.of<CreateChatBloc>(context)!
                      .selectMember(info!.id!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
