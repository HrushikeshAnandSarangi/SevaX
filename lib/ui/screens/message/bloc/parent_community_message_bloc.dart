import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/repositories/chats_repository.dart';
import 'package:sevaexchange/repositories/storage_repository.dart';
import 'package:sevaexchange/repositories/timebank_repository.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';

import '../message_room_manager.dart';

class ParentCommunityMessageBloc {
  final _groupName = BehaviorSubject<String>();
  final _selectedTimebanks = BehaviorSubject<List<String>>.seeded([]);
  final _previousSelectedTimebanks = BehaviorSubject<List<String>>.seeded([]);
  final Map<String, ParticipantInfo> allTimbankData = {};
  final profanityDetector = ProfanityDetector();
  final _file = BehaviorSubject<MessageRoomImageModel>();
  final data = BehaviorSubject<List<ParentCommunityMessageData>>.seeded([]);
  final _participantInfo = BehaviorSubject<List<ParticipantInfo>>();

  Stream<List<ParentCommunityMessageData>> get childCommunities => data.stream;
  List<String> getAllSelectedTimebanks() {
    return _selectedTimebanks.value;
  }

  Function(String) get onGroupNameChanged => _groupName.sink.add;
  Function(MessageRoomImageModel) get onImageChanged => _file.sink.add;
  Function(List<String>) get addCurrentParticipants =>
      _selectedTimebanks.sink.add;
  Function(List<String>) get addPreviousParticipants =>
      _previousSelectedTimebanks.sink.add;
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
                communityId: element.communityId);
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
      list.removeWhere((ParticipantInfo info) => info.id == timebankId);

      _participantInfo.add(list);
    } else {
      x.add(timebankId);
      final participant = allTimbankData[timebankId];
      if (participant != null) {
        list.add(participant);
      }
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
        final participant = allTimbankData[id];
        if (participant != null) {
          participant.type = ChatType.TYPE_MULTI_USER_MESSAGING;
          participantInfos.add(participant);
        }
      },
    );
    createAndOpenChat(
      isTimebankMessage: true,
      context: context,
      timebankId: '',
      communityId: '',
      sender: creator,
      reciever: participantInfos[1],
      isFromRejectCompletion: false,
      isParentChildCommunication: true,
      feedId: '', // Provide appropriate value if needed
      showToCommunities: null!, // Provide appropriate value if needed
      entityId: '', // Provide appropriate value if needed
      onChatCreate: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  Future<ChatModel?> createMultiUserMessaging(
      BuildContext context, ParticipantInfo creator) async {
    if (_groupName.value.isEmpty) {
      _groupName.addError("validation_error_room_name");
      return null;
    } else if (profanityDetector.isProfaneString(_groupName.value)) {
      _groupName.addError("profanity");
      return null;
    } else {
      String? imageUrl;
      if (_file.value.selectedImage != null) {
        imageUrl = await StorageRepository.uploadFile(
            "multiUserMessagingLogo", _file.value.selectedImage);
      } else if (_file.value.stockImageUrl != null) {
        imageUrl = _file.value.stockImageUrl;
      } else {
        imageUrl = null;
      }
      List<ParticipantInfo> participantInfos = [
        creator..type = ChatType.TYPE_MULTI_USER_MESSAGING
      ];
      for (String id in _selectedTimebanks.value) {
        final participant = allTimbankData[id];
        if (participant != null) {
          participant.type = ChatType.TYPE_MULTI_USER_MESSAGING;
          participantInfos.add(participant);
        }
      }
      if (_selectedTimebanks.value.length == 1) {
        createAndOpenChat(
          isTimebankMessage: true,
          context: context,
          timebankId: _selectedTimebanks.value.first,
          communityId:
              allTimbankData[_selectedTimebanks.value.first]?.communityId ?? '',
          sender: creator,
          reciever: participantInfos.length > 1 ? participantInfos[1] : creator,
          isFromRejectCompletion: false,
          isParentChildCommunication: true,
          feedId: '', // Provide appropriate value if needed
          showToCommunities: null!, // Provide appropriate value if needed
          entityId: '', // Provide appropriate value if needed
          onChatCreate: () {},
        );
        return null;
      } else {
        MultiUserMessagingModel groupDetails = MultiUserMessagingModel(
          name: _groupName.value,
          imageUrl: imageUrl ?? '',
          admins: [creator.id ?? ''],
        );

        List<ParticipantInfo> participantInfos = [
          creator..type = ChatType.TYPE_MULTI_USER_MESSAGING
        ];
        for (String id in _selectedTimebanks.value) {
          final participant = allTimbankData[id];
          if (participant != null) {
            participant.type = ChatType.TYPE_MULTI_USER_MESSAGING;
            participantInfos.add(participant);
            await MessageRoomManager.addRemoveCommunityChatParticipant(
                communityId: participant.communityId ?? '',
                timebankId: id,
                creatorDetails: creator,
                messageRoomImageUrl: groupDetails.imageUrl ?? '',
                messageRoomName: groupDetails.name ?? '',
                notificationType:
                    NotificationType.COMMUNITY_ADDED_TO_MESSAGE_ROOM,
                participantId: id,
                context: context);
          }
        }

        ChatModel model = ChatModel(
          participants: [
            ..._selectedTimebanks.value.whereType<String>(),
            if (creator.id != null) creator.id!
          ],
          communityId: '',
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
    ParticipantInfo creator,
    ChatModel chatModel,
    BuildContext context,
  ) async {
    if (_groupName.value.isEmpty) {
      _groupName.addError("validation_error_room_name");
      return;
    } else if (profanityDetector.isProfaneString(_groupName.value)) {
      _groupName.addError("profanity");
      return;
    } else {
      String? imageUrl;
      if (_file.value.selectedImage != null) {
        imageUrl = await StorageRepository.uploadFile(
            "multiUserMessagingLogo", _file.value.selectedImage);
      } else if (_file.value.stockImageUrl != null) {
        imageUrl = _file.value.stockImageUrl;
      } else {
        imageUrl = null;
      }
      List<String> participantsIds =
          List<String>.from(_participantInfo.value.map((x) => x.id ?? ''));
      for (final info in _participantInfo.value) {
        if (!_previousSelectedTimebanks.value.contains(info.id)) {
          log('added here');

          final participant = allTimbankData[info.id];
          await MessageRoomManager.addRemoveCommunityChatParticipant(
              communityId: participant?.communityId ?? '',
              timebankId: info.id ?? '',
              creatorDetails: creator,
              messageRoomImageUrl: imageUrl ?? '',
              messageRoomName: _groupName.value,
              notificationType:
                  NotificationType.COMMUNITY_ADDED_TO_MESSAGE_ROOM,
              participantId: info.id ?? '',
              context: context);
        }
      }

      for (final element in _previousSelectedTimebanks.value) {
        if (!participantsIds.contains(element)) {
          log('remove here');
          final participant = allTimbankData[element];
          await MessageRoomManager.addRemoveCommunityChatParticipant(
              communityId: participant?.communityId ?? '',
              timebankId: element,
              creatorDetails: creator,
              messageRoomImageUrl: imageUrl ?? '',
              messageRoomName: _groupName.value,
              notificationType:
                  NotificationType.COMMUNITY_REMOVED_FROM_MESSAGE_ROOM,
              participantId: element,
              context: context);
        }
      }
      await ChatsRepository.editGroup(
        chatModel.id ?? '',
        _groupName.value,
        imageUrl ?? '',
        _participantInfo.value,
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
    required this.id,
    required this.photoUrl,
    required this.name,
  });
}
