import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/repositories/chats_repository.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/message_card.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class CommunityMessages extends StatelessWidget {
  final MessageBloc? bloc;

  CommunityMessages({this.bloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          S.of(context).community_chat,
          style: TextStyle(fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: ChatsRepository.getParentChildChats(
            SevaCore.of(context).loggedInUser.currentTimebank!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (snapshot.data!.length == 0) {
            return Center(child: Text(S.of(context).no_message));
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (_, index) {
              ChatModel chat = snapshot.data![index];
              log('parrt  ${chat.participants}');
              return MessageCard(
                model: chat,
                isAdminMessage: true,
                timebankId: SevaCore.of(context).loggedInUser.currentTimebank!,
              );
            },
          );
        },
      ),
    );
  }
}
