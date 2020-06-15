import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/create_new_chat_search_field.dart';
import 'package:sevaexchange/ui/screens/message/widgets/member_list_builder.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';

import 'new_chat_page.dart';

class CreateNewChatPage extends StatefulWidget {
  @override
  _CreateNewChatPageState createState() => _CreateNewChatPageState();
}

class _CreateNewChatPageState extends State<CreateNewChatPage> {
  CreateChatBloc _bloc = CreateChatBloc();
  TextEditingController textController = TextEditingController();

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc.getMembers(
        SevaCore.of(context).loggedInUser.sevaUserID,
        SevaCore.of(context).loggedInUser.currentCommunity,
      );
    });
  }

  @override
  dispose() {
    super.dispose();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "New Chat",
            style: TextStyle(fontSize: 18),
          ),
          centerTitle: true,

          // actions: <Widget>[
          //   FlatButton(
          //     child: Text("Cancel"),
          //     textColor: Colors.white,
          //     onPressed: () {},
          //   ),
          // ],
          bottom: CreateNewChatSearchField(
            controller: textController,
            onChanged: (String value) {},
          ),
        ),
        body: StreamBuilder(
          stream: _bloc.searchText,
          builder: (_, AsyncSnapshot<String> snapshot) {
            if (snapshot.data != null && snapshot.data != '') {
              return MemberListBuilder(
                infos: _bloc.getFilteredListOfParticipants(snapshot.data),
              );
            }
            return NewChatPage();
          },
        ),
      ),
    );
  }
}
