import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/message/bloc/chat_model_sync_singleton.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class ChatsRepository {
  static CollectionReference collectionReference = CollectionRef.chats;

  static Stream<List<ChatModel>> getPersonalChats(
      {required String userId, required String communityId}) async* {
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
        logger.i("${personal.docs.length}:${public.docs.length}");

        return [...personal.docs, ...public.docs];
      },
    );

    yield* data.transform(
      StreamTransformer<List<DocumentSnapshot>, List<ChatModel>>.fromHandlers(
        handleData: (docs, sink) {
          List<ChatModel> chats = [];
          for (var chatDocument in docs) {
            var chat =
                ChatModel.fromMap(chatDocument.data() as Map<String, dynamic>);
            chat.id = chatDocument.id;
            if (chat.interCommunity ?? false) {
              if (!(chat.showToCommunities?.contains(communityId) ?? false)) {
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
      {String? documentId}) async {
    DocumentReference ref = collectionReference.doc(documentId);
    await ref.set(
      chat.toMap(),
      SetOptions(merge: true),
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
      SetOptions(merge: true),
    );
  }

  static Future<void> transferOwnership(String chatId) async {
    DocumentSnapshot result = await collectionReference.doc(chatId).get();
    ChatModel chatModel =
        ChatModel.fromMap(result.data() as Map<String, dynamic>);
    if ((chatModel.participants?.length ?? 0) > 0) {
      await collectionReference.doc(chatId).set(
        {
          "groupDetails": {
            "admins": FieldValue.arrayUnion(
              [
                chatModel.participants![
                    Random().nextInt(chatModel.participants!.length)],
              ],
            )
          },
        },
        SetOptions(merge: true),
      );
    }
  }

  static Future<void> addMember(String chatId, ParticipantInfo userInfo) async {
    return await collectionReference.doc(chatId).set(
      {
        "participantInfo": FieldValue.arrayUnion([userInfo.toMap()]),
        "participants": FieldValue.arrayUnion([userInfo.id])
      },
      SetOptions(merge: true),
    );
  }

  static Future<ChatModel> getChatModel(String chatId) async {
    DocumentSnapshot result = await collectionReference.doc(chatId).get();
    return ChatModel.fromMap(result.data() as Map<String, dynamic>);
  }

  static Stream<List<ChatModel>> getParentChildChats(String timebankId) async* {
    var data = collectionReference
        .where("isParentChildCommunication", isEqualTo: true)
        .where("participants", arrayContains: timebankId)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<ChatModel>>.fromHandlers(
        handleData: (data, sink) {
          List<ChatModel> chats = [];
          data.docs.forEach((element) {
            var chat =
                ChatModel.fromMap(element.data() as Map<String, dynamic>);
            chat.id = element.id;
            chats.add(chat);
          });
          sink.add(chats);
          ChatModelSync chatModelSync = ChatModelSync();
          chatModelSync.addChatModels(chats);
        },
      ),
    );
  }

  static Future<void> editGroup(
    String chatId,
    String? groupName,
    String? imageUrl,
    List<ParticipantInfo>? infos,
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
        SetOptions(merge: true),
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
        SetOptions(merge: true),
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
        SetOptions(merge: true),
      );
    }
    return batch.commit();
  }
}
