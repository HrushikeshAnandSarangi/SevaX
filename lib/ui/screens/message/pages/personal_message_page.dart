import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/personal_message_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class PersonalMessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<MessageBloc>(context);
    return StreamBuilder<List<ChatModel>>(
        stream: _bloc.personalMessage,
        builder: (context, snapshot) {
          print(snapshot.data.length);
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10),
            physics: BouncingScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (_, index) {
              return PersonalMessageCard(
                name: "Stalin Parker",
                message: "Design is not about doing visual ansdjankaskd ad",
                timestamp: 12334,
              );
            },
          );
        });
  }
}
