import 'dart:async';
import 'dart:core' as prefix0;
import 'dart:core';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/message_model.dart';

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
  @required String senderId,
  @required MessageModel messageModel,
  @required bool isAdmin,
  @required String timebankId,
  @required List<String> participants,
  bool isTimebankMessage = false,
  File file,
}) async {
  WriteBatch batch = Firestore.instance.batch();
  DocumentReference messageRef = Firestore.instance
      .collection('chatsnew')
      .document(chatId)
      .collection('messages')
      .document();
  //Create new messages
  batch.setData(
    messageRef,
    messageModel.toMap(),
  );
  //if sender is admin , mark the previous messages as read

  if (isAdmin) {
    batch.updateData(
      Firestore.instance.collection("timebanknew").document(timebankId),
      {
        "unreadMessages": FieldValue.arrayRemove([chatId]),
        // "lastMessageTimestamp": null,
      },
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
  if (isTimebankMessage && !isAdmin && timebankId != null) {
    batch.updateData(
      Firestore.instance.collection("timebanknew").document(timebankId),
      {
        "unreadMessages": FieldValue.arrayUnion([chatId]),
        "lastMessageTimestamp": FieldValue.serverTimestamp(),
      },
    );
  }

  //update chat with last message, timestamp and unreadStatus

  Map<String, FieldValue> unreadStatus = Map<String, FieldValue>.fromIterable(
    participants,
    key: (id) => id,
    value: (_) => FieldValue.increment(1),
  )..remove(senderId);

  batch.setData(
    Firestore.instance.collection("chatsnew").document(chatId),
    {
      'lastMessage': messageModel.message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      "unreadStatus": unreadStatus,
    },
    merge: true,
  );
  batch.commit();

  if (messageModel.type == MessageType.IMAGE) {
    log(file.path);
    log(messageRef.documentID);
    log("started upload");
    FirebaseStorage _storage = FirebaseStorage();
    StorageUploadTask _uploadTask =
        _storage.ref().child("chats/${DateTime.now()}.png").putFile(file);
    StorageTaskSnapshot snapshot = await _uploadTask.onComplete;
    String attachmentUrl = await snapshot.ref.getDownloadURL();
    log(attachmentUrl);
    Firestore.instance
        .collection("chatsnew")
        .document(chatId)
        .collection("messages")
        .document(messageRef.documentID)
        .setData(
      {"data": attachmentUrl},
      merge: true,
    );
  }
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
