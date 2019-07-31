import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:sevaexchange/base/base_service.dart';

import 'package:sevaexchange/models/models.dart';

class ChatsService extends BaseService {
  /// Create a [chat] 
  Future<void> createChat({
    @required ChatModel chat,
  }) async {
    log.i('createChat: MessageModel: ${chat.toMap()}');
    return await Firestore.instance
        .collection('chats')
        .document(chat.user1 + '*' + chat.user2)
        .setData(chat.toMap(), merge: true);
  }

  /// Update a [chat]
  Future<void> updateChat({
    @required ChatModel chat,
  }) async {
    log.i('updateChat: MessageModel: ${chat.toMap()}');
    return await Firestore.instance
        .collection('chats')
        .document(chat.user1 + '*' + chat.user2)
        .updateData(chat.toMap());
  }

/// Create a [messagemodel] using [chatmodel] to access the chat document 
  Future<void> createmessage({
    @required ChatModel chatmodel,
    @required MessageModel messagemodel,
  }) async {
    log.i(
        'createmessage: ChatModel: ${chatmodel.toMap()} \n MessageModel: ${messagemodel.toMap()}');
    return await Firestore.instance
        .collection('chats')
        .document(chatmodel.user1 + '*' + chatmodel.user2)
        .collection('messages')
        .document()
        .setData(messagemodel.toMap());
  }

/// Get [chatlist] for a [email]
  Stream<List<ChatModel>> getChatsforUser({
    @required String email,
  }) async* {
    log.i('getChatsforUser: Email: $email');
    var data = Firestore.instance.collection('chats').snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<ChatModel>>.fromHandlers(
        handleData: (snapshot, chatSink) {
          List<ChatModel> chatlist = [];
          snapshot.documents.forEach(
            (documentSnapshot) {
              ChatModel model = ChatModel.fromMap(documentSnapshot.data);
              if ((model.user1 == email || model.user2 == email) &&
                  model.lastMessage != null) {
                chatlist.add(model);
              }
            },
          );
          chatSink.add(chatlist);
        },
      ),
    );
  }

/// Get [messagelist] for a [chatModel]
  Stream<List<MessageModel>> getMessagesforChat({
    @required ChatModel chatModel,
  }) async* {
    log.i('getMessagesforChat: chatModel: $chatModel');
    var data = Firestore.instance
        .collection('messages')
        .document(chatModel.user1 + '*' + chatModel.user2)
        .collection('chats')
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<MessageModel>>.fromHandlers(
        handleData: (snapshot, messageSink) {
          List<MessageModel> messagelist = [];
          snapshot.documents.forEach(
            (documentSnapshot) {
              MessageModel model = MessageModel.fromMap(documentSnapshot.data);

              messagelist.add(model);
            },
          );
          messageSink.add(messagelist);
        },
      ),
    );
  }
}
