import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/widgets/APi/chats_api.dart';
import 'package:sevaexchange/widgets/APi/storage_api.dart';

class EditGroupInfoBloc {
  final _chatModel = BehaviorSubject<ChatModel>();
  final _file = BehaviorSubject<File>();
  final _groupName = BehaviorSubject<String>();
  final _participantInfo = BehaviorSubject<List<ParticipantInfo>>();

  Stream<String> get groupName => _groupName.stream;
  Stream<File> get image => _file.stream;
  Stream<ChatModel> get chatModel => _chatModel.stream;
  Stream<List<ParticipantInfo>> get participants => _participantInfo.stream;

  List<ParticipantInfo> get participantsList => _participantInfo.value;

  Function(String) get onGroupNameChanged => _groupName.sink.add;
  Function(File) get onImageChanged => _file.sink.add;
  Function(List<ParticipantInfo>) get addParticipants =>
      _participantInfo.sink.add;

  Future<ChatModel> getChatModel(String chatId) async {
    return await ChatsApi.getChatModel(chatId);
  }

  void removeMember(String userId) {
    List<ParticipantInfo> infos = _participantInfo.value;
    infos.removeWhere((ParticipantInfo info) => info.id == userId);
    _participantInfo.add(infos);
  }

  Future<void> editGroupDetails(String chatId) async {
    if (_groupName.value == null || _groupName.value.isEmpty) {
      _groupName.addError("Group name cannot be empty");
    } else {
      String imageUrl;
      if (_file.value != null) {
        imageUrl =
            await StorageApi.uploadFile("multiUserMessagingLogo", _file.value);
      }
      ChatsApi.editGroup(
          chatId, _groupName.value, imageUrl, _participantInfo.value);
    }
  }

  void dispose() {
    _chatModel.close();
    _file.close();
    _groupName.close();
    _participantInfo.close();
  }
}
