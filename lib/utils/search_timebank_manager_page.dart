import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/members_of_timebank.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/chatview.dart';
import 'package:sevaexchange/views/search_view.dart';

class SearchTimebankMemberElastic extends StatefulWidget {
  String timebankId;
  MEMBER_SELECTION_MODE selectionMode;
  NewsModel newsModel;
  bool isFromShare = false;

  SearchTimebankMemberElastic(String timebankId, bool isFromShare,
      NewsModel newsModel, MEMBER_SELECTION_MODE selectionMode) {
    this.timebankId = timebankId;
    this.isFromShare = isFromShare;
    this.newsModel = newsModel;
    this.selectionMode = selectionMode;
  }

  createState() => _SearchTimebankMemberElastic();
}

class _SearchTimebankMemberElastic extends State<SearchTimebankMemberElastic> {
  final TextEditingController searchTextController = TextEditingController();
  var fromNewChat = IsFromNewChat(true, DateTime.now().millisecondsSinceEpoch);
  final searchOnChange = new BehaviorSubject<String>();
  var validItems = List<String>();

  @override
  void initState() {
    super.initState();
    FirestoreManager.getAllTimebankIdStream(
      timebankId: widget.timebankId,
    ).then((onValue) {
      setState(() {
        validItems = onValue;
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
          child: TextField(
            onChanged: (String queryString) {
              searchOnChange.add(queryString);
              setState(() {});
            },
            style: TextStyle(color: Colors.white),
            controller: searchTextController,
            decoration: InputDecoration(
                hasFloatingPlaceholder: false,
                alignLabelWithHint: true,
                isDense: true,
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                hintText: 'Search members',
                hintStyle: TextStyle(color: Colors.white)),
            // controller: searchTextController,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ResultViewElastic(
                SearchType.USER,
                searchTextController,
                widget.timebankId,
                validItems,
                widget.selectionMode,
                widget.newsModel,
                widget.isFromShare),
          ),
        ],
      ),
    );
  }
}

class ResultViewElastic extends StatefulWidget {
  final SearchType type;
  final TextEditingController controller;
  final String timebankId;
  final List<String> validItems;
  final MEMBER_SELECTION_MODE selectionMode;
  final NewsModel newsModel;
  final bool isFromShare;

  ResultViewElastic(this.type, this.controller, this.timebankId,
      this.validItems, this.selectionMode, this.newsModel, this.isFromShare);

  @override
  _ResultViewElasticState createState() {
    return _ResultViewElasticState();
  }
}

class _ResultViewElasticState extends State<ResultViewElastic> {
  bool checkValidSting(String str) {
    return str != null && str.trim().length != 0;
  }

  Widget getTitleForCard(String str, String fullName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        str == null || str == "No content"
            ? Offstage()
            : Text(
                fullName == null ? defaultUsername : fullName.trim(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
        Text(
          str.trim(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          // style: sectionHeadingStyle,
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget fetchHeadingFromNewsModel(NewsModel newsModel) {
    if (checkValidSting(newsModel.title)) {
      return getTitleForCard(newsModel.title, newsModel.fullName);
    }
    if (checkValidSting(newsModel.subheading)) {
      return getTitleForCard(newsModel.subheading, newsModel.fullName);
    }
    if (checkValidSting(newsModel.description)) {
      return getTitleForCard(newsModel.description, newsModel.fullName);
    }
    return getTitleForCard('No content', newsModel.fullName);
  }

  Widget getUserWidget(UserModel user, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        switch (widget.selectionMode) {
          case MEMBER_SELECTION_MODE.NEW_CHAT:
            if (user.email == SevaCore.of(context).loggedInUser.email) {
              return null;
            } else {
              UserModel loggedInUser = SevaCore.of(context).loggedInUser;
              ParticipantInfo sender = ParticipantInfo(
                id: loggedInUser.sevaUserID,
                photoUrl: loggedInUser.photoURL,
                name: loggedInUser.fullname,
                type: MessageType.TYPE_PERSONAL,
              );

              ParticipantInfo reciever = ParticipantInfo(
                id: user.sevaUserID,
                photoUrl: user.photoURL,
                name: user.fullname,
                type: MessageType.TYPE_PERSONAL,
              );

              createAndOpenChat(
                context: context,
                timebankId: widget.timebankId,
                communityId: loggedInUser.currentCommunity,
                sender: sender,
                reciever: reciever,
                isFromShare: false,
                news: NewsModel(),
                isFromNewChat:
                    IsFromNewChat(true, DateTime.now().millisecondsSinceEpoch),
              );
              Navigator.of(context).pop();
            }
            return user.email == SevaCore.of(context).loggedInUser.email
                ? null
                : () {};

            break;

          case MEMBER_SELECTION_MODE.SHARE_FEED:
            if (user.email == SevaCore.of(context).loggedInUser.email) {
              return null;
            } else {
              UserModel loggedInUser = SevaCore.of(context).loggedInUser;
              ParticipantInfo sender = ParticipantInfo(
                id: loggedInUser.sevaUserID,
                photoUrl: loggedInUser.photoURL,
                name: loggedInUser.fullname,
                type: MessageType.TYPE_PERSONAL,
              );

              ParticipantInfo reciever = ParticipantInfo(
                id: user.sevaUserID,
                photoUrl: user.photoURL,
                name: user.fullname,
                type: MessageType.TYPE_PERSONAL,
              );

              createAndOpenChat(
                context: context,
                timebankId: widget.timebankId,
                communityId: loggedInUser.currentCommunity,
                sender: sender,
                reciever: reciever,
                isFromShare: true,
                news: widget.newsModel,
                isFromNewChat: IsFromNewChat(
                  false,
                  DateTime.now().millisecondsSinceEpoch,
                ),
              );
              Navigator.of(context).pop();
            }
            return user.email == SevaCore.of(context).loggedInUser.email
                ? null
                : () {};

            break;
          default:
            return () {
              print("");
            };
        }
      },
      child: Card(
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.photoURL ?? defaultUserImageURL),
          ),
          title: Text(
            user.fullname,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            user.email,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    if (widget == null ||
        widget.controller == null ||
        widget.controller.text == null) {
      return Container();
    }

    if (widget.controller.text.trim().isEmpty) {
      return Center(
        child: ClipOval(
          child: FadeInImage.assetNetwork(
              placeholder: 'lib/assets/images/search.png',
              image: 'lib/assets/images/search.png'),
        ),
      );
    } else if (widget.controller.text.trim().length < 3) {
      print('Search requires minimum 3 characters');
      return getEmptyWidget('Users', 'Search requires minimum 3 characters');
    }
    return StreamBuilder<List<UserModel>>(
      stream: SearchManager.searchForUserWithTimebankId(
          queryString: widget.controller.text, validItems: widget.validItems),
      builder: (context, snapshot) {
        print('$snapshot');
        if (snapshot.hasError) {
          Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              height: 48,
              width: 48,
              child: CircularProgressIndicator(),
            ),
          );
        }
        List<UserModel> userList = snapshot.data;
        if (userList.length == 0) {
          return getEmptyWidget('Users', 'No user found');
        }
        return ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                padding: EdgeInsets.only(left: 8, top: 16),
                child: Text('Users', style: sectionTextStyle),
              );
            }
            UserModel user = userList.elementAt(index - 1);
            return getUserWidget(user, context);
          },
          itemCount: userList.length + 1,
        );
      },
    );
  }

  Widget getEmptyWidget(String title, String notFoundValue) {
    return Center(
      child: Text(
        notFoundValue,
        overflow: TextOverflow.ellipsis,
        style: sectionHeadingStyle,
      ),
    );
  }

  TextStyle get sectionHeadingStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12.5,
      color: Colors.black,
    );
  }

  TextStyle get sectionTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.grey,
    );
  }
}
