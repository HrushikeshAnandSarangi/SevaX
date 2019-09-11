import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sevaexchange/main.dart' as prefix0;
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'dart:async';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sevaexchange/views/news/newslistview.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import 'new_chat.dart';

class ChatView extends StatefulWidget {
  final String useremail;
  final ChatModel chatModel;
  bool isFromRejectCompletion;
  bool isFromShare;
  NewsModel news;

  ChatView(
      {Key key,
      this.useremail,
      this.chatModel,
      this.isFromRejectCompletion,
      this.isFromShare,
      this.news})
      : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  //UserModel user;
  UserModel loggedInUser;
  MessageModel messageModel = MessageModel();
  String loggedInEmail;
  final TextEditingController textcontroller = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ScrollController scrollcontroller = ScrollController();

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
    // TODO: implement initState
    if (widget.isFromRejectCompletion == null)
      widget.isFromRejectCompletion = false;
    if (widget.isFromRejectCompletion)
      textcontroller.text =
          'I am rejecting your task completion request because ';
    if (widget.isFromShare == null) widget.isFromShare = false;
    if (widget.isFromShare) textcontroller.text = widget.news.id;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Timer(Duration(milliseconds: 100), () {
        scrollcontroller.jumpTo(scrollcontroller.position.maxScrollExtent);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.isFromShare == null
              ? () {
                  Navigator.pop(context);
                }
              : widget.isFromShare
                  ? () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  : () {
                      Navigator.pop(context);
                    },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: FutureBuilder<Object>(
            future: FirestoreManager.getUserForEmail(
                emailAddress: widget.useremail),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return new Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center();
              }
              UserModel user = snapshot.data;

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
                        image: NetworkImage(user.photoURL),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  ),
                  Text(
                    '${user.fullname}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            }),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: getMessagesforChat(chatModel: widget.chatModel),
              builder: (BuildContext context,
                  AsyncSnapshot<List<MessageModel>> chatListSnapshot) {
                if (chatListSnapshot.hasError) {
                  return new Text('Error: ${chatListSnapshot.error}');
                }
                switch (chatListSnapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    List<MessageModel> chatModelList = chatListSnapshot.data;
                    if (chatModelList.length == 0) {
                      return Center(child: Text('No Messages'));
                    }
                    return Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: ListView(
                        controller: scrollcontroller,
                        children: chatModelList.map(
                          (MessageModel chatModel) {
                            return getChatListView(
                                chatModel, loggedInEmail, widget.useremail);
                          },
                        ).toList(),
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
                      decoration: InputDecoration(hintText: 'Type message'),
                      maxLines: null,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value.isEmpty) {
                          //print('error');
                          return 'Please type message';
                        }
                        messageModel.message = value;
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
                    color: Colors.white,
                  )),
                  backgroundColor: Theme.of(context).accentColor,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      String loggedInEmailId =
                          SevaCore.of(context).loggedInUser.email;
                      print(loggedInEmailId);
                      messageModel.fromId = loggedInEmailId;
                      messageModel.toId = widget.useremail;
                      messageModel.timestamp =
                          DateTime.now().millisecondsSinceEpoch;
                      createmessage(
                          messagemodel: messageModel,
                          chatmodel: widget.chatModel);
                      widget.chatModel.lastMessage = messageModel.message;
                      updateChat(chat: widget.chatModel);
                      textcontroller.clear();
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Timer(Duration(milliseconds: 100), () {
                          scrollcontroller.jumpTo(
                              scrollcontroller.position.maxScrollExtent);
                        });
                      });
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

  Widget getChatListView(
      MessageModel messageModel, String loggedinEmail, String chatUserEmail) {
    // if (messageModel.fromId == loggedinEmail) {
    RegExp exp = RegExp(
        r'[a-zA-Z][a-zA-Z0-9_.%$&]*[@][a-zA-Z0-9]*[.][a-zA-Z.]*[*][0-9]{13,}');
    if (exp.hasMatch(messageModel.message)) {
      return FutureBuilder<Object>(
          future: FirestoreManager.getNewsForId(messageModel.message),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return messageModel.fromId == loggedinEmail
                  ? sendmessageShimmer
                  : receivemessageShimmer;
            }
            NewsModel news = snapshot.data;

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
                    padding: messageModel.fromId == loggedinEmail &&
                            news != null
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
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
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
          topLeft: Radius.circular(8)),
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
                  child: FadeInImage(
                    fit: BoxFit.fitWidth,
                    placeholder:
                        AssetImage('lib/assets/images/noimagefound.png'),
                    image: NetworkImage(news.newsImageUrl),
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
