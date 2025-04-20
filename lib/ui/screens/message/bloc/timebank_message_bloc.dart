import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class TimebankMessageBloc {
  final _messages = BehaviorSubject<List<ChatModel>>();

  Stream<List<ChatModel>> get messagelist => _messages.stream;

  void fetchAllTimebankMessage(String timebankId, final String communityId) {
    CollectionRef.chats
        .where("communityId", isEqualTo: communityId)
        .where("isTimebankMessage", isEqualTo: true)
        .where("participants", arrayContains: timebankId)
        .snapshots()
        .listen((QuerySnapshot query) {
      List<ChatModel> chats = [];
      query.docs.forEach((DocumentSnapshot snapshot) {
        ChatModel chat =
            ChatModel.fromMap(snapshot.data() as Map<String, dynamic>);
        chat.id = snapshot.id;
        chats.add(chat);
      });
      _messages.add(chats);
    });
  }

  void dispose() {
    _messages.close();
  }
}
