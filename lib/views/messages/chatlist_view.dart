import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/members_of_timebank.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/messages/chatview.dart';
import 'package:sevaexchange/views/messages/select_timebank_for_chat.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import '../core.dart';
import 'list_members_timebank.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({Key key}) : super(key: key);

  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  // final BuildContext parentContext;
  // _ChatListViewState(this.parentContext);

//  var updateUser = SevaCore.of(context).loggedInUser;
  @override
  Widget build(BuildContext context) {
    var blockedMembers =
        List<String>.from(SevaCore.of(context).loggedInUser.blockedMembers);
    var blockedByMembers =
        List<String>.from(SevaCore.of(context).loggedInUser.blockedBy);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Messages',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: getChatsforUser(
          email: SevaCore.of(context).loggedInUser.email,
          blockedBy: blockedByMembers,
          blockedMembers: blockedMembers,
          communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        ),
        builder: (BuildContext context,
            AsyncSnapshot<List<ChatModel>> chatListSnapshot) {
          if (!chatListSnapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (chatListSnapshot.hasError) {
            return new Text('Error: ${chatListSnapshot.error}');
          }
          // setState(() {

          // });

          switch (chatListSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              // print("Chat Model list ${chatListSnapshot.data}");
              List<ChatModel> allChalModelList = chatListSnapshot.data;

              List<ChatModel> chatModelList = allChalModelList;
              if (chatModelList.length == 0) {
                return Center(child: Text('No Messages'));
              }

              return ListView.builder(
                itemCount: chatModelList.length,
                itemBuilder: (context, index) {
                  return chatModelList[index].isBlocked
                      ? Offstage()
                      : getMessageListView(chatModelList[index], context);
                },
              );
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
          icon: Icon(
            Icons.chat,
          ),
          label: Text('New Message'),
          foregroundColor: FlavorConfig.values.buttonTextColor,
          onPressed: () {
            if (SevaCore.of(context).loggedInUser.associatedWithTimebanks > 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SelectTimeBankForNewChat()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectMembersFromTimebank(
                    timebankId:
                        SevaCore.of(context).loggedInUser.currentTimebank,
                    newsModel: NewsModel(),
                    isFromShare: false,
                    selectionMode: MEMBER_SELECTION_MODE.NEW_CHAT,
                    userSelected: HashMap(),
                  ),
                ),
              );
            }
            // NewsModel news;
            // Navigator.push(
            //   context,
            //   // MaterialPageRoute(builder: (context) => NewChat(false, news)),
            //   MaterialPageRoute(builder: (context) => SelectTimeBankForNewChat()),
            // );
          },
        ),
      ),
    );
  }

  Widget abc(BuildContext context) {
    List<TimebankModel> timebankList = [];
    return StreamBuilder<List<TimebankModel>>(
        stream: FirestoreManager.getTimebanksForUserStream(
          userId: SevaCore.of(context).loggedInUser.sevaUserID,
          communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          timebankList = snapshot.data;
          // timebankList.forEach((t){
          //   if(t.name==timebankName){
          //     timebankId=t.id;
          //   }
          // });
          List<String> dropdownList = [];
          timebankList.forEach((t) {
            dropdownList.add(t.id);
          });

          print("Length inside chat${dropdownList.length}");

          return ListView.builder(
              itemCount: timebankList.length,
              itemBuilder: (context, index) {
                TimebankModel timebank = timebankList.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListMambersForNewChat(),
                      ),
                    );
                    // print("inside tap");
                  },
                  child: Card(
                    margin: EdgeInsets.all(5),
                    child: Container(
                      margin: EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(timebank.name),
                        ],
                      ),
                    ),
                  ),
                );
              });
        });
  }

// Widget checkTimebanksCount(BuildContext context) {
//   return
// }
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
    // print("------------------------->" + chatModel.toString());
    String lastmessage;
    if (chatModel.lastMessage == null) {
      lastmessage = '';
    } else
      lastmessage = chatModel.lastMessage;

    var userEmail = SevaCore.of(context).loggedInUser.email;

    // if (chatModel.user1 == SevaCore.of(context).loggedInUser.email) {

    return Dismissible(
      key: Key(chatModel.user1),

      onDismissed: (direction) {
        _ackAlert(
          SevaCore.of(context).loggedInUser.email,
          chatModel,
          context,
          SevaCore.of(context).loggedInUser.currentCommunity,
        );
        // Then show a snackbar.
      },
      // a red background as the item is swiped away.
      background: Container(color: Colors.red),

      child: Container(
        child: Card(
          elevation: 0,
          child: InkWell(
            onTap: () {
              print("Getting intp existing chat");
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => ChatView(
                    useremail: SevaCore.of(context).loggedInUser.email ==
                            chatModel.user1
                        ? chatModel.user2
                        : chatModel.user1,
                    chatModel: chatModel,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipOval(
                    child: Container(
                      height: 55,
                      width: 55,
                      child: FadeInImage.assetNetwork(
                        placeholder: 'lib/assets/images/profile.png',
                        image: chatModel.photoURL == null
                            ? "https://firebasestorage.googleapis.com/v0/b/sevaexchange.appspot.com/o/timebanklogos%2Fseva_default.jpg?alt=media&token=e3804df4-6146-4bfb-8c8e-b24a62da312d"
                            : chatModel.photoURL,
                      ),
                    ),
                  ),
                  Container(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Offstage(
                          offstage: isValidEmail(chatModel.user1) &&
                              isValidEmail(chatModel.user2),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(3)),
                            padding: EdgeInsets.only(
                                left: 5, right: 5, top: 2, bottom: 2),
                            // color: Colors.green,
                            child: Text(
                              "Timebank",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 3,
                            top: isValidEmail(chatModel.user1) &&
                                    isValidEmail(chatModel.user2)
                                ? 5
                                : 0,
                          ),
                          child: Text(
                            chatModel.messagTitleUserName == null
                                ? 'Not added '
                                : chatModel.messagTitleUserName,
                            style: Theme.of(parentContext).textTheme.subhead,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 3),
                          child: Text(
                            lastmessage,
                            style: TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          timeAgo
                              .format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    chatModel.timestamp),
                              )
                              .replaceAll('hours ago', 'h'),
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            chatModel.unreadStatus != null &&
                                    chatModel.unreadStatus.containsKey(
                                      userEmail,
                                    )
                                ? "${chatModel.unreadStatus[userEmail] == 0 ? '' : chatModel.unreadStatus[userEmail]}"
                                : '',
                          ),
                          ClipOval(
                            child: Container(
                              height: 35,
                              width: 35,
                              child: GestureDetector(
                                child: IconButton(
                                  icon: Image.asset(
                                    'lib/assets/images/recycle-bin.png',
                                  ),
                                  iconSize: 30,
                                  onPressed: () {
                                    _ackAlert(
                                      SevaCore.of(context).loggedInUser.email,
                                      chatModel,
                                      context,
                                      SevaCore.of(context)
                                          .loggedInUser
                                          .currentCommunity,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (chatModel.user1 == "anitha.beberg@gmail.com") {
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
            // filter blocked content
            if (SevaCore.of(context)
                    .loggedInUser
                    .blockedMembers
                    .contains(user.sevaUserID) ||
                SevaCore.of(context)
                    .loggedInUser
                    .blockedBy
                    .contains(user.sevaUserID)) {
              return Offstage();
            } else {
              print(
                  "USER PERMITTED  ${SevaCore.of(context).loggedInUser.blockedMembers}  ${user.sevaUserID}");
            }

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
                        // ClipOval(
                        //     child: Container(
                        //   width: 30,
                        //   height: 30,
                        //   child: Image.network(user.photoURL),
                        // )),
                        // Image.asset('lib/assets/images/waiting.jpg'),
                        // ClipOval(
                        //   child: Container(
                        //     height: 45,
                        //     width: 45,
                        //     child: Image.network(
                        //         'http://bluefaqs.com/wp-content/uploads/2010/06/Conifer.jpg'),
                        //   ),
                        // ),
                        Container(width: 16),
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
    }
    // else if (chatModel.user2 == SevaCore.of(context).loggedInUser.email) {
    else if (chatModel.user2 == "anita.beberg@gmail.com") {
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

            if (SevaCore.of(context)
                    .loggedInUser
                    .blockedMembers
                    .contains(user.sevaUserID) ||
                SevaCore.of(context)
                    .loggedInUser
                    .blockedBy
                    .contains(user.sevaUserID)) {
              print("USER BLOCKED");
            } else {
              print(
                  "USER PERMITTED 2-> ${SevaCore.of(context).loggedInUser.blockedMembers}  ${user.email}");
            }

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

  Future<void> _ackAlert(String email, ChatModel chatModel,
      BuildContext context, String communityId) {
    print("Hello alert");
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete chat'),
          content: const Text('Are you sure you want to delete this chat'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Delete',
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () async {
                var participants = [];
                participants.add(chatModel.user1);
                participants.add(chatModel.user2);

                participants.sort();

                var messageId =
                    "${participants[0]}*${participants[1]}*${FlavorConfig.values.timebankId}*$communityId";

                Map<dynamic, dynamic> unreadCount = HashMap();
                unreadCount = chatModel.unreadStatus;
                unreadCount[email] = 0;

                Navigator.of(context).pop();
                await Firestore.instance
                    .collection("chatsnew")
                    .document(messageId)
                    .updateData({
                  'unread_status': unreadCount,
                  'softDeletedBy': FieldValue.arrayUnion(
                    [email],
                  )
                });
                chatModel.deletedBy[email] =
                    DateTime.now().millisecondsSinceEpoch;

                await Firestore.instance
                    .collection("chatsnew")
                    .document(messageId)
                    .updateData({
                  'deletedBy': chatModel.deletedBy,
                });

                setState(() {
                  print("Update and remove the object from list");
                });
              },
            ),
          ],
        );
      },
    );
  }
}
