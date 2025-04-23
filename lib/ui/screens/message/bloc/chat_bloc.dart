import 'dart:collection';
import 'package:universal_io/io.dart' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/message_model.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/repositories/chats_repository.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/user_repository.dart';
import 'package:sevaexchange/utils/data_managers/new_chat_manager.dart';

class ChatBloc {
  final _messages = BehaviorSubject<List<MessageModel>>();
  final _feedsCache = HashMap<String, NewsModel>();

  Stream<List<MessageModel>> get messages => _messages.stream;

  NewsModel? getNewsModel(String id) {
    if (_feedsCache.containsKey(id)) {
      return _feedsCache[id];
    }
    return null;
  }

  void setNewsModel(NewsModel model) {
    if (model.id != null) {
      _feedsCache.putIfAbsent(model.id!, () => model);
    }
  }

  Future<void> getAllMessages(String chatId, String userId) async {
    DocumentSnapshot chatModelSnapshot =
        await CollectionRef.chats.doc(chatId).get();
    final data = chatModelSnapshot.data();
    if (data == null) return;
    ChatModel chatModel = ChatModel.fromMap(data as Map<String, dynamic>);
    chatModel.id = chatModelSnapshot.id;
    Stream<QuerySnapshot> querySnapshot;

    if (chatModel.deletedBy != null &&
        chatModel.deletedBy!.containsKey(userId)) {
      int timestamp = chatModel.deletedBy![userId];
      querySnapshot = CollectionRef.chats
          .doc(chatModel.id)
          .collection('messages')
          .where("timestamp", isGreaterThan: timestamp)
          .orderBy("timestamp")
          .snapshots();
    } else {
      querySnapshot = CollectionRef.chats
          .doc(chatModel.id)
          .collection('messages')
          .orderBy("timestamp")
          .snapshots();
    }
    querySnapshot.listen((QuerySnapshot event) {
      List<MessageModel> messages = [];
      event.docs.forEach((DocumentSnapshot document) {
        final docData = document.data();
        if (docData != null) {
          MessageModel model =
              MessageModel.fromMap(docData as Map<String, dynamic>);
          model.id = document.id;
          messages.add(model);
        }
      });
      if (!_messages.isClosed) _messages.add(messages);
    });
  }

  Future<void> pushNewMessage({
    required ChatModel chatModel,
    required String messageContent,
    required String senderId,
    required String recieverId,
    required MessageType type,
    required io.File file,
    required String timebankId,
  }) async {
    MessageModel messageModel = MessageModel(
      fromId: senderId,
      toId: recieverId,
      message: messageContent,
      type: type,
      timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
    );

    if (chatModel.isTimebankMessage ?? false) {}

    createNewMessage(
      chatId: chatModel.id ?? '',
      senderId: senderId,
      messageModel: messageModel,
      timebankId: timebankId,
      isTimebankMessage: chatModel.isTimebankMessage ?? false,
      isAdmin: senderId.contains("-"), //timebank id contains "-"
      file: file,
      participants: chatModel.participants ?? <String>[],
    );
  }

  Future<void> markMessageAsRead({
    required String chatId,
    required String userId,
  }) async {
    return CollectionRef.chats.doc(chatId).set(
      {
        'unreadStatus': {userId: 0}
      },
      SetOptions(merge: true),
    );
  }

  Future<void> clearChat(String chatId, String userId) async {
    return CollectionRef.chats.doc(chatId).set(
      {
        "softDeletedBy": FieldValue.arrayUnion([userId]),
        "deletedBy": {
          userId: DateTime.now().millisecondsSinceEpoch,
        }
      },
      SetOptions(merge: true),
    );
  }

  Future<void> blockMember({
    required String loggedInUserEmail,
    required String userId,
    required String blockedUserId,
  }) async {
    return await UserRepository.blockUser(
      loggedInUserEmail: loggedInUserEmail,
      userId: userId,
      blockedUserId: blockedUserId,
    );
  }

  Future<void> removeMember(
    String chatId,
    String userId,
    bool isCreator,
  ) async {
    await ChatsRepository.removeMember(chatId, userId);
    if (isCreator) {
      await ChatsRepository.transferOwnership(chatId);
    }
  }

  Future<void> addMember(String chatId, ParticipantInfo participant) async {
    return await ChatsRepository.addMember(chatId, participant);
  }

  void dispose() {
    _messages.close();
  }
}
