import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/chats_repository.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/message/bloc/chat_model_sync_singleton.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/utils.dart';

class MessageBloc extends BlocBase {
  final _personalMessage = BehaviorSubject<List<ChatModel>>();
  final _adminMessage = BehaviorSubject<List<AdminMessageWrapperModel>>();
  final _personalMessageCount = BehaviorSubject<int>();
  final _adminMessageCount = BehaviorSubject<int>();
  final _frequentContacts = BehaviorSubject<List<FrequentContactsModel>>();

  Stream<List<ChatModel>> get personalMessage => _personalMessage.stream;
  Stream<List<AdminMessageWrapperModel>> get adminMessage =>
      _adminMessage.stream;

  List<FrequentContactsModel> get frequentContacts => _frequentContacts.value;

  Stream<int> get messageCount => CombineLatestStream.combine2(
      _personalMessageCount, _adminMessageCount, (int p, int a) => p + a);

  Future<void> fetchAllMessage(
    String communityId,
    UserModel userModel,
    // List<UserModel> membersInCommunity,
  ) async {
    ChatModelSync chatModelSync = ChatModelSync();
    ChatsRepository.getPersonalChats(
            userId: userModel.sevaUserID, communityId: communityId)
        .listen((data) {
      List<ChatModel> chats = [];
      List<FrequentContactsModel> frequentContacts = [];
      int unreadCount = 0;
      data.forEach((chat) {
        log(chat.id + '====timestamp ===> ${chat.timestamp}');
        String senderId = chat.participants.firstWhere(
          (id) => id != userModel.sevaUserID,
          orElse: () => null,
        );
        log("===> sender id :$senderId");
        if ((senderId != null || chat.isGroupMessage)) {
          if (isMemberBlocked(userModel, senderId) ||
              (chat.deletedBy.containsKey(userModel.sevaUserID) &&
                  chat.deletedBy[userModel.sevaUserID] >
                      (chat.timestamp ?? 0)) ||
              (chat.lastMessage == '' || chat.lastMessage == null) &&
                  !chat.isGroupMessage) {
            if (chat.isGroupMessage) {
              if (chat.unreadStatus.containsKey(userModel.sevaUserID) &&
                  chat.unreadStatus[userModel.sevaUserID] > 0) {
                unreadCount++;
              }
              chats.add(chat);
            }
            log("Blocked or no message");
          } else {
            if (chat.unreadStatus.containsKey(userModel.sevaUserID) &&
                chat.unreadStatus[userModel.sevaUserID] > 0) {
              unreadCount++;
            }
            if (frequentContacts.length < 5) {
              FrequentContactsModel fc;
              if (chat.isGroupMessage) {
                fc = FrequentContactsModel(
                    chat, null, chat.isGroupMessage, chat.isTimebankMessage);
              } else {
                fc = FrequentContactsModel(
                    null,
                    chat.participantInfo.firstWhere(
                        (ParticipantInfo info) => info.id == senderId),
                    chat.isGroupMessage,
                    chat.isTimebankMessage);
              }
              frequentContacts.add(fc);
            }
            chats.add(chat);
          }
        } else {
          // FirebaseCrashlytics.instance
          //     .log('Chat issue with same memeber chat id ${chat.id}');

          log('chat id is ${chat.id}');
        }
      });
      if (!_personalMessage.isClosed) _personalMessage.add(chats);
      if (!chatModelSync.isClosed) chatModelSync.addChatModels(chats);
      if (!_frequentContacts.isClosed) _frequentContacts.add(frequentContacts);
      if (!_personalMessageCount.isClosed)
        _personalMessageCount.add(unreadCount);
    });

    CollectionRef.timebank
        .where("community_id", isEqualTo: communityId)
        .where("admins", arrayContains: userModel.sevaUserID)
        .orderBy("lastMessageTimestamp", descending: true)
        .snapshots()
        .listen((QuerySnapshot query) {
      List<AdminMessageWrapperModel> temp = [];
      int unreadCount = 0;
      query.docs.forEach((DocumentSnapshot snapshot) {
        TimebankModel model = TimebankModel(snapshot.data());
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
      if (!_adminMessageCount.isClosed) _adminMessageCount.add(unreadCount);
    });
  }

  @override
  void dispose() async {
    await _personalMessage.drain();
    _personalMessage.close();
    _adminMessage.close();
    _personalMessageCount.close();
    _adminMessageCount.close();
    _frequentContacts.close();
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
