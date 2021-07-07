import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/chat_page.dart';
import 'package:sevaexchange/ui/screens/message/pages/create_new_chat_page.dart';
import 'package:sevaexchange/ui/screens/message/pages/group_members_page.dart';
import 'package:sevaexchange/ui/screens/message/pages/parent_community_message_create.dart';
import 'package:sevaexchange/ui/screens/message/pages/quick_scroll_bar.dart';
import 'package:sevaexchange/ui/screens/message/pages/timebank_members_page.dart';
import 'package:sevaexchange/ui/screens/message/widgets/frequent_contacts_builder.dart';
import 'package:sevaexchange/ui/screens/message/widgets/selected_member_list_builder.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/ui/utils/strings.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

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
  void dispose() {
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
                ..._bloc.isSelectionEnabled
                    ? <Widget>[SelectedMemberListBuilder()]
                    : [
                        TransactionsMatrixCheck(
                          comingFrom: ComingFrom.Chats,
                          upgradeDetails: AppConfig
                              .upgradePlanBannerModel.multi_member_messaging,
                          transaction_matrix_type: "multi_member_messaging",
                          child: Padding(
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
                                          senderId:
                                              model.groupDetails.admins[0],
                                          timebankId: SevaCore.of(context)
                                              .loggedInUser
                                              .currentTimebank,
                                        ),
                                      ),
                                    );
                                  }
                                });
                              },
                              child: Container(
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
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
                                        S.of(context).messaging_room,
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
                        ),
                        HideWidget(
                          hide: memberType(
                                  Provider.of<HomePageBaseBloc>(context,
                                          listen: false)
                                      .primaryTimebankModel(),
                                  SevaCore.of(context)
                                      .loggedInUser
                                      .sevaUserID) ==
                              MemberType.MEMBER,
                          child: Container(
                            height: 50,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CommunityMessageCreate(),
                                  ),
                                );
                              },
                              child: Text('New Community Message'),
                            ),
                          ),
                        ),
                      ],
                Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey[300],
                  padding: EdgeInsets.only(left: 12),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    S.of(context).frequently_contacted.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                (widget.frequentContacts ?? [])
                                .where((element) => !element.isGroupMessage)
                                .length >
                            0 ||
                        !_bloc.isSelectionEnabled
                    ? FrequentContactsBuilder(
                        _bloc.isSelectionEnabled
                            ? widget.frequentContacts
                                .where((element) => !element.isGroupMessage)
                                .toList()
                            : widget.frequentContacts,
                        _bloc.isSelectionEnabled,
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(S.of(context).no_frequent_contacts),
                        ),
                      ),
                // StreamBuilder<List<ParticipantInfo>>(
                //     stream: _bloc.parentChildCommunities,
                //     builder: (context, snapshot) {
                //       if (snapshot.data == null || snapshot.data.isEmpty) {
                //         return Container();
                //       }
                //       return Column(
                //         children: [
                //           Container(
                //             height: 30,
                //             width: MediaQuery.of(context).size.width,
                //             color: Colors.grey[300],
                //             padding: EdgeInsets.only(left: 12),
                //             alignment: Alignment.centerLeft,
                //             child: Text(
                //               "Parent child Messaging",
                //               style: TextStyle(
                //                 fontWeight: FontWeight.bold,
                //                 fontSize: 15,
                //               ),
                //             ),
                //           ),

                //         ],
                //       );
                //     }),
                StreamBuilder<List<TimebankModel>>(
                  stream: _bloc.timebanksOfUser,
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return LoadingIndicator();
                    }
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
                              S.of(context).timebank_members,
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
                              S.of(context).groups,
                              0,
                            ),
                            tabBuilder(
                              S.of(context).timebank_members,
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
