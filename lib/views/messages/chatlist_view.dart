import 'package:flutter/material.dart';
import 'package:sevaexchange/main.dart';
import 'package:sevaexchange/main.dart' as prefix0;
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'package:sevaexchange/views/messages/chatview.dart';
import 'package:sevaexchange/views/messages/new_chat.dart';
import '../core.dart';
import 'package:shimmer/shimmer.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({Key key}) : super(key: key);

  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  // final BuildContext parentContext;
  // _ChatListViewState(this.parentContext);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Messages',style: TextStyle(color: Colors.white),),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              NewsModel news;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewChat(false, news)),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<List<MessageModel>>(
        stream:
            getMessagesforUser(email: SevaCore.of(context).loggedInUser.email),
        builder: (BuildContext context,
            AsyncSnapshot<List<MessageModel>> messageListSnapshot) {
          if (messageListSnapshot.hasError) {
            return new Text('Error: ${messageListSnapshot.error}');
          }
          switch (messageListSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<MessageModel> messageModelList = messageListSnapshot.data;
              if (messageModelList.length == 0) {
                return Center(child: Text('No Requests'));
              }
              return Container(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: ListView(
                  children: messageModelList.map(
                    (MessageModel messageModel) {
                      return getMessageListView(messageModel, context);
                    },
                  ).toList(),
                ),
              );
          }
        },
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

  Widget getMessageListView(
      MessageModel messageModel, BuildContext parentContext) {
    String lastmessage;
    if (messageModel.lastMessage == null) {
      lastmessage = '';
    } else
      lastmessage = messageModel.lastMessage;
    if (messageModel.user1 == SevaCore.of(context).loggedInUser.email) {
      return StreamBuilder<Object>(
          stream: getUserForEmailStream(messageModel.user2),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return taskShimmer;
            }
            UserModel user = snapshot.data;
            return Container(
              child: Card(
                elevation: 0,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) => ChatView(
                              useremail: user.email,
                              messageModel: messageModel,
                            ),
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipOval(
                          child: SizedBox(
                            height: 45,
                            width: 45,
                            child: FadeInImage.assetNetwork(
                                placeholder: 'lib/assets/images/profile.png',
                                image: user.photoURL),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                user.fullname,
                                style:
                                    Theme.of(parentContext).textTheme.subhead,
                              ),
                              Text(
                                lastmessage,
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
    } else if (messageModel.user2 == SevaCore.of(context).loggedInUser.email) {
      return StreamBuilder<Object>(
          stream: getUserForEmailStream(messageModel.user1),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return taskShimmer;
            }
            UserModel user = snapshot.data;
            return Container(
              child: Card(
                elevation: 0,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) => ChatView(
                              useremail: user.email,
                              messageModel: messageModel,
                            ),
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipOval(
                          child: SizedBox(
                            height: 45,
                            width: 45,
                            child: FadeInImage.assetNetwork(
                                placeholder: 'lib/assets/images/profile.png',
                                image: user.photoURL),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                user.fullname,
                                style:
                                    Theme.of(parentContext).textTheme.subhead,
                              ),
                              Text(
                                lastmessage,
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
    }
  }
}
