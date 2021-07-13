import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/repositories/chats_repository.dart';
import 'package:sevaexchange/repositories/storage_repository.dart';
import 'package:sevaexchange/repositories/timebank_repository.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';

class ParentCommunityMessageBloc {
  final _groupName = BehaviorSubject<String>();
  final _selectedTimebanks = BehaviorSubject<List<String>>.seeded([]);
  final Map<String, ParticipantInfo> allTimbankData = {};
  final profanityDetector = ProfanityDetector();
  final _file = BehaviorSubject<MessageRoomImageModel>();
  final data = BehaviorSubject<List<ParentCommunityMessageData>>.seeded([]);
  final _participantInfo = BehaviorSubject<List<ParticipantInfo>>();

  Stream<List<ParentCommunityMessageData>> get childCommunities => data.stream;

  Function(String) get onGroupNameChanged => _groupName.sink.add;
  Function(MessageRoomImageModel) get onImageChanged => _file.sink.add;
  Function(List<String>) get addCurrentParticipants =>
      _selectedTimebanks.sink.add;
  Function(List<ParticipantInfo>) get addParticipants =>
      _participantInfo.sink.add;
  Stream<String> get groupName => _groupName.stream;
  Stream<MessageRoomImageModel> get selectedImage => _file.stream;
  Stream<List<String>> get selectedTimebanks => _selectedTimebanks.stream;
  Stream<List<ParticipantInfo>> get selectedTimebanksInfo =>
      _participantInfo.stream;

  void init(String timebankId) {
    TimebankRepository.getChildCommunities(timebankId).then(
      (value) {
        if (value != null) {
          List<ParentCommunityMessageData> x = [];
          value.forEach((element) {
            x.add(
              ParentCommunityMessageData(
                id: element.id,
                name: element.name,
                photoUrl: element.photoUrl,
              ),
            );
            allTimbankData[element.id] = ParticipantInfo(
              id: element.id,
              name: element.name,
              photoUrl: element.photoUrl,
            );
            log(" llll ${allTimbankData.values.length}");
          });
          data.add(x);
        }
      },
    );
  }

  void selectParticipant(String timebankId) {
    var x = _selectedTimebanks.value;
    var list = _participantInfo.value ?? [];
    if (x.contains(timebankId)) {
      x.remove(timebankId);
      list.remove(allTimbankData[timebankId]);
      _participantInfo.add(list);
    } else {
      x.add(timebankId);
      list.add(allTimbankData[timebankId]);
      _participantInfo.add(list);
    }
    _selectedTimebanks.add(x);
  }

  Future<void> createSingleCommunityChat(
      BuildContext context, ParticipantInfo creator) async {
    List<ParticipantInfo> participantInfos = [
      creator..type = ChatType.TYPE_MULTI_USER_MESSAGING
    ];
    _selectedTimebanks.value.forEach(
      (String id) async {
        participantInfos.add(
          allTimbankData[id]..type = ChatType.TYPE_MULTI_USER_MESSAGING,
        );
      },
    );
    createAndOpenChat(
      isTimebankMessage: true,
      context: context,
      timebankId: null,
      communityId: null,
      sender: creator,
      reciever: participantInfos[1],
      isFromRejectCompletion: false,
      isParentChildCommunication: true,
      onChatCreate: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  Future<ChatModel> createMultiUserMessaging(
      BuildContext context, ParticipantInfo creator) async {
    if (_groupName.value == null || _groupName.value.isEmpty) {
      _groupName.addError("validation_error_room_name");
      return null;
    } else if (profanityDetector.isProfaneString(_groupName.value)) {
      _groupName.addError("profanity");
      return null;
    } else {
      String imageUrl;
      if (_file.value != null && _file.value.selectedImage != null) {
        imageUrl = _file.value != null
            ? await StorageRepository.uploadFile(
                "multiUserMessagingLogo", _file.value.selectedImage)
            : null;
      } else if (_file.value != null && _file.value.stockImageUrl != null) {
        imageUrl = _file.value.stockImageUrl;
      } else {
        imageUrl = null;
      }
      List<ParticipantInfo> participantInfos = [
        creator..type = ChatType.TYPE_MULTI_USER_MESSAGING
      ];
      _selectedTimebanks.value.forEach(
        (String id) async {
          participantInfos.add(
            allTimbankData[id]..type = ChatType.TYPE_MULTI_USER_MESSAGING,
          );
        },
      );
      if (_selectedTimebanks.value.length == 1) {
        createAndOpenChat(
          isTimebankMessage: true,
          context: context,
          timebankId: null,
          communityId: null,
          sender: creator,
          reciever: participantInfos[1],
          isFromRejectCompletion: false,
          isParentChildCommunication: true,
          onChatCreate: () {},
        );
      } else {
        MultiUserMessagingModel groupDetails = MultiUserMessagingModel(
          name: _groupName.value,
          imageUrl: imageUrl,
          admins: [creator.id],
        );

        List<ParticipantInfo> participantInfos = [
          creator..type = ChatType.TYPE_MULTI_USER_MESSAGING
        ];
        _selectedTimebanks.value.forEach(
          (String id) async {
            participantInfos.add(
              allTimbankData[id]..type = ChatType.TYPE_MULTI_USER_MESSAGING,
            );
          },
        );

        ChatModel model = ChatModel(
          participants: _selectedTimebanks.value..add(creator.id),
          communityId: null,
          showToCommunities: null,
          participantInfo: participantInfos,
          interCommunity: false,
          isTimebankMessage: true,
          isGroupMessage: true,
          isParentChildCommunication: true,
          groupDetails: groupDetails,
        );
        String chatId = await ChatsRepository.createNewChat(model);
        return model..id = chatId;
      }
    }
  }

  Future<void> updateCommunityChat(
      ParticipantInfo creator, ChatModel chatModel) async {
    if (_groupName.value == null || _groupName.value.isEmpty) {
      _groupName.addError("validation_error_room_name");
      return null;
    } else if (profanityDetector.isProfaneString(_groupName.value)) {
      _groupName.addError("profanity");
      return null;
    } else {
      String imageUrl;
      if (_file.value != null && _file.value.selectedImage != null) {
        imageUrl = _file.value != null
            ? await StorageRepository.uploadFile(
                "multiUserMessagingLogo", _file.value.selectedImage)
            : null;
      } else if (_file.value != null && _file.value.stockImageUrl != null) {
        imageUrl = _file.value.stockImageUrl;
      } else {
        imageUrl = null;
      }
      List<ParticipantInfo> participantInfos = [
        creator..type = ChatType.TYPE_MULTI_USER_MESSAGING
      ];
      _selectedTimebanks.value.forEach(
        (String id) {
          participantInfos.add(
            allTimbankData[id]..type = ChatType.TYPE_MULTI_USER_MESSAGING,
          );
        },
      );

      await ChatsRepository.editGroup(
        chatModel.id,
        _groupName.value,
        imageUrl,
        participantInfos,
      );
    }
  }

  void dispose() {
    data.close();
    _selectedTimebanks.close();
    _file.close();
    _groupName.close();
    _participantInfo.close();
  }
}

class ParentCommunityMessageData {
  final String id;
  final String photoUrl;
  final String name;

  ParentCommunityMessageData({
    this.id,
    this.photoUrl,
    this.name,
  });
}
