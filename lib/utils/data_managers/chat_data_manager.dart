import 'dart:collection';
import 'dart:core' as prefix0;
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';

import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/chatview.dart';
import 'package:sevaexchange/views/splash_view.dart';

/// Create a [chat]
Future<void> createChat({
  @required ChatModel chat,
}) async {
  // log.i('createChat: MessageModel: ${chat.toMap()}');
  chat.rootTimebank = FlavorConfig.values.timebankId;
  return await Firestore.instance
      .collection('chatsnew')
      .document(
          chat.user1 + '*' + chat.user2 + '*' + FlavorConfig.values.timebankId)
      .setData(chat.toMap(), merge: true);
}

/// Update a [chat]
Future<void> updateChat({@required ChatModel chat, String email}) async {
  return await Firestore.instance
      .collection('chatsnew')
      .document(
          chat.user1 + '*' + chat.user2 + '*' + FlavorConfig.values.timebankId)
      .updateData({
    'softDeletedBy': chat.softDeletedBy,
    'user1': chat.user1,
    'user2': chat.user2,
    'lastMessage': chat.lastMessage,
    'rootTimebank': chat.rootTimebank,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
}

Future<void> updateReadStatus(ChatModel chat, String email) async {
  return await Firestore.instance
      .collection("chatsnew")
      .document(
        chat.user1 + '*' + chat.user2 + '*' + FlavorConfig.values.timebankId,
      )
      .get()
      .then((messageModel) {
    ChatModel chatModel = ChatModel.fromMap(messageModel.data);
    Map<dynamic, dynamic> unreadCount = HashMap();
    unreadCount = chatModel.unreadStatus;
    chat.unreadStatus[email] = 0;
  });
}

/// Update a [chat]
Future<void> updateMessagingReadStatus({
  @required ChatModel chat,
  @required String email,
  @required String userEmail,
}) async {
  await Firestore.instance
      .collection("chatsnew")
      .document(
        chat.user1 + '*' + chat.user2 + '*' + FlavorConfig.values.timebankId,
      )
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
        .document(chat.user1 +
            '*' +
            chat.user2 +
            '*' +
            FlavorConfig.values.timebankId)
        .updateData({'unread_status': unreadStatus});
  });
}

/// Update a [chat]
Future<void> updateMessagingReadStatusForMe({
  @required ChatModel chat,
  @required String email,
  @required String userEmail,
}) async {
  await Firestore.instance
      .collection("chatsnew")
      .document(
        chat.user1 + '*' + chat.user2 + '*' + FlavorConfig.values.timebankId,
      )
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
        .document(chat.user1 +
            '*' +
            chat.user2 +
            '*' +
            FlavorConfig.values.timebankId)
        .updateData({'unread_status': unreadStatus});
  });
}

//Create a message
Future<void> createmessage({
  @required ChatModel chatmodel,
  @required MessageModel messagemodel,
}) async {
  // log.i(
  //'createmessage: ChatModel: ${chatmodel.toMap()} \n MessageModel: ${messagemodel.toMap()}');
  return await Firestore.instance
      .collection('chatsnew')
      .document(chatmodel.user1 +
          '*' +
          chatmodel.user2 +
          '*' +
          FlavorConfig.values.timebankId)
      .collection('messages')
      .document()
      .setData(messagemodel.toMap());
}

//Get chats for a user
Stream<List<ChatModel>> getChatsforUser({
  @required String email,
  @required List<String> blockedBy,
  @required List<String> blockedMembers,
}) async* {
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
            var sevaUserId = onValue[i]['sevauserid'];

            chatlist[i].messagTitleUserName = onValue[i]['fullname'];
            chatlist[i].photoURL = onValue[i]['photourl'];

            chatlist[i].isBlocked = (blockedBy.contains(sevaUserId) ||
                blockedMembers.contains(sevaUserId));
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
      .collection("users")
      .document(userEmail)
      .get()
      .then((onValue) {
    return onValue;
  });
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
      .document(chatModel.user1 +
          '*' +
          chatModel.user2 +
          '*' +
          FlavorConfig.values.timebankId)
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
