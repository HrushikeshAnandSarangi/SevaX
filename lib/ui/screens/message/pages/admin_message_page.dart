import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/admin_message_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class AdminMessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<MessageBloc>(context);
    return StreamBuilder<List<AdminMessageWrapperModel>>(
      stream: _bloc.adminMessage,
      builder: (context, snapshot) {
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
            AdminMessageWrapperModel model = snapshot.data[index];
            return AdminMessageCard(
              model: model,
            );
          },
        );
      },
    );
  }
}
