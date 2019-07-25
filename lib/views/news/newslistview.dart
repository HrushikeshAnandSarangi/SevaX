import 'package:flutter/material.dart';

import 'package:timeago/timeago.dart' as timeAgo;

import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart'
    as FirestoreManager;
import 'package:sevaexchange/views/timebanks/timebank_view.dart';
import 'package:sevaexchange/views/campaigns/campaignsview.dart';

class NewsListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NewsList();
  }
}

class NewsList extends StatefulWidget {
  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NewsModel>>(
      stream: FirestoreManager.getNewsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
            break;
          default:
            List<NewsModel> newsList = snapshot.data;
            if (newsList.length == 0) {
              return Center(child: Text('Your feed is empty'));
            }
            return ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                return getNewsCard(
                  newsList.elementAt(index),
                );
              },
            );
        }
      },
    );
  }

  Widget getNewsCard(NewsModel news) {
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
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(25),
                  offset: Offset(0, 0),
                  spreadRadius: 8,
                  blurRadius: 10),
            ]),
        child: Column(
          children: <Widget>[
            Container(
              height: 250,
              child: SizedBox.expand(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
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
                  padding: const EdgeInsets.only(left: 16.0),
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
                      IconButton(
                        icon: Icon(Icons.bookmark_border),
                        onPressed: () {},
                      )
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: FlatButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.reply,
                          color: Colors.green,
                          size: 20,
                        ),
                        label: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('Share',
                              style: TextStyle(
                                fontSize: 14,
                              )),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.perm_contact_calendar,
                      color: Colors.indigo,
                      size: 20,
                    ),
                    SizedBox(width: 8.0),
                    SizedBox(
                      width: 100,
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
              ],
            ),
          ],
        ),
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
          style: TextStyle(fontSize: 16.0,color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {},
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
