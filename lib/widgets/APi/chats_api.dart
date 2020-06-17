import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/chat_model.dart';

class ChatsApi {
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
}
