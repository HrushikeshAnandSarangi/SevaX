import 'dart:async';
import 'dart:collection';
import 'dart:core' as prefix0;
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/views/messages/chatview.dart';

/// Create a [chat]
Future<void> createChat({
  @required ChatModel chat,
}) async {
//tested and working for multiple communities
  // prefix0.print("${chat.communityId}-------------------------------------------------------------------");
  // log.i('createChat: MessageModel: ${chat.toMap()}');
  chat.rootTimebank = FlavorConfig.values.timebankId;
  print("creating a new chat for ${chat}");



  return await Firestore.instance
      .collection('chatsnew')
      .document(
          "${chat.user1}*${chat.user2}*${FlavorConfig.values.timebankId}*${chat.communityId}")
      .setData(chat.toMap(), merge: true);
}

//tested and working for multiple communities
/// Update a [chat]
Future<void> updateChat({@required ChatModel chat, String email}) async {
  return await Firestore.instance
      .collection('chatsnew')
      .document(
          "${chat.user1}*${chat.user2}*${FlavorConfig.values.timebankId}*${chat.communityId}")
      .updateData({
    'softDeletedBy': chat.softDeletedBy,
    'user1': chat.user1,
    'user2': chat.user2,
    'lastMessage': chat.lastMessage,
    'rootTimebank': chat.rootTimebank,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
}

@Deprecated("Feature not implemmented yet")
Future<void> updateReadStatus(ChatModel chat, String email) async {
  return await Firestore.instance
      .collection("chatsnew")
      .document(
          "${chat.user1}*${chat.user2}*${FlavorConfig.values.timebankId}*${chat.communityId}")
      .get()
      .then((messageModel) {
    ChatModel chatModel = ChatModel.fromMap(messageModel.data);
    Map<dynamic, dynamic> unreadCount = HashMap();
    unreadCount = chatModel.unreadStatus;
    chat.unreadStatus[email] = 0;
  });
}

//tested and working
/// Update a [chat]

Future<void> updateMessagingReadStatus({
  @required ChatModel chat,
  @required String email,
  @required String userEmail,
  bool isAdmin = false
}) async {
  await Firestore.instance
      .collection("chatsnew")
      .document(
          "${chat.user1}*${chat.user2}*${FlavorConfig.values.timebankId}*${chat.communityId}")
      .get()
      .then((messageModel) {
    ChatModel chatModel = ChatModel.fromMap(messageModel.data);
    //Data retrieved from firebase of chat model

    //Frame the updated data count
    var lastUnreadCount = chatModel.unreadStatus[userEmail] == null
        ? 0
        : chatModel.unreadStatus[userEmail];

    prefix0.Map<String, int> unreadStatus = HashMap();
    unreadStatus[email] = 0;
    unreadStatus[userEmail] = lastUnreadCount + 1;

    //
    return Firestore.instance
        .collection('chatsnew')
        .document(
            "${chat.user1}*${chat.user2}*${FlavorConfig.values.timebankId}*${chat.communityId}")
        .updateData({'unread_status': unreadStatus});
  });
}

// updating chatcommunity Id
/// Update a [chat]
Future<void> updateMessagingReadStatusForMe({
  @required ChatModel chat,
  @required String email,
  @required String userEmail,
}) async {
  await Firestore.instance
      .collection("chatsnew")
      .document(
          "${chat.user1}*${chat.user2}*${FlavorConfig.values.timebankId}*${chat.communityId}")
      .get()
      .then((messageModel) {
    ChatModel chatModel = ChatModel.fromMap(messageModel.data);
    //Data retrieved from firebase of chat model

    prefix0.Map<dynamic, dynamic> unreadStatus = HashMap();
    unreadStatus = chatModel.unreadStatus;
    unreadStatus[email] = 0;
    //

    return Firestore.instance
        .collection('chatsnew')
        .document(
            "${chat.user1}*${chat.user2}*${FlavorConfig.values.timebankId}*${chat.communityId}")
        .updateData({'unread_status': unreadStatus});
  });
}

//Create a message
Future<void> createmessage({
  @required ChatModel chatmodel,
  @required MessageModel messagemodel,
}) async {
  // log.i(
  var docId =
      "${chatmodel.user1}*${chatmodel.user2}*${FlavorConfig.values.timebankId}*${chatmodel.communityId}";
  return await Firestore.instance
      .collection('chatsnew')
      .document(docId)
      .collection('messages')
      .document()
      .setData(messagemodel.toMap());
}

//Get chats for a user
Stream<List<ChatModel>> getChatsforUser({
  @required String email,
  @required List<String> blockedBy,
  @required List<String> blockedMembers,
  @required String communityId,
}) async* {
  prefix0.print("Community id is here ---> $communityId");

  var data = Firestore.instance
      .collection('chatsnew')
      // .where('communityId', isEqualTo: communityId)
      .orderBy('timestamp', descending: true)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<ChatModel>>.fromHandlers(
      handleData: (snapshot, chatSink) async {
        var futures = <Future>[];
        List<ChatModel> chatlist = [];
        chatlist.clear();
        snapshot.documents.forEach(
          (documentSnapshot) async {
            ChatModel model = ChatModel.fromMap(documentSnapshot.data);
            if (model.communityId != communityId) return;

            if ((model.user1 == email || model.user2 == email) &&
                model.lastMessage != null &&
                model.rootTimebank == FlavorConfig.values.timebankId &&
                !model.softDeletedBy.contains(
                  email,
                )) {
              if (model.user1 == email) {
                futures.add(getUserInfo(model.user2));
              }
              if (model.user2 == email) {
                futures.add(getUserInfo(model.user1));
              }

              chatlist.add(model);
            }

            // email = "anitha.beberg@gmail.com";
            // if ((model.user1 == "anitha.beberg@gmail.com" ||
            //         model.user2 == "anitha.beberg@gmail.com") &&
            //     model.lastMessage != null &&
            //     model.rootTimebank == FlavorConfig.values.timebankId) {
            //   if (model.user1 == email) {
            //     futures.add(getUserInfo(model.user2));
            //   }
            //   if (model.user2 == email) {
            //     futures.add(getUserInfo(model.user1));
            //   }
            //   chatlist.add(model);
            // }
          },
        );
        await Future.wait(futures).then((onValue) {
          var i = 0;
          while (i < chatlist.length) {
            ///checking if this is a timebank data or user data

            if (onValue[i]['address'] != null) {
              // var sevaUserId = onValue[i]['sevauserid'];
              chatlist[i].messagTitleUserName = onValue[i]['name'];
              chatlist[i].photoURL = onValue[i]['photo_url'];
              chatlist[i].isBlocked = false;
            } else {
              ///User Data
              var sevaUserId = onValue[i]['sevauserid'];
              chatlist[i].messagTitleUserName = onValue[i]['fullname'];
              chatlist[i].photoURL = onValue[i]['photourl'];
              chatlist[i].isBlocked = (blockedBy.contains(sevaUserId) ||
                  blockedMembers.contains(sevaUserId));
            }
            i++;

            ///timebank Data

          }
          chatSink.add(chatlist);
        });
      },
    ),
  );
}

//Get chats for a user
Stream<List<ChatModel>> getChatsForTimebank({
  @required String timebankId,
  @required String communityId,
}) async* {
  prefix0.print("Community id is here ---> $communityId");

  var data = Firestore.instance
      .collection('chatsnew')
      .orderBy('timestamp', descending: true)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<ChatModel>>.fromHandlers(
      handleData: (snapshot, chatSink) async {
        var futures = <Future>[];
        List<ChatModel> chatlist = [];
        chatlist.clear();
        snapshot.documents.forEach(
          (documentSnapshot) async {
            ChatModel model = ChatModel.fromMap(documentSnapshot.data);
            if (model.communityId != communityId) return;

            if ((model.user1 == timebankId || model.user2 == timebankId) &&
                model.lastMessage != null &&
                model.rootTimebank == FlavorConfig.values.timebankId &&
                !model.softDeletedBy.contains(
                  timebankId,
                )) {
              if (model.user1 == timebankId) {
                ///checking if the second person is a timebank
                if (isValidEmail(model.user1)) {
                  futures.add(getUserInfo(model.user2));
                } else {
                  futures.add(getUserInfo(model.user2));
                }
              }
              if (model.user2 == timebankId) {
                ///checking if the second person is a timebank
                if (isValidEmail(model.user1)) {
                  futures.add(getUserInfo(model.user1));
                } else {
                  futures.add(getUserInfo(model.user1));
                }
              }
              chatlist.add(model);
            }

            // email = "anitha.beberg@gmail.com";
            // if ((model.user1 == "anitha.beberg@gmail.com" ||
            //         model.user2 == "anitha.beberg@gmail.com") &&
            //     model.lastMessage != null &&
            //     model.rootTimebank == FlavorConfig.values.timebankId) {
            //   if (model.user1 == email) {
            //     futures.add(getUserInfo(model.user2));
            //   }
            //   if (model.user2 == email) {
            //     futures.add(getUserInfo(model.user1));
            //   }
            //   chatlist.add(model);
            // }
          },
        );
        await Future.wait(futures).then((onValue) {
          var i = 0;
          while (i < chatlist.length) {
            // var sevaUserId = onValue[i]['sevauserid'];

            chatlist[i].messagTitleUserName = onValue[i]['fullname'];
            chatlist[i].photoURL = onValue[i]['photourl'];

            // chatlist[i].isBlocked = (blockedBy.contains(sevaUserId) ||
            //     blockedMembers.contains(sevaUserId));
            chatlist[i].isBlocked = false;
            i++;
          }
          chatSink.add(chatlist);
        });
      },
    ),
  );
}

Future<DocumentSnapshot> getUserInfo(String userEmail) {
  return Firestore.instance
      .collection(isValidEmail(userEmail) ? "users" : "timebanknew")
      .document(userEmail)
      .get()
      .then((onValue) {
    return onValue;
  });
}

bool isValidEmail(String email) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
}

//Get Messages for a chat
Stream<List<MessageModel>> getMessagesforChat({
  @required ChatModel chatModel,
  String email,
  IsFromNewChat isFromNewChat,
}) async* {
  print('getMessagesforChat: chatModel: $chatModel');
  var data = Firestore.instance
      .collection('chatsnew')
      .document(
          "${chatModel.user1}*${chatModel.user2}*${FlavorConfig.values.timebankId}*${chatModel.communityId}")
      .collection('messages')
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<MessageModel>>.fromHandlers(
      handleData: (snapshot, messageSink) {
        List<MessageModel> messagelist = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            MessageModel model = MessageModel.fromMap(documentSnapshot.data);
            messagelist.add(model);
            messagelist.sort((m1, m2) {
              return m1.timestamp.compareTo(m2.timestamp);
            });
          },
        );

        if (chatModel.deletedBy != null &&
            chatModel.deletedBy.containsKey(email)) {
          var timestamp = chatModel.deletedBy[email];

          List<MessageModel> filteredList = [];
          for (var i = 0; i < messagelist.length; i++) {
            messagelist[i].timestamp > timestamp
                ? filteredList.add(messagelist[i])
                : print("valid message");
          }
          messageSink.add(filteredList);
        } else if (isFromNewChat.isFromNewChat) {
          var timestamp = isFromNewChat.newChatTimeStamp;

          List<MessageModel> filteredList = [];
          for (var i = 0; i < messagelist.length; i++) {
            messagelist[i].timestamp > timestamp
                ? filteredList.add(messagelist[i])
                : print("valid message");
          }
          messageSink.add(filteredList);
        } else {
          messageSink.add(messagelist);
        }
      },
    ),
  );
}
