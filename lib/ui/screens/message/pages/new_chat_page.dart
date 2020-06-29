import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/chat_page.dart';
import 'package:sevaexchange/ui/screens/message/pages/create_new_chat_page.dart';
import 'package:sevaexchange/ui/screens/message/pages/group_members_page.dart';
import 'package:sevaexchange/ui/screens/message/pages/quick_scroll_bar.dart';
import 'package:sevaexchange/ui/screens/message/pages/timebank_members_page.dart';
import 'package:sevaexchange/ui/screens/message/widgets/frequent_contacts_builder.dart';
import 'package:sevaexchange/ui/screens/message/widgets/selected_member_list_builder.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/ui/utils/strings.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class NewChatPage extends StatefulWidget {
  final List<FrequentContactsModel> frequentContacts;

  const NewChatPage({Key key, this.frequentContacts}) : super(key: key);
  @override
  _NewChatPageState createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  int currentIndex = 0;
  ScrollController _scrollController;
  bool showQuickScroll = false;

  @override
  void initState() {
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      print(
          "${_scrollController.offset}  ${widget.frequentContacts.length * 50 + 30 * 2 + 50}");
      if (_scrollController.offset >
          widget.frequentContacts.length * 50 + 30 * 2 + 50) {
        if (!showQuickScroll) {
          showQuickScroll = true;
          setState(() {});
        }
      } else {
        if (showQuickScroll) {
          showQuickScroll = false;
          setState(() {});
        }
      }
    });
    super.initState();
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateChatBloc>(context);
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _bloc.isSelectionEnabled
                    ? SelectedMemberListBuilder()
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute<ChatModel>(
                                builder: (context) => CreateNewChatPage(
                                  frequentContacts: widget.frequentContacts,
                                  isSelectionEnabled: true,
                                ),
                              ),
                            )
                                .then((ChatModel model) {
                              if (model != null) {
                                Navigator.of(context).pop(model);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      chatModel: model,
                                      senderId: model.groupDetails.admins[0],
                                    ),
                                  ),
                                );
                              }
                            });
                          },
                          child: Container(
                            height: 50,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
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
                                    AppLocalizations.of(context)
                                        .translate('messages', 'multi_user'),
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
                      ),
                Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey[300],
                  padding: EdgeInsets.only(left: 12),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context).translate(
                      'messages',
                      'frequently_contacted',
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                (widget.frequentContacts?.length ?? 0) > 0
                    ? FrequentContactsBuilder(
                        widget.frequentContacts,
                        _bloc.isSelectionEnabled,
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text("No Frequent Contacts"),
                        ),
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
                              AppLocalizations.of(context)
                                  .translate('messages', 'timebank_members'),
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
                            tabBuilder(
                              AppLocalizations.of(context).translate(
                                'messages',
                                'groups',
                              ),
                              0,
                            ),
                            tabBuilder(
                              AppLocalizations.of(context)
                                  .translate('messages', 'timebank_members'),
                              1,
                            ),
                          ],
                        ),
                        [
                          GroupMembersPage(),
                          TimebankMembersPage(),
                        ][currentIndex],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Positioned(
          child: Offstage(
            offstage: currentIndex == 0 ||
                _bloc.allMembers.length < 10 ||
                !showQuickScroll,
            child: QuickScrollBar(
              onChanged: (String key) {
                log("$key ${_bloc.scrollOffset[key]}");
                if (_bloc.scrollOffset.containsKey(key)) {
                  _scrollController.animateTo(
                    // (key.codeUnits[0] - 65) * 40.0 +
                    alphabetList.indexOf(key) * 40.0 +
                        _bloc.scrollOffset[key] * 40.0,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                  );
                }
              },
            ),
          ),
        ),
      ],
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
