import 'dart:async';
import 'dart:core' as prefix0;
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/views/messages/chatview.dart';

Future<void> createChat({
  @required ChatModel chat,
}) async {
  return await Firestore.instance
      .collection('chatsnew')
      .document(
          "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
      .setData(chat.toMap(), merge: true);
}

Future<void> updateChat({@required ChatModel chat, String userId}) async {
  String key = chat.participants[0] != userId
      ? chat.participants[0]
      : chat.participants[1];
  return await Firestore.instance
      .collection('chatsnew')
      .document(
          "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
      .setData(
    {
      'softDeletedBy': chat.softDeletedBy,
      'lastMessage': chat.lastMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      "unreadStatus": {
        key: FieldValue.increment(1),
      }
    },
    merge: true,
  );

  // .setData(
  //   {
  //     'notificationId' : {
  //       'userId' : {
  //         'claimedId' : "xyz"
  //       }
  //     }

  //   }
}

Future<void> createNewChat({
  @required ChatModel chat,
}) async {
  return await Firestore.instance
      .collection('chatsnew')
      .document(
          "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
      .setData(
        chat.toMap(),
        merge: true,
      );
}

//tested and working
/// Update a [chat]

// Future<void> updateMessageUnReadStatus({
//   @required ChatModel chat,
//   @required String userId,
// }) async {
//   String key = chat.participants[0] != userId
//       ? chat.participants[0]
//       : chat.participants[1];
//   await Firestore.instance
//       .collection("chatsnew")
//       .document(
//           "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
//       .setData({
//     "unreadStatus": {
//       key: FieldValue.increment(1),
//     }
//   }, merge: true);
// }

// updating chatcommunity Id
/// Update a [chat]
Future<void> markMessageAsRead({
  @required ChatModel chat,
  @required String userId,
}) async {
  return Firestore.instance
      .collection('chatsnew')
      .document(
          "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
      .setData(
    {
      'unreadStatus': {userId: 0}
    },
    merge: true,
  );
}

Future<void> createNewMessage({
  @required String chatId,
  @required String recieverId,
  @required MessageModel messageModel,
  @required bool isAdmin,
  @required timebankId,
  bool isTimebankMessage = false,
}) async {
  WriteBatch batch = Firestore.instance.batch();

  //Create new messages
  batch.setData(
    Firestore.instance
        .collection('chatsnew')
        .document(chatId)
        .collection('messages')
        .document(),
    messageModel.toMap(),
  );

  //if sender is admin , mark the previous messages as read

  if (isAdmin) {
    batch.setData(
      Firestore.instance.collection("timebanknew").document(timebankId),
      {
        "unreadMessages": FieldValue.arrayRemove([chatId]),
        // "lastMessageTimestamp": null,
      },
      merge: true,
    );
    batch.setData(
      Firestore.instance.collection("chatsnew").document(chatId),
      {
        "unreadStatus": {
          timebankId: 0,
        },
      },
      merge: true,
    );
  }

  //if timebank message add it to timebankModel for count purpose
  if (isTimebankMessage && !isAdmin) {
    batch.setData(
      Firestore.instance.collection("timebanknew").document(timebankId),
      {
        "unreadMessages": FieldValue.arrayUnion([chatId]),
        "lastMessageTimestamp": FieldValue.serverTimestamp(),
      },
      merge: true,
    );
  }

  //update chat with last message, timestamp and unreadStatus
  batch.setData(
    Firestore.instance.collection("chatsnew").document(chatId),
    {
      'lastMessage': messageModel.message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      "unreadStatus": {
        recieverId: FieldValue.increment(1),
      },
    },
    merge: true,
  );
  batch.commit();
}

Stream<List<MessageModel>> getMessagesforChat({
  @required ChatModel chat,
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
