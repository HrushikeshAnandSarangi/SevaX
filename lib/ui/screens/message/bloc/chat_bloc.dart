import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/message_model.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/repositories/chats_repository.dart';
import 'package:sevaexchange/repositories/user_repository.dart';
import 'package:sevaexchange/utils/data_managers/new_chat_manager.dart';

class ChatBloc {
  final _messages = BehaviorSubject<List<MessageModel>>();
  final _feedsCache = HashMap<String, NewsModel>();

  Stream<List<MessageModel>> get messages => _messages.stream;

  NewsModel getNewsModel(String id) {
    if (_feedsCache.containsKey(id)) {
      return _feedsCache[id];
    }
    return null;
  }

  void setNewsModel(NewsModel model) {
    _feedsCache.putIfAbsent(model.id, () => model);
  }

  Future<void> getAllMessages(String chatId, String userId) async {
    DocumentSnapshot chatModelSnapshot =
        await Firestore.instance.collection("chatsnew").document(chatId).get();
    ChatModel chatModel = ChatModel.fromMap(chatModelSnapshot.data);
    chatModel.id = chatModelSnapshot.documentID;
    Stream<QuerySnapshot> querySnapshot;

    if (chatModel.deletedBy.containsKey(userId)) {
      int timestamp = chatModel.deletedBy[userId];
      querySnapshot = Firestore.instance
          .collection('chatsnew')
          .document(chatModel.id)
          .collection('messages')
          .where("timestamp", isGreaterThan: timestamp)
          .orderBy("timestamp")
          .snapshots();
    } else {
      querySnapshot = Firestore.instance
          .collection('chatsnew')
          .document(chatModel.id)
          .collection('messages')
          .orderBy("timestamp")
          .snapshots();
    }
    querySnapshot.listen((QuerySnapshot event) {
      List<MessageModel> messages = [];
      event.documents.forEach((DocumentSnapshot document) {
        MessageModel model = MessageModel.fromMap(document.data);

        model.id = document.documentID;
        messages.add(model);
      });
      if (!_messages.isClosed) _messages.add(messages);
    });
  }

  Future<void> pushNewMessage({
    ChatModel chatModel,
    String messageContent,
    String senderId,
    String recieverId,
    MessageType type,
    File file,
  }) async {
    MessageModel messageModel = MessageModel(
      fromId: senderId,
      toId: recieverId,
      message: messageContent,
      type: type,
      timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
    );

    if (chatModel.isTimebankMessage) {}

    createNewMessage(
      chatId: chatModel.id,
      senderId: senderId,
      messageModel: messageModel,
      timebankId: senderId,
      isTimebankMessage: chatModel.isTimebankMessage,
      isAdmin: senderId.contains("-"), //timebank id contains "-"
      file: file,
      participants: chatModel.participants,
    );
  }

  Future<void> markMessageAsRead({
    String chatId,
    String userId,
  }) async {
    return Firestore.instance.collection('chatsnew').document(chatId).setData(
      {
        'unreadStatus': {userId: 0}
      },
      merge: true,
    );
  }

  Future<void> clearChat(String chatId, String userId) async {
    return Firestore.instance.collection('chatsnew').document(chatId).setData(
      {
        "softDeletedBy": FieldValue.arrayUnion([userId]),
        "deletedBy": {
          userId: DateTime.now().millisecondsSinceEpoch,
        }
      },
      merge: true,
    );
  }

  Future<void> blockMember({
    String loggedInUserEmail,
    String userId,
    String blockedUserId,
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
