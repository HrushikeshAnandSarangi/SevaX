import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class MessageBloc extends BlocBase {
  final _personalMessage = BehaviorSubject<List<ChatModel>>();
  final _adminMessage = BehaviorSubject<List<ChatModel>>();

  Stream<List<ChatModel>> get personalMessage => _personalMessage.stream;
  Stream<List<ChatModel>> get adminMessage => _adminMessage.stream;

  void fetchAllMessage(String communityId, String userEmail) {
    log("$communityId    $userEmail");
    Firestore.instance
        .collection("chatsnew")
        .where("users", arrayContains: userEmail)
        .where("communityId", isEqualTo: communityId)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      List<ChatModel> chats = [];
      log(querySnapshot.documents.length.toString());
      querySnapshot.documents.forEach((DocumentSnapshot snapshot) {
        ChatModel chat = ChatModel.fromMap(snapshot.data);
        chats.add(chat);
        print(chat);
      });
      print(chats);
      _personalMessage.add(chats);
    });
  }

  @override
  void dispose() {
    _personalMessage.close();
    _adminMessage.close();
  }
}
