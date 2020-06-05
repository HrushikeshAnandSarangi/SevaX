import 'dart:collection';
import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sevaexchange/components/pdf_screen.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_router.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/utils/members_of_timebank.dart';
import 'package:sevaexchange/views/messages/select_timebank_for_news_share.dart';
import 'package:sevaexchange/views/news/news_card_view.dart';
import 'package:sevaexchange/views/news/newscreate.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/project_view/timebank_projects_view.dart';
import 'package:sevaexchange/views/timebank_modules/timebank_requests.dart';
import 'package:sevaexchange/views/timebanks/group_manage_seva.dart';
import 'package:sevaexchange/views/timebanks/new_timebank_notification_view.dart';
import 'package:sevaexchange/views/timebanks/timbank_admin_request_list.dart';
import 'package:sevaexchange/views/timebanks/timebank_view_latest.dart';
import 'package:sevaexchange/widgets/timebank_notification_badge.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import '../flavor_config.dart';
import 'core.dart';

class TimebankTabsViewHolder extends StatelessWidget {
  final String timebankId;
  final TimebankModel timebankModel;
  TimebankTabsViewHolder.of({this.timebankId, this.timebankModel});

  @override
  Widget build(BuildContext context) {
    return TabarView(
      timebankId: timebankId,
      timebankModel: timebankModel,
    );
  }
}

enum AboutUserRole { ADMIN, JOINED_USER, NORMAL_USER }

class TabarView extends StatefulWidget {
  final String timebankId;
  final TimebankModel timebankModel;

  TabarView({this.timebankId, this.timebankModel});

  @override
  _TabarViewState createState() => _TabarViewState();
}

class _TabarViewState extends State<TabarView> with TickerProviderStateMixin {
  TimebankModel timebankModel;

  @override
  void initState() {
    timebankModel = widget.timebankModel;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<TimebankModel>(
        stream: FirestoreManager.getTimebankModelStream(
          timebankId: widget.timebankId,
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
          timebankModel = snapshot.data;
          return getUserRole(
            determineUserRoleInAbout(
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
              timeBankModel: timebankModel,
            ),
            context,
            timebankModel,
            widget.timebankId,
            this,
          );
        },
      ),
    );
  }
}

Widget getUserRole(
  AboutUserRole role,
  BuildContext context,
  TimebankModel timebankModel,
  String timebankId,
  TickerProvider vsync,
) {
  switch (role) {
    case AboutUserRole.ADMIN:
      TabController controller = TabController(vsync: vsync, length: 8);
      return createAdminTabBar(
        context,
        timebankModel,
        timebankId,
        controller,
      );

    case AboutUserRole.JOINED_USER:
      TabController controller = TabController(vsync: vsync, length: 6);
      return createJoinedUserTabBar(
        context,
        timebankModel,
        timebankId,
        controller,
      );

    case AboutUserRole.NORMAL_USER:
      TabController controller = TabController(vsync: vsync, length: 2);
      return createNormalUserTabBar(
        context,
        timebankModel,
        timebankId,
        controller,
      );

    default:
      TabController controller = TabController(vsync: vsync, length: 2);
      return createNormalUserTabBar(
        context,
        timebankModel,
        timebankId,
        controller,
      );
  }
}

Widget createAdminTabBar(
  BuildContext context,
  TimebankModel timebankModel,
  String timebankId,
  TabController controller,
) {
  return Scaffold(
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
        Stack(
          children: <Widget>[
            TabBar(
              controller: controller,
              labelPadding: EdgeInsets.symmetric(horizontal: 10),
              labelColor: Theme.of(context).primaryColor,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorSize: TabBarIndicatorSize.label,
              unselectedLabelColor: Colors.black,
              isScrollable: true,
              tabs: [
                Tab(
                  text: AppLocalizations.of(context)
                      .translate('homepage', "feeds"),
                ),
                Tab(
                  text: AppLocalizations.of(context)
                      .translate('homepage', "projects"),
                ),
                Tab(
                  text: AppLocalizations.of(context)
                      .translate('homepage', "requests"),
                ),
                Tab(
                  text: AppLocalizations.of(context)
                      .translate('homepage', "offers"),
                ),
                Tab(
                  text: AppLocalizations.of(context)
                      .translate('homepage', "about"),
                ),
                // Tab(
                //   text: "Bookmarked Offers",
                // ),
                Tab(
                  text: AppLocalizations.of(context)
                      .translate('homepage', "members"),
                ),
                Tab(
                  text: AppLocalizations.of(context)
                      .translate('homepage', "manage"),
                ),
                Container(
                  width: 20,
                  // height: 10,
                  // color: Colors.green,
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(width: 5),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        controller.animateTo(7);
                      },
                      child: GetActiveTimebankNotifications(
                        timebankId: timebankId,
                      ),
                    ),
                    // SizedBox(width: 14),

                    SizedBox(width: 10),
                  ],
                ),
              ),
            )
          ],
        ),
        Expanded(
          // height: MediaQuery.of(context).size.height - 137,
          child: TabBarView(
            controller: controller,
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
                timebankModel: timebankModel,
              ),
            ],
          ),
        ),
      ],
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

Widget createJoinedUserTabBar(
  BuildContext context,
  TimebankModel timebankModel,
  String timebankId,
  TabController controller,
) {
  return Scaffold(
    appBar: AppBar(
      elevation: 0.5,
      // backgroundColor: Colors.white,
      title: Text(
        timebankModel.name,
        style: TextStyle(fontSize: 18),
      ),
    ),
    body: Column(
      children: <Widget>[
        TabBar(
          controller: controller,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFFF766FE0),
          indicatorSize: TabBarIndicatorSize.label,
          isScrollable: true,
          tabs: [
            Tab(
              text: AppLocalizations.of(context).translate('homepage', "feeds"),
            ),
            Tab(
              text: AppLocalizations.of(context)
                  .translate('homepage', "projects"),
            ),
            Tab(
              text: AppLocalizations.of(context)
                  .translate('homepage', "requests"),
            ),
            Tab(
              text:
                  AppLocalizations.of(context).translate('homepage', "offers"),
            ),
            Tab(
              text: AppLocalizations.of(context).translate('homepage', "about"),
            ),
            // Tab(
            //   text: "Bookmarked Offers",
            // ),
            Tab(
              text:
                  AppLocalizations.of(context).translate('homepage', "members"),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
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
  );
}

Widget createNormalUserTabBar(
  BuildContext context,
  TimebankModel timebankModel,
  String timebankId,
  TabController controller,
) {
  return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0.5,
        //  backgroundColor: Colors.white,
        title: Text(timebankModel.name),
      ),
      body: Column(
        children: <Widget>[
          TabBar(
            controller: controller,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFF766FE0),
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: false,
            tabs: [
              Tab(
                text:
                    AppLocalizations.of(context).translate('homepage', 'about'),
              ),
              Tab(
                text: AppLocalizations.of(context)
                    .translate('homepage', 'members'),
              )
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: controller,
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
            ),
          ),
        ],
      ));
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
                AppLocalizations.of(context).translate('homepage', 'feeds'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
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
                        AppLocalizations.of(context)
                            .translate('homepage', 'start_feed'),
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
              return Text(
                  AppLocalizations.of(context).translate('homepage', 'gps_on'));
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
                newsList = filterBlockedContent(newsList, context);
                newsList = filterPinnedNews(newsList, context);

                if (newsList.length == 1 && newsList[0].isPinned == true) {
                  return Expanded(
                    child: ListView(
                      children: <Widget>[
                        newFeedsCard(
                          news: newsList.elementAt(0),
                          isFromMessage: false,
                        )
                      ],
                    ),
                  );
                }
                if (newsList.length == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Center(
                        child: Text(AppLocalizations.of(context)
                            .translate('homepage', 'feed_empty'))),
                  );
                }
                return Expanded(
                  child: ListView(
                    children: <Widget>[
                      isPinned
                          ? newFeedsCard(
                              news: pinnedNewsModel,
                              isFromMessage: false,
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
                              return newFeedsCard(
                                news: newsList.elementAt(index),
                                isFromMessage: false,
                              );
                            } else {
                              return newFeedsCard(
                                news: newsList.elementAt(index),
                                isFromMessage: false,
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

    if (filteredNewsList.length > 1) {
      filteredNewsList.removeWhere((news) => news.isPinned == true);
    }

    return filteredNewsList;
  }

  void _showAdminAccessMessage() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(AppLocalizations.of(context)
              .translate('homepage', 'access_denied')),
          content: new Text(
              AppLocalizations.of(context).translate('homepage', 'not_auth')),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                  AppLocalizations.of(context).translate('homepage', 'close')),
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

  Future<File> createFileOfPdfUrl(
      String documentUrl, String documentName) async {
    final url = documentUrl;
    final filename = documentName;
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  void openPdfViewer(String documentUrl, String documentName) {
    createFileOfPdfUrl(documentUrl, documentName).then((f) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFScreen(
                  docName: documentName,
                  pathPDF: f.path,
                  pdf: f,
                )),
      );
    });
  }

  Widget newFeedsCard({NewsModel news, bool isFromMessage}) {
    String loggedinemail = SevaCore.of(context).loggedInUser.email;

    return InkWell(
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
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 12),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                    ),
                    Text(getLocation(news.placeAddress)),
                    Spacer(),
                    Text(
                      timeAgo.format(
                        DateTime.fromMillisecondsSinceEpoch(news.postTimestamp),locale: Locale(AppConfig.prefs.getString('language_code')).toLanguageTag()
                      ),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // SizedBox(height: 16),
              //Pinning ui
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 10, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Text(
                              news.title != null && news.title != "NoData"
                                  ? news.title.trim()
                                  : news.subheading.trim(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 7,
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Europa"),
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
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: NetworkImage(
                          news.userPhotoURL ?? defaultUserImageURL),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            news.fullName != null && news.fullName != ""
                                ? news.fullName.trim()
                                : "User name not available",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 7,
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          document(newsModel: news),
                          //  SizedBox(height: 10),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              //feed image
              news.newsImageUrl == null
                  ? news.imageScraped == null || news.imageScraped == "NoData"
                      ? Offstage()
                      : getImageView(news.id, news.imageScraped)
                  : getImageView(news.id, news.newsImageUrl),

              //feed options

              Padding(
                padding: const EdgeInsets.only(bottom: 0.0, top: 4, right: 15),
                child: !isFromMessage
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          //slot closed
                          Container(
                            child: news.sevaUserId !=
                                    SevaCore.of(context).loggedInUser.sevaUserID
                                ? getOptionButtons(
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      child: Icon(
                                        Icons.flag,
                                        color: news.reports.contains(
                                                SevaCore.of(context)
                                                    .loggedInUser
                                                    .sevaUserID)
                                            ? Colors.red
                                            : Colors.black,
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
                                          builder: (BuildContext viewContextS) {
                                            // return object of type Dialog
                                            return AlertDialog(
                                              title: Text('Already reported!'),
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
                                                    Navigator.of(viewContextS)
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
                                          builder: (BuildContext viewContext) {
                                            // return object of type Dialog
                                            return AlertDialog(
                                              title: Text(
                                                AppLocalizations.of(context)
                                                    .translate(
                                                  'homepage',
                                                  'report_feed',
                                                ),
                                              ),
                                              content: Text(
                                                AppLocalizations.of(context)
                                                    .translate(
                                                  'homepage',
                                                  'want_report',
                                                ),
                                              ),
                                              actions: <Widget>[
                                                FlatButton(
                                                  padding: EdgeInsets.fromLTRB(
                                                      20, 5, 20, 5),
                                                  color: Theme.of(context)
                                                      .accentColor,
                                                  textColor: FlavorConfig
                                                      .values.buttonTextColor,
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                      'homepage',
                                                      'report_feed',
                                                    ),
                                                    style: TextStyle(
                                                      fontSize:
                                                          dialogButtonSize,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    if (news.reports.contains(
                                                        SevaCore.of(context)
                                                            .loggedInUser
                                                            .sevaUserID)) {
                                                      print(
                                                          'already in reports');
                                                    } else {
                                                      if (news
                                                          .reports.isEmpty) {
                                                        news.reports =
                                                            List<String>();
                                                      }
                                                      news.reports.add(
                                                          SevaCore.of(context)
                                                              .loggedInUser
                                                              .sevaUserID);
                                                      Firestore.instance
                                                          .collection('news')
                                                          .document(news.id)
                                                          .updateData({
                                                        'reports': news.reports
                                                      });
                                                    }
                                                    Navigator.of(viewContext)
                                                        .pop();
                                                  },
                                                ),
                                                FlatButton(
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                      'homepage',
                                                      'cancel',
                                                    ),
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(viewContext)
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
                                            news.likes.contains(loggedinemail)
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
                              Set<String> likesList = Set.from(news.likes);
                              news.likes != null &&
                                      news.likes.contains(loggedinemail)
                                  ? likesList.remove(loggedinemail)
                                  : likesList.add(loggedinemail);
                              news.likes = likesList.toList();
                              FirestoreManager.updateNews(newsObject: news);
                            },
                          ),
                        ],
                      )
                    : Center(),
              ),
            ],
          ),
        ),
      ),
    );
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
                          widget.timebankModel.admins.contains(
                                  SevaCore.of(context).loggedInUser.sevaUserID)
                              ? getOptionButtons(
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    child: Container(
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
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: getOptionButtons(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[],
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
                                            ),locale: Locale(AppConfig.prefs.getString('language_code')).toLanguageTag()
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 4),
                      child: !isFromMessage
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: news.sevaUserId !=
                                          SevaCore.of(context)
                                              .loggedInUser
                                              .sevaUserID
                                      ? getOptionButtons(
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            child: Icon(
                                              Icons.flag,
                                              color: news.reports.contains(
                                                      SevaCore.of(context)
                                                          .loggedInUser
                                                          .sevaUserID)
                                                  ? Colors.red
                                                  : Colors.black,
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
                                                  return AlertDialog(
                                                    title: Text(AppLocalizations
                                                            .of(context)
                                                        .translate('homepage',
                                                            'reported_already')),
                                                    content: Text(
                                                        AppLocalizations.of(
                                                                context)
                                                            .translate(
                                                                'homepage',
                                                                'reported_done')),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)
                                                              .translate(
                                                                  'homepage',
                                                                  'ok'),
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
                                                  return AlertDialog(
                                                    title: Text(
                                                        AppLocalizations.of(
                                                                context)
                                                            .translate(
                                                                'homepage',
                                                                'report')),
                                                    content: Text(
                                                        AppLocalizations.of(
                                                                context)
                                                            .translate(
                                                                'homepage',
                                                                'want_report')),
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
                                                          AppLocalizations.of(
                                                                  context)
                                                              .translate(
                                                                  'homepage',
                                                                  'report_feed'),
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
                                                          AppLocalizations.of(
                                                                  context)
                                                              .translate(
                                                                  'shared',
                                                                  'cancel'),
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
                                news.newsDocumentUrl != null
                                    ? getOptionButtons(
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          child: Icon(
                                            Icons.attach_file,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                        ),
                                        () {
                                          openPdfViewer(news.newsDocumentUrl,
                                              news.newsDocumentName);
                                        },
                                      )
                                    : Offstage(),
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
    return Container(
      height: 200,
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
          onTap: onPressed),
    );
  }

  Widget document({NewsModel newsModel}) {
    return newsModel.newsDocumentUrl == null
        ? Offstage()
        : GestureDetector(
            onTap: () {
              openPdfViewer(
                  newsModel.newsDocumentUrl, newsModel.newsDocumentName);
            },
            child: Container(
              height: 30,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(15.7),
                color: Colors.grey[200],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.attach_file,
                      size: 15,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        newsModel.newsDocumentName ?? "Document",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 12),
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
//    return Container(
//      child: newsModel.newsDocumentUrl == null
//          ? Offstage()
//          : GestureDetector(
//              onTap: () => openPdfViewer(
//                  newsModel.newsDocumentUrl, newsModel.newsDocumentName),
//              child: Padding(
//                padding: const EdgeInsets.all(8.0),
//                child: Card(
//                  color: Colors.grey[100],
//                  child: ListTile(
//                    leading: Icon(
//                      Icons.attach_file,
//                      size: 15,
//                    ),
//                    title: Text(
//                      newsModel.newsDocumentName ?? "Document.pdf",
//                      overflow: TextOverflow.ellipsis,
//                      style: TextStyle(fontFamily: 'Europa', fontSize: 12),
//                    ),
//                  ),
//                ),
//              ),
//            ),
//    );
  }

  String getLocation(String location) {
    if (location != null) {
      List<String> l = location.split(',');
      l = l.reversed.toList();
      if (l.length >= 2) {
        return "${l[1]},${l[0]}";
      } else if (l.length >= 1) {
        return "${l[0]}";
      } else {
        print("elasticsearch pjs location result is");
        return "Unknown";
      }
    } else {
      print("elasticsearch pjs location result isggggg");
      return "Unknown";
    }
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
}
