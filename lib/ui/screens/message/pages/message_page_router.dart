import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/personal_message_page.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

import 'admin_message_page.dart';
import 'create_new_chat_page.dart';

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
          S.of(context).bottom_nav_messages,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateNewChatPage(
                    isSelectionEnabled: false,
                    frequentContacts: _bloc.frequentContacts,
                  ),
                ),
              );
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
        S.of(context).personal,
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
      1: Text(
        S.of(context).admin,
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    };
  }
}
