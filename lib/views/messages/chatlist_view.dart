import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
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
        title: Text(
          'Chats',
          style: TextStyle(color: Colors.white),
        ),
        // actions: <Widget>[

        // ],
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: getChatsforUser(email: SevaCore.of(context).loggedInUser.email),
        builder: (BuildContext context,
            AsyncSnapshot<List<ChatModel>> chatListSnapshot) {
          if (chatListSnapshot.hasError) {
            return new Text('Error: ${chatListSnapshot.error}');
          }
          switch (chatListSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<ChatModel> chatModelList = chatListSnapshot.data;
              if (chatModelList.length == 0) {
                return Center(child: Text('No Chats'));
              }
              return Container(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: ListView(
                  children: chatModelList.map(
                    (ChatModel chatModel) {
                      return getMessageListView(chatModel, context);
                    },
                  ).toList(),
                ),
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(
          Icons.chat,
        ),
        label: Text('New Chat'),
        foregroundColor: FlavorConfig.values.buttonTextColor,
        onPressed: () {
          NewsModel news;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewChat(false, news)),
          );
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

  Widget getMessageListView(ChatModel chatModel, BuildContext parentContext) {
    String lastmessage;
    if (chatModel.lastMessage == null) {
      lastmessage = '';
    } else
      lastmessage = chatModel.lastMessage;
    if (chatModel.user1 == SevaCore.of(context).loggedInUser.email) {
      return StreamBuilder<Object>(
          stream: getUserForEmailStream(chatModel.user2),
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
                          chatModel: chatModel,
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
    } else if (chatModel.user2 == SevaCore.of(context).loggedInUser.email) {
      return StreamBuilder<Object>(
          stream: getUserForEmailStream(chatModel.user1),
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
                          chatModel: chatModel,
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
