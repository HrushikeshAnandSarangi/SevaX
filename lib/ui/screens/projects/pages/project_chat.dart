import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/repositories/chats_repository.dart';
import 'package:sevaexchange/ui/screens/message/pages/chat_page.dart';
import 'package:sevaexchange/ui/screens/projects/bloc/project_description_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

enum ChatViewContext { PROJECT, REQUEST, MEMBER_CHAT_LIST, UNDEFINED }

class ProjectChatView extends StatefulWidget {
  @override
  _ProjectChatViewState createState() => _ProjectChatViewState();
}

class _ProjectChatViewState extends State<ProjectChatView> {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ProjectDescriptionBloc>(context);
    return StreamBuilder<ChatModel>(
      stream: bloc.chatModel,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(S.of(context).general_stream_error),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: LoadingIndicator());
        }
        var user = SevaCore.of(context).loggedInUser;
        bool isMember = snapshot.data.participants.contains(user.sevaUserID);
        // isMember = false;
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ChatPage(
              chatModel: snapshot.data,
              isAdminMessage: false,
              showAppBar: false,
              senderId: SevaCore.of(context).loggedInUser.sevaUserID,
              chatViewContext: ChatViewContext.PROJECT,
              timebankId: user.currentTimebank,
            ),
            isMember
                ? Container()
                : BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 8.0,
                      sigmaY: 8.0,
                    ),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
            Offstage(
              offstage: isMember,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('To View and receive updates join the community'),
                  RaisedButton(
                    child: Text('Join Chat'),
                    onPressed: () {
                      ChatsRepository.addMember(
                        snapshot.data.id,
                        ParticipantInfo(
                          id: user.sevaUserID,
                          name: user.fullname,
                          photoUrl: user.photoURL,
                          type: ChatType.TYPE_MULTI_USER_MESSAGING,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
