import 'package:flutter/material.dart';
import 'package:sevaexchange/models/new_chat_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/message_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class PersonalMessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<MessageBloc>(context);
    return StreamBuilder<List<ChatModel>>(
      stream: _bloc.personalMessage,
      builder: (_, AsyncSnapshot<List<ChatModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data.length == 0) {
          return Center(child: Text("No message"));
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 10),
          physics: BouncingScrollPhysics(),
          itemCount: snapshot.data.length,
          itemBuilder: (_, index) {
            ChatModel model = snapshot.data[index];
            return MessageCard(
              model: model,
            );
          },
        );
      },
    );
  }
}
