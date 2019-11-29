import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/news/edit_news.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/views/messages/new_chat.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsCardView extends StatelessWidget {
  final NewsModel newsModel;

  NewsCardView({Key key, @required this.newsModel}) : super(key: key) {
    // assert(newsModel.title != null, 'News title cannot be null');
    // assert(newsModel.description != null, 'News description cannot be null');
    // assert(newsModel.fullName != null, 'Full name cannot be null');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          newsModel.title == null ? newsModel.fullName : newsModel.title,
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        actions: <Widget>[
          _getDeleteButton(context),
          // IconButton(
          //   icon: Icon(Icons.share),
          //   onPressed: () => _shareNews(context),
          // ),
          //shadowing for now as edit feed is not yet completed
          // newsModel.sevaUserId == SevaCore.of(context).loggedInUser.sevaUserID
          //     ? IconButton(
          //         icon: Icon(Icons.edit),
          //         onPressed: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) => NewsEdit(
          //                 newsModel: newsModel,
          //                 timebankId:
          //                     SevaCore.of(context).loggedInUser.currentTimebank,
          //               ),
          //             ),
          //           );
          //         },
          //       )
          //     : Offstage()
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              newsAuthorAndDate,
              newsModel.title == null || newsModel.title == "NoData"
                  ? Offstage()
                  : newsTitle,
              newsImage,
              photoCredits,
              subHeadings,
              tags,
              listOfHashTags,
              listOfLinks
            ],
          ),
        ),
      ),
    );
  }

  Widget _getDeleteButton(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: AuthProvider.of(context).auth.getLoggedInUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Offstage();
        if (snapshot.hasError || !snapshot.hasData) return Offstage();
        UserModel user = snapshot.data;
        if (user.sevaUserID != newsModel.sevaUserId) return Offstage();
        return IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            _deleteNews(context);
            // _showDeleteConfirmationDialog(context);
          },
        );
      },
    );
  }

  Widget get newsTitle {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
      child: newsModel.title == null || newsModel.title == "NoData"
          ? Offstage()
          : Text(
              newsModel.title.trim(),
              style: TextStyle(
                  fontSize: 28.0,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget get listOfHashTags {
    if (newsModel.hashTags.length > 0) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: newsModel.hashTags.map((hash) {
              // final _random = new Random();
              // var element = colorList[_random.nextInt(colorList.length)];
              return chip(hash, false);
            }).toList(),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(5.0),
    );
  }

  Widget chip(
    String value,
    bool selected,
  ) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.white.withAlpha(0),
        child: InkWell(
          customBorder: StadiumBorder(),
          onTap: () {},
          child: Material(
            elevation: selected ? 3 : 0,
            shape: StadiumBorder(),
            child: AnimatedContainer(
              curve: Curves.easeIn,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              duration: Duration(milliseconds: 250),
              decoration: ShapeDecoration(
                shape: StadiumBorder(),
                color: selected ? Colors.black : null,
              ),
              child: AnimatedCrossFade(
                duration: Duration(milliseconds: 250),
                crossFadeState: selected
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Text(
                  value,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                secondChild: Text(
                  value,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get listOfLinks {
    if (newsModel.urlsFromPost.length > 0) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: newsModel.urlsFromPost.map((link) {
              // final _random = new Random();
              // var element = colorList[_random.nextInt(colorList.length)];
              return chipForLinks(link, false);
            }).toList(),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(5.0),
    );
  }

  Widget chipForLinks(
    String value,
    bool selected,
  ) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.white.withAlpha(0),
        child: InkWell(
          customBorder: StadiumBorder(),
          onTap: () async {
            // print("Here is the value : $value");
            if (await canLaunch(value)) {
              await launch(value);
            } else {
              throw 'Could not launch $value';
            }
          },
          child: Material(
            elevation: selected ? 3 : 0,
            shape: StadiumBorder(),
            child: AnimatedContainer(
              curve: Curves.easeIn,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              duration: Duration(milliseconds: 250),
              decoration: ShapeDecoration(
                shape: StadiumBorder(),
                color: selected ? Colors.blue : null,
              ),
              child: AnimatedCrossFade(
                duration: Duration(milliseconds: 250),
                crossFadeState: selected
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Text(value,
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis),
                secondChild: Text(value,
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get newsAuthorAndDate {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 5, 5, 15),
            height: 40,
            width: 40,
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                newsModel.userPhotoURL == null
                    ? 'https://secure.gravatar.com/avatar/b10f7ddbf9b8be9e3c46c302bb20101d?s=400&d=mm&r=g'
                    : newsModel.userPhotoURL,
              ),
              minRadius: 40.0,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 5, left: 5),
                child: Text(
                  newsModel.fullName,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5),
                child: Text(
                  _getFormattedTime(newsModel.postTimestamp),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget get newsImage {

    return newsModel.newsImageUrl == null
        ? newsModel.imageScraped == null || newsModel.imageScraped == "NoData"
            ? Offstage()
            : getImageView(url: newsModel.imageScraped, imageId: newsModel.id)
        : getImageView(url: newsModel.newsImageUrl, imageId: newsModel.id);
  }

  Widget getImageView({
    String url,
    String imageId,
  }) {
    print("______________________________>" + url);

    return Container(
      margin: EdgeInsets.all(5),
      child: url != null
          ? Hero(
              tag: imageId,
              child: Image.network(
                url,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset('lib/assets/images/noimagefound.png'),
    );
  }

  Widget get photoCredits {
    return Center(
      child: Container(
        child: Text(
          newsModel.photoCredits != null
              ? 'Credits: ${newsModel.photoCredits}'
              : '',
          style: TextStyle(fontSize: 15.0, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget get tags {
    return newsModel.description == null
        ? Offstage()
        : Container(
            padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  newsModel.description.trim(),
                  style: TextStyle(fontSize: 18.0, height: 1.4),
                )
              ],
            ),
          );
  }

  Widget get subHeadings {
    return newsModel.subheading == null
        ? Offstage()
        : Container(
            padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  newsModel.subheading.trim(),
                  style: TextStyle(fontSize: 18.0, height: 1.4),
                )
              ],
            ),
          );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Feed'),
          content: Text('Are you sure you want to delete this news feed?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            RaisedButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                _deleteNews(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  String _getFormattedTime(int timestamp) {
    return timeAgo.format(
      DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
  }

  void _shareNews(BuildContext context) {
    bool isShare = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewChat(isShare, newsModel),
      ),
    );
  }

  void _deleteNews(BuildContext context) async {
    await deleteNews(newsModel);
    // Navigator.pop(context);
    Navigator.pop(context);
  }
}
