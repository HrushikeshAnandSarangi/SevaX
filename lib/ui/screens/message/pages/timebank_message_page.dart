import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/bloc/timebank_message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/message_card.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class TimebankMessagePage extends StatefulWidget {
  final AdminMessageWrapperModel adminMessageWrapperModel;
  final String communityId;

  const TimebankMessagePage(
      {Key? key,
      required this.adminMessageWrapperModel,
      required this.communityId})
      : super(key: key);
  static Route<dynamic> route(
          {required AdminMessageWrapperModel adminMessageWrapperModel,
          required String communityId}) =>
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
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "${widget.adminMessageWrapperModel.name}",
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: _bloc.messagelist,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Text(S.of(context).no_message),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (_, index) {
              ChatModel chat = snapshot.data![index];
              return MessageCard(
                model: chat,
                isAdminMessage: true,
                timebankId: widget.adminMessageWrapperModel.id,
              );
            },
          );
        },
      ),
    );
  }
}
