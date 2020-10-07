import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/chat_model.dart';

class ChatsRepository {
  static CollectionReference collectionReference =
      Firestore.instance.collection("chatsnew");

  static Future<String> createNewChat(ChatModel chat,
      {String documentId}) async {
    DocumentReference ref = collectionReference.document(documentId);
    await ref.setData(
      chat.toMap(),
      merge: true,
    );
    return ref.documentID;
  }

  static Future<void> removeMember(String chatId, String userId) async {
    return await collectionReference.document(chatId).setData(
      {
        "participants": FieldValue.arrayRemove([userId]),
        "groupDetails": {
          "admins": FieldValue.arrayRemove([userId]),
        }
      },
      merge: true,
    );
  }

  static Future<void> transferOwnership(String chatId) async {
    DocumentSnapshot result = await collectionReference.document(chatId).get();
    ChatModel chatModel = ChatModel.fromMap(result.data);
    if (chatModel.participants.length > 0) {
      await collectionReference.document(chatId).setData(
        {
          "groupDetails": {
            "admins": FieldValue.arrayUnion(
              [
                chatModel.participants[
                    Random().nextInt(chatModel.participants.length)],
              ],
            )
          },
        },
        merge: true,
      );
    }
  }

  static Future<void> addMember(String chatId, ParticipantInfo userInfo) async {
    return await collectionReference.document(chatId).setData(
      {
        "participantInfo": FieldValue.arrayUnion([userInfo.toMap()]),
        "participants": FieldValue.arrayUnion([userInfo.id])
      },
      merge: true,
    );
  }

  static Future<ChatModel> getChatModel(String chatId) async {
    DocumentSnapshot result = await collectionReference.document(chatId).get();
    return ChatModel.fromMap(result.data);
  }

  static Future<void> editGroup(
    String chatId,
    String groupName,
    String imageUrl,
    List<ParticipantInfo> infos,
  ) async {
    WriteBatch batch = Firestore.instance.batch();
    if (groupName != null) {
      batch.setData(
        collectionReference.document(chatId),
        {
          "groupDetails": {
            "name": groupName,
          }
        },
        merge: true,
      );
    }
    if (imageUrl != null) {
      batch.setData(
        collectionReference.document(chatId),
        {
          "groupDetails": {
            "imageUrl": imageUrl,
          }
        },
        merge: true,
      );
    }

    if (infos != null) {
      batch.setData(
        collectionReference.document(chatId),
        {
          "participantInfo": List<dynamic>.from(infos.map(
              (x) => (x..type = ChatType.TYPE_MULTI_USER_MESSAGING).toMap())),
          "participants": List<dynamic>.from(infos.map((x) => x.id))
        },
        merge: true,
      );
    }
    return batch.commit();
  }
}
