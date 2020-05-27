import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/personal_message_page.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/members_of_timebank.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/select_timebank_for_chat.dart';

import 'admin_message_page.dart';

class MessagePageRouter extends StatefulWidget {
  @override
  _MessagePageRouterState createState() => _MessagePageRouterState();
}

class _MessagePageRouterState extends State<MessagePageRouter> {
  MessageBloc _bloc = MessageBloc();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _bloc.fetchAllMessage(
        SevaCore.of(context).loggedInUser.currentCommunity,
        SevaCore.of(context).loggedInUser.sevaUserID,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return BlocProvider<MessageBloc>(
      bloc: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Messages",
            style: TextStyle(fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    color: Theme.of(context).primaryColor,
                    icon: Icon(
                      Icons.create_new_folder,
                    ),
                    onPressed: () {
                      if (SevaCore.of(context)
                              .loggedInUser
                              .associatedWithTimebanks >
                          1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectTimeBankForNewChat(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectMembersFromTimebank(
                              timebankId: SevaCore.of(context)
                                  .loggedInUser
                                  .currentTimebank,
                              newsModel: NewsModel(),
                              isFromShare: false,
                              selectionMode: MEMBER_SELECTION_MODE.NEW_CHAT,
                              userSelected: HashMap(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              StreamBuilder<List<AdminMessageWrapperModel>>(
                  stream: _bloc.adminMessage,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data.length > 0) {
                      return messageSwitch();
                    }
                    return Container();
                  }),
              Expanded(
                child: [
                  PersonalMessagePage(),
                  AdminMessagePage(),
                ][currentPage],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messageSwitch() {
    return Container(
      width: double.infinity,
      child: CupertinoSegmentedControl<int>(
        selectedColor: Theme.of(context).primaryColor,
        children: logoWidgets,
        borderColor: Colors.grey,
        groupValue: currentPage,
        onValueChanged: (int val) {
          if (val != currentPage) {
            setState(() {
              currentPage = val;
            });
          }
        },
      ),
    );
  }

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text(
      'Personal',
      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    ),
    1: Text(
      'Admin',
      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    ),
  };
}
