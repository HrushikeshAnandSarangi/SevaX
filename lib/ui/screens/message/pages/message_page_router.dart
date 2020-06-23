import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/personal_message_page.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
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
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<MessageBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('messages', 'messages_title'),
          style: TextStyle(fontSize: 18),
        ),
        actions: <Widget>[
          IconButton(
            color: Colors.white,
            icon: Image.asset(
              createMessageIcon,
              width: 20,
              height: 20,
            ),
            onPressed: () {
              if (SevaCore.of(context).loggedInUser.associatedWithTimebanks >
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
                      timebankId:
                          SevaCore.of(context).loggedInUser.currentTimebank,
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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: <Widget>[
            StreamBuilder<List<AdminMessageWrapperModel>>(
                stream: _bloc.adminMessage,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.length > 0) {
                    return Column(
                      children: <Widget>[
                        SizedBox(height: 10),
                        messageSwitch(),
                      ],
                    );
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
    );
  }

  Widget messageSwitch() {
    return Container(
      width: double.infinity,
      child: CupertinoSegmentedControl<int>(
        selectedColor: Theme.of(context).primaryColor,
        children: getLocalWidgets(context),
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

  Map<int, Widget> getLocalWidgets(BuildContext context) {
    return <int, Widget>{
      0: Text(
        AppLocalizations.of(context).translate('messages', 'personal_messages'),
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
      1: Text(
        AppLocalizations.of(context).translate('messages', 'admin_messages'),
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    };
  }
}
