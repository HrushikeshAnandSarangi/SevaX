import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/home_page/timebank_home_page.dart';
import 'package:sevaexchange/views/switch_timebank.dart';
import 'package:sevaexchange/views/timebank_content_holder.dart';
import 'package:sevaexchange/views/timebank_modules/timebank_offers.dart';
import 'package:sevaexchange/views/timebank_modules/timebank_requests.dart';
import 'package:sevaexchange/views/timebanks/new_timebank_notification_view.dart';
import 'package:sevaexchange/views/timebanks/timbank_admin_request_list.dart';
import 'package:sevaexchange/views/timebanks/timebank_manage_seva.dart';
import 'package:sevaexchange/views/timebanks/timebank_view_latest.dart';
import 'package:sevaexchange/widgets/timebank_notification_badge.dart';

import 'messages/timebank_chats.dart';
// import 'package:sevaexchange/views/timebanks/timebank_notification_view.dart';
// import 'package:sevaexchange/views/timebanks/admin_notification_view.dart';

class HomeDashBoard extends StatelessWidget {
  HomeDashBoard();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  TabController controller;
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
        TabController(initialIndex: 0, length: 6, vsync: this);
    tabs = [
      Tab(
          text:
              "${selectedCommunity != null ? selectedCommunity.name : ''} Timebank"),
      Tab(text: "Feeds"),
      Tab(text: "Requests"),
      Tab(text: "Offers"),
      Tab(text: "About"),
      Tab(text: "Members")
    ];
    super.initState();
    Future.delayed(Duration.zero, () {
      print('---->${SevaCore.of(context).loggedInUser.currentCommunity}');
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
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _homeDashBoardBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: StreamBuilder<List<CommunityModel>>(
            stream: _homeDashBoardBloc.communities,
            builder: (context, snapshot) {
              setCurrentCommunity(snapshot.data);
              return snapshot.data != null
                  ? DropdownButtonHideUnderline(
                      child: DropdownButton<CommunityModel>(
                      value: selectedCommunity,
                      onChanged: (v) {
                        if (v.id != selectedCommunity.id) {
                          SevaCore.of(context).loggedInUser.currentCommunity =
                              v.id;
                          _homeDashBoardBloc
                              .setDefaultCommunity(
                            context: context,
                            community: v,
                            //oldCommunityId: selectedCommunity.id,
                          )
                              .then((_) {
                            SevaCore.of(context).loggedInUser.currentCommunity =
                                v.id;
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
                    ))
                  : Text('Loading');
            },
          ),
        ),
        body: StreamBuilder<SelectedCommuntityGroup>(
          stream: _homeDashBoardBloc
              .getCurrentGroups(SevaCore.of(context).loggedInUser),
          builder: (context, snapshot) {
            if (snapshot.data == null || !snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data != null) {
              print("asd" + snapshot.data.timebanks.length.toString());
              snapshot.data.timebanks.forEach(
                (TimebankModel data) {
                  print(
                      "timebank ->> ${data.id}  current primary - >${snapshot.data.currentCommunity.primary_timebank}");
                  if (data.id ==
                      snapshot.data.currentCommunity.primary_timebank) {
                    print("inside if" + data.toString());
                    primaryTimebank = data;
                    timeBankModelSingleton.model = primaryTimebank;
                  }
                },
              );

              if (primaryTimebank != null &&
                  primaryTimebank.admins
                      .contains(SevaCore.of(context).loggedInUser.sevaUserID) &&
                  tabs.length == 6) {
                isAdmin = true;
                _timebankController = TabController(length: 9, vsync: this);

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
                      // TimebankFeeds(),
                      RequestsModule.of(
                        timebankId: primaryTimebank.id,
                        timebankModel: primaryTimebank,
                      ),
                      OffersModule.of(
                        timebankId: primaryTimebank.id,
                        timebankModel: primaryTimebank,
                      ),
                      TimeBankAboutView.of(
                        timebankModel: primaryTimebank,
                        email: SevaCore.of(context).loggedInUser.email,
                      ),
                      TimebankRequestAdminPage(
                        isUserAdmin: primaryTimebank.admins.contains(
                          SevaCore.of(context).loggedInUser.sevaUserID,
                        ),
                        timebankId: primaryTimebank.id,
                        userEmail: SevaCore.of(context).loggedInUser.email,
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

// SafeArea(
//       child: ListView(
//         children: <Widget>[
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 2),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Row(
//                   children: <Widget>[
//                     Padding(
//                       padding: EdgeInsets.all(20),
//                       child: FadeAnimation(
//                         1,
//                         Text(
//                           "Your Groups",
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                               fontFamily: 'Europa',
//                               fontSize: 20),
//                         ),
//                       ),
//                     ),
//                     Spacer(),
//                     IconButton(
//                         icon: Icon(Icons.add_circle_outline),
//                         iconSize: 35,
//                         color: Colors.grey,
//                         alignment: Alignment.center,
//                         onPressed: () {
//                           createEditCommunityBloc.updateUserDetails(
//                               SevaCore.of(context).loggedInUser);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => TimebankCreate(
//                                 timebankId: SevaCore.of(context)
//                                     .loggedInUser
//                                     .currentTimebank,
//                               ),
//                             ),
//                           );
//                         }),
//                   ],
//                 ),
//                 //SizedBox(height: 20,),
//                 Column(
//                   children: <Widget>[
//                     getTimebanks(context: context),
//                   ],
//                 ),

//                 SizedBox(
//                   height: 30,
//                 ),
//                 Container(
//                   height: 10,
//                   color: Colors.grey[300],
//                 ),
//                 Container(
//                   height: 15,
//                   color: Colors.white,
//                 ),
//               ],
//             ),
//           ),
//           StickyHeader(
//             header: Container(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Padding(
//                     padding:
//                         const EdgeInsets.only(left: 20, bottom: 10, top: 10),
//                     child: Text(
//                       'Your Calender',
//                       textAlign: TextAlign.start,
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontFamily: 'Europa',
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   TabBar(
//                     labelColor: Theme.of(context).primaryColor,
//                     unselectedLabelStyle: TextStyle(color: Colors.grey),
//                     labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                     //labelColor: Colors.white,
//                     indicatorColor: Theme.of(context).primaryColor,
//                     tabs: [
//                       Tab(
//                         child: Text('Pending '),
//                       ),
//                       Tab(
//                         child: Text('Not Accepted '),
//                       ),
//                       Tab(
//                         child: Text('Completed '),
//                       ),
//                     ],
//                     controller: controller,
//                     isScrollable: false,
//                     unselectedLabelColor: Colors.black,
//                   ),
//                 ],
//               ),
//             ),
//             content: Container(
//               height: size.height - 180,
//               // height: size.height - 10,
//               child: MyTaskPage(controller),
//             ),
//           ),
//         ],
//       ),
//     ),
