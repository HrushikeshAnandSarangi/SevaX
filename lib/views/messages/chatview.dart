import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/news/news_card_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class IsFromNewChat {
  bool isFromNewChat = false;
  int newChatTimeStamp;
  IsFromNewChat(this.isFromNewChat, this.newChatTimeStamp);
}

class ChatView extends StatefulWidget {
  final String useremail;
  final ChatModel chatModel;
  bool isFromRejectCompletion;
  bool isFromShare;
  NewsModel news;
  IsFromNewChat isFromNewChat;
  GeoFirePoint candidateLocation;

  ChatView({
    Key key,
    this.useremail,
    this.chatModel,
    this.isFromRejectCompletion,
    this.isFromShare,
    this.news,
    this.isFromNewChat,
  }) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  Map<String, NewsModel> sharedPosts;
  //UserModel user;
  UserModel loggedInUser;
  UserModel partnerUser;
  MessageModel messageModel = MessageModel();
  String loggedInEmail;
  final TextEditingController textcontroller = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ScrollController _scrollController = new ScrollController();
  Future _fetchAppBarData;
  String messageContent;
  bool _isOnTop = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loggedInEmail = SevaCore.of(context).loggedInUser.email;

    FirestoreManager.getUserForEmailStream(loggedInEmail).listen((userModel) {
      if (mounted) {
        setState(() {
          this.loggedInUser = userModel;
        });
      } else
        return Center(child: CircularProgressIndicator());
    });
  }

  @override
  void initState() {
    sharedPosts = HashMap();

    _scrollController = ScrollController();
    Future.delayed(Duration.zero, () {
      updateMessagingReadStatus(
        chat: widget.chatModel,
        userEmail: widget.useremail,
        email: SevaCore.of(context).loggedInUser.email,
        once: true,
      );
    });

    _fetchAppBarData = isValidEmail(widget.useremail)
        ? FirestoreManager.getUserForEmail(emailAddress: widget.useremail)
        : FirestoreManager.getTimeBankForId(timebankId: widget.useremail);
    if (widget.isFromRejectCompletion == null)
      widget.isFromRejectCompletion = false;
    if (widget.isFromRejectCompletion)
      textcontroller.text =
          '${AppLocalizations.of(context).translate('chat','rejecting_becz')} ';
    if (widget.isFromShare == null) widget.isFromShare = false;
    //here is we keep id
    if (widget.isFromShare) {
      textcontroller.text = widget.news.id;
      print("Priniting new message ");
// widget.chatModel.user1 ==

      pushNewMessage(
        communityId: widget.chatModel.communityId,
        loggedInEmailId: widget.useremail == widget.chatModel.user1
            ? widget.chatModel.user2
            : widget.chatModel.user1,
        messageContent: widget.news.id,
      );
    }
    //  _scrollToBottom();
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() {
    Location().getLocation().then((onValue) {
      widget.chatModel.candidateLocation =
          GeoFirePoint(onValue.latitude, onValue.longitude);

      print(
          "-------------------------------------------->>> ${widget.chatModel.candidateLocation.latitude}");
    });
  }

  Widget appBar({String imageUrl, String appbarTitle}) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Container(
            height: 36,
            width: 36,
            decoration: ShapeDecoration(
              shape: CircleBorder(
                side: BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              image: DecorationImage(
                image: NetworkImage(imageUrl ?? defaultUserImageURL),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
          ),
          Expanded(
            child: Text(appbarTitle,
                style: TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: widget.isFromShare == null
              ? () {
                  Navigator.pop(context);
                  print("Inside pop widget.isFromShare == null");
                }
              : widget.isFromShare
                  ? () {
                      print("Inside pop widget.isFromShare true");
                      Navigator.pop(context);
                    }
                  : () {
                      print("Inside pop widget.isFromShare false");
                      Navigator.pop(context);
                    },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FutureBuilder<Object>(
                future: _fetchAppBarData,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return new Text(AppLocalizations.of(context).translate('chat','error2'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center();
                  }

                  if (!isValidEmail(widget.useremail)) {
                    TimebankModel timebankModel = snapshot.data;
                    return appBar(
                        appbarTitle: timebankModel.name,
                        imageUrl: timebankModel.photoUrl ?? '');
                  }

                  partnerUser = snapshot.data;
                  print("Blah blah blah Blocked:${partnerUser.sevaUserID}");
                  return appBar(
                      appbarTitle: partnerUser.fullname,
                      imageUrl: partnerUser.photoURL);
                }),
            Divider(),
            Offstage(
              offstage: !isValidEmail(widget.chatModel.user1) ||
                  !isValidEmail(widget.chatModel.user2),
              child: RaisedButton(
                color: Color(0xffb71c1c),
                child: Container(
                  child: Text(
                    AppLocalizations.of(context).translate('chat','block'),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onPressed: () {
                  blockMemberDialogView(
                    context,
                  ).then((result) {
                    print("result " + result);
                    if (result == 'BLOCK') {
                      blockMember();
                      Navigator.pop(context);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: getMessagesforChat(
                  chatModel: widget.chatModel,
                  email: SevaCore.of(context).loggedInUser.email,
                  isFromNewChat: widget.isFromNewChat == null
                      ? IsFromNewChat(
                          false,
                          DateTime.now().millisecondsSinceEpoch,
                        )
                      : widget.isFromNewChat),
              builder: (BuildContext context,
                  AsyncSnapshot<List<MessageModel>> chatListSnapshot) {
                if (chatListSnapshot.hasError) {
                  _scrollToBottom();
                  return new Text('${AppLocalizations.of(context).translate('chat','error')} ${chatListSnapshot.error}');
                }

                if (!chatListSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                switch (chatListSnapshot.connectionState) {
                  default:
                    print("Inside chat view");
                    List<MessageModel> chatModelList = chatListSnapshot.data;
                    if (chatModelList.length == 0) {
                      return Center(child: Text(AppLocalizations.of(context).translate('chat','no_messages')));
                    }

                    var email = SevaCore.of(context).loggedInUser.email;
                    widget.chatModel.communityId =
                        SevaCore.of(context).loggedInUser.currentCommunity;

                    updateMessagingReadStatusForMe(
                      chat: widget.chatModel,
                      email: email,
                      userEmail: widget.useremail,
                    );

                    List<Widget> messages = chatModelList.map(
                      (MessageModel chatModel) {
                        return getChatListView(
                            chatModel, loggedInEmail, widget.useremail);
                      },
                    ).toList();
                    _scrollToBottom();

                    return Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: ListView(
                        //  shrinkWrap: true,
                        // reverse: false,
                        controller: _scrollController,
                        children: <Widget>[...messages],
                      ),
                    );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: textcontroller,
                      decoration: InputDecoration(hintText: AppLocalizations.of(context).translate('chat','type')),
                      maxLines: null,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context).translate('chat','type_empty');
                        }
                        messageContent = value;

                        setState(() {});
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                FloatingActionButton(
                  child: Center(
                    child: Icon(
                      Icons.send,
                      color: FlavorConfig.values.buttonTextColor,
                    ),
                  ),
                  backgroundColor: Theme.of(context).accentColor,
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      // This statment clears the soft delete parameter and message becomes visible to both the parties
                      // pushNewMessage(messageContent);

                      pushNewMessage(
                        messageContent: messageContent,
                        communityId: loggedInUser.currentCommunity,
                        loggedInEmailId: loggedInUser.email,
                      );

                      //FocusScope.of(context).requestFocus(FocusNode());
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // setState(() {});
//    SchedulerBinding.instance.addPostFrameCallback((_) {
//      Timer(Duration(milliseconds: 100), () {
//        try {
//          _scrollController.jumpTo(
//            _scrollController.position.maxScrollExtent,
//          );
//        } catch (e) {
//          print("Scroller not attached");
//        }
//      });
//    });
  }

  void pushNewMessage({
    String messageContent,
    String loggedInEmailId,
    String communityId,
  }) {
    widget.chatModel.softDeletedBy = [];

    // String loggedInEmailId = SevaCore.of(context).loggedInUser.email;
    // widget.chatModel.communityId = SevaCore.of(context).loggedInUser.currentCommunity;
    // widget.chatModel.communityId = "162cefc3-e1eb-4d8a-b297-fdf4e8176686";
    widget.chatModel.communityId = communityId;
    messageModel.fromId = loggedInEmailId;
    messageModel.toId = widget.useremail;
    messageModel.message = messageContent;
    messageModel.timestamp = DateTime.now().millisecondsSinceEpoch;
    widget.chatModel.lastMessage = messageModel.message;

    // RegExp exp = RegExp(
    //     r'[a-zA-Z][a-zA-Z0-9_.%$&]*[@][a-zA-Z0-9]*[.][a-zA-Z.]*[*][0-9]{13,}');
    // if (exp.hasMatch(lastMessage)) {
    //   this.lastMessage = "Shared a feed";
    // }

    createmessage(
      messagemodel: messageModel,
      chatmodel: widget.chatModel,
    );

    updateChat(
      chat: widget.chatModel,
      email: loggedInEmailId,
    ).then((onVlaue) {
      //
      updateMessagingReadStatus(
        chat: widget.chatModel,
        email: loggedInEmailId,
        userEmail: widget.useremail,
      );
    });
    setState(() {
      textcontroller.clear();
      _scrollToBottom();
    });
  }

  Widget _getSharedNewDetails({MessageModel messageModel}) {
    return FutureBuilder<Object>(
        future: FirestoreManager.getNewsForId(messageModel.message),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return new Text(AppLocalizations.of(context).translate('chat','couldnt_post'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }

          NewsModel news = snapshot.data;
          sharedPosts[messageModel.message] = news;

          return getSharedNewsCard(
            loggedinEmail: loggedInUser.email,
            news: news,
            loggedInUser: loggedInUser,
            messageModel: messageModel,
          );
        });
  }

  Widget getChatListView(
      MessageModel messageModel, String loggedinEmail, String chatUserEmail) {
    // if (messageModel.fromId == loggedinEmail) {
    RegExp exp = RegExp(
        r'[a-zA-Z][a-zA-Z0-9_.%$&]*[@][a-zA-Z0-9]*[.][a-zA-Z.]*[*][0-9]{13,}');
    if (exp.hasMatch(messageModel.message)) {
      return sharedPosts.containsKey(messageModel.message)
          ? getSharedNewsCard(
              loggedinEmail: loggedInUser.email,
              news: sharedPosts[messageModel.message],
              loggedInUser: loggedInUser,
              messageModel: messageModel,
            )
          : _getSharedNewDetails(messageModel: messageModel);
    } else
      return Container(
        padding: messageModel.fromId == loggedinEmail
            ? EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width / 10, 5, 0, 5)
            : EdgeInsets.fromLTRB(
                0, 5, MediaQuery.of(context).size.width / 10, 5),
        alignment: messageModel.fromId == loggedinEmail
            ? Alignment.topRight
            : Alignment.topLeft,
        child: Wrap(
          children: <Widget>[
            Container(
              decoration: messageModel.fromId == loggedinEmail
                  ? myBoxDecorationsend()
                  : myBoxDecorationreceive(),
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Column(
                crossAxisAlignment: messageModel.fromId != loggedinEmail
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    messageModel.message,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    DateFormat('hh:mm a MMMM dd').format(
                      getDateTimeAccToUserTimezone(
                          dateTime: DateTime.fromMillisecondsSinceEpoch(
                              messageModel.timestamp),
                          timezoneAbb: loggedInUser.timezone),
                    ),
                    style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget getSharedNewsCard({
    String loggedinEmail,
    NewsModel news,
    UserModel loggedInUser,
    MessageModel messageModel,
  }) {
    return Container(
      padding: messageModel.fromId == loggedinEmail
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 10, 5, 0, 5)
          : EdgeInsets.fromLTRB(
              0, 5, MediaQuery.of(context).size.width / 10, 5),
      alignment: messageModel.fromId == loggedinEmail
          ? Alignment.topRight
          : Alignment.topLeft,
      child: Wrap(
        children: <Widget>[
          Container(
            decoration: messageModel.fromId == loggedinEmail
                ? myBoxDecorationsend()
                : myBoxDecorationreceive(),
            padding: messageModel.fromId == loggedinEmail && news != null
                ? EdgeInsets.fromLTRB(0, 0, 5, 2)
                : messageModel.fromId != loggedinEmail && news != null
                    ? EdgeInsets.fromLTRB(0, 0, 0, 2)
                    : EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                news != null
                    ? getNewsCard(news)
                    : Text(
                        messageModel.message,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                Text(
                  DateFormat('h:mm a').format(
                    getDateTimeAccToUserTimezone(
                        dateTime: DateTime.fromMillisecondsSinceEpoch(
                            messageModel.timestamp),
                        timezoneAbb: loggedInUser.timezone),
                  ),
                  style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> blockMemberDialogView(BuildContext viewContext) async {
    return showDialog(
      context: viewContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(AppLocalizations.of(context).translate('chat','block') + " ${partnerUser.fullname.split(' ')[0]}."),
          content: new Text(
              "${partnerUser.fullname.split(' ')[0]} ${AppLocalizations.of(context).translate('chat','block_warn')}"),
          actions: <Widget>[
            new FlatButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              textColor: FlavorConfig.values.buttonTextColor,
              child: new Text(
                AppLocalizations.of(context).translate('chat','block'),
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop("BLOCK");
              },
            ),
            new FlatButton(
              child: new Text(
                AppLocalizations.of(context).translate('shared','cancel'),
                style: TextStyle(fontSize: dialogButtonSize, color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop("CANCEL");
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    sharedPosts.clear();
  }

  bool isValidEmail(String email) {
    RegExp regex =
        RegExp(r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)');
    return regex.hasMatch(email);
  }

  void blockMember() {
    Firestore.instance
        .collection("users")
        .document(SevaCore.of(context).loggedInUser.email)
        .updateData({
      'blockedMembers': FieldValue.arrayUnion([partnerUser.sevaUserID])
    });
    Firestore.instance
        .collection("users")
        .document(partnerUser.email)
        .updateData({
      'blockedBy':
          FieldValue.arrayUnion([SevaCore.of(context).loggedInUser.sevaUserID])
    });
    setState(() {
      var updateUser = SevaCore.of(context).loggedInUser;
      var blockedMembers = List<String>.from(updateUser.blockedMembers);
      blockedMembers.add(partnerUser.sevaUserID);
      SevaCore.of(context).loggedInUser =
          updateUser.setBlockedMembers(blockedMembers);
    });
  }

  Widget get sendmessageShimmer {
    return Container(
      padding:
          EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 10, 5, 0, 5),
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 5, 2),
        decoration: myBoxDecorationsend(),
        child: Shimmer.fromColors(
          baseColor: Colors.black.withAlpha(50),
          highlightColor: Colors.white.withAlpha(50),
          child: Container(
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(100),
              borderRadius: BorderRadius.circular(15.0),
            ),
            //color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  height: 250,
                  color: Colors.white.withAlpha(220),
                ),
                Container(
                  height: 16,
                  color: Colors.white.withAlpha(220),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  height: 14,
                  color: Colors.white.withAlpha(220),
                ),
                Container(
                  height: 12,
                  color: Colors.white.withAlpha(220),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get receivemessageShimmer {
    return Container(
      padding:
          EdgeInsets.fromLTRB(0, 5, MediaQuery.of(context).size.width / 10, 5),
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
        decoration: myBoxDecorationreceive(),
        child: Shimmer.fromColors(
          baseColor: Colors.black.withAlpha(50),
          highlightColor: Colors.white.withAlpha(50),
          child: Container(
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(100),
              borderRadius: BorderRadius.circular(15.0),
            ),
            // color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  height: 250,
                  color: Colors.white.withAlpha(220),
                ),
                Container(
                  height: 16,
                  color: Colors.white.withAlpha(220),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  height: 14,
                  color: Colors.white.withAlpha(220),
                ),
                Container(
                  height: 12,
                  color: Colors.white.withAlpha(220),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration myBoxDecorationsend() {
    return BoxDecoration(
      color: Colors.indigo[200],
      border: Border.all(width: 0.1),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(15),
        topLeft: Radius.circular(8),
      ),
    );
  }

  BoxDecoration myBoxDecorationreceive() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(width: 0.1),
      borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(8),
          bottomLeft: Radius.circular(15),
          topRight: Radius.circular(8)),
    );
  }

  Widget getNewsCard(NewsModel news) {
    var imageBanner = news.newsImageUrl == null
        ? (news.imageScraped == null ? "NoData" : news.imageScraped)
        : news.newsImageUrl;
    print("FNAL IMAGE --> " + imageBanner);

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
              height: imageBanner != "NoData" ? 250 : 0,
              child: SizedBox.expand(
                child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: imageBanner != "NoData"
                        ? FadeInImage(
                            fit: BoxFit.fitWidth,
                            placeholder:
                                AssetImage('lib/assets/images/waiting.jpg'),
                            image: NetworkImage(
                              imageBanner ?? defaultUserImageURL,
                            ),
                          )
                        : Offstage()),
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
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Text(
                                news.title == null
                                    ? news.subheading
                                    : news.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                            // Text(
                            //   news.title == null ? "" : ,
                            //   overflow: TextOverflow.ellipsis,
                            // ),
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
                  padding: EdgeInsets.all(5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
