import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/admin_message_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class CommunityMessages extends StatelessWidget {
  final MessageBloc bloc;
  CommunityMessages({this.bloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community Messages',
          style: TextStyle(fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<List<AdminMessageWrapperModel>>(
          stream: bloc.adminMessage,
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
      ),
    );
  }
}
