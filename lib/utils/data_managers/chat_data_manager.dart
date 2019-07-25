import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/main.dart';
import 'dart:async';
import 'package:meta/meta.dart';

import 'package:sevaexchange/models/models.dart';

/// Create a chat
Future<void> createChat({
  @required MessageModel chat,
}) async {
  return await Firestore.instance
      .collection('messages')
      .document(chat.user1 + '*' + chat.user2)
      .setData(chat.toMap(), merge: true);
}

/// Update a chat
Future<void> updateChat({
  @required MessageModel chat,
}) async {
  return await Firestore.instance
      .collection('messages')
      .document(chat.user1 + '*' + chat.user2)
      .updateData(chat.toMap());
}

//Create a message
Future<void> createmessage({
  @required ChatModel chatmodel,
  @required MessageModel messagemodel,
}) async {
  // List users = [chat.fromId,chat.toId];
  // users.sort();
  // String user1=users[0];
  // String user2=users[1];

  return await Firestore.instance
      .collection('messages')
      .document(messagemodel.user1 + '*' + messagemodel.user2)
      .collection('chats')
      .document()
      .setData(chatmodel.toMap());
}

//Get Messages for a user
Stream<List<MessageModel>> getMessagesforUser({
  @required String email,
}) async* {
  var data = Firestore.instance.collection('messages').snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<MessageModel>>.fromHandlers(
      handleData: (snapshot, messageSink) {
        List<MessageModel> messagelist = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            MessageModel model = MessageModel.fromMap(documentSnapshot.data);
            if ((model.user1 == email || model.user2 == email) &&
                model.lastMessage != null) {
              messagelist.add(model);
            }
          },
        );
        messageSink.add(messagelist);
      },
    ),
  );
}

//Get Messages for a chat
Stream<List<ChatModel>> getMessagesforChat({
  @required MessageModel messagemodel,
}) async* {
  var data = Firestore.instance
      .collection('messages')
      .document(messagemodel.user1 + '*' + messagemodel.user2)
      .collection('chats')
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<ChatModel>>.fromHandlers(
      handleData: (snapshot, messageSink) {
        List<ChatModel> chatlist = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            ChatModel model = ChatModel.fromMap(documentSnapshot.data);

            chatlist.add(model);
          },
        );
        messageSink.add(chatlist);
      },
    ),
  );
}
