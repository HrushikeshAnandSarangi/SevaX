import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/member_list_builder.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class TimebankMembersPage extends StatefulWidget {
  @override
  _TimebankMembersPageState createState() => _TimebankMembersPageState();
}

class _TimebankMembersPageState extends State<TimebankMembersPage> {
  Map<String, List<ParticipantInfo>> members = {};
  List<String> keys;
  ScrollController _scrollController;
  Map<String, GlobalKey> globalKeys = {};

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateChatBloc>(context);
    return Stack(
      children: <Widget>[
        StreamBuilder<List<ParticipantInfo>>(
            stream: _bloc.members,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (snapshot.data.length == 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("No Members"),
                  ),
                );
              }

              members = {};
              snapshot.data.forEach((info) {
                // if (!globalKeys.containsKey(info.name[0])) {
                //   globalKeys[info.name[0].toUpperCase()] = GlobalKey();
                // }
                if (members.containsKey(info.name[0].toUpperCase)) {
                  members[info.name[0].toUpperCase()].add(info);
                } else {
                  members[info.name[0].toUpperCase()] = [info];
                }
              });
              keys = members.keys.toList();
              return ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: keys.length,
                itemBuilder: (_, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 12),
                        // key: globalKeys[keys[index]],
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
                        infos: members[keys[index]],
                        physics: NeverScrollableScrollPhysics(),
                      ),
                    ],
                  );
                },
              );
            }),
        // QuickScrollBar(
        //     scrollController: _scrollController,
        //     onChanged: (String key) {
        //       // log("$key  $globalKeys");

        //       if (globalKeys.containsKey(key)) {
        //         Scrollable.ensureVisible(globalKeys[key].currentContext);
        //       }
        //     }),
      ],
    );
  }
}
