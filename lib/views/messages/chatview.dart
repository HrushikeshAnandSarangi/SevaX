import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/new_chat_manager.dart'
    as newChatManager;
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/news/news_card_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeAgo;

enum MessageMenu {
  BLOCK,
  CLEAR_CHAT,
}

class IsFromNewChat {
  bool isFromNewChat = false;
  int newChatTimeStamp;
  IsFromNewChat(this.isFromNewChat, this.newChatTimeStamp);
}

class ChatView extends StatefulWidget {
  final ChatModel chatModel;
  bool isFromRejectCompletion;
  bool isFromShare;
  NewsModel news;
  IsFromNewChat isFromNewChat;
  GeoFirePoint candidateLocation;
  final String senderId;

  ChatView({
    Key key,
    this.chatModel,
    this.isFromRejectCompletion,
    this.isFromShare,
    this.news,
    this.isFromNewChat,
    this.senderId,
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

  String messageContent;

  String recieverId;
  String chatId;
  // String timebankId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loggedInEmail = SevaCore.of(context).loggedInUser.email;

    FirestoreManager.getUserForEmailStream(loggedInEmail).listen((userModel) {
      if (mounted) {
        setState(() {
          this.loggedInUser = userModel;
        });
      }
    });
  }

  @override
  void initState() {
    recieverId = widget.chatModel.participants[0] != widget.senderId
        ? widget.chatModel.participants[0]
        : widget.chatModel.participants[1];
    FirestoreManager.getUserForId(sevaUserId: recieverId).then((userModel) {
      if (mounted) {
        setState(() {
          this.partnerUser = userModel;
        });
      }
    });
    chatId =
        "${widget.chatModel.participants[0]}*${widget.chatModel.participants[1]}*${widget.chatModel.communityId}";
    sharedPosts = HashMap();

    _scrollController = ScrollController();
    if (widget.isFromRejectCompletion == null)
      widget.isFromRejectCompletion = false;
    if (widget.isFromRejectCompletion)
      textcontroller.text =
          '${AppLocalizations.of(context).translate('chat', 'rejecting_becz')} ';
    if (widget.isFromShare == null) widget.isFromShare = false;
    //here is we keep id
    if (widget.isFromShare) {
      textcontroller.text = widget.news.id;
      pushNewMessage(
        communityId: widget.chatModel.communityId,
        senderId: widget.senderId,
        messageContent: widget.news.id,
      );
    }
    //  _scrollToBottom();
    super.initState();
    // getCurrentLocation();
  }

  Widget appBar({String imageUrl, String appbarTitle}) {
    return Row(
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
        SizedBox(width: 10),
        Expanded(
          child: Text(appbarTitle,
              style: TextStyle(fontSize: 18), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ParticipantInfo senderInfo = getUserInfo(
      recieverId,
      widget.chatModel.participantInfo,
    );

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
                }
              : widget.isFromShare
                  ? () {
                      Navigator.pop(context);
                    }
                  : () {
                      Navigator.pop(context);
                    },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: appBar(
          appbarTitle: senderInfo.name,
          imageUrl: senderInfo.photoUrl,
        ),
        actions: <Widget>[
          chatMoreOptions(),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: newChatManager.getMessagesforChat(
                  chat: widget.chatModel,
                  userId: SevaCore.of(context).loggedInUser.sevaUserID,
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
                  return Text(
                      '${AppLocalizations.of(context).translate('chat', 'error')} ${chatListSnapshot.error}');
                }

                if (!chatListSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                switch (chatListSnapshot.connectionState) {
                  default:
                    List<MessageModel> chatModelList = chatListSnapshot.data;
                    if (chatModelList.length == 0) {
                      return Center(
                          child: Text(AppLocalizations.of(context)
                              .translate('chat', 'no_messages')));
                    }

                    if (!widget.chatModel.isTimebankMessage ||
                        widget.senderId == loggedInUser.sevaUserID) {
                      newChatManager.markMessageAsRead(
                        chat: widget.chatModel,
                        userId: SevaCore.of(context).loggedInUser.sevaUserID,
                      );
                    }

                    List<Widget> messages = chatModelList.map(
                      (MessageModel chatModel) {
                        return getChatListView(
                            chatModel, loggedInEmail, widget.senderId);
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
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)
                              .translate('chat', 'type')),
                      maxLines: null,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) => value.isEmpty
                          ? AppLocalizations.of(context)
                              .translate('chat', 'type_empty')
                          : null,
                      onSaved: (value) {
                        messageContent = value;
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
                      _formKey.currentState.save();
                      pushNewMessage(
                        messageContent: messageContent,
                        communityId: loggedInUser.currentCommunity,
                        senderId: widget.senderId,
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
  }

  void pushNewMessage({
    String messageContent,
    String senderId,
    String communityId,
  }) {
    messageModel.fromId = senderId;
    messageModel.toId = widget.senderId;
    messageModel.message = messageContent;
    messageModel.timestamp = DateTime.now().millisecondsSinceEpoch;

    if (widget.chatModel.isTimebankMessage) {}

    newChatManager.createNewMessage(
      chatId: chatId,
      recieverId: recieverId,
      messageModel: messageModel,
      timebankId: widget.chatModel.timebankId,
      isTimebankMessage: widget.chatModel.isTimebankMessage,
      isAdmin: widget.chatModel.timebankId == widget.senderId,
    );
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
          return Text(
              AppLocalizations.of(context).translate('chat', 'couldnt_post'));
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
      },
    );
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
      padding: messageModel.fromId == widget.senderId
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 10, 5, 0, 5)
          : EdgeInsets.fromLTRB(
              0, 5, MediaQuery.of(context).size.width / 10, 5),
      alignment: messageModel.fromId == widget.senderId
          ? Alignment.topRight
          : Alignment.topLeft,
      child: Wrap(
        children: <Widget>[
          Container(
            decoration: messageModel.fromId == widget.senderId
                ? myBoxDecorationsend()
                : myBoxDecorationreceive(),
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Column(
              crossAxisAlignment: messageModel.fromId != widget.senderId
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  messageModel.message,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  DateFormat(
                    'hh:mm a MMMM dd',
                  )
//                  DateFormat(
//                          'hh:mm a MMMM dd',
//                          Locale(AppConfig.prefs.getString('language_code'))
//                              .toLanguageTag())
                      .format(
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
      padding: messageModel.fromId == widget.senderId
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 10, 5, 0, 5)
          : EdgeInsets.fromLTRB(
              0, 5, MediaQuery.of(context).size.width / 10, 5),
      alignment: messageModel.fromId == widget.senderId
          ? Alignment.topRight
          : Alignment.topLeft,
      child: Wrap(
        children: <Widget>[
          Container(
            decoration: messageModel.fromId == widget.senderId
                ? myBoxDecorationsend()
                : myBoxDecorationreceive(),
            padding: messageModel.fromId == widget.senderId && news != null
                ? EdgeInsets.fromLTRB(0, 0, 5, 2)
                : messageModel.fromId != widget.senderId && news != null
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
                  DateFormat(
                          'h:mm a',
                          Locale(AppConfig.prefs.getString('language_code'))
                              .toLanguageTag())
                      .format(
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

  @override
  void dispose() {
    super.dispose();
    sharedPosts.clear();
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
                            ), locale: Locale(AppConfig.prefs.getString('language_code')).toLanguageTag()
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

  Future<void> clearChat(String chatId, String userId) async {
    return Firestore.instance.collection('chatsnew').document(chatId).setData(
      {
        "softDeletedBy": FieldValue.arrayUnion([userId]),
        "deletedBy": {
          userId: DateTime.now().millisecondsSinceEpoch,
        }
      },
      merge: true,
    );
  }

  Future<String> showClearChatDialog(BuildContext viewContext, String title,
      String content, String buttonLabel) {
    return showDialog(
      context: viewContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: new Text(content),
          actions: <Widget>[
            new FlatButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              textColor: FlavorConfig.values.buttonTextColor,
              child: new Text(
                buttonLabel,
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop("SUCCESS");
              },
            ),
            new FlatButton(
              child: new Text(
                AppLocalizations.of(context).translate('shared', 'cancel'),
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

  Widget chatMoreOptions() {
    return PopupMenuButton<MessageMenu>(
      onSelected: (MessageMenu value) {
        switch (value) {
          case MessageMenu.BLOCK:
            showClearChatDialog(
              context,
              AppLocalizations.of(context).translate('chat', 'block') +
                  " ${partnerUser.fullname.split(' ')[0]}.",
              "${partnerUser.fullname.split(' ')[0]} ${AppLocalizations.of(context).translate('chat', 'block_warn')}",
              AppLocalizations.of(context).translate('chat', 'block'),
            ).then((value) {
              if (value != "CANCEL") {
                blockMember();
                Navigator.pop(context);
              }
            });
            break;
          case MessageMenu.CLEAR_CHAT:
            showClearChatDialog(
              context,
              AppLocalizations.of(context).translate('chat', 'delete_title'),
              AppLocalizations.of(context).translate('chat', 'delete_desc'),
              AppLocalizations.of(context).translate('chat', 'delete_title'),
            ).then((value) {
              if (value != "CANCEL") {
                clearChat(chatId, widget.senderId);
                Navigator.pop(context);
              }
            });
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
              child: Text(
                AppLocalizations.of(context).translate('chat', 'delete_title'),
              ),
              value: MessageMenu.CLEAR_CHAT),
          ...!widget.chatModel.isTimebankMessage
              ? [
                  PopupMenuItem(
                    child: Text(
                      AppLocalizations.of(context).translate('chat', 'block'),
                    ),
                    value: MessageMenu.BLOCK,
                  )
                ]
              : [],
        ];
      },
    );
  }
}
