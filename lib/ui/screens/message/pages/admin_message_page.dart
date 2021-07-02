import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/admin_message_card.dart';
import 'package:sevaexchange/ui/screens/message/widgets/community_messages.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class AdminMessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<MessageBloc>(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommunityMessages(
                      bloc: _bloc,
                    ),
                  ),
                );
              },
              child: Text(
                'Community Chats',
                style: TextStyle(
                  fontSize: 22,
                  color: FlavorConfig.values.theme.primaryColor,
                  fontFamily: 'Europa',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          StreamBuilder<List<AdminMessageWrapperModel>>(
            stream: _bloc.adminMessage,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              }
              if (snapshot.data.length == 0) {
                return Center(child: Text(S.of(context).no_message));
              }
              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 10),
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  AdminMessageWrapperModel model = snapshot.data[index];
                  return AdminMessageCard(
                    model: model,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
