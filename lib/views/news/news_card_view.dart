import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/views/messages/new_chat.dart';

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
          _getDeleteButton(context),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareNews(context),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              newsTitle,
              newsAuthorAndDate,
              newsImage,
              photoCredits,
              tags,
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
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
      child: Text(
        newsModel.title,
        style: TextStyle(
            fontSize: 28.0,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget get newsAuthorAndDate {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(
              newsModel.fullName,
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          Text(
            _getFormattedTime(newsModel.postTimestamp),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          )
        ],
      ),
    );
  }

  Widget get newsImage {
    return Container(
      child: newsModel.newsImageUrl != null
          ? Hero(
              tag: newsModel.id,
              child: Image.network(
                newsModel.newsImageUrl,
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
    return Container(
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
