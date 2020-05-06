import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/members_of_timebank.dart';
import 'package:sevaexchange/views/messages/select_timebank_for_news_share.dart';
import 'package:sevaexchange/views/news/news_card_view.dart';
import 'package:sevaexchange/views/timebanks/timebank_view.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
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
            // Expanded(
            //   child: StreamBuilder<Object>(
            //     stream: FirestoreManager.getTimebanksForUserStream(
            //       userId: SevaCore.of(context).loggedInUser.sevaUserID,
            //     ),
            //     builder: (context, snapshot) {
            //       if (snapshot.hasError)
            //         return Text('Please make sure you have GPS turned on.');
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return Center(child: CircularProgressIndicator());
            //       }
            //       timebankList = snapshot.data;
            //       List<String> dropdownList = [];

            //       int adminOfCount = 0;
            //       if (FlavorConfig.values.timebankName == "Yang 2020") {
            //         dropdownList.add("Create Yang Gang");
            //       }
            //       timebankList.forEach((t) {
            //         dropdownList.add(t.id);

            //         if (t.admins.contains(
            //             SevaCore.of(context).loggedInUser.sevaUserID)) {
            //           adminOfCount++;

            //           SevaCore.of(context)
            //               .loggedInUser
            //               .timebankIdForYangGangAdmin = t.id;
            //         }
            //       });

            //       SevaCore.of(context).loggedInUser.associatedWithTimebanks =
            //           dropdownList.length;
            //       SevaCore.of(context).loggedInUser.adminOfYanagGangs =
            //           adminOfCount;

            //       return DropdownButtonHideUnderline(
            //         child: DropdownButton<String>(

            //               isExpanded: false,
            //           value: timebankId,
            //           onChanged: (String newValue) {
            //             if (newValue == "Create Yang Gang") {
            //               createSubTimebank(context);
            //             } else {
            //               setState(() {
            //                 timebankId = newValue;
            //                 SevaCore.of(context).loggedInUser.currentTimebank =
            //                     newValue;
            //                 SevaCore.of(context).loggedInUser.adminOfYanagGangs =
            //                     adminOfCount;

            //                 didChangeDependencies();
            //               });
            //             }
            //           },
            //           items: dropdownList
            //               .map<DropdownMenuItem<String>>((String value) {
            //             if (value == "Create Yang Gang") {
            //               return DropdownMenuItem<String>(
            //                 value: value,
            //                 child: Text(
            //                   value,
            //                   style: TextStyle(color: Colors.red),
            //                 ),
            //               );
            //             } else {
            //               if (value == 'All') {
            //                 return DropdownMenuItem<String>(
            //                   value: value,
            //                   child: Text(value),
            //                 );
            //               } else {
            //                 return DropdownMenuItem<String>(

            //                   value: value,
            //                   child: FutureBuilder<Object>(
            //                       future: FirestoreManager.getTimeBankForId(
            //                           timebankId: value),
            //                       builder: (context, snapshot) {
            //                         if (snapshot.hasError)
            //                           return Text(
            //                               'Please make sure you have GPS turned on.');
            //                         if (snapshot.connectionState ==
            //                             ConnectionState.waiting) {
            //                           return Offstage();
            //                         }
            //                         TimebankModel timebankModel = snapshot.data;
            //                         return Text(
            //                           timebankModel.name,
            //                           maxLines: 1,
            //                           overflow: TextOverflow.ellipsis,
            //                           style: TextStyle(fontSize: 14.0),
            //                         );
            //                       }),
            //                 );
            //               }
            //             }
            //           }).toList(),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            Container(
              width: 105,
              child: CupertinoSegmentedControl<int>(
                children: logoWidgets,
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
                //groupValue: sharedValue,
              ),
            ),

//            RaisedButton(
//              onPressed: () {
//                setState(() {
//                  if (isNearMe == true) {
//                    isNearMe = false;
//                    //globals.nearme = isNearMe;
//                  } else {
//                    isNearMe = true;
//                    //globals.nearme = isNearMe;
//                  }
//                });
//              },
//              child: isNearMe == false ? Text('Near Me') : Text('All'),
//              color: Theme.of(context).accentColor,
//              textColor: Colors.white,
//            ),
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
                            // overflow: TextOverflow.ellipsis,
                            // maxLines: 1,
                            // style: TextStyle(fontWeight: FontWeight.bold),
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
                                ),
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
                                // Expanded(
                                //   child: getOptionButtons(
                                //     Row(
                                //       // mainAxisSize: MainAxisSize.min,
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.start,
                                //       children: <Widget>[
                                //         // SizedBox(width: 16),
                                //         // FlavorConfig.appFlavor ==
                                //         //             Flavor.HUMANITY_FIRST ||
                                //         //         FlavorConfig.appFlavor ==
                                //         //             Flavor.APP
                                //         //     ? Icon(
                                //         //         Icons.perm_contact_calendar,
                                //         //         color: Theme.of(context)
                                //         //             .accentColor,
                                //         //         size: 20,
                                //         //       )
                                //         //     : SvgPicture.asset(
                                //         //         'lib/assets/tulsi_icons/tulsi2020_icons_author-profile-icon.svg',
                                //         //         height: 16,
                                //         //         width: 16,
                                //         //       ),
                                //         // Padding(
                                //         //   padding:
                                //         //       const EdgeInsets.only(left: 5),
                                //         //   child: Text(
                                //         //     news.fullName,
                                //         //     overflow: TextOverflow.ellipsis,
                                //         //     maxLines: 1,
                                //         //     style: TextStyle(
                                //         //       fontSize: 14,
                                //         //     ),
                                //         //   ),
                                //         // ),
                                //       ],
                                //     ),
                                //     () {
                                //       String emailId = news.email;
                                //       Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //           builder: (context) => ProfileViewer(
                                //             userEmail: emailId,
                                //           ),
                                //         ),
                                //       );
                                //     },
                                //   ),
                                // ),
                                news.sevaUserId !=
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
                                                      Flavor.APP
                                              ? Icon(
                                                  Icons.flag,
                                                  size: 20,
                                                )
                                              : SvgPicture.asset(
                                                  'lib/assets/tulsi_icons/tulsi2020_icons_share-icon.svg',
                                                  height: 20,
                                                  width: 20,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                        ),
                                        () {
                                          if (news.reports.contains(
                                              SevaCore.of(context)
                                                  .loggedInUser
                                                  .sevaUserID)) {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (BuildContext viewContextS) {
                                                // return object of type Dialog
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
                                                        'Cancel',
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
                                )
                              ],
                            )
                          : Center(),
                    ),
                  ],
                ),
              ],
            ),
            // !isFromMessage
            //     ? Positioned(
            //         bottom: 8,
            //         right: 8,
            //         child: Material(
            //           color: Colors.white.withAlpha(100),
            //           shape: CircleBorder(),
            //           child:
            //         ),
            //       )
            // : Center(),
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
                // case EntityType.campaign:
                //   loadCampaignForId(context, entityModel.entityId);
                //   break;
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

  // void loadCampaignForId(
  //   BuildContext context,
  //   String campaignId,
  // ) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) {
  //         return CampaignView(
  //           campaignId: campaignId,
  //         );
  //       },
  //     ),
  //   );
  // }
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
