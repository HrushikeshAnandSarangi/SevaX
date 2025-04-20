import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/message_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class PersonalMessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<MessageBloc>(context);
    return StreamBuilder<List<ChatModel>>(
      stream: _bloc.personalMessage,
      builder: (_, AsyncSnapshot<List<ChatModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              S.of(context).no_message,
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 10),
          physics: BouncingScrollPhysics(),
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (_, index) {
            ChatModel model = snapshot.data![index];
            return MessageCard(
              model: model,
              timebankId: SevaCore.of(context).loggedInUser.currentTimebank!,
            );
          },
        );
      },
    );
  }
}
