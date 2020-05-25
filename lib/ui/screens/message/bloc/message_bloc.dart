import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/new_chat_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class MessageBloc extends BlocBase {
  final _personalMessage = BehaviorSubject<List<ChatModel>>();
  final _adminMessage = BehaviorSubject<List<AdminMessageWrapperModel>>();

  Stream<List<ChatModel>> get personalMessage => _personalMessage.stream;
  Stream<List<AdminMessageWrapperModel>> get adminMessage =>
      _adminMessage.stream;

  Future<void> fetchAllMessage(String communityId, String userId) async {
    log("$communityId");
    Firestore.instance
        .collection("chatsnew")
        .where("participants", arrayContains: userId)
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

    Firestore.instance
        .collection("timebanknew")
        .where("community_id", isEqualTo: communityId)
        .where("admins", arrayContains: userId)
        .snapshots()
        .listen((QuerySnapshot query) {
      List<AdminMessageWrapperModel> temp = [];
      query.documents.forEach((DocumentSnapshot snapshot) {
        TimebankModel model = TimebankModel(snapshot.data);
        temp.add(
          AdminMessageWrapperModel(
            id: model.id,
            photoUrl: model.photoUrl,
            name: model.name,
          ),
        );
      });
      _adminMessage.add(temp);
    });
  }

  @override
  void dispose() {
    _personalMessage.close();
    _adminMessage.close();
  }
}

class AdminMessageWrapperModel {
  final String id;
  final String photoUrl;
  final String name;
  final String newMessageCount;

  AdminMessageWrapperModel(
      {this.id, this.photoUrl, this.name, this.newMessageCount});
}
