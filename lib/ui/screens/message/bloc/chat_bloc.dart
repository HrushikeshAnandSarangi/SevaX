import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/message_model.dart';
import 'package:sevaexchange/utils/data_managers/new_chat_manager.dart';

class ChatBloc {
  final _messages = BehaviorSubject<List<MessageModel>>();

  Stream<List<MessageModel>> get messages => _messages.stream;

  // FirebaseStorage _storage = FirebaseStorage();

  Future<void> getAllMessages(String chatId, String userId) async {
    DocumentSnapshot chatModelSnapshot =
        await Firestore.instance.collection("chatsnew").document(chatId).get();
    print("chat data for $chatId => ${chatModelSnapshot.data}");
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
      _messages.add(messages);
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
      recieverId: recieverId,
      messageModel: messageModel,
      timebankId: chatModel.timebankId,
      isTimebankMessage: chatModel.isTimebankMessage,
      isAdmin: chatModel.timebankId == senderId,
      file: file,
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

  // Future<void> uploadImage(File _file, String chatId, String messageId) async {
  //   StorageUploadTask _uploadTask =
  //       _storage.ref().child("chats/${DateTime.now()}.png").putFile(_file);
  //   StorageTaskSnapshot snapshot = await _uploadTask.onComplete;
  //   String attachmentUrl = await snapshot.ref.getDownloadURL();
  //   Firestore.instance
  //       .collection("chatsnew")
  //       .document(chatId)
  //       .collection("messages")
  //       .document(messageId)
  //       .setData(
  //     {"data": attachmentUrl},
  //     merge: true,
  //   );
  // }

  void dispose() {
    _messages.close();
  }
}
