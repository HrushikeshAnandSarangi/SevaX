import 'dart:collection';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_router.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/utils/members_of_timebank.dart';
import 'package:sevaexchange/views/campaigns/campaignsview.dart';
import 'package:sevaexchange/views/messages/select_timebank_for_news_share.dart';
import 'package:sevaexchange/views/news/news_card_view.dart';
import 'package:sevaexchange/views/news/newscreate.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/project_view/timebank_projects_view.dart';
import 'package:sevaexchange/views/timebank_modules/timebank_requests.dart';
import 'package:sevaexchange/views/timebanks/group_manage_seva.dart';
import 'package:sevaexchange/views/timebanks/new_timebank_notification_view.dart';
import 'package:sevaexchange/views/timebanks/timbank_admin_request_list.dart';
import 'package:sevaexchange/views/timebanks/timebank_view.dart';
import 'package:sevaexchange/views/timebanks/timebank_view_latest.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
import 'package:sevaexchange/widgets/timebank_notification_badge.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import '../flavor_config.dart';
import 'core.dart';
import 'messages/timebank_chats.dart';

class TimebankTabsViewHolder extends StatelessWidget {
  final String timebankId;
  final TimebankModel timebankModel;
  TimebankTabsViewHolder.of({this.timebankId, this.timebankModel});

  @override
  Widget build(BuildContext context) {
    return TabarView(
      // loggedInUser: loggedInUser,
      timebankId: timebankId,
      timebankModel: timebankModel,
    );
  }
}

enum AboutUserRole { ADMIN, JOINED_USER, NORMAL_USER }

class TabarView extends StatelessWidget {
  final String timebankId;
  TimebankModel timebankModel;

  //final UserModel loggedInUser;
  //TabarView({this.loggedInUser, this.timebankId, this.timebankModel});
  TabarView({this.timebankId, this.timebankModel});

  @override
  Widget build(BuildContext context) {
    var body = StreamBuilder<TimebankModel>(
      stream: FirestoreManager.getTimebankModelStream(
        timebankId: timebankId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        this.timebankModel = snapshot.data;
        return getUserRole(
          determineUserRoleInAbout(
            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
            timeBankModel: timebankModel,
          ),
          context,
          timebankModel,
          timebankId,
        );
      },
    );
    return Scaffold(
      body: body,
    );
  }
}

Widget getUserRole(
  AboutUserRole role,
  BuildContext context,
  TimebankModel timebankModel,
  String timebankId,
) {
  switch (role) {
    case AboutUserRole.ADMIN:
      return createAdminTabBar(
        context,
        timebankModel,
        timebankId,
      );

    case AboutUserRole.JOINED_USER:
      return createJoinedUserTabBar(
        context,
        timebankModel,
        timebankId,
      );

    case AboutUserRole.NORMAL_USER:
      return createNormalUserTabBar(
        context,
        timebankModel,
        timebankId,
      );

    default:
      return createNormalUserTabBar(
        context,
        timebankModel,
        timebankId,
      );
  }
}

Widget createAdminTabBar(
  BuildContext context,
  TimebankModel timebankModel,
  String timebankId,
) {
  return DefaultTabController(
    length: 9,
    child: Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          timebankModel.name,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        children: <Widget>[
          ShowLimitBadge(),
          TabBar(
            labelColor: Theme.of(context).primaryColor,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            unselectedLabelColor: Colors.black,
            isScrollable: true,
            tabs: [
              Tab(
                text: "Feeds",
              ),
              Tab(
                text: "Projects",
              ),
              Tab(
                text: "Requests",
              ),
              Tab(
                text: "Offers",
              ),
              Tab(
                text: "About",
              ),
              // Tab(
              //   text: "Bookmarked Offers",
              // ),
              Tab(
                text: "Members",
              ),
              Tab(
                text: "Manage",
              ),
              GetActiveTimebankNotifications(timebankId: timebankId),
              getMessagingTab(
                communityId: SevaCore.of(context).loggedInUser.currentCommunity,
                timebankId: timebankId,
              ),
            ],
          ),
          Expanded(
            // height: MediaQuery.of(context).size.height - 137,
            child: TabBarView(
              children: [
                DiscussionList(
                  timebankModel: timebankModel,
                  timebankId: timebankId,
                ),
                TimeBankProjectsView(
                  timebankId: timebankId,
                  timebankModel: timebankModel,
                ),
                RequestsModule.of(
                  timebankId: timebankId,
                  timebankModel: timebankModel,
                  isFromSettings: false,
                ),
                OfferRouter(
                  timebankId: timebankId,
                  timebankModel: timebankModel,
                ),
                TimeBankAboutView.of(
                  timebankModel: timebankModel,
                  email: SevaCore.of(context).loggedInUser.email,
                ),
                // AcceptedOffers(
                //   sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
                //   timebankId: timebankModel.id,
                // ),
                TimebankRequestAdminPage(
                  isUserAdmin: timebankModel.admins
                      .contains(SevaCore.of(context).loggedInUser.sevaUserID),
                  timebankId: timebankModel.id,
                  userEmail: SevaCore.of(context).loggedInUser.email,
                  isFromGroup: true,
                ),
                ManageGroupView.of(
                  timebankModel: timebankModel,
                ),
                TimebankNotificationsView(
                  timebankId: timebankModel.id,
                ),
                TimebankChatListView(
                  timebankId: timebankId,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget get gettingMessages {
  return Icon(Icons.message);
}

Widget unreadMessages(int unreadCount) {
  return Stack(
    children: <Widget>[
      Icon(Icons.message),
      unreadCount > 0 ? badge(unreadCount) : Offstage(),
    ],
  );
}

Widget badge(int count) => Positioned(
      right: 0,
      top: 0,
      child: new Container(
        padding: EdgeInsets.all(1),
        decoration: new BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(7.5),
        ),
        constraints: BoxConstraints(
          minWidth: 15,
          minHeight: 15,
        ),
        child: Text(
          count.toString(),
          style: new TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

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

Widget createJoinedUserTabBar(
  BuildContext context,
  TimebankModel timebankModel,
  String timebankId,
) {
  return DefaultTabController(
    length: 6,
    child: Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        // backgroundColor: Colors.white,
        title: Text(
          timebankModel.name,
          style: TextStyle(fontSize: 18),
        ),
        // bottom: ColoredTabBar(
        //   color: Colors.white,
        //   tabBar: TabBar(
        //     labelColor: Theme.of(context).primaryColor,
        //     unselectedLabelColor: Colors.grey,
        //     indicatorColor: Color(0xFFF766FE0),
        //     indicatorSize: TabBarIndicatorSize.label,
        //     isScrollable: true,
        //     tabs: [
        //       Tab(
        //         text: "Feeds",
        //       ),
        //       Tab(
        //         text: "Requests",
        //       ),
        //       Tab(
        //         text: "Offers",
        //       ),
        //       Tab(
        //         text: "About",
        //       ),
        //       Tab(
        //         text: "Members",
        //       ),
        //     ],
        //   ),
        // ),
      ),
      body: Column(
        children: <Widget>[
          TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFF766FE0),
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            tabs: [
              Tab(
                text: "Feeds",
              ),
              Tab(
                text: "Projects",
              ),
              Tab(
                text: "Requests",
              ),
              Tab(
                text: "Offers",
              ),
              Tab(
                text: "About",
              ),
              // Tab(
              //   text: "Bookmarked Offers",
              // ),
              Tab(
                text: "Members",
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                DiscussionList(
                  timebankModel: timebankModel,
                  timebankId: timebankId,
                ),
                TimeBankProjectsView(
                  timebankId: timebankId,
                  timebankModel: timebankModel,
                ),
                RequestsModule.of(
                  timebankId: timebankId,
                  timebankModel: timebankModel,
                  isFromSettings: false,
                ),
                OfferRouter(
                  timebankId: timebankId,
                  timebankModel: timebankModel,
                ),
                TimeBankAboutView.of(
                  timebankModel: timebankModel,
                  email: SevaCore.of(context).loggedInUser.email,
                ),
                // AcceptedOffers(
                //   sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
                //   timebankId: timebankModel.id,
                // ),
                TimebankRequestAdminPage(
                  isUserAdmin: timebankModel.admins.contains(
                    SevaCore.of(context).loggedInUser.sevaUserID,
                  ),
                  timebankId: timebankModel.id,
                  userEmail: SevaCore.of(context).loggedInUser.email,
                  isFromGroup: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget createNormalUserTabBar(
  BuildContext context,
  TimebankModel timebankModel,
  String timebankId,
) {
  return DefaultTabController(
    length: 2,
    child: Scaffold(
        appBar: AppBar(
            elevation: 0.5,
            backgroundColor: Colors.white,
            title: Text(timebankModel.name),
            bottom: TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.label,
              isScrollable: true,
              tabs: [
                Tab(
                  text: "About",
                ),
                Tab(
                  text: "Members",
                )
              ],
            )),
        body: TabBarView(
          children: [
            TimeBankAboutView.of(
              timebankModel: timebankModel,
              email: SevaCore.of(context).loggedInUser.email,
            ),
            TimebankRequestAdminPage(
              isUserAdmin: false,
              timebankId: timebankModel.id,
              userEmail: SevaCore.of(context).loggedInUser.email,
              isFromGroup: true,
            ),
          ],
        )),
  );
}

AboutUserRole determineUserRoleInAbout(
    {String sevaUserId, TimebankModel timeBankModel}) {
  if (timeBankModel.admins.contains(sevaUserId)) {
    return AboutUserRole.ADMIN;
  } else if (timeBankModel.members.contains(sevaUserId)) {
    return AboutUserRole.JOINED_USER;
  } else {
    return AboutUserRole.NORMAL_USER;
  }
}

class DiscussionList extends StatefulWidget {
  final String loggedInUser;
  final String timebankId;
  final TimebankModel timebankModel;
  DiscussionList({this.timebankId, this.loggedInUser, this.timebankModel});
  @override
  DiscussionListState createState() {
    return DiscussionListState();
  }
}

class DiscussionListState extends State<DiscussionList> {
  String timebankName;
  List<TimebankModel> timebankList = [];
  bool isNearMe = false;
  int sharedValue = 0;
  String pinnedNewsId = '';
  bool isPinned = false;
  NewsModel pinnedNewsModel;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      child: buildTree(context),
    );
  }

  Widget buildTree(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              Text(
                "Feeds",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              Expanded(
                child: Container(),
              ),
              Padding(
                padding: EdgeInsets.only(right: 5),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.white,
          height: 0,
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NewsCreate(
                      timebankId: widget.timebankId,
                    )));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      SevaCore.of(context).loggedInUser.photoURL ??
                          defaultUserImageURL),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(10.7),
                      color: Colors.grey[200],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        ' Start a new feed....',
                        maxLines: 1,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        StreamBuilder<List<NewsModel>>(
          stream: FirestoreManager.getNewsStream(timebankID: widget.timebankId),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Text('Please make sure you have GPS turned on.');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 3),
                  child: Center(child: CircularProgressIndicator()),
                );

                break;
              default:
                List<NewsModel> newsList = snapshot.data;
                print('latest feeds ${newsList}');
                newsList = filterBlockedContent(newsList, context);
                newsList = filterPinnedNews(newsList, context);

                print("Size of incloming docs ${newsList.length}");
                if (newsList.length == 1 && newsList[0].isPinned == true) {
                  return Expanded(
                    child: ListView(
                      children: <Widget>[
                        getNewsCard(
                          newsList.elementAt(0),
                          false,
                        )
                      ],
                    ),
                  );
                }
                if (newsList.length == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Center(child: Text('Your feed is empty')),
                  );
                }
                return Expanded(
                  child: ListView(
                    children: <Widget>[
                      isPinned
                          ? getNewsCard(
                              pinnedNewsModel,
                              false,
                            )
                          : Offstage(),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: newsList.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= newsList.length) {
                            return Container(
                              width: double.infinity,
                              height: 20,
                            );
                          }

                          if (newsList.elementAt(index).reports.length > 2) {
                            return Offstage();
                          } else {
                            if (index == 0) {
                              return getNewsCard(
                                newsList.elementAt(index),
                                false,
                              );
                            } else {
                              return getNewsCard(
                                newsList.elementAt(index),
                                false,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                );
            }
          },
        )
      ],
    );
  }
//
//  Widget getCreateFeedCard({NewsModel news}) {
//    return Row(
//      crossAxisAlignment: CrossAxisAlignment.center,
//      children: <Widget>[
//        Container(
//          alignment: Alignment.topCenter,
//          width: 40,
//          height: 40,
//          margin: EdgeInsets.only(left: 5, bottom: 10, top: 10),
//          child: ClipOval(
//            child: FadeInImage.assetNetwork(
//              placeholder: 'lib/assets/images/search.png',
//              image: SevaCore.of(context).loggedInUser.photoURL,
//            ),
//          ),
//        ),
//        Expanded(
//          child: Container(
//            margin: EdgeInsets.only(left: 9, right: 4),
//            child: FlatButton(
//              color: Color.fromARGB(50, 149, 149, 149),
//              onPressed: () {},
//              // onPressed: () {
//              //   if (SevaCore.of(context).loggedInUser.associatedWithTimebanks >
//              //       1) {
//              //     Navigator.push(
//              //       context,
//              //       MaterialPageRoute(
//              //         builder: (context) {
//              //           var selectTimeBankForNewRequest = SelectTimeBankForNewRequest;
//              //           return selectTimeBankForNewRequest("Feed");
//              //         },
//              //       ),
//              //     );
//              //   } else {
//              //     Navigator.push(
//              //       context,
//              //       MaterialPageRoute(
//              //         builder: (context) => NewsCeate(
//              //           timebankId:
//              //               SevaCore.of(context).loggedInUser.currentTimebank,
//              //         ),
//              //       ),
//              //     );
//              //   }
//              //these
//              // },
//              child: GestureDetector(
//                onTap: () {
//                  Navigator.push(
//                    context,
//                    MaterialPageRoute(
//                      builder: (context) => NewsCreate(
//                        timebankId:
//                            SevaCore.of(context).loggedInUser.currentTimebank,
//                      ),
//                    ),
//                  );
//                },
//                child: Container(
//                  alignment: Alignment.bottomLeft,
//                  child: Text(
//                    'Start a new discussion...',
//                    style: TextStyle(color: Colors.black),
//                    textAlign: TextAlign.left,
//                  ),
//                ),
//              ),
//            ),
//          ),
//        )
//      ],
//    );
//  }

  void createSubTimebank(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimebankCreate(
          timebankId: FlavorConfig.values.timebankId,
        ),
      ),
    );
  }

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text(
      'All',
      style: TextStyle(fontSize: 10.0),
    ),
    1: Text(
      'Near Me',
      style: TextStyle(fontSize: 10.0),
    ),
  };
  List<NewsModel> filterPinnedNews(
      List<NewsModel> newsList, BuildContext context) {
    List<NewsModel> filteredNewsList = [];
    filteredNewsList = newsList;
    filteredNewsList.forEach((newsModel) {
      if (newsModel.isPinned == true) {
        pinnedNewsModel = newsModel;
        isPinned = true;
      }
    });

    // print('pinned news ${pinnedNewsModel}');
    if (filteredNewsList.length > 1) {
      filteredNewsList.removeWhere((news) => news.isPinned == true);
    }
    // print('filtered news ${filteredNewsList}');

    return filteredNewsList;
  }

  void _showAdminAccessMessage() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Access denied."),
          content: new Text("You are not authorized to pin a feed."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<NewsModel> filterBlockedContent(
      List<NewsModel> newsList, BuildContext context) {
    List<NewsModel> filteredNewsList = [];

    newsList.forEach((news) {
      SevaCore.of(context)
                  .loggedInUser
                  .blockedMembers
                  .contains(news.sevaUserId) ||
              SevaCore.of(context)
                  .loggedInUser
                  .blockedBy
                  .contains(news.sevaUserId)
          ? print("Removed blocked content")
          : filteredNewsList.add(news);
    });
    return filteredNewsList;
  }

  Widget getNewsCard(NewsModel news, bool isFromMessage) {
    String loggedinemail = SevaCore.of(context).loggedInUser.email;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return NewsCardView(
                newsModel: news,
              );
            },
          ),
        );
      },
      child: Container(
          margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: Stack(children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                news.newsImageUrl == null
                    ? news.imageScraped == null || news.imageScraped == "NoData"
                        ? Offstage()
                        : getImageView(news.id, news.imageScraped)
                    : getImageView(news.id, news.newsImageUrl),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, top: 15, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(news.title,
                                //     overflow: TextOverflow.ellipsis,
                                //     maxLines: 1,
                                //     style: TextStyle(
                                //       fontSize: 16,
                                //       color: Colors.black,
                                //       fontWeight: FontWeight.w600,
                                //     )),
                                // Linkify(
                                //   text:
                                //       'http://www.espncricinfo.com/story/_/id/25950138/daryl-mitchell-lbw-brings-drs-back-spotlight',
                                //   onOpen: (url) async {
                                //     if (await canLaunch(url)) {
                                //       await launch(url);
                                //     } else {
                                //       throw 'Could not launch $url';
                                //     }
                                //   },
                                //   style: TextStyle(
                                //     fontWeight: FontWeight.bold,
                                //     fontSize: 16.0,
                                //   ),
                                // ),
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Text(
                                    news.title != null && news.title != "NoData"
                                        ? news.title.trim()
                                        : news.subheading.trim(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 7,
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //  SizedBox(width: 8.0),
                          widget.timebankModel.admins.contains(
                                  SevaCore.of(context).loggedInUser.sevaUserID)
                              ? getOptionButtons(
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    child: Container(
//                                      color: news.isPinned
//                                          ? Colors.green
//                                          : Colors.black,
                                      height: 20,
                                      width: 20,
                                      child: Image.asset(
                                        'lib/assets/images/pin.png',
                                        color: news.isPinned
                                            ? Colors.green
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  () {
                                    news.isPinned
                                        ? unPinFeed(newsModel: news)
                                        : pinNews(
                                            newsModel: news,
                                          );
                                    setState(() {});
                                  },
                                )
                              : Offstage(),
                        ],
                      ),
                    ),

                    //replacement area starts
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: getOptionButtons(
                            Row(
                              // mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                // SizedBox(width: 16),
                                // FlavorConfig.appFlavor ==
                                //             Flavor.HUMANITY_FIRST ||
                                //         FlavorConfig.appFlavor ==
                                //             Flavor.APP
                                //     ? Icon(
                                //         Icons.perm_contact_calendar,
                                //         color: Theme.of(context)
                                //             .accentColor,
                                //         size: 20,
                                //       )
                                //     : SvgPicture.asset(
                                //         'lib/assets/tulsi_icons/tulsi2020_icons_author-profile-icon.svg',
                                //         height: 16,
                                //         width: 16,
                                //       ),
                                // Padding(
                                //   padding:
                                //       const EdgeInsets.only(left: 5),
                                //   child: Text(
                                //     news.fullName,
                                //     overflow: TextOverflow.ellipsis,
                                //     maxLines: 1,
                                //     style: TextStyle(
                                //       fontSize: 14,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            () {
                              String emailId = news.email;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileViewer(
                                    userEmail: emailId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Slot
                        Row(
                          children: <Widget>[
                            ClipOval(
                              child: SizedBox(
                                height: 45,
                                width: 45,
                                child: FadeInImage.assetNetwork(
                                  fit: BoxFit.cover,
                                  placeholder: defaultUserImageURL,
                                  //  placeholder: 'lib/assets/images/profile.png',
                                  image: news.userPhotoURL == null
                                      ? defaultUserImageURL
                                      : news.userPhotoURL,
                                ),
                              ),
                            ),
//                            Container(
//                              margin: EdgeInsets.all(5),
//                              height: 40,
//                              width: 40,
//                              child: CircleAvatar(
//                                backgroundImage: NetworkImage(
//                                  news.userPhotoURL == null
//                                      ? defaultUserImageURL
//                                      : news.userPhotoURL,
//                                ),
//                                minRadius: 40.0,
//                              ),
//                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Text(
                                    news.fullName?.trim() ?? '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 5),
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                          timeAgo.format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                              news.postTimestamp,
                                            ),
                                          ),
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 125,
                                  margin: EdgeInsets.only(left: 5, right: 40),
                                  child: Text(
                                    news.placeAddress == null
                                        ? ""
                                        : news.placeAddress.trim(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 12.0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    //replascement stops here

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 4),
                      child: !isFromMessage
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                //slot closed
                                Container(
                                  child: news.sevaUserId !=
                                          SevaCore.of(context)
                                              .loggedInUser
                                              .sevaUserID
                                      ? getOptionButtons(
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            child: FlavorConfig.appFlavor ==
                                                        Flavor.HUMANITY_FIRST ||
                                                    FlavorConfig.appFlavor ==
                                                        Flavor.APP ||
                                                    FlavorConfig.appFlavor ==
                                                        Flavor.SEVA_DEV
                                                ? Icon(
                                                    Icons.flag,
                                                    color: news.reports
                                                            .contains(SevaCore
                                                                    .of(context)
                                                                .loggedInUser
                                                                .sevaUserID)
                                                        ? Colors.red
                                                        : Colors.black,
                                                    size: 20,
                                                  )
                                                : Icon(
                                                    Icons.flag,
                                                    size: 20,
                                                  ),
                                          ),
                                          () {
                                            if (news.reports.contains(
                                                SevaCore.of(context)
                                                    .loggedInUser
                                                    .sevaUserID)) {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                    viewContextS) {
                                                  // return object of type Dialog
                                                  return AlertDialog(
                                                    title: Text(
                                                        'Already reported!'),
                                                    content: Text(
                                                        'You already reported this feed'),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: Text(
                                                          'OK',
                                                          style: TextStyle(
                                                            fontSize:
                                                                dialogButtonSize,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(
                                                                  viewContextS)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext viewContext) {
                                                  // return object of type Dialog
                                                  return AlertDialog(
                                                    title: Text('Report Feed?'),
                                                    content: Text(
                                                        'Do you want to report this feed?'),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                20, 5, 20, 5),
                                                        color: Theme.of(context)
                                                            .accentColor,
                                                        textColor: FlavorConfig
                                                            .values
                                                            .buttonTextColor,
                                                        child: Text(
                                                          'Report Feed',
                                                          style: TextStyle(
                                                            fontSize:
                                                                dialogButtonSize,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          if (news.reports
                                                              .contains(SevaCore
                                                                      .of(context)
                                                                  .loggedInUser
                                                                  .sevaUserID)) {
                                                            print(
                                                                'already in reports');
                                                          } else {
                                                            if (news.reports
                                                                .isEmpty) {
                                                              news.reports =
                                                                  List<
                                                                      String>();
                                                            }
                                                            news.reports.add(
                                                                SevaCore.of(
                                                                        context)
                                                                    .loggedInUser
                                                                    .sevaUserID);
                                                            Firestore.instance
                                                                .collection(
                                                                    'news')
                                                                .document(
                                                                    news.id)
                                                                .updateData({
                                                              'reports':
                                                                  news.reports
                                                            });
                                                          }
                                                          Navigator.of(
                                                                  viewContext)
                                                              .pop();
                                                        },
                                                      ),
                                                      FlatButton(
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(
                                                                  viewContext)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        )
                                      : Offstage(),
                                ),
                                getOptionButtons(
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    child: Icon(
                                      Icons.share,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                  () {
                                    // bool isShare = true;
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         // NewChat(isShare, news),
                                    //         SelectMember.shareFeed(
                                    //       timebankId: SevaCore.of(context)
                                    //           .loggedInUser
                                    //           .currentTimebank,
                                    //       newsModel: news,
                                    //       isFromShare: isShare,
                                    //     ),
                                    //   ),
                                    // );

                                    // SHARE ICON ON TAP

                                    if (SevaCore.of(context)
                                            .loggedInUser
                                            .associatedWithTimebanks >
                                        1) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SelectTimeBankNewsShare(
                                                  news,
                                                )),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SelectMembersFromTimebank(
                                            timebankId: SevaCore.of(context)
                                                .loggedInUser
                                                .currentTimebank,
                                            newsModel: NewsModel(),
                                            isFromShare: false,
                                            selectionMode:
                                                MEMBER_SELECTION_MODE.NEW_CHAT,
                                            userSelected: HashMap(),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                getOptionButtons(
                                  Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Center(
                                          child: news.likes != null &&
                                                  news.likes
                                                      .contains(loggedinemail)
                                              ? Icon(
                                                  Icons.favorite,
                                                  size: 24,
                                                  color: Colors.red[900],
                                                )
                                              : Icon(
                                                  Icons.favorite_border,
                                                  size: 24,
                                                  color: Colors.red[900],
                                                ),
                                        ),
                                      ),
                                      Text('${news.likes.length}',
                                          style: TextStyle(
                                            fontSize: 14,
                                          )),
                                    ],
                                  ),
                                  () {
                                    Set<String> likesList =
                                        Set.from(news.likes);
                                    news.likes != null &&
                                            news.likes.contains(loggedinemail)
                                        ? likesList.remove(loggedinemail)
                                        : likesList.add(loggedinemail);
                                    news.likes = likesList.toList();
                                    FirestoreManager.updateNews(
                                        newsObject: news);
                                  },
                                ),
                              ],
                            )
                          : Center(),
                    ),
                  ],
                ),
                Divider(color: Colors.black38),
              ],
            )
          ])),
    );
  }

  Widget getImageView(String newsId, String urlToLoad) {
    print("Load here ->  $urlToLoad");
    return Container(
      height: 250,
      child: SizedBox.expand(
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
          child: Hero(
            tag: newsId,
            child: FadeInImage(
              fit: BoxFit.fitWidth,
              placeholder: AssetImage('lib/assets/images/noimagefound.png'),
              image: NetworkImage(urlToLoad),
            ),
          ),
        ),
      ),
    );
  }

  Widget getOptionButtons(Widget child, VoidCallback onPressed) {
    return Material(
      color: Colors.white,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
        onTap: onPressed
//        {
//          Navigator.push(
//            context,
//            MaterialPageRoute(
//              builder: (context) => UpdateApp(
//                //userEmail: emailId,
//              ),
//            ),
//          );
//        }
        ,
        // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // padding: EdgeInsets.all(0),
      ),
    );
  }

  Widget chipForNews(BuildContext context, NewsModel newsModel) {
    assert(newsModel != null, 'News model cannot be null');

    Color chipColor;
    Color chipTextColor;

    if (newsModel.entity == null) {
      chipColor = null;
    } else if (newsModel.entity.entityType == EntityType.timebank) {
      chipColor = Colors.indigoAccent;
      chipTextColor = Colors.white;
    } else if (newsModel.entity.entityType == EntityType.campaign) {
      chipColor = Colors.deepOrangeAccent;
      chipTextColor = Colors.white;
    } else {
      chipColor = Colors.amberAccent;
    }

    String chipText;
    if (newsModel.entity == null) {
      chipText = null;
    } else {
      chipText = newsModel.entity.entityName ?? 'General';
    }

    return chipText == null
        ? Container()
        : GestureDetector(
            onTap: () async {
              if (newsModel.entity == null) return;
              if (newsModel.entity.entityType == EntityType.general) return;
              EntityModel entityModel = newsModel.entity;
              switch (entityModel.entityType) {
                case EntityType.timebank:
                  loadTimebankForId(context, entityModel.entityId);
                  break;
                case EntityType.campaign:
                  loadCampaignForId(context, entityModel.entityId);
                  break;
                default:
                  break;
              }
            },
            child: Chip(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              label: Text(
                chipText,
                style: TextStyle(color: chipTextColor),
              ),
              backgroundColor: chipColor,
            ),
          );
  }

  void pinNews({NewsModel newsModel}) async {
    if (pinnedNewsModel != null && isPinned == true) {
      unPinFeed(newsModel: pinnedNewsModel);
    }
    newsModel.isPinned = true;
    await FirestoreManager.updateNews(newsObject: newsModel);
  }

  void unPinFeed({NewsModel newsModel}) async {
    newsModel.isPinned = false;
    await FirestoreManager.updateNews(newsObject: newsModel);

    setState(() {
      pinnedNewsModel = null;
      isPinned = false;
    });
  }

  void loadTimebankForId(
    BuildContext context,
    String timebankId,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext routeContext) {
          return TimebankView(
            timebankId: timebankId,
          );
        },
      ),
    );
  }

  void loadCampaignForId(
    BuildContext context,
    String campaignId,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return CampaignView(
            campaignId: campaignId,
          );
        },
      ),
    );
  }
}
