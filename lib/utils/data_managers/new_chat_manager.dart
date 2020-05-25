import 'dart:async';
import 'dart:collection';
import 'dart:core' as prefix0;
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/new_chat_model.dart' as prefix;
import 'package:sevaexchange/views/messages/chatview.dart';

Future<void> createChat({
  @required prefix.ChatModel chat,
}) async {
  return await Firestore.instance
      .collection('chatsnew')
      .document(
          "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
      .setData(chat.toMap(), merge: true);
}

Future<void> updateChat(
    {@required prefix.ChatModel chat, String userId}) async {
  return await Firestore.instance
      .collection('chatsnew')
      .document(
          "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
      .updateData({
    'softDeletedBy': chat.softDeletedBy,
    'lastMessage': chat.lastMessage,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
}

@Deprecated("Feature not implemmented yet")
Future<void> updateReadStatus(prefix.ChatModel chat, String userId) async {
  return await Firestore.instance
      .collection("chatsnew")
      .document(
          "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
      .get()
      .then((messageModel) {
    prefix.ChatModel chatModel = prefix.ChatModel.fromMap(messageModel.data);
    Map<dynamic, dynamic> unreadCount = HashMap();
    unreadCount = chatModel.unreadStatus;
    chat.unreadStatus[userId] = 0;
  });
}

//tested and working
/// Update a [chat]

Future<void> updateMessagingReadStatus({
  @required prefix.ChatModel chat,
  @required String userId,
  @required String userEmail,
  bool isAdmin = false,
  bool once = false,
}) async {
  await Firestore.instance
      .collection("chatsnew")
      .document(
          "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
      .get()
      .then((messageModel) {
    prefix.ChatModel chatModel = prefix.ChatModel.fromMap(messageModel.data);
    //Data retrieved from firebase of chat model

    //Frame the updated data count
    var lastUnreadCount = chatModel.unreadStatus[userEmail] == null
        ? 0
        : chatModel.unreadStatus[userEmail];

    prefix0.Map<String, int> unreadStatus = HashMap();
    unreadStatus[userId] = 0;
    unreadStatus[userEmail] = once ? lastUnreadCount : lastUnreadCount + 1;

    //
    return Firestore.instance
        .collection('chatsnew')
        .document(
            "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
        .updateData({'unread_status': unreadStatus});
  });
}

// updating chatcommunity Id
/// Update a [chat]
Future<void> updateMessagingReadStatusForMe({
  @required prefix.ChatModel chat,
  @required String userId,
  @required String userEmail,
}) async {
  await Firestore.instance
      .collection("chatsnew")
      .document(
          "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
      .get()
      .then((messageModel) {
    prefix.ChatModel chatModel = prefix.ChatModel.fromMap(messageModel.data);
    //Data retrieved from firebase of chat model

    prefix0.Map<dynamic, dynamic> unreadStatus = HashMap();
    unreadStatus = chatModel.unreadStatus;
    unreadStatus[userId] = 0;
    //

    return Firestore.instance
        .collection('chatsnew')
        .document(
            "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
        .updateData({
      'unread_status': unreadStatus,
      //   'location': chat.candidateLocation != null
      //       ? chat.candidateLocation.data
      //       : GeoFirePoint(40.754387, -73.984291).data
    });
  });
}

//Create a message
Future<void> createmessage({
  @required prefix.ChatModel chat,
  @required MessageModel messagemodel,
}) async {
  // log.i(
  var docId =
      "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}";
  return await Firestore.instance
      .collection('chatsnew')
      .document(docId)
      .collection('messages')
      .document()
      .setData(messagemodel.toMap());
}

Stream<List<MessageModel>> getMessagesforChat({
  @required prefix.ChatModel chat,
  String userId,
  IsFromNewChat isFromNewChat,
}) async* {
  print('getMessagesforChat: chatModel: $chat');
  var data = Firestore.instance
      .collection('chatsnew')
      .document(
          "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
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

        if (chat.deletedBy != null && chat.deletedBy.containsKey(userId)) {
          var timestamp = chat.deletedBy[userId];

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
