import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class ChatsRepository {
  static CollectionReference collectionReference = CollectionRef.chats;

  static Stream<List<ChatModel>> getPersonalChats(
      {@required String userId, @required String communityId}) async* {
    var personalChats = collectionReference
        .where("participants", arrayContains: userId)
        .where("communityId", isEqualTo: communityId)
        .snapshots();

    var publicChats = collectionReference
        .where('interCommunity', isEqualTo: true)
        .where("participants", arrayContains: userId)
        .snapshots();

    var data = CombineLatestStream.combine2<QuerySnapshot, QuerySnapshot,
        List<DocumentSnapshot>>(
      personalChats,
      publicChats,
      (personal, public) {
        logger.i("${personal.documents.length}:${public.documents.length}");

        return [...personal.documents, ...public.documents];
      },
    );

    yield* data.transform(
      StreamTransformer<List<DocumentSnapshot>, List<ChatModel>>.fromHandlers(
        handleData: (documents, sink) {
          List<ChatModel> chats = [];
          for (var chatDocument in documents) {
            var chat = ChatModel.fromMap(chatDocument.data());
            chat.id = chatDocument.id;
            if (chat.interCommunity) {
              if (!chat.showToCommunities.contains(communityId)) {
                continue;
              }
            }
            chats.add(chat);
          }
          sink.add(chats);
        },
      ),
    );
  }

  static Future<String> createNewChat(ChatModel chat,
      {String documentId}) async {
    DocumentReference ref = collectionReference.doc(documentId);
    await ref.set(
      chat.toMap(),
      merge: true,
    );
    return ref.id;
  }

  static Future<void> removeMember(String chatId, String userId) async {
    return await collectionReference.doc(chatId).set(
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
    DocumentSnapshot result = await collectionReference.doc(chatId).get();
    ChatModel chatModel = ChatModel.fromMap(result.data());
    if (chatModel.participants.length > 0) {
      await collectionReference.doc(chatId).set(
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
    return await collectionReference.doc(chatId).set(
      {
        "participantInfo": FieldValue.arrayUnion([userInfo.toMap()]),
        "participants": FieldValue.arrayUnion([userInfo.id])
      },
      merge: true,
    );
  }

  static Future<ChatModel> getChatModel(String chatId) async {
    DocumentSnapshot result = await collectionReference.doc(chatId).get();
    return ChatModel.fromMap(result.data());
  }

  static Future<void> editGroup(
    String chatId,
    String groupName,
    String imageUrl,
    List<ParticipantInfo> infos,
  ) async {
    WriteBatch batch = CollectionRef.batch;
    if (groupName != null) {
      batch.set(
        collectionReference.doc(chatId),
        {
          "groupDetails": {
            "name": groupName,
          }
        },
        merge: true,
      );
    }
    if (imageUrl != null) {
      batch.set(
        collectionReference.doc(chatId),
        {
          "groupDetails": {
            "imageUrl": imageUrl,
          }
        },
        merge: true,
      );
    }

    if (infos != null) {
      batch.set(
        collectionReference.doc(chatId),
        {
          "participantInfo": FieldValue.arrayUnion(
            List<dynamic>.from(
              infos.map(
                (x) => (x..type = ChatType.TYPE_MULTI_USER_MESSAGING).toMap(),
              ),
            ),
          ),
          "participants": List<dynamic>.from(infos.map((x) => x.id))
        },
        merge: true,
      );
    }
    return batch.commit();
  }
}
