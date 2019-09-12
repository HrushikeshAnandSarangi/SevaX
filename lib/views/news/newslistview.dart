import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:timeago/timeago.dart' as timeAgo;

import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/messages/new_chat.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/timebanks/timebank_view.dart';
import 'package:sevaexchange/views/campaigns/campaignsview.dart';

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
              'Timebank : ',
              style: (TextStyle(fontWeight: FontWeight.w500)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
            ),
            StreamBuilder<Object>(
                stream: FirestoreManager.getTimebanksForUserStream(
                    userId: SevaCore.of(context).loggedInUser.sevaUserID),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  timebankList = snapshot.data;
                  // timebankList.forEach((t){
                  //   if(t.name==timebankName){
                  //     timebankId=t.id;
                  //   }
                  // });
                  List<String> dropdownList = [];
                  timebankList.forEach((t) {
                    dropdownList.add(t.id);
                  });
                  dropdownList.insert(0, 'All');
                  return DropdownButton<String>(
                    value: timebankId,
                    onChanged: (String newValue) {
                      setState(() {
                        timebankId = newValue;
                        //print(timebankId);
                      });
                    },
                    items: dropdownList
                        .map<DropdownMenuItem<String>>((String value) {
                      if (value == 'All') {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      } else
                        return DropdownMenuItem<String>(
                          value: value,
                          child: FutureBuilder<Object>(
                              future: FirestoreManager.getTimeBankForId(
                                  timebankId: value),
                              builder: (context, snapshot) {
                                if (snapshot.hasError)
                                  return new Text('Error: ${snapshot.error}');
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Offstage();
                                }
                                TimebankModel timebankModel = snapshot.data;
                                return Text(timebankModel.name);
                              }),
                        );
                    }).toList(),
                  );
                }),
          ],
        ),
        Divider(
          color: Colors.grey,
          height: 0,
        ),
        timebankId != 'All'
            ? StreamBuilder<List<NewsModel>>(
                stream: FirestoreManager.getNewsStream(timebankID: timebankId),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                      break;
                    default:
                      List<NewsModel> newsList = snapshot.data;
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
            : StreamBuilder<List<NewsModel>>(
                stream: FirestoreManager.getAllNewsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                      break;
                    default:
                      List<NewsModel> newsList = snapshot.data;
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
              ),
      ],
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
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(25),
                  offset: Offset(0, 0),
                  spreadRadius: 8,
                  blurRadius: 10),
            ]),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 250,
                  child: SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: Hero(
                        tag: news.id,
                        child: FadeInImage(
                          fit: BoxFit.fitWidth,
                          placeholder:
                              AssetImage('lib/assets/images/noimagefound.png'),
                          image: NetworkImage(news.newsImageUrl),
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 5),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(news.title,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    )),
                                Text(
                                  news.subheading,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.0),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 16),
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
                                Expanded(
                                  child: getOptionButtons(
                                    Row(
                                      // mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(width: 16),
                                        FlavorConfig.appFlavor ==
                                                    Flavor.HUMANITY_FIRST ||
                                                FlavorConfig.appFlavor ==
                                                    Flavor.APP
                                            ? Icon(
                                                Icons.perm_contact_calendar,
                                                color: Theme.of(context)
                                                    .accentColor,
                                                size: 20,
                                              )
                                            : SvgPicture.asset(
                                                'lib/assets/tulsi_icons/tulsi2020_icons_author-profile-icon.svg',
                                                height: 16,
                                                width: 16,
                                              ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Text(
                                            news.fullName,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
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
                                getOptionButtons(
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    child: FlavorConfig.appFlavor ==
                                                Flavor.HUMANITY_FIRST ||
                                            FlavorConfig.appFlavor == Flavor.APP
                                        ? Icon(
                                            Icons.share,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 20,
                                          )
                                        : SvgPicture.asset(
                                            'lib/assets/tulsi_icons/tulsi2020_icons_share-icon.svg',
                                            height: 20,
                                            width: 20,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                  ),
                                  () {
                                    bool isShare = true;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NewChat(isShare, news),
                                      ),
                                    );
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

  Widget getOptionButtons(Widget child, VoidCallback onPressed) {
    return Material(
      color: Colors.white,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
        onTap: onPressed,
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

class NewsCardView extends StatelessWidget {
  final NewsModel newsModel;

  NewsCardView({Key key, @required this.newsModel}) : super(key: key) {
    assert(newsModel.title != null, 'News title cannot be null');
    assert(newsModel.description != null, 'News description cannot be null');
    assert(newsModel.fullName != null, 'Full name cannot be null');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          newsModel.title,
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              bool isShare = true;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewChat(isShare, newsModel)));
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                child: Text(
                  newsModel.title,
                  style: TextStyle(
                      fontSize: 28.0,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Padding(padding: EdgeInsets.all(5.0)),
                          Text(
                            newsModel.fullName,
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 10.0, 10.0),
                child: Text(
                  timeAgo.format(
                    DateTime.fromMillisecondsSinceEpoch(
                      newsModel.postTimestamp,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
              Container(
                child: newsModel.newsImageUrl != null
                    ? Hero(
                        tag: newsModel.id,
                        child: Image.network(
                          newsModel.newsImageUrl,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset('lib/assets/images/noimagefound.png'),
              ),
              Center(
                child: Container(
                  child: Text(
                    newsModel.photoCredits != null
                        ? 'Credits: ${newsModel.photoCredits}'
                        : '',
                    style:
                        TextStyle(fontSize: 15.0, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      newsModel.description,
                      style: TextStyle(fontSize: 18.0, height: 1.4),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
