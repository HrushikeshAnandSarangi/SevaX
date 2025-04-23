import 'dart:async';
import 'dart:core' as prefix0;
import 'dart:core';
import 'dart:developer';
import 'package:universal_io/io.dart' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/message_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

Future<void> createChat({
  required ChatModel chat,
}) async {
  return await CollectionRef.chats
      .doc(
          "${chat.participants![0]}*${chat.participants![1]}*${chat.communityId}")
      .set(chat.toMap(), SetOptions(merge: true));
}

Future<void> updateChat({required ChatModel chat, String? userId}) async {
  String key = chat.participants![0] != userId
      ? chat.participants![0]
      : chat.participants![1];
  return await CollectionRef.chats
      .doc(
          "${chat.participants![0]}*${chat.participants![1]}*${chat.communityId}")
      .set(
    {
      'softDeletedBy': chat.softDeletedBy,
      'lastMessage': chat.lastMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      "unreadStatus": {
        key: FieldValue.increment(1),
      }
    },
    SetOptions(merge: true),
  );
}

Future<void> createNewChat({
  required ChatModel chat,
}) async {
  return await CollectionRef.chats
      .doc(
          "${chat.participants![0]}*${chat.participants![1]}*${chat.communityId}")
      .set(
        chat.toMap(),
        SetOptions(merge: true),
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
//   await CollectionRef
//       .chats
//       .doc(
//           "${chat.participants[0]}*${chat.participants[1]}*${chat.communityId}")
//       .set({
//     "unreadStatus": {
//       key: FieldValue.increment(1),
//     }
//   }, SetOptions(merge: true));
// }

// updating chatcommunity Id
/// Update a [chat]
Future<void> markMessageAsRead({
  required ChatModel chat,
  required String userId,
}) async {
  return CollectionRef.chats
      .doc(
          "${chat.participants![0]}*${chat.participants![1]}*${chat.communityId}")
      .set(
    {
      'unreadStatus': {userId: 0}
    },
    SetOptions(merge: true),
  );
}

Future<void> createNewMessage({
  required String chatId,
  required String senderId,
  required MessageModel messageModel,
  required bool isAdmin,
  required String timebankId,
  required List<String> participants,
  bool isTimebankMessage = false,
  io.File? file,
}) async {
  WriteBatch batch = CollectionRef.batch;
  DocumentReference messageRef =
      CollectionRef.chats.doc(chatId).collection('messages').doc();
  //Create new messages
  batch.set(
    messageRef,
    messageModel.toMap(),
  );
  //if sender is admin , mark the previous messages as read

  if (isAdmin) {
    batch.update(
      CollectionRef.timebank.doc(timebankId),
      {
        "unreadMessages": FieldValue.arrayRemove([chatId]),
        // "lastMessageTimestamp": null,
      },
    );
    batch.set(
      CollectionRef.chats.doc(chatId),
      {
        "unreadStatus": {
          timebankId: 0,
        },
      },
      SetOptions(merge: true),
    );
  }

  //if timebank message add it to timebankModel for count purpose
  if (isTimebankMessage && !isAdmin && timebankId != null) {
    batch.update(
      CollectionRef.timebank.doc(timebankId),
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

  batch.set(
    CollectionRef.chats.doc(chatId),
    {
      'lastMessage': messageModel.message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      "unreadStatus": unreadStatus,
    },
    SetOptions(merge: true),
  );
  batch.commit();

  if (messageModel.type == MessageType.IMAGE) {
    log(file!.path);
    log(messageRef.id);
    var reference = DateTime.now().toString();
    FirebaseStorage _storage = FirebaseStorage.instance;

    UploadTask _uploadTask =
        _storage.ref().child("chats/${reference}.png").putFile(file);
    String attachmentUrl = '';

    _uploadTask.then((value) async {
      attachmentUrl = await value.ref.getDownloadURL().then((value) {
        return value;
      });
      CollectionRef.chats
          .doc(chatId)
          .collection("messages")
          .doc(messageRef.id)
          .update(
        {"data": attachmentUrl},
      );
    });
    log(attachmentUrl);
  }
}

Future<DocumentSnapshot> getUserInfo(String userEmail) {
  if (isValidEmail(userEmail)) {
    return CollectionRef.users.doc(userEmail).get().then((onValue) {
      return onValue;
    });
  } else {
    return CollectionRef.timebank.doc(userEmail).get().then((onValue) {
      return onValue;
    });
  }
}

bool isValidEmail(String email) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
}
