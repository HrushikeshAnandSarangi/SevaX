import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';

import 'package:sevaexchange/models/models.dart';

/// Create a [chat]
Future<void> createChat({
  @required ChatModel chat,
}) async {
  // log.i('createChat: MessageModel: ${chat.toMap()}');
  chat.rootTimebank = FlavorConfig.values.timebankId;
  return await Firestore.instance
      .collection('chatsnew')
      .document(
          chat.user1 + '*' + chat.user2 + '*' + FlavorConfig.values.timebankId)
      .setData(chat.toMap(), merge: true);
}

/// Update a [chat]
Future<void> updateChat({
  @required ChatModel chat,
}) async {
  // log.i('updateChat: MessageModel: ${chat.toMap()}');
  return await Firestore.instance
      .collection('chatsnew')
      .document(
          chat.user1 + '*' + chat.user2 + '*' + FlavorConfig.values.timebankId)
      .updateData(chat.toMap());
}

//Create a message
Future<void> createmessage({
  @required ChatModel chatmodel,
  @required MessageModel messagemodel,
}) async {
  // log.i(
  //'createmessage: ChatModel: ${chatmodel.toMap()} \n MessageModel: ${messagemodel.toMap()}');
  return await Firestore.instance
      .collection('chatsnew')
      .document(chatmodel.user1 +
          '*' +
          chatmodel.user2 +
          '*' +
          FlavorConfig.values.timebankId)
      .collection('messages')
      .document()
      .setData(messagemodel.toMap());
}

//Get chats for a user
Stream<List<ChatModel>> getChatsforUser({
  @required String email, 
}) async* {
  // log.i('getChatsforUser: Email: $email');
  var data = Firestore.instance.collection('chatsnew').snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<ChatModel>>.fromHandlers(
      handleData: (snapshot, chatSink) {
        List<ChatModel> chatlist = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            ChatModel model = ChatModel.fromMap(documentSnapshot.data);
              print("executing chat size ${snapshot.documents.length}");
              if ((model.user1 == email || model.user2 == email) &&
                model.lastMessage != null &&
                model.rootTimebank == FlavorConfig.values.timebankId) {
              chatlist.add(model);
            }
            print("Final chat size  :  ${chatlist.length}" );
          },
        );
        chatSink.add(chatlist);
      },
    ),
  );
}

//Get Messages for a chat
Stream<List<MessageModel>> getMessagesforChat({
  @required ChatModel chatModel,
}) async* {
  // log.i('getMessagesforChat: chatModel: $chatModel');
  var data = Firestore.instance
      .collection('chatsnew')
      .document(chatModel.user1 +
          '*' +
          chatModel.user2 +
          '*' +
          FlavorConfig.values.timebankId)
      .collection('messages')
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<MessageModel>>.fromHandlers(
      handleData: (snapshot, messageSink) {
        List<MessageModel> messagelist = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            MessageModel model = MessageModel.fromMap(documentSnapshot.data);

            messagelist.add(model);
            messagelist.sort((m1,m2){
              return m1.timestamp.compareTo(m2.timestamp);
            });
          },
        );
        messageSink.add(messagelist);
      },
    ),
  );
}
