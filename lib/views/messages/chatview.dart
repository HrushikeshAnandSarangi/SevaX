import 'package:flutter/material.dart';
import 'package:sevaexchange/main.dart' as prefix0;
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart'
    as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'dart:async';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ChatView extends StatefulWidget {
  final String useremail;
  final MessageModel messageModel;
  bool isFromRejectCompletion;

  ChatView({Key key, this.useremail, this.messageModel,this.isFromRejectCompletion}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  //UserModel user;
  UserModel loggedInUser;
  ChatModel chat = ChatModel();
  String loggedInEmail;
  final TextEditingController textcontroller = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ScrollController scrollcontroller = ScrollController();
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loggedInEmail = SevaCore.of(context).loggedInUser.email;
    
    FirestoreManager.getUserForEmailStream(loggedInEmail).listen((userModel) {
      if (mounted){setState(() {
          this.loggedInUser = userModel;
        });}
        
        else return Center(child: CircularProgressIndicator());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    if(widget.isFromRejectCompletion == null) widget.isFromRejectCompletion = false;
    if(widget.isFromRejectCompletion) textcontroller.text = 'I am rejecting your task completion request because ';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Timer(
        Duration(milliseconds: 100),
        () =>
            scrollcontroller.jumpTo(scrollcontroller.position.maxScrollExtent));
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: 
        FutureBuilder<Object>(
          future: FirestoreManager.getUserForEmail(emailAddress: widget.useremail),
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
                Text('${user.fullname}',style: TextStyle(color: Colors.white),),
              ],
            );
          }
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<ChatModel>>(
              stream: getMessagesforChat(messagemodel: widget.messageModel),
              builder: (BuildContext context,
                  AsyncSnapshot<List<ChatModel>> chatListSnapshot) {
                if (chatListSnapshot.hasError) {
                  return new Text('Error: ${chatListSnapshot.error}');
                }
                switch (chatListSnapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    List<ChatModel> chatModelList = chatListSnapshot.data;
                    if (chatModelList.length == 0) {
                      return Center(child: Text('No Messages'));
                    }
                    return Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: ListView(
                        controller: scrollcontroller,
                        children: chatModelList.map(
                          (ChatModel chatModel) {
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
                        chat.message = value;
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
                  backgroundColor: Colors.indigoAccent,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      String loggedInEmailId =
                          SevaCore.of(context).loggedInUser.email;
                      print(loggedInEmailId);
                      chat.fromId = loggedInEmailId;
                      chat.toId = widget.useremail;
                      chat.timestamp = DateTime.now().millisecondsSinceEpoch;
                      createmessage(
                          chatmodel: chat, messagemodel: widget.messageModel);
                      widget.messageModel.lastMessage = chat.message;
                      updateChat(chat: widget.messageModel);
                      textcontroller.clear();
                      scrollcontroller
                          .jumpTo(scrollcontroller.position.maxScrollExtent);
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
      ChatModel chatmodel, String loggedinEmail, String chatUserEmail) {
    if (chatmodel.fromId == loggedinEmail) {
      return Container(
        padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width / 10, 5, 0, 5),
        alignment: Alignment.topRight,
        child: Wrap(
          children: <Widget>[
            Container(
              decoration: myBoxDecorationsend(),
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    chatmodel.message,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    DateFormat('h:mm a').format(
                      getDateTimeAccToUserTimezone(
                          dateTime: DateTime.fromMillisecondsSinceEpoch(
                              chatmodel.timestamp),
                          timezoneAbb: loggedInUser.timezone),
                    ),
                    style: TextStyle(fontSize: 10,color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else
      return Container(
        padding: EdgeInsets.fromLTRB(
            0, 5, MediaQuery.of(context).size.width / 10, 5),
        alignment: Alignment.topLeft,
        child: Wrap(
          children: <Widget>[
            Container(
              decoration: myBoxDecorationreceive(),
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    chatmodel.message,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    DateFormat('h:mm a').format(
                      getDateTimeAccToUserTimezone(
                          dateTime: DateTime.fromMillisecondsSinceEpoch(
                              chatmodel.timestamp),
                          timezoneAbb: loggedInUser.timezone),
                    ),
                    style: TextStyle(fontSize: 10,color: Colors.grey),
                    
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget get taskShimmer {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white.withAlpha(80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: ListTile(
            title: Container(height: 10, color: Colors.white),
            subtitle: Container(height: 10, color: Colors.white),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
            ),
          ),
        ),
        baseColor: Colors.black.withAlpha(50),
        highlightColor: Colors.white.withAlpha(50),
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
}
