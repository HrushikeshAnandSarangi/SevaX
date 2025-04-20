import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/member_list_builder.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class TimebankMembersPage extends StatefulWidget {
  @override
  _TimebankMembersPageState createState() => _TimebankMembersPageState();
}

class _TimebankMembersPageState extends State<TimebankMembersPage> {
  late List<String> keys;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateChatBloc>(context);
    return Stack(
      children: <Widget>[
        StreamBuilder<List<ParticipantInfo>>(
          stream: _bloc!.members,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }

            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(S.of(context).no_members),
                ),
              );
            }
            keys = _bloc.sortedMembers.keys.toList();
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: keys.length,
              itemBuilder: (_, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 12),
                      height: 40,
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      color: Colors.indigo[50],
                      child: Text(
                        keys[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    MemberListBuilder(
                      infos: _bloc.sortedMembers[keys[index]] ?? [],
                      physics: NeverScrollableScrollPhysics(),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
