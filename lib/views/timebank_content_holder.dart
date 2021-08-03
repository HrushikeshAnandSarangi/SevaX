import 'dart:async';
import 'dart:collection';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/components/common_help_icon.dart';
import 'package:sevaexchange/components/pdf_screen.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/enums/help_context_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/bloc/share_feed_bloc_component.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/states/share_feed_screen.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/members/bloc/members_bloc.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_router.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_listing_page.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/members_of_timebank.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/messages/select_timebank_for_news_share.dart';
import 'package:sevaexchange/views/news/news_card_view.dart';
import 'package:sevaexchange/views/news/newscreate.dart';
import 'package:sevaexchange/views/project_view/timebank_projects_view.dart';
import 'package:sevaexchange/views/timebanks/group_manage_seva.dart';
import 'package:sevaexchange/views/timebanks/timebank_view_latest.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/empty_widget.dart';
import 'package:sevaexchange/widgets/umeshify.dart';
import 'package:sevaexchange/widgets/user_profile_image.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:url_launcher/url_launcher.dart';

import '../flavor_config.dart';
import 'core.dart';

enum AboutUserRole { ADMIN, JOINED_USER, NORMAL_USER }

class TabarView extends StatefulWidget {
  final UserModel userModel;

  final TimebankModel timebankModel;

  TabarView({this.timebankModel, this.userModel});

  @override
  _TabarViewState createState() => _TabarViewState();
}

class _TabarViewState extends State<TabarView> with TickerProviderStateMixin {
  TimebankModel timebankModel;
  TabController controller;

  @override
  void initState() {
    timebankModel = widget.timebankModel;
    AppConfig.helpIconContextMember = HelpContextMemberType.groups;
    AppConfig.timebankConfigurations =
        widget.timebankModel.timebankConfigurations ?? getConfigurationModel();

    var tempRole = determineUserRoleInAbout(
      sevaUserId: widget.userModel.sevaUserID,
      timeBankModel: timebankModel,
    );
    switch (tempRole) {
      case AboutUserRole.ADMIN:
        controller = TabController(vsync: this, length: 7);
        break;
      case AboutUserRole.JOINED_USER:
        controller = TabController(vsync: this, length: 6);
        break;
      case AboutUserRole.NORMAL_USER:
        controller = TabController(vsync: this, length: 2);
        break;
      default:
        controller = TabController(vsync: this, length: 2);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getUserRole(
      determineUserRoleInAbout(
        sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        timeBankModel: timebankModel,
      ),
      context,
      timebankModel,
      widget.timebankModel.id,
      this,
    );
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
        return createAdminTabBar(
          context,
          timebankModel,
          timebankId,
          controller,
        );

      case AboutUserRole.JOINED_USER:
        return createJoinedUserTabBar(
          context,
          timebankModel,
          timebankId,
          controller,
        );

      case AboutUserRole.NORMAL_USER:
        return createNormalUserTabBar(
          context,
          timebankModel,
          timebankId,
          controller,
        );

      default:
        return createNormalUserTabBar(
          context,
          timebankModel,
          timebankId,
          controller,
        );
    }
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
      leading: BackButton(
        onPressed: () {
          AppConfig.helpIconContextMember = HelpContextMemberType.seva_community;
          Navigator.pop(context);
        },
      ),
      elevation: 0.5,
      centerTitle: true,
      title: Text(
        timebankModel.name,
        style: TextStyle(fontSize: 18),
      ),
      actions: [
        CommonHelpIconWidget(),
      ],
    ),
    body: Column(
      children: <Widget>[
        // ShowLimitBadge(),
        TabBar(
          onTap: (int index) {
            switch (index) {
              case 1:
                AppConfig.helpIconContextMember = HelpContextMemberType.events;
                break;
              case 2:
                AppConfig.helpIconContextMember = HelpContextMemberType.requests;
                break;
              case 3:
                AppConfig.helpIconContextMember = HelpContextMemberType.offers;
                break;
              default:
                AppConfig.helpIconContextMember = HelpContextMemberType.groups;
                break;
            }
            logger.i(
                "tabbar index group scope tapped is $index with ${AppConfig.helpIconContextMember}");
          },
          controller: controller,
          labelPadding: EdgeInsets.symmetric(horizontal: 10),
          labelColor: Theme.of(context).primaryColor,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          unselectedLabelColor: Colors.black,
          isScrollable: true,
          tabs: [
            Tab(
              text: S.of(context).feeds,
            ),
            Tab(
              text: S.of(context).projects,
            ),
            Tab(
              text: S.of(context).requests,
            ),
            Tab(
              text: S.of(context).offers,
            ),
            Tab(
              text: S.of(context).about,
            ),
            Tab(
              text: S.of(context).members,
            ),
            Tab(
              text: S.of(context).manage,
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
              RequestListingPage(
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
                userId: SevaCore.of(context).loggedInUser.sevaUserID,
              ),
              MembersPage(
                timebankId: timebankModel.id,
              ),
              ManageGroupView.of(
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
      child: Container(
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(7.5),
        ),
        constraints: BoxConstraints(
          minWidth: 15,
          minHeight: 15,
        ),
        child: Text(
          count.toString(),
          style: TextStyle(
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
      leading: BackButton(
        color: Colors.black,
        onPressed: () {
          AppConfig.helpIconContextMember = HelpContextMemberType.seva_community;
          Navigator.pop(context);
        },
      ),
      elevation: 0.5,
      // backgroundColor: Colors.white,
      title: Text(
        timebankModel.name,
        style: TextStyle(fontSize: 18),
      ),
      actions: [
        CommonHelpIconWidget(),
      ],
    ),
    body: Column(
      children: <Widget>[
        TabBar(
          controller: controller,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.black,
          indicatorColor: Color(0xFFF766FE0),
          indicatorSize: TabBarIndicatorSize.label,
          isScrollable: true,
          onTap: (index) {
            switch (index) {
              case 1:
                AppConfig.helpIconContextMember = HelpContextMemberType.events;
                break;
              case 2:
                AppConfig.helpIconContextMember = HelpContextMemberType.requests;
                break;
              case 3:
                AppConfig.helpIconContextMember = HelpContextMemberType.offers;
                break;
              default:
                AppConfig.helpIconContextMember = HelpContextMemberType.groups;
                break;
            }
            logger.i(
                "tabbar index group scope tapped is $index with ${AppConfig.helpIconContextMember}");
          },
          tabs: [
            Tab(
              text: S.of(context).feeds,
            ),
            Tab(
              text: S.of(context).projects,
            ),
            Tab(
              text: S.of(context).requests,
            ),
            Tab(
              text: S.of(context).offers,
            ),
            Tab(
              text: S.of(context).about,
            ),
            Tab(
              text: S.of(context).members,
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
              RequestListingPage(
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
                userId: SevaCore.of(context).loggedInUser.sevaUserID,
              ),
              // AcceptedOffers(
              //   sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
              //   timebankId: timebankModel.id,
              // ),
              MembersPage(
                timebankId: timebankModel.id,
              ),
              // TimebankRequestAdminPage(
              //   isUserAdmin: isAccessAvailable(timebankModel,
              //           SevaCore.of(context).loggedInUser.sevaUserID) ||
              //       timebankModel.organizers.contains(
              //         SevaCore.of(context).loggedInUser.sevaUserID,
              //       ),
              //   timebankId: timebankModel.id,
              //   userEmail: SevaCore.of(context).loggedInUser.email,
              //   isFromGroup: true,
              // ),
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
          color: Colors.black,
          onPressed: () {
            AppConfig.helpIconContextMember = HelpContextMemberType.seva_community;
            Navigator.pop(context);
          },
        ),
        elevation: 0.5,

        //  backgroundColor: Colors.white,
        title: Text(timebankModel.name),
        actions: [
          CommonHelpIconWidget(),
        ],
      ),
      body: Column(
        children: <Widget>[
          TabBar(
            controller: controller,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.black,
            indicatorColor: Color(0xFFF766FE0),
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: false,
            tabs: [
              Tab(
                text: S.of(context).about,
              ),
              Tab(
                text: S.of(context).members,
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
                  userId: SevaCore.of(context).loggedInUser.sevaUserID,
                ),
                MembersPage(
                  timebankId: timebankModel.id,
                ),
              ],
            ),
          ),
        ],
      ));
}

AboutUserRole determineUserRoleInAbout({String sevaUserId, TimebankModel timeBankModel}) {
  if (isAccessAvailable(timeBankModel, sevaUserId)) {
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
  StreamController<List<NewsModel>> newsStream;
  List<String> sortOrderArr = ["Latest", "Likes"];
  String sortOrderVal = "Latest";
  SearchSegmentBloc searchSegmentBloc;
  List<UserModel> membersInTimebank = [];

  @override
  void initState() {
    newsStream = StreamController();

    FirestoreManager.getNewsStream(
      timebankID: widget.timebankId,
    ).listen((event) {
      newsStream.add(event);
    });

    super.initState();
  }

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
                S.of(context).feeds,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              Spacer(),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  style: TextStyle(color: Colors.white),
                  focusColor: Colors.white,
                  iconEnabledColor: FlavorConfig.values.theme.primaryColor,
                  value: sortOrderVal,
                  onChanged: (val) {
                    if (val != sortOrderVal) {
                      sortOrderVal = val;
                      setState(() {});
                    }
                  },
                  items: List.generate(
                    sortOrderArr.length,
                    (index) => DropdownMenuItem(
                      value: sortOrderArr[index],
                      child: Text(
                        sortOrderArr[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: 'Europa',
                          color: FlavorConfig.values.theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.white,
          height: 0,
        ),
        ConfigurationCheck(
          actionType: 'create_feeds',
          role: memberType(widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
          child: InkWell(
            onTap: () {
              if (widget.timebankModel.id == FlavorConfig.values.timebankId &&
                  !isAccessAvailable(
                      widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID)) {
                showAdminAccessMessage(context: context);
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NewsCreate(
                          timebankId: widget.timebankId,
                          timebankModel: widget.timebankModel,
                        )));
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        SevaCore.of(context).loggedInUser.photoURL ?? defaultUserImageURL),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.7),
                        color: Colors.grey[200],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          S.of(context).start_new_post,
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
        ),
        StreamBuilder<List<NewsModel>>(
          stream: newsStream.stream,
          builder: (context, snapshot) {
            // logger.i("Stream Updated==================================<<" +
            //     DateTime.now().toString());

            if (snapshot.hasError)
              return Text(
                S.of(context).gps_on_reminder,
              );
            if (!snapshot.hasData)
              return Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
                child: LoadingIndicator(),
              );

            List<NewsModel> newsList = snapshot.data;

            if (sortOrderVal.toLowerCase() == SortOrderClass.LIKES.toLowerCase()) {
              newsList.sort((a, b) => b.likes.length.compareTo(a.likes.length));
            } else {
              newsList.sort((a, b) => b.postTimestamp.compareTo(a.postTimestamp));
            }
            newsList = filterBlockedContent(newsList, context);
            newsList = filterPinnedNews(newsList, context);

            // return Text(newsList.length.toString() + ' length');

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
              return EmptyWidget(
                title: S.of(context).no_posts_title,
                sub_title: S.of(context).no_posts_description,
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
                      // return Text(snapshot.data.length.toString() + ' length');

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
          },
        )
      ],
    );
  }

  List<NewsModel> filterPinnedNews(List<NewsModel> newsList, BuildContext context) {
    List<NewsModel> filteredNewsList = [];
    filteredNewsList = newsList;
    isPinned = false;
    filteredNewsList.forEach((newsModel) {
      if (newsModel.isPinned) {
        //  filteredNewsList.remove(newsModel);
        //  filteredNewsList.insert(0, newsModel);

        pinnedNewsModel = null;
        pinnedNewsModel = newsModel;
        isPinned = true;
      }
    });

    if (filteredNewsList.length > 1) {
      filteredNewsList.removeWhere((news) => news.isPinned == true);
    }

    return filteredNewsList;
  }

  List<NewsModel> filterBlockedContent(List<NewsModel> newsList, BuildContext context) {
    List<NewsModel> filteredNewsList = [];

    newsList.forEach((news) {
      SevaCore.of(context).loggedInUser.blockedMembers.contains(news.sevaUserId) ||
              SevaCore.of(context).loggedInUser.blockedBy.contains(news.sevaUserId)
          ? logger.i("Removed blocked content")
          : filteredNewsList.add(news);
    });
    return filteredNewsList;
  }

  void openPdfViewer(String documentUrl, String documentName) {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    progressDialog.show();
    createFileOfPdfUrl(documentUrl, documentName).then((f) {
      progressDialog.hide();

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFScreen(
                  docName: documentName,
                  pathPDF: f.path,
                  isFromFeeds: true,
                )),
      );
    });
  }

  Widget newFeedsCard({NewsModel news, bool isFromMessage}) {
    String loggedinemail = SevaCore.of(context).loggedInUser.email;
    var feedAddress = getLocation(news.placeAddress ?? '');

    return InkWell(
      key: ValueKey(news.id),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_context) {
              return BlocProvider(
                bloc: BlocProvider.of<HomeDashBoardBloc>(context),
                child: NewsCardView(
                  newsModel: news,
                  isFocused: false,
                  timebankModel: widget.timebankModel,
                ),
              );
            },
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.only(
                                top: 5,
                              ),
                              child: Row(
                                children: <Widget>[
                                  feedAddress != null && feedAddress != ''
                                      ? Icon(
                                          Icons.location_on,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      : Container(),
                                  feedAddress != null && feedAddress != ''
                                      ? Text(feedAddress)
                                      : Container(),
                                  Spacer(),
                                  Text(
                                    timeAgo.format(
                                        DateTime.fromMillisecondsSinceEpoch(news.postTimestamp),
                                        locale: Locale(AppConfig.prefs.getString('language_code'))
                                            .toLanguageTag()),
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              //Pinning ui

              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    UserProfileImage(
                      photoUrl: news.userPhotoURL,
                      email: news.email,
                      userId: news.sevaUserId,
                      height: 40,
                      width: 40,
                      timebankModel: widget.timebankModel,
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
                                : S.of(context).user_name_not_availble,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 7,
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          document(
                              newsDocumentName: news.newsDocumentName,
                              newsDocumentUrl: news.newsDocumentUrl),
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
              Padding(
                key: ValueKey(news.subheading),
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
                            child: Umeshify(
                              text: news.subheading != null && news.subheading != ""
                                  ? news.subheading.trim()
                                  : '',
                              onOpen: (url) async {
                                if (await canLaunch(url)) {
                                  launch(url);
                                } else {
                                  logger.e("could not launch");
                                }
                              },
                            ),
                          ),
                          // scraped Data
                          Container(
                            key: ValueKey(news.title),
                            margin: EdgeInsets.only(top: 5),
                            child: Umeshify(
                              text: news.title != null && news.title != "NoData"
                                  ? news.title.trim()
                                  : '',
                              onOpen: (url) async {
                                if (await canLaunch(url)) {
                                  launch(url);
                                } else {
                                  logger.e("could not launch");
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    isAccessAvailable(
                            widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID)
                        ? getOptionButtons(
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Container(
                                height: 20,
                                width: 20,
                                child: Image.asset(
                                  'lib/assets/images/pin.png',
                                  color: news.isPinned ? Colors.green : Colors.black,
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
                            child: news.sevaUserId != SevaCore.of(context).loggedInUser.sevaUserID
                                ? getOptionButtons(
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      child: Icon(
                                        Icons.flag,
                                        color: news.reports.contains(
                                                SevaCore.of(context).loggedInUser.sevaUserID)
                                            ? Colors.red
                                            : Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                    () {
                                      if (news.reports
                                          .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext viewContextS) {
                                            // return object of type Dialog
                                            return AlertDialog(
                                              title: Text(S.of(context).already_reported),
                                              content: Text(S.of(context).feed_reported),
                                              actions: <Widget>[
                                                CustomTextButton(
                                                  child: Text(
                                                    S.of(context).ok,
                                                    style: TextStyle(
                                                      fontSize: dialogButtonSize,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(viewContextS).pop();
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
                                              title: Text(S.of(context).report_feed),
                                              content: Text(
                                                S.of(context).report_feed_confirmation_message,
                                              ),
                                              actions: <Widget>[
                                                CustomTextButton(
                                                  color: HexColor("#d2d2d2"),
                                                  textColor: Colors.white,
                                                  child: Text(
                                                    S.of(context).cancel,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(viewContext).pop();
                                                  },
                                                ),
                                                CustomTextButton(
                                                  color: Theme.of(context).accentColor,
                                                  textColor: Colors.white,
                                                  child: Text(
                                                    S.of(context).report_feed,
                                                    style: TextStyle(
                                                      fontSize: dialogButtonSize,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    if (news.reports.contains(SevaCore.of(context)
                                                        .loggedInUser
                                                        .sevaUserID)) {
                                                    } else {
                                                      if (news.reports.isEmpty) {
                                                        news.reports = [];
                                                      }
                                                      CollectionRef.feeds.doc(news.id).update({
                                                        'reports': FieldValue.arrayUnion([
                                                          SevaCore.of(context)
                                                              .loggedInUser
                                                              .sevaUserID
                                                        ])
                                                      });
                                                    }
                                                    Navigator.of(viewContext).pop();
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
                          ShareFeedsComponent(
                            feedToShare: news,
                            timebankId: widget.timebankId,
                            searchSegmentBloc: getSearchBlocForShare(),
                            loggedInUser: SevaCore.of(context).loggedInUser,
                          ),

                          getOptionButtons(
                            Row(
                              children: <Widget>[
                                Text('${news.likes.length}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Center(
                                    child: news.likes != null && news.likes.contains(loggedinemail)
                                        ? Icon(
                                            Icons.favorite,
                                            size: 24,
                                            color: Color(0xFFec444b),
                                          )
                                        : Icon(
                                            Icons.favorite_border,
                                            size: 24,
                                            color: Color(0xFFec444b),
                                          ),
                                  ),
                                ),

                                Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('${news.comments.length}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            )))),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_context) => BlocProvider(
                                          bloc: BlocProvider.of<HomeDashBoardBloc>(context),
                                          child: NewsCardView(
                                            newsModel: news,
                                            isFocused: false,
                                            timebankModel: widget.timebankModel,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 3),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(S.of(context).comments,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54,
                                              )))),
                                ),
                              ],
                            ),
                            () {
                              Set<String> likesList = Set.from(news.likes);
                              news.likes != null && news.likes.contains(loggedinemail)
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

  SearchSegmentBloc getSearchBlocForShare() {
    if (membersInTimebank.length == 0) {
      TimebankModel currentTimebankModel;

      final _membersBloc = Provider.of<MembersBloc>(context, listen: false);
      final _homePageBaseBloc = Provider.of<HomePageBaseBloc>(context, listen: false);
      currentTimebankModel =
          _homePageBaseBloc.getTimebankModelFromCurrentCommunity(widget.timebankId);

      currentTimebankModel.members.forEach((element) {
        membersInTimebank.add(
          _membersBloc.getMemberFromLocalData(
            userId: element,
          ),
        );
      });

      searchSegmentBloc = SearchSegmentBloc();
      searchSegmentBloc.init(listOfMembersInTimebank: membersInTimebank);
    }
    return searchSegmentBloc;
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

  Widget document({String newsDocumentUrl, String newsDocumentName}) {
    return newsDocumentUrl == null
        ? Offstage()
        : GestureDetector(
            onTap: () {
              openPdfViewer(newsDocumentUrl, newsDocumentName);
            },
            child: Container(
              height: 30,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.7),
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
                        newsDocumentName ?? S.of(context).document,
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
        return null;
      }
    } else {
      return null;
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
