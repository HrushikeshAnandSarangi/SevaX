import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/chats_repository.dart';
import 'package:sevaexchange/repositories/storage_repository.dart';
import 'package:sevaexchange/ui/screens/message/message_room_manager.dart';

import 'create_chat_bloc.dart';

class EditGroupInfoBloc {
  final _chatModel = BehaviorSubject<ChatModel>();
  final _file = BehaviorSubject<MessageRoomImageModel>();
  final _groupName = BehaviorSubject<String>();
  final _participantInfo = BehaviorSubject<List<ParticipantInfo>>();
  final _currentMembers = BehaviorSubject<List<String>>();
  final profanityDetector = ProfanityDetector();

  Stream<String> get groupName => _groupName.stream;
  Stream<MessageRoomImageModel> get image => _file.stream;
  Stream<ChatModel> get chatModel => _chatModel.stream;
  Stream<List<ParticipantInfo>> get participants => _participantInfo.stream;

  List<ParticipantInfo> get participantsList => _participantInfo.value;
  List<String> get currentParticipantsList => _currentMembers.value;

  Function(String) get onGroupNameChanged => _groupName.sink.add;
  Function(MessageRoomImageModel) get onImageChanged => _file.sink.add;
  Function(List<ParticipantInfo>) get addParticipants =>
      _participantInfo.sink.add;

  Function(List<String>) get addCurrentParticipants => _currentMembers.sink.add;

  Future<ChatModel> getChatModel(String chatId) async {
    return await ChatsRepository.getChatModel(chatId);
  }

  void removeMember(String userId) {
    List<ParticipantInfo> infos = _participantInfo.value;
    infos.removeWhere((ParticipantInfo info) => info.id == userId);
    _participantInfo.add(infos);
    log('part  ${_participantInfo.value.length}');
  }

  Future<bool> editGroupDetails(
      String chatId, BuildContext context, UserModel creator) async {
    if (_groupName.value == null || _groupName.value.isEmpty) {
      _groupName.addError("Group name cannot be empty");
      return false;
    } else if (profanityDetector.isProfaneString(_groupName.value)) {
      _groupName.addError('profanity');
      return false;
    } else {
      String imageUrl;

      if (_file.value != null && _file.value.selectedImage != null) {
        imageUrl = _file.value != null
            ? await StorageRepository.uploadFile(
                "multiUserMessagingLogo", _file.value.selectedImage)
            : null;
      } else if (_file.value != null && _file.value.stockImageUrl != null) {
        imageUrl = _file.value.stockImageUrl;
      }
      List<String> participantsIds =
          List<String>.from(_participantInfo.value.map((x) => x.id));
      ParticipantInfo creatorDetails = _participantInfo.value.firstWhere(
          (element) => element.id == creator.sevaUserID,
          orElse: () => ParticipantInfo(
              name: creator.fullname,
              type: ChatType.TYPE_MULTI_USER_MESSAGING,
              id: creator.sevaUserID,
              photoUrl: creator.photoURL ?? defaultUserImageURL));

      _participantInfo.value.forEach((ParticipantInfo info) async {
        if (!_currentMembers.value.contains(info.id)) {
          await MessageRoomManager.addRemoveParticipant(
              communityId: creator.currentCommunity,
              timebankId: creator.currentTimebank,
              creatorDetails: creatorDetails,
              messageRoomImageUrl: imageUrl,
              messageRoomName: _groupName.value,
              notificationType: NotificationType.MEMBER_ADDED_TO_MESSAGE_ROOM,
              participantId: info.id,
              context: context);
        }
      });

      _currentMembers.value.forEach((element) async {
        if (!participantsIds.contains(element)) {
          await MessageRoomManager.addRemoveParticipant(
              communityId: creator.currentCommunity,
              timebankId: creator.currentTimebank,
              creatorDetails: creatorDetails,
              messageRoomImageUrl: imageUrl,
              messageRoomName: _groupName.value,
              notificationType:
                  NotificationType.MEMBER_REMOVED_FROM_MESSAGE_ROOM,
              participantId: element,
              context: context);
        }
      });

      await ChatsRepository.editGroup(
        chatId,
        _groupName.value,
        imageUrl,
        _participantInfo.value,
      );

      return true;
    }
  }

  void dispose() {
    _chatModel.close();
    _file.close();
    _groupName.close();
    _participantInfo.close();
  }
}
