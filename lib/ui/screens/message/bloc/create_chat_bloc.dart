import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/chats_repository.dart';
import 'package:sevaexchange/repositories/storage_repository.dart';
import 'package:sevaexchange/repositories/timebank_repository.dart';
import 'package:sevaexchange/repositories/user_repository.dart';
import 'package:sevaexchange/ui/screens/message/message_room_manager.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';

import '../../../../flavor_config.dart';

class CreateChatBloc extends BlocBase {
  final bool isSelectionEnabled;
  CreateChatBloc(this.isSelectionEnabled);
  final _members = BehaviorSubject<List<ParticipantInfo>>();
  final _searchText = BehaviorSubject<String>();
  final _groupName = BehaviorSubject<String>();
  final _timebanksOfUser = BehaviorSubject<List<TimebankModel>>();
  final List<String> _selectedMembersList = [];
  final Map<String, ParticipantInfo> allMembers = {};
  final _selectedMembers = BehaviorSubject<List<String>>();
  final _file = BehaviorSubject<MessageRoomImageModel>();
  final Map<String, List<ParticipantInfo>> sortedMembers = {};
  final Map<String, int> scrollOffset = {};
  final profanityDetector = ProfanityDetector();
  final _parentChildCommunities = BehaviorSubject<List<ParticipantInfo>>();

  Function(String) get onSearchChanged => _searchText.sink.add;
  Function(String) get onGroupNameChanged => _groupName.sink.add;
  Function(MessageRoomImageModel) get onImageChanged => _file.sink.add;

  Stream<String> get searchText => _searchText.stream;
  Stream<String> get groupName => _groupName.stream;

  Stream<List<ParticipantInfo>> get members => _members.stream;
  Stream<List<TimebankModel>> get timebanksOfUser => _timebanksOfUser.stream;
  Stream<List<String>> get selectedMembers => _selectedMembers.stream;
  Stream<MessageRoomImageModel> get selectedImage => _file.stream;
  Stream<List<ParticipantInfo>> get parentChildCommunities =>
      _parentChildCommunities.stream;

  void selectMember(String participantId) {
    _selectedMembersList.contains(participantId)
        ? _selectedMembersList.remove(participantId)
        : _selectedMembersList.add(participantId);
    _selectedMembers.add(_selectedMembersList);
  }

  Future<void> getMembers(
      UserModel user, String communityId, String timebankId) async {
    List<ParticipantInfo> users =
        await UserRepository.getShortDetailsOfAllMembersOfCommunity(
      communityId,
      user.sevaUserID,
    );
    users.removeWhere((ParticipantInfo info) => info.id == user.sevaUserID);
    users.forEach((ParticipantInfo info) {
      if (!isMemberBlocked(user, info.id)) {
        allMembers[info.id] = info;
        String key = info.name[0].toUpperCase();
        if (sortedMembers.containsKey(key)) {
          sortedMembers[key].add(info);
          // scrollOffset[key] += 1;
        } else {
          sortedMembers[key] = [info];
          // scrollOffset[key] = 1;
        }
      }
    });

    int count = 0;
    sortedMembers.forEach((String key, List<ParticipantInfo> value) {
      count += value.length;
      scrollOffset[key] = count;
    });

    List<TimebankModel> timebanks =
        await TimebankRepository.getTimebanksWhichUserIsPartOf(
      user.sevaUserID,
      communityId,
    );
    timebanks.removeWhere(
      (TimebankModel model) =>
          model.members.length == 1 ||
          model.parentTimebankId == FlavorConfig.values.timebankId,
    );

    List<ParticipantInfo> childParticipants = [];
    var childCommunities =
        await TimebankRepository.getChildCommunities(timebankId);
    if (childCommunities != null) {
      childCommunities.forEach((element) {
        var info = ParticipantInfo(
          id: element.id,
          name: element.name,
          photoUrl: element.photoUrl,
        );
        allMembers[element.id] = info;
        childParticipants.add(info);
      });
    }

    if (!_timebanksOfUser.isClosed) _timebanksOfUser.add(timebanks);
    if (!_members.isClosed) _members.add(users);
    if (!_parentChildCommunities.isClosed)
      _parentChildCommunities.add(childParticipants);
  }

  Future<ChatModel> createMultiUserMessaging(
      UserModel creator, BuildContext context) async {
    if (_groupName.value == null || _groupName.value.isEmpty) {
      _groupName.addError("validation_error_room_name");
      logger.e('error');
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
      MultiUserMessagingModel groupDetails = MultiUserMessagingModel(
        name: _groupName.value,
        imageUrl: imageUrl,
        admins: [creator.sevaUserID],
      );

      ParticipantInfo creatorDetails = ParticipantInfo(
        id: creator.sevaUserID,
        photoUrl: creator.photoURL,
        name: creator.fullname,
        type: ChatType.TYPE_MULTI_USER_MESSAGING,
      );

      List<ParticipantInfo> participantInfos = [creatorDetails];
      _selectedMembers.value.forEach((String id) async {
        participantInfos.add(
          allMembers[id]..type = ChatType.TYPE_MULTI_USER_MESSAGING,
        );

        await MessageRoomManager.addRemoveParticipant(
            communityId: creator.currentCommunity,
            timebankId: creator.currentTimebank,
            creatorDetails: creatorDetails,
            messageRoomImageUrl: groupDetails.imageUrl,
            messageRoomName: groupDetails.name,
            notificationType: NotificationType.MEMBER_ADDED_TO_MESSAGE_ROOM,
            participantId: allMembers[id].id,
            context: context);
      });

      ChatModel model = ChatModel(
        participants: _selectedMembers.value..add(creator.sevaUserID),
        communityId: creator.currentCommunity,
        participantInfo: participantInfos,
        isTimebankMessage: false,
        isGroupMessage: true,
        groupDetails: groupDetails,
      );
      String chatId = await ChatsRepository.createNewChat(model);
      return model..id = chatId;
    }
  }

  List<ParticipantInfo> getFilteredListOfParticipants(String searchText) {
    List<ParticipantInfo> participants = [];
    if (searchText != null && _members.value != null) {
      _members.value.forEach((ParticipantInfo info) {
        if (info.name.toLowerCase().contains(searchText.toLowerCase())) {
          participants.add(info);
        }
      });
    }
    return participants;
  }

  void dispose() {
    _members.close();
    _selectedMembers.close();
    _timebanksOfUser.close();
    _searchText.close();
    _file.close();
    _groupName.close();
  }
}

class MessageRoomImageModel {
  final String stockImageUrl;
  final File selectedImage;

  MessageRoomImageModel({this.stockImageUrl, this.selectedImage});
}
