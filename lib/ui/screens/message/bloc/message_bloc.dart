import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/user_model.dart';
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

  Future<void> fetchAllMessage(String communityId, UserModel userModel) async {
    log("$communityId");
    Firestore.instance
        .collection("chatsnew")
        .where("participants", arrayContains: userModel.sevaUserID)
        .where("communityId", isEqualTo: communityId)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      List<ChatModel> chats = [];
      int unreadCount = 0;
      log(querySnapshot.documents.length.toString());
      querySnapshot.documents.forEach((DocumentSnapshot snapshot) {
        ChatModel chat = ChatModel.fromMap(snapshot.data);

        String senderId =
            chat.participants.firstWhere((id) => id != userModel.sevaUserID);
        log("===> sender id :$senderId");
        if (userModel.blockedBy.contains(senderId) ||
            userModel.blockedMembers.contains(senderId)) {
          log("Blocked");
        } else {
          if (chat.unreadStatus.containsKey(userModel.sevaUserID) &&
              chat.unreadStatus[userModel.sevaUserID] > 0) {
            unreadCount++;
          }
          chats.add(chat);
        }
      });
      if (!_personalMessage.isClosed) _personalMessage.add(chats);
      if (!_personalMessageCount.isClosed)
        _personalMessageCount.add(unreadCount);
    });

    Firestore.instance
        .collection("timebanknew")
        .where("community_id", isEqualTo: communityId)
        .where("admins", arrayContains: userModel.sevaUserID)
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
