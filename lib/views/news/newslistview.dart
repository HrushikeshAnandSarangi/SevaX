import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/members_of_timebank.dart';
import 'package:sevaexchange/views/messages/select_timebank_for_news_share.dart';
import 'package:sevaexchange/views/news/news_card_view.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import '../../flavor_config.dart';
import '../core.dart';

class NewsListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NewsList();
  }
}

class NewsList extends StatefulWidget {
  @override
  NewsListState createState() => NewsListState();
}

class NewsListState extends State<NewsList> {
  String timebankName;
  String timebankId = FlavorConfig.values.timebankId;
  List<TimebankModel> timebankList = [];
  bool isNearMe = false;
  int sharedValue = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10),
            ),
            Text(
              FlavorConfig.values.timebankTitle,
              style: (TextStyle(fontWeight: FontWeight.w500)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
            ),
            Expanded(
              child: Text(''),
            ),
            Container(
              width: 105,
              child: CupertinoSegmentedControl<int>(
                children: {
                  0: Text(
                    AppLocalizations.of(context).translate('shared', 'all'),
                    style: TextStyle(fontSize: 10.0),
                  ),
                  1: Text(
                    AppLocalizations.of(context).translate('shared', 'near_me'),
                    style: TextStyle(fontSize: 10.0),
                  ),
                },
                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                selectedColor: Color.fromARGB(255, 4, 47, 110),
                groupValue: sharedValue,
                onValueChanged: (int val) {
                  print(val);
                  if (val != sharedValue) {
                    if (val == 0) {
                      setState(() {
                        isNearMe = false;
                      });
                    } else {
                      setState(() {
                        isNearMe = true;
                      });
                    }

                    setState(() {
                      sharedValue = val;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 5),
            ),
          ],
        ),
        Divider(
          color: Colors.grey,
          height: 0,
        ),
        timebankId != 'All' && isNearMe == false
            ? StreamBuilder<List<NewsModel>>(
                stream: FirestoreManager.getNewsStream(timebankID: timebankId),
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

                      newsList = filterBlockedContent(newsList, context);
                      print("Size of incloming docs ${newsList.length}");
                      if (newsList.length == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text('Your feed is empty')),
                        );
                      }
                      return Expanded(
                        child: ListView.builder(
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
                              print(
                                  "newsListSize = ${newsList.length} --index  $index");
                              return getNewsCard(
                                newsList.elementAt(index),
                                false,
                              );
                            }
                          },
                        ),
                      );
                  }
                },
              )
            : timebankId == 'All' && isNearMe == false
                ? StreamBuilder<List<NewsModel>>(
                    stream: FirestoreManager.getAllNewsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return new Text(
                            'Please make sure you have GPS turned on.');
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                          break;
                        default:
                          List<NewsModel> newsList = snapshot.data;
                          newsList = filterBlockedContent(newsList, context);

                          if (newsList.length == 0) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text('Your feed is empty')),
                            );
                          }
                          return Expanded(
                            child: ListView.builder(
                              itemCount: newsList.length,
                              itemBuilder: (context, index) {
                                return getNewsCard(
                                    newsList.elementAt(index), false);
                              },
                            ),
                          );
                      }
                    },
                  )
                : timebankId != 'All' && isNearMe == true
                    ? StreamBuilder<List<NewsModel>>(
                        stream: FirestoreManager.getNearNewsStream(
                            timebankID: timebankId),
                        builder: (context, snapshot) {
                          print(
                              "Getting news stream for near me ${snapshot.connectionState}");

                          if (snapshot.hasError)
                            return Text(
                                'Please make sure you have GPS turned on.');
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Center(child: CircularProgressIndicator());
                              break;
                            default:
                              List<NewsModel> newsList = snapshot.data;

                              print(
                                  "News list from near me ${newsList.length}");
                              newsList =
                                  filterBlockedContent(newsList, context);

                              if (newsList.length == 0) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      Center(child: Text('Your feed is empty')),
                                );
                              }
                              return Expanded(
                                child: ListView.builder(
                                  itemCount: newsList.length,
                                  itemBuilder: (context, index) {
                                    return getNewsCard(
                                        newsList.elementAt(index), false);
                                  },
                                ),
                              );
                          }
                        },
                      )
                    : timebankId == 'All' && isNearMe == true
                        ? StreamBuilder<List<NewsModel>>(
                            stream: FirestoreManager.getAllNearNewsStream(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError)
                                return Text(
                                    'Please make sure you have GPS turned on.');
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Center(
                                      child: CircularProgressIndicator());
                                  break;
                                default:
                                  List<NewsModel> newsList = snapshot.data;
                                  newsList =
                                      filterBlockedContent(newsList, context);

                                  if (newsList.length == 0) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                          child: Text('Your feed is empty')),
                                    );
                                  }
                                  return Expanded(
                                    child: ListView.builder(
                                      itemCount: newsList.length,
                                      itemBuilder: (context, index) {
                                        return getNewsCard(
                                            newsList.elementAt(index), false);
                                      },
                                    ),
                                  );
                              }
                            },
                          )
                        : Offstage(),
      ],
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
        margin: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                offset: Offset(0, 0),
                spreadRadius: 8,
                blurRadius: 10,
              ),
            ]),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(5),
                      height: 40,
                      width: 40,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          news.userPhotoURL == null
                              ? defaultUserImageURL
                              : news.userPhotoURL,
                        ),
                        minRadius: 40.0,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Text(
                            news.fullName.trim(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5, right: 40),
                          child: Text(
                            news.placeAddress == null
                                ? ""
                                : news.placeAddress.trim(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                news.newsImageUrl == null
                    ? news.imageScraped == null || news.imageScraped == "NoData"
                        ? Offstage()
                        : getImageView(news.id, news.imageScraped)
                    : getImageView(news.id, news.newsImageUrl),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 5),
                      child: Row(
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.0),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 12),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              timeAgo.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  news.postTimestamp,
                                ), locale: Locale(AppConfig.prefs.getString('language_code')).toLanguageTag()
                              ),
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 4),
                      child: !isFromMessage
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                news.sevaUserId !=
                                        SevaCore.of(context)
                                            .loggedInUser
                                            .sevaUserID
                                    ? getOptionButtons(
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            child: Icon(
                                              Icons.flag,
                                              size: 20,
                                            )),
                                        () {
                                          if (news.reports.contains(
                                              SevaCore.of(context)
                                                  .loggedInUser
                                                  .sevaUserID)) {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (BuildContext viewContextS) {
                                                return AlertDialog(
                                                  title:
                                                      Text('Already reported!'),
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
                                                return AlertDialog(
                                                  title: Text(AppLocalizations.of(context).translate('homepage', 'report')),
                                                  content: Text(AppLocalizations.of(context).translate('homepage', 'want_report')),
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
                                                        AppLocalizations.of(context).translate('homepage', 'report_feed'),
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
                                                                List<String>();
                                                          }
                                                          news.reports.add(
                                                              SevaCore.of(
                                                                      context)
                                                                  .loggedInUser
                                                                  .sevaUserID);
                                                          Firestore.instance
                                                              .collection(
                                                                  'news')
                                                              .document(news.id)
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
                                                        AppLocalizations.of(context).translate('shared', 'cancel'),
                                                        style: TextStyle(
                                                            color: Colors.red),
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
                                getOptionButtons(
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    child: Icon(
                                      Icons.share,
                                      color: Theme.of(context).primaryColor,
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
                                )
                              ],
                            )
                          : Center(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
              image: NetworkImage(
                urlToLoad ?? defaultUserImageURL,
              ),
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
        onTap: onPressed,
      ),
    );
  }

//  Widget chipForNews(BuildContext context, NewsModel newsModel) {
//    assert(newsModel != null, 'News model cannot be null');
//
//    Color chipColor;
//    Color chipTextColor;
//
//    if (newsModel.entity == null) {
//      chipColor = null;
//    } else if (newsModel.entity.entityType == EntityType.timebank) {
//      chipColor = Colors.indigoAccent;
//      chipTextColor = Colors.white;
//    } else if (newsModel.entity.entityType == EntityType.campaign) {
//      chipColor = Colors.deepOrangeAccent;
//      chipTextColor = Colors.white;
//    } else {
//      chipColor = Colors.amberAccent;
//    }
//
//    String chipText;
//    if (newsModel.entity == null) {
//      chipText = null;
//    } else {
//      chipText = newsModel.entity.entityName ?? 'General';
//    }
//
//    return chipText == null
//        ? Container()
//        : GestureDetector(
//            onTap: () async {
//              if (newsModel.entity == null) return;
//              if (newsModel.entity.entityType == EntityType.general) return;
//              EntityModel entityModel = newsModel.entity;
//              switch (entityModel.entityType) {
//                case EntityType.timebank:
//                  loadTimebankForId(context, entityModel.entityId);
//                  break;
//
//                default:
//                  break;
//              }
//            },
//            child: Chip(
//              padding: EdgeInsets.symmetric(horizontal: 8.0),
//              label: Text(
//                chipText,
//                style: TextStyle(color: chipTextColor),
//              ),
//              backgroundColor: chipColor,
//            ),
//          );
//  }
//
//  void loadTimebankForId(
//    BuildContext context,
//    String timebankId,
//  ) {
//    Navigator.of(context).push(
//      MaterialPageRoute(
//        builder: (BuildContext routeContext) {
//          return TimebankView(
//            timebankId: timebankId,
//          );
//        },
//      ),
//    );
//  }
//}
}

Future _getLocation(
  double latitude,
  double longitude,
) async {
  String address = await LocationUtility().getFormattedAddress(
    latitude,
    longitude,
  );

  return address;
}
