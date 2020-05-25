import 'package:flutter/material.dart';
import 'package:sevaexchange/models/new_chat_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/bloc/timebank_message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/message_card.dart';

class TimebankMessagePage extends StatefulWidget {
  final AdminMessageWrapperModel adminMessageWrapperModel;
  final String communityId;

  const TimebankMessagePage(
      {Key key, this.adminMessageWrapperModel, this.communityId})
      : super(key: key);
  static Route<dynamic> route(
          {AdminMessageWrapperModel adminMessageWrapperModel,
          String communityId}) =>
      MaterialPageRoute(
        builder: (context) => TimebankMessagePage(
          adminMessageWrapperModel: adminMessageWrapperModel,
          communityId: communityId,
        ),
      );

  @override
  _TimebankMessagePageState createState() => _TimebankMessagePageState();
}

class _TimebankMessagePageState extends State<TimebankMessagePage> {
  final TimebankMessageBloc _bloc = TimebankMessageBloc();

  @override
  void initState() {
    _bloc.fetchAllTimebankMessage(
      widget.adminMessageWrapperModel.id,
      widget.communityId,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.adminMessageWrapperModel.name} message",
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: _bloc.messagelist,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.length == 0) {
            return Center(child: Text("No message"));
          }
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (_, index) {
              ChatModel chat = snapshot.data[index];
              return MessageCard(
                model: chat,
              );
            },
          );
        },
      ),
    );
  }
}
