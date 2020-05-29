import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class MessageBloc extends BlocBase {
  final _personalMessage = BehaviorSubject<List<ChatModel>>();
  final _adminMessage = BehaviorSubject<List<AdminMessageWrapperModel>>();
  final _personalMessageCount = BehaviorSubject<int>();
  final _adminMessageCount = BehaviorSubject<int>();

  Stream<List<ChatModel>> get personalMessage => _personalMessage.stream;
  Stream<List<AdminMessageWrapperModel>> get adminMessage =>
      _adminMessage.stream;

  Stream<int> get messageCount => CombineLatestStream.combine2(
      _personalMessageCount, _adminMessageCount, (int p, int a) => p + a);

  Future<void> fetchAllMessage(String communityId, String userId) async {
    log("$communityId");
    Firestore.instance
        .collection("chatsnew")
        .where("participants", arrayContains: userId)
        .where("communityId", isEqualTo: communityId)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      List<ChatModel> chats = [];
      int unreadCount = 0;
      log(querySnapshot.documents.length.toString());
      querySnapshot.documents.forEach((DocumentSnapshot snapshot) {
        ChatModel chat = ChatModel.fromMap(snapshot.data);
        if (chat.unreadStatus.containsKey(userId) &&
            chat.unreadStatus[userId] > 0) {
          unreadCount++;
        }
        chats.add(chat);
      });
      if (!_personalMessage.isClosed) _personalMessage.add(chats);
      if (!_personalMessageCount.isClosed)
        _personalMessageCount.add(unreadCount);
    });

    Firestore.instance
        .collection("timebanknew")
        .where("community_id", isEqualTo: communityId)
        .where("admins", arrayContains: userId)
        .orderBy("lastMessageTimestamp", descending: true)
        .snapshots()
        .listen((QuerySnapshot query) {
      List<AdminMessageWrapperModel> temp = [];
      int unreadCount = 0;
      query.documents.forEach((DocumentSnapshot snapshot) {
        TimebankModel model = TimebankModel(snapshot.data);
        if (model.unreadMessageCount > 0) {
          unreadCount++;
        }
        temp.add(
          AdminMessageWrapperModel(
            id: model.id,
            photoUrl: model.photoUrl,
            name: model.name,
            newMessageCount: model.unreadMessageCount,
            timestamp: model.lastMessageTimestamp,
          ),
        );
      });
      if (!_adminMessage.isClosed) _adminMessage.add(temp);
      print("unread count ==> $unreadCount");
      if (!_adminMessageCount.isClosed) _adminMessageCount.add(unreadCount);
    });
  }

  @override
  void dispose() {
    _personalMessage.close();
    _adminMessage.close();
    _personalMessageCount.close();
    _adminMessageCount.close();
  }
}

class AdminMessageWrapperModel {
  final String id;
  final String photoUrl;
  final String name;
  final int newMessageCount;
  final DateTime timestamp;

  AdminMessageWrapperModel({
    this.id,
    this.timestamp,
    this.photoUrl,
    this.name,
    this.newMessageCount,
  });
}
