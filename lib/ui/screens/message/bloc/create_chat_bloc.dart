import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/chats_repository.dart';
import 'package:sevaexchange/repositories/storage_repository.dart';
import 'package:sevaexchange/repositories/timebank_repository.dart';
import 'package:sevaexchange/repositories/user_repository.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

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

  Function(String) get onSearchChanged => _searchText.sink.add;
  Function(String) get onGroupNameChanged => _groupName.sink.add;
  Function(MessageRoomImageModel) get onImageChanged => _file.sink.add;

  Stream<String> get searchText => _searchText.stream;
  Stream<String> get groupName => _groupName.stream;

  Stream<List<ParticipantInfo>> get members => _members.stream;
  Stream<List<TimebankModel>> get timebanksOfUser => _timebanksOfUser.stream;
  Stream<List<String>> get selectedMembers => _selectedMembers.stream;
  Stream<MessageRoomImageModel> get selectedImage => _file.stream;

  void selectMember(String participantId) {
    _selectedMembersList.contains(participantId)
        ? _selectedMembersList.remove(participantId)
        : _selectedMembersList.add(participantId);
    _selectedMembers.add(_selectedMembersList);
  }

  Future<void> getMembers(String userId, String communityId) async {
    List<ParticipantInfo> users =
        await UserRepository.getShortDetailsOfAllMembersOfCommunity(
            communityId, userId);
    users.removeWhere((ParticipantInfo info) => info.id == userId);
    users.forEach((ParticipantInfo info) {
      allMembers[info.id] = info;
      String key = info.name[0].toUpperCase();
      if (sortedMembers.containsKey(key)) {
        sortedMembers[key].add(info);
        // scrollOffset[key] += 1;
      } else {
        sortedMembers[key] = [info];
        // scrollOffset[key] = 1;
      }
    });

    int count = 0;
    sortedMembers.forEach((String key, List<ParticipantInfo> value) {
      count += value.length;
      scrollOffset[key] = count;
    });

    print(scrollOffset);

    List<TimebankModel> timebanks =
        await TimebankRepository.getTimebanksWhichUserIsPartOf(
            userId, communityId);
    timebanks.removeWhere(
      (TimebankModel model) =>
          model.members.length == 1 ||
          model.parentTimebankId == FlavorConfig.values.timebankId,
    );
    if (!_timebanksOfUser.isClosed) _timebanksOfUser.add(timebanks);
    if (!_members.isClosed) _members.add(users);
  }

  Future<ChatModel> createMultiUserMessaging(UserModel creator) async {
    if (profanityDetector.isProfaneString(_groupName.value)) {
      _groupName.addError("profanity");
      return null;
    } else if (_groupName.value != null) {
      String imageUrl;

      if (_file.value != null && _file.value.selectedImage != null) {
        imageUrl = _file.value != null
            ? await StorageRepository.uploadFile(
                "multiUserMessagingLogo", _file.value.selectedImage)
            : null;
      } else if (_file.value != null && _file.value.stockImageUrl != null) {
        imageUrl = _file.value.stockImageUrl;
      } else {
        return null;
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
      _selectedMembers.value.forEach(
        (String id) => participantInfos.add(
          allMembers[id]..type = ChatType.TYPE_MULTI_USER_MESSAGING,
        ),
      );

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
    } else {
      _groupName.addError("validation_error_room_name");
      return null;
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
