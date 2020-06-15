import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/group_members_page.dart';
import 'package:sevaexchange/ui/screens/message/pages/timebank_members_page.dart';
import 'package:sevaexchange/ui/screens/message/widgets/member_list_builder.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class NewChatPage extends StatefulWidget {
  @override
  _NewChatPageState createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateChatBloc>(context);
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                log("new group chat");
              },
              child: Container(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(groupIcon),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Multi-User Messaging",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 30,
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[300],
              padding: EdgeInsets.only(left: 12),
              alignment: Alignment.centerLeft,
              child: Text(
                "FREQUENTLY CONTACTED",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            StreamBuilder(
              stream: BlocProvider.of<MessageBloc>(context).frequentContacts,
              builder: (_, AsyncSnapshot<List<ParticipantInfo>> snapshot) {
                if (snapshot.data == null || snapshot.data.length == 0) {
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("No Frequent Contacts"),
                  ));
                }
                return MemberListBuilder(
                  infos: snapshot.data,
                  physics: NeverScrollableScrollPhysics(),
                );
              },
            ),
            StreamBuilder<List<TimebankModel>>(
              stream: _bloc.timebanksOfUser,
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                print(snapshot.data.length);
                if (snapshot.data.length == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey[300],
                        padding: EdgeInsets.only(left: 12),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "TIMEBANK MEMBERS",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TimebankMembersPage(),
                    ],
                  );
                }
                return Column(
                  children: [
                    Row(
                      children: <Widget>[
                        tabBuilder("GROUPS", 0),
                        tabBuilder("TIMEBANK MEMBERS", 1),
                      ],
                    ),
                    [GroupMembersPage(), TimebankMembersPage()][currentIndex],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget tabBuilder(String text, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index != currentIndex) {
            setState(() {
              currentIndex = index;
            });
          }
        },
        child: Container(
          height: 30,
          alignment: Alignment.center,
          color: index == currentIndex
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: index == currentIndex ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
