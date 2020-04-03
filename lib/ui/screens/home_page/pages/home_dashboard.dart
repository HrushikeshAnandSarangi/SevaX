import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/timebank_home_page.dart';
import 'package:sevaexchange/ui/screens/search/pages/search_page.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/timebank_chats.dart';
import 'package:sevaexchange/views/project_view/timebank_projects_view.dart';
import 'package:sevaexchange/views/requests/project_request.dart';
import 'package:sevaexchange/views/switch_timebank.dart';
import 'package:sevaexchange/views/timebank_content_holder.dart';
import 'package:sevaexchange/views/timebank_modules/timebank_offers.dart';
import 'package:sevaexchange/views/timebank_modules/timebank_requests.dart';
import 'package:sevaexchange/views/timebanks/new_timebank_notification_view.dart';
import 'package:sevaexchange/views/timebanks/timbank_admin_request_list.dart';
import 'package:sevaexchange/views/timebanks/timebank_manage_seva.dart';
import 'package:sevaexchange/views/timebanks/timebank_view_latest.dart';
import 'package:sevaexchange/views/workshop/acceptedOffers.dart';
import 'package:sevaexchange/widgets/timebank_notification_badge.dart';

// class HomeDashBoard extends StatelessWidget {
//   HomeDashBoard();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: HomeDashBoard(),
//     );
//   }
// }

class HomeDashBoard extends StatefulWidget {
  @override
  _HomeDashBoardState createState() => _HomeDashBoardState();
}

class _HomeDashBoardState extends State<HomeDashBoard>
    with TickerProviderStateMixin {
  TabController controller;
  TabController manageController;
  TabController _timebankController;
  TimebankModel primaryTimebank;
  HomeDashBoardBloc _homeDashBoardBloc = HomeDashBoardBloc();
  CommunityModel selectedCommunity;
  TimeBankModelSingleton timeBankModelSingleton = TimeBankModelSingleton();
  List<Widget> tabs = [];
  List<Widget> pages = [];
  bool isAdmin = false;

  @override
  void initState() {
    controller = TabController(initialIndex: 0, length: 3, vsync: this);
    _timebankController =
        TabController(initialIndex: 0, length: 8, vsync: this);
    tabs = [
      Tab(
          text:
              "${selectedCommunity != null ? selectedCommunity.name : ''} Timebank"),
      Center(child: Tab(text: "Feeds")),
      Tab(text: "Projects"),
      Tab(text: "Requests"),
      Tab(text: "Offers"),
      Tab(text: "About"),
      Tab(text: "Accepted Offers"),
      Tab(text: "Members")
    ];
    super.initState();
    Future.delayed(Duration.zero, () {
      _homeDashBoardBloc.getAllCommunities(SevaCore.of(context).loggedInUser);
    });
  }

  @override
  void dispose() {
    _homeDashBoardBloc.dispose();
    super.dispose();
  }

  void setCurrentCommunity(List<CommunityModel> data) {
    if (data != null)
      data.forEach((model) {
        if (model.id == SevaCore.of(context).loggedInUser.currentCommunity) {
          selectedCommunity = model;
          SevaCore.of(context).loggedInUser.currentTimebank =
              model.primary_timebank;
          SevaCore.of(context).loggedInUser.associatedWithTimebanks =
              model.timebanks.length;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final _user = BlocProvider.of<UserDataBloc>(context);
    // print("user bloc ${_user.user.email}");

    return BlocProvider(
      bloc: _homeDashBoardBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title: StreamBuilder<List<CommunityModel>>(
            stream: _homeDashBoardBloc.communities,
            builder: (context, snapshot) {
              setCurrentCommunity(snapshot.data);
              return snapshot.data != null
                  ? Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Theme.of(context).primaryColor,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CommunityModel>(
                          style: TextStyle(color: Colors.white),
                          focusColor: Colors.white,
                          iconEnabledColor: Colors.white,
                          value: selectedCommunity,
                          onChanged: (v) {
                            if (v.id != selectedCommunity.id) {
                              SevaCore.of(context)
                                  .loggedInUser
                                  .currentCommunity = v.id;
                              _homeDashBoardBloc
                                  .setDefaultCommunity(
                                context: context,
                                community: v,
                                //oldCommunityId: selectedCommunity.id,
                              )
                                  .then((_) {
                                SevaCore.of(context)
                                    .loggedInUser
                                    .currentCommunity = v.id;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SwitchTimebank(),
                                  ),
                                );
                              });
                            }
                          },
                          items: List.generate(
                            snapshot.data.length,
                            (index) => DropdownMenuItem(
                              value: snapshot.data[index],
                              child: Text(
                                snapshot.data[index].name,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Text('Loading');
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Builder(builder: (context) {
                      return BlocProvider(
                        bloc: _user,
                        child: SearchPage(
                          bloc: _homeDashBoardBloc,
                          user: SevaCore.of(context).loggedInUser,
                          timebank: primaryTimebank,
                          community: selectedCommunity,
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<SelectedCommuntityGroup>(
          stream: _homeDashBoardBloc
              .getCurrentGroups(SevaCore.of(context).loggedInUser),
          builder: (context, snapshot) {
            if (snapshot.data == null || !snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data != null) {
              // print("asd" + snapshot.data.timebanks.length.toString());
              snapshot.data.timebanks.forEach(
                (TimebankModel data) {
                  //print("timebank ->> ${data.id}  current primary - >${snapshot.data.currentCommunity.primary_timebank}");
                  if (data.id ==
                      snapshot.data.currentCommunity.primary_timebank) {
                    //   print("inside if" + data.toString());
                    primaryTimebank = data;
                    timeBankModelSingleton.model = primaryTimebank;
                  }
                },
              );

              if (primaryTimebank != null &&
                  primaryTimebank.admins
                      .contains(SevaCore.of(context).loggedInUser.sevaUserID) &&
                  tabs.length == 8) {
                isAdmin = true;
                _timebankController = TabController(length: 12, vsync: this);

                tabs.add(Tab(text: 'Manage'));
                tabs.add(
                  GetActiveTimebankNotifications(
                      timebankId: primaryTimebank.id),
                );
                tabs.add(
                  getMessagingTab(
                    timebankId: primaryTimebank.id,
                    communityId:
                        SevaCore.of(context).loggedInUser.currentCommunity,
                  ),
                );
              }
            }
            return Column(
              children: <Widget>[
                ShowLimitBadge(),
                TabBar(
                  controller: _timebankController,
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  isScrollable: true,
                  tabs: tabs,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _timebankController,
                    children: <Widget>[
                      TimebankHomePage(
                        selectedCommuntityGroup: snapshot.data,
                      ),
                      DiscussionList(
                        timebankId: primaryTimebank.id,
                      ),
                      TimeBankProjectsView(
                        timebankId: primaryTimebank.id,
                        timebankModel: primaryTimebank,
                      ),
                      // TimebankFeeds(),
                      RequestsModule.of(
                        timebankId: primaryTimebank.id,
                        timebankModel: primaryTimebank,
                        isFromSettings: false,
                      ),
                      OffersModule.of(
                        timebankId: primaryTimebank.id,
                        timebankModel: primaryTimebank,
                      ),
//                      ProjectRequests(
//                        timebankId: primaryTimebank.id,
//                        timebankModel: primaryTimebank,
//                      ),
                      TimeBankAboutView.of(
                        timebankModel: primaryTimebank,
                        email: SevaCore.of(context).loggedInUser.email,
                      ),
                      AcceptedOffers(
                        sevaUserId:
                            SevaCore.of(context).loggedInUser.sevaUserID,
                        timebankId: primaryTimebank.id,
                      ),
                      TimebankRequestAdminPage(
                        isUserAdmin: primaryTimebank.admins.contains(
                          SevaCore.of(context).loggedInUser.sevaUserID,
                        ),
                        timebankId: primaryTimebank.id,
                        userEmail: SevaCore.of(context).loggedInUser.email,
                        isCommunity: true,
                        isFromGroup: false,
                      ),
                      ...isAdmin
                          ? [
                              ManageTimebankSeva.of(
                                timebankModel: primaryTimebank,
                              ),
                              TimebankNotificationsView(
                                timebankId: primaryTimebank.id,
                              ),
                              TimebankChatListView(
                                timebankId: primaryTimebank.id,
                              ),
                            ]
                          : []
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget getMessagingTab({String timebankId, String communityId}) {
    return StreamBuilder<List<ChatModel>>(
      stream: getChatsForTimebank(
        timebankId: timebankId,
        communityId: communityId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Tab(
            icon: gettingMessages,
          );
        }
        var unreadCount = 0;
        snapshot.data.forEach((model) {
          model.unreadStatus.containsKey(timebankId)
              ? unreadCount += model.unreadStatus[timebankId]
              : print("not found");
        });

        return Tab(
          icon: unreadMessages(unreadCount),
        );
      },
    );
  }
}

// class HomePageTabControllerBloc
